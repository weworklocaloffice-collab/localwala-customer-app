import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/presentation/pages/cart/make_payments/bloc/make_payments_bloc.dart';
import 'package:user/app/presentation/pages/modals/payment_method_sheet/payment_method_sheet_view.dart';
import 'package:user/app/presentation/pages/modals/payment_success_modal/payment_success_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/app/services/razorpay_service.dart';
import 'package:user/app/services/local_notification_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class MakePaymentScreen extends StatelessWidget {
  final String paymentId;
  final String codPaymentId;
  const MakePaymentScreen({super.key, required this.paymentId, this.codPaymentId = ''});

  @override
  Widget build(BuildContext context) {
    return MakePaymentView(paymentId: paymentId, codPaymentId: codPaymentId);
  }
}

class MakePaymentView extends StatefulWidget {
  final String paymentId;
  final String codPaymentId;
  const MakePaymentView({super.key, required this.paymentId, this.codPaymentId = ''});

  @override
  State<MakePaymentView> createState() => _MakePaymentViewState();
}

class _MakePaymentViewState extends State<MakePaymentView> {
  bool isLoading = true;
  bool recallAPI = true;
  Map<String, dynamic>? orderData;
  final RazorpayService _razorpayService = RazorpayService();
  // Live success data for ref-#6 screen (razorpay payment id + method label).
  String _successPid = '';
  String _successMethod = '';
  // Local Mongo order _id for Track Order -> history_detail. Display still
  // uses orderNo (_successPid); this is the HistoryDetail id.
  String _successOrderDbId = '';
  // Bumped on Try Again: forces a fresh sheet state (resets its spinner).
  int _sheetKey = 0;

  @override
  void initState() {
    super.initState();
    context.read<MakePaymentsBloc>().add(MakePaymentsInitialEvent(paymentId: widget.paymentId));
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
    // CustomUI renders INLINE in this screen body (no popup, no extra navigation).
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
      // Enterprise: one clear line (insufficient/cancelled/timeout/OTP…),
      // never the raw gateway paragraph. Full raw kept in debug log only.
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
      context.read<MakePaymentsBloc>().add(MakePaymentsResponseEvent());
    }
  }

  /// COD chosen in payment screen: initiation already switched server-side.
  /// Mark success with COD label (no gateway verify needed).
  void _handleCodSuccess() {
    if (recallAPI) {
      setState(() {
        recallAPI = false;
        _successPid = widget.paymentId;
        _successMethod = 'Cash on Delivery';
      });
      FocusScope.of(context).requestFocus(FocusNode());
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      LocalNotificationService.cancelPaymentProgress();
      context.read<MakePaymentsBloc>().add(MakePaymentsResponseEvent());
    }
  }

  Future<void> _verifyPaymentOnBackend(dynamic response) async {
    // NOTE: no fetchOrder here — makePayment GET mints server work and is
    // idempotent now, but verify only needs the POST below.
    final api = ApiRequestService();
    final fields = RazorpayService.extractSuccessFields(response);
    final String? pid = fields['pid'];
    final String? oid = fields['oid'];
    final String? sig = fields['sig'];
    debugPrint('VERIFY POST pid=$pid oid=$oid paymentId=${widget.paymentId} raw=$response');
    final postResponse = await api.post(
      '${ApiEndPoints.v1request.paidSuccess}${widget.paymentId}',
      body: {
        'razorpay_payment_id': pid,
        'razorpay_order_id': oid,
        'razorpay_signature': sig,
      },
    );
    debugPrint('VERIFY POST pid=$pid oid=$oid sig=$sig paymentId=${widget.paymentId} success=${postResponse.success} data=${postResponse.raw.data}');
    if (postResponse.success && postResponse.raw.data != null && postResponse.raw.data['success'] == true) {
      // Live echo from backend (orderNo + gateway method truth). Falls back
      // to local values when absent (wallet/dining/tiffin subjects).
      final Map data = postResponse.raw.data as Map;
      final echoOrderNo = (data['orderNo'] ?? '').toString();
      final echoMethod = (data['method'] ?? '').toString();
      final echoOrderId = (data['orderId'] ?? data['order_id_local'] ?? '').toString();
      if (mounted) {
        setState(() {
          _successPid = echoOrderNo.isNotEmpty
              ? echoOrderNo
              : ((pid ?? '').isNotEmpty ? pid! : widget.paymentId);
          _successMethod = echoMethod.isNotEmpty ? echoMethod.toUpperCase() : _razorpayService.lastMethodLabel;
          _successOrderDbId = echoOrderId;
        });
      }
      LocalNotificationService.cancelPaymentProgress();
      context.read<MakePaymentsBloc>().add(MakePaymentsResponseEvent());
    } else {
      debugPrint('VERIFY FAILED paymentId=${widget.paymentId} backend=${postResponse.raw.data}');
      LocalNotificationService.cancelPaymentProgress();
      _handlePaymentFailure();
    }
  }

  /// Track Order -> History Detail for this order. Falls back to History
  /// list (tab 2) when backend did not return orderId (old builds).
  void _goTrackOrder(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [2]);
    if (_successOrderDbId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pushNamed(AppRouter.historyDetailRoute, arguments: [_successOrderDbId]);
      });
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
          return const FractionallySizedBox(heightFactor: 0.7, child: PaymentSuccessModalScreen(from: 'order_failed'));
        },
      ).then((value) {
        if (!context.mounted) return;
        // Try Again: backend is idempotent — same order_id reused, no orphan.
        // Null (system back on modal) also resets — never leave processing stuck.
        if (value == null || value.toString() == 'retry') {
          setState(() {
            recallAPI = true;
            _sheetKey++;
          });
          return;
        }
        if (value != null && value != '' && value.toString() == 'true') {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [2]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MakePaymentsBloc, MakePaymentsState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          final amt = orderData?['amount'];
          final amtStr = amt is int ? (amt / 100).toStringAsFixed(2) : '$amt';
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            builder: (BuildContext context) {
              return FractionallySizedBox(
                heightFactor: 0.9,
                child: PaymentSuccessModalScreen(
                  from: 'order',
                  orderId: _successPid.isNotEmpty ? _successPid : widget.paymentId,
                  amount: amtStr,
                  methodLabel: _successMethod.isNotEmpty ? _successMethod : 'Online Payment',
                  onTrackOrder: () {
                    Navigator.of(context).pop(true);
                    if (!context.mounted) return;
                    _goTrackOrder(context);
                  },
                  onBackHome: () {
                    Navigator.of(context).pop(true);
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [0]);
                  },
                ),
              );
            },
          ).then((value) {
            if (!context.mounted) return;
            if (value != null && value != '' && value.toString() == 'true') {
              _goTrackOrder(context);
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
                          codPaymentId: widget.codPaymentId,
                          onCodSuccess: _handleCodSuccess,
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
