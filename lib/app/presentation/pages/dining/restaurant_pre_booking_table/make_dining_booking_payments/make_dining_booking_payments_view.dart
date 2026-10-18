import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/presentation/pages/dining/restaurant_pre_booking_table/make_dining_booking_payments/bloc/make_dining_booking_payment_bloc.dart';
import 'package:user/app/presentation/pages/modals/payment_method_sheet/payment_method_sheet_view.dart';
import 'package:user/app/presentation/pages/modals/payment_success_modal/payment_success_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/app/services/razorpay_service.dart';
import 'package:user/app/services/local_notification_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class MakeDiningBookingPaymentScreen extends StatelessWidget {
  final String paymentId;
  const MakeDiningBookingPaymentScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context) {
    return MakeDiningBookingPaymentView(paymentId: paymentId);
  }
}

class MakeDiningBookingPaymentView extends StatefulWidget {
  final String paymentId;
  const MakeDiningBookingPaymentView({super.key, required this.paymentId});

  @override
  State<MakeDiningBookingPaymentView> createState() => _MakeDiningBookingPaymentViewState();
}

class _MakeDiningBookingPaymentViewState extends State<MakeDiningBookingPaymentView> {
  bool isLoading = true;
  bool recallAPI = true;
  Map<String, dynamic>? orderData;
  int _sheetKey = 0;
  final RazorpayService _razorpayService = RazorpayService();

  @override
  void initState() {
    super.initState();
    context.read<MakeDiningBookingPaymentBloc>().add(MakeDiningBookingPaymentInitialEvent(paymentId: widget.paymentId));
    _razorpayService.initialize(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
    _startPayment();
  }

  Future<void> _startPayment() async {
    final data = await _razorpayService.fetchOrder(widget.paymentId);
    if (data == null) {
      LocalNotificationService.cancelPaymentProgress();
      _handlePaymentFailure();
      return;
    }
    // Shared CustomUI sheet renders INLINE (no Razorpay popup, no extra nav).
    if (mounted) {
      setState(() {
        orderData = data;
        isLoading = false;
      });
    }
  }

  void _handlePaymentSuccess(dynamic response) {
    if (recallAPI) {
      setState(() {
        recallAPI = false;
      });
      FocusScope.of(context).requestFocus(FocusNode());
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _verifyPaymentOnBackend(response);
    }
  }

  void _handlePaymentError(dynamic response) {
    if (recallAPI) {
      setState(() {
        recallAPI = false;
      });
      final fallback = AppLocalizations.of(context)?.pay_failed_snack ?? 'Payment failed';
      final msg = RazorpayService.friendlyError(response, fallback);
      debugPrint('Razorpay CustomUI error: $msg | raw=$response');
      // Gateway-side failure (no POST exists): app-side nudge so the retry
      // path survives app-kill. No-op for user-cancel/timeout.
      if (RazorpayService.shouldNotifyGatewayError(response)) {
        LocalNotificationService.notifyGatewayFailure(msg);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      LocalNotificationService.cancelPaymentProgress();
      _handlePaymentFailure();
    }
  }

  void _handleExternalWallet(dynamic response) {
    if (recallAPI) {
      setState(() {
        recallAPI = false;
      });
      FocusScope.of(context).requestFocus(FocusNode());
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      LocalNotificationService.cancelPaymentProgress();
      context.read<MakeDiningBookingPaymentBloc>().add(MakeDiningBookingPaymentResponseEvent());
    }
  }

  Future<void> _verifyPaymentOnBackend(dynamic response) async {
    final api = ApiRequestService();
    final fields = RazorpayService.extractSuccessFields(response);
    final String? pid = fields['pid'];
    final String? oid = fields['oid'];
    final String? sig = fields['sig'];
    debugPrint('VERIFY POST pid=$pid oid=$oid paymentId=${widget.paymentId} raw=$response');
    final verifyResponse = await api.post(
      '${ApiEndPoints.v1request.paidSuccess}${widget.paymentId}',
      body: {
        'razorpay_payment_id': pid,
        'razorpay_order_id': oid,
        'razorpay_signature': sig,
      },
    );
    if (verifyResponse.success && verifyResponse.raw.data != null && verifyResponse.raw.data['success'] == true) {
      LocalNotificationService.cancelPaymentProgress();
      context.read<MakeDiningBookingPaymentBloc>().add(MakeDiningBookingPaymentResponseEvent());
    } else {
      LocalNotificationService.cancelPaymentProgress();
      _handlePaymentFailure();
    }
  }

  void _handlePaymentFailure() {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext context) {
          return const FractionallySizedBox(heightFactor: 0.7, child: PaymentSuccessModalScreen(from: 'dining_failed'));
        },
      ).then((value) {
        if (!context.mounted) return;
        if (value != null && value.toString() == 'retry') {
          setState(() {
            recallAPI = true;
            _sheetKey++;
          });
          return;
        }
        if (value != null && value != '' && value.toString() == 'true') {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [4]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MakeDiningBookingPaymentBloc, MakeDiningBookingPaymentState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            builder: (BuildContext context) {
              return FractionallySizedBox(heightFactor: 0.7, child: PaymentSuccessModalScreen(from: 'dining'));
            },
          ).then((value) {
            if (!context.mounted) return;
            if (value != null && value != '' && value.toString() == 'true') {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [4]);
            }
          });
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(title: const Text('Payment')),
            body: isLoading
                ? kAppCenterCircularProgress(context)
                : orderData == null
                    ? const SizedBox.shrink()
                    : SingleChildScrollView(
                        child: CustomPaymentSheetScreen(
                          key: ValueKey(_sheetKey),
                          orderData: orderData!,
                          razorpayService: _razorpayService,
                          paymentId: widget.paymentId,
                        ),
                      ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _razorpayService.clear();
    super.dispose();
  }
}
