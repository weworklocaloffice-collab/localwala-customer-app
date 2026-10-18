/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * WeWorkLocal is a technology platform that connects
 * customers, vendors, service providers, and delivery
 * partners through a unified digital ecosystem.
 *
 * Core features include local commerce, food delivery,
 * service bookings, referral programs, wallet management,
 * real-time tracking, digital payments, and business
 * management solutions.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/navigation_back_response_model.dart';
import 'package:user/app/core/models/ongoing_new_location_received_response_model.dart';
import 'package:user/app/core/models/order_detail_response_model.dart';
import 'package:user/app/core/repositories/chat_repository.dart';
import 'package:user/app/presentation/pages/modals/complaints_modal/complaints_modal_view.dart';
import 'package:user/app/presentation/pages/history/history_detail/bloc/history_detail_bloc.dart';
import 'package:user/app/presentation/pages/modals/cancellation_reason_list_modal/cancellation_reason_list_modal_view.dart';
import 'package:user/app/presentation/pages/modals/order_help_modal/order_help_modal_view.dart';
import 'package:user/app/presentation/pages/modals/order_review_ratings_modal/order_review_ratings_modal_view.dart';
import 'package:user/app/presentation/pages/modals/permission_denied/location_permission_denied_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/map_style.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/services/live_location_service_socket_io.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class HistoryDetailScreen extends StatelessWidget {
  final String id;
  const HistoryDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return HistoryDetailView(id: id);
  }
}

class HistoryDetailView extends StatefulWidget {
  final String id;
  const HistoryDetailView({super.key, required this.id});

  @override
  State<HistoryDetailView> createState() => _HistoryDetailViewState();
}

class _HistoryDetailViewState extends State<HistoryDetailView> {
  final LiveLocationServiceSocket liveLocationServiceSocket = LiveLocationServiceSocket();
  final ChatRepository chatRepository = ChatRepository();
  bool isConnected = false;
  Future<void> initSocketForLocation(String driverId) async {
    if (isConnected) return;

    // The socket handshake is authenticated server-side; without a token the
    // connection is refused and live tracking never starts.
    final String token = await chatRepository.authToken();
    if (!mounted || token.isEmpty) return;

    liveLocationServiceSocket.connectToServer(driverId, token, (data) {
      if (!mounted) return;
      final newLocation = OngoingNewLocationReceivedLocationResponseModel.fromJson(data);
      context.read<HistoryDetailBloc>().add(HistoryDetailNewDeliverymanLocation(latitude: newLocation.latitude!, longitude: newLocation.longitude!));
    });

    if (!mounted) return;
    setState(() {
      isConnected = true;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<HistoryDetailBloc>().add(HistoryDetailInitialEvent(id: widget.id));
  }

  @override
  void dispose() {
    super.dispose();
    liveLocationServiceSocket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<HistoryDetailBloc, HistoryDetailState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isRepayOrderFailed) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isRepayOrderSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.makePaymentRoute, (Route<dynamic> route) => false, arguments: [state.paymentURL]);
        } else if (state.status.isCancelSuccess) {
          Navigator.of(context).pop({"type": "refresh", "value": "hard"});
        } else if (state.status.isDeniedForever) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              var height = MediaQuery.of(context).size.height;
              var width = MediaQuery.of(context).size.width;
              return AlertDialog(
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                content: SizedBox(height: height - 400, width: width - 80, child: const LocationPermissionDeniedDialonScreen()),
              );
            },
          ).then((value) {
            if (!context.mounted) return;
            if (value == true) {
              context.read<HistoryDetailBloc>().add(HistoryDetailOpenSettingEvent());
            }
          });
        } else if (state.status.isOngoingOrderStatus) {
          initSocketForLocation(state.orderDetail.details!.driverInfo!.id!);
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isRepayOrderRequested || state.status.isCancelRequested ? true : false,
          child: Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              title: Text(translate.history_detail),
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: FaIcon(FontAwesomeIcons.chevronDown, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRouter.supportChatRoute, arguments: ['orders', state.orderId]),
                  label: Text(
                    translate.support,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'semibold'),
                  ),
                  icon: Icon(Icons.chat_outlined, color: Theme.of(context).primaryColor, size: 12),
                  iconAlignment: IconAlignment.start,
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: false,
                      enableDrag: false,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                          heightFactor: 0.65,
                          child: OrderHelpModalScreen(
                            orderId: state.orderId,
                            orderNumber: state.orderDetail.details!.orderNo!,
                            orderStatus: state.orderDetail.details!.status!,
                            paymentMode: state.orderDetail.details!.paymentInfo!.paymentWay!,
                            refundRequestEnable: state.orderDetail.businessSettings!.refundRequest!,
                            restaurant: state.orderDetail.details!.restaurant!.id!,
                            payment: state.orderDetail.details!.paymentInfo!.id!,
                            subscriptionOrder: state.orderDetail.details!.subscriptionOrder!,
                          ),
                        );
                      },
                    ).then((value) {
                      if (!context.mounted) return;
                      NavigationBackResponseModel backResponse = NavigationBackResponseModel.fromJson(value);
                      if (backResponse.action!.isNotEmpty && backResponse.action! != 'none') {
                        if (backResponse.action! == 'navigate' && backResponse.value! == 'complaints') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (BuildContext context) {
                                return ComplaintModalScreen(orderId: state.orderId);
                              },
                            ),
                          );
                        }
                      }
                    });
                  },
                  icon: FaIcon(FontAwesomeIcons.ellipsisVertical, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const HistoryDetailLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const HistoryDetailErrorView(),
                  ] else if (state.orderDetail.details != null) ...[
                    OrderTimeline(
                      status: state.orderDetail.details!.status!.toString(),
                      orderNo: state.orderDetail.details!.orderNo!.toString(),
                      payOver: state.isPendingPaymentTimeOver,
                    ),
                  ],
                  if (state.status.isNewOrderView || state.status.isCancelRequested || state.status.isCancelFailed) ...[
                    HistoryDetailNewOrderResponseView(
                      model: state.orderDetail,
                      orderStatusName: state.orderStatusName,
                      markers: state.markers,
                      polyline: state.polyline,
                      zoomLevel: state.mapZoomLevel,
                      callRestaurant: state.callRestaurant!,
                      callDriver: state.callDriver!,
                    ),
                  ] else if (state.status.isOngoingOrderStatus) ...[
                    HistoryDetailOngoingOrderResponseView(
                      model: state.orderDetail,
                      orderStatusName: state.orderStatusName,
                      markers: state.markers,
                      polyline: state.polyline,
                      zoomLevel: state.mapZoomLevel,
                      callRestaurant: state.callRestaurant!,
                      callDriver: state.callDriver!,
                    ),
                  ] else if (state.status.isCompletedView || state.status.isRepayOrderRequested || state.status.isRepayOrderFailed) ...[
                    HistoryDetailCompleteOrderResponseView(model: state.orderDetail, orderStatusName: state.orderStatusName, callRestaurant: state.callRestaurant!),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: SizedBox(
                height: state.status.isNewOrderView || state.status.isCancelRequested || state.status.isCancelFailed || state.status.isCompletedView || state.status.isRepayOrderRequested || state.status.isRepayOrderFailed || state.status.isOngoingOrderStatus
                    ? ((state.orderDetail.details?.status == 'pending_payments' && state.isPendingPaymentTimeOver == false)
                        ? 112
                        : 80)
                    : 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.status.isOngoingOrderStatus) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.read<HistoryDetailBloc>().add(HistoryDetailCallDriverEvent()),
                                icon: const Icon(Icons.call_outlined, size: 18),
                                label: const Text('Call rider'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final d = state.orderDetail.details!.driverInfo;
                                  if (d == null || d.id == null || d.id!.isEmpty) return;
                                  Navigator.of(context).pushNamed(AppRouter.messagesRoute,
                                      arguments: [d.id!, d.firstName ?? 'Rider']);
                                },
                                icon: const Icon(Icons.chat_outlined, size: 18),
                                label: const Text('Message'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).pushNamed(AppRouter.supportChatRoute,
                                    arguments: ['orders', state.orderId]),
                                icon: const Icon(Icons.support_agent_outlined, size: 18),
                                label: const Text('Help'),
                              ),
                            ),
                          ],
                        ),
                      ] else if (state.status.isNewOrderView || state.status.isCancelRequested || state.status.isCancelFailed) ...[
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      isDismissible: false,
                                      enableDrag: false,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      builder: (BuildContext context) {
                                        return const FractionallySizedBox(heightFactor: 0.7, child: CancellationReasonListModalScreen());
                                      },
                                    ).then((value) {
                                      if (!context.mounted) return;
                                      if (value != null && value.toString().isNotEmpty) {
                                        context.read<HistoryDetailBloc>().add(HistoryDetailCancelMyOrderEvent(reasonId: value.toString()));
                                      }
                                    });
                                  },
                                  style: kAppElevatedButtonStyle(
                                    context,
                                    disabledColor: Theme.of(context).disabledColor,
                                    bgColor: Theme.of(context).primaryColor,
                                    foreColor: Theme.of(context).scaffoldBackgroundColor,
                                    height: 50.0,
                                  ),
                                  child: state.status.isCancelRequested ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.cancel_order),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (state.status.isCompletedView || state.status.isRepayOrderRequested || state.status.isRepayOrderFailed) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.orderDetail.details!.status! == 'pending_payments' && state.isPendingPaymentTimeOver == false) ...[
                              _RepayCountdown(
                                  elapsedMinutes: state.orderDetail.details!.timeDifferenceOfOrderInMinutes ?? 0,
                                  orderId: state.orderId),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                                              child: Icon(Icons.account_balance_wallet_outlined, size: 16, color: Theme.of(context).primaryColor),
                                            ),
                                            kAppSpacerHorizontal(width: 5),
                                            Flexible(child: Text(translate.pay_using, style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis)),
                                          ],
                                        ),
                                        kAppSpacerVertical(height: 5),
                                        Text(state.paymentName, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblMediumFontRegular(context)),
                                        Text(translate.pay_methods_hint_cod, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                      ],
                                    ),
                                  ),
                                  const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                                  Expanded(
                                    flex: 3,
                                    child: InkWell(
                                      onTap: () => context.read<HistoryDetailBloc>().add(HistoryDetailRepayOrderEvent()),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                        width: double.infinity,
                                        height: 60.0,
                                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                                        child: state.status.isRepayOrderRequested
                                            ? Center(child: kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0))
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(kAppPriceFormat(double.parse(state.orderDetail.details!.grandTotal!.toString())), style: kAppLblMediumFontSemiBoldWhite(context)),
                                                      kAppSpacerVertical(height: 3),
                                                      Text(translate.total, style: kAppLblTinyFontBoldCart(context)),
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Text(translate.repay_online, style: kAppLblMediumFontSemiBoldWhite(context)),
                                                      Icon(Icons.arrow_right, color: Theme.of(context).scaffoldBackgroundColor, size: 14),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (state.orderDetail.details!.status! == 'pending_payments' && state.isPendingPaymentTimeOver == true) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [Text(translate.order_was_incomplete_due_to_pending_payment, style: kAppLblSmallFontRegular(context))],
                              ),
                            ] else if (state.orderDetail.details!.status! == 'delivered' && !state.orderDetail.details!.ratingSaved!) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  fullscreenDialog: true,
                                                  builder: (BuildContext context) {
                                                    return OrderReviewRatingsModalScreen(orderId: state.orderId);
                                                  },
                                                ),
                                              )
                                              .then((value) {
                                                if (!context.mounted) return;
                                                if (value != null && value != '' && value.toString().isNotEmpty) {
                                                  if (value.toString() == 'true' || value == true) {
                                                    context.read<HistoryDetailBloc>().add(HistoryDetailReviewSavedEvent());
                                                  }
                                                }
                                              });
                                        },
                                        style: kAppElevatedButtonStyle(
                                          context,
                                          disabledColor: Theme.of(context).disabledColor,
                                          bgColor: Theme.of(context).primaryColor,
                                          foreColor: Theme.of(context).scaffoldBackgroundColor,
                                          height: 50.0,
                                        ),
                                        child: Text(translate.review_and_rating),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HistoryDetailLoadingView extends StatelessWidget {
  const HistoryDetailLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonLine(
                    style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonLine(
                    style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonLine(style: SkeletonLineStyle(height: 8, width: 64, borderRadius: BorderRadius.circular(8))),
                  const SizedBox(width: 5),
                  SkeletonLine(style: SkeletonLineStyle(height: 8, width: 64, borderRadius: BorderRadius.circular(8))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonLine(
                    style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
          const SizedBox(height: 20),
          SkeletonLine(
            style: SkeletonLineStyle(height: 50, width: double.infinity, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(10, (index) {
                return SkeletonAvatar(
                  style: SkeletonAvatarStyle(width: 80, height: 30, padding: const EdgeInsets.symmetric(horizontal: 5), borderRadius: BorderRadius.circular(8)),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: List.generate(5, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            SkeletonLine(
                              style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                            ),
                            const SizedBox(height: 5),
                            SkeletonLine(
                              style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                            ),
                            const SizedBox(height: 5),
                            SkeletonLine(
                              style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SkeletonLine(style: SkeletonLineStyle(height: 25, width: 25, borderRadius: BorderRadius.circular(8))),
                                const SizedBox(width: 10),
                                SkeletonLine(style: SkeletonLineStyle(height: 25, width: 25, borderRadius: BorderRadius.circular(8))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SkeletonAvatar(style: SkeletonAvatarStyle(width: 80, height: 80, borderRadius: BorderRadius.circular(10))),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryDetailErrorView extends StatelessWidget {
  const HistoryDetailErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
      child: Center(
        child: Column(
          children: [
            kAppSpacerVertical(height: 20),
            Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
            kAppSpacerVertical(height: 20),
            Text(translate.empty_data_two, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          ],
        ),
      ),
    );
  }
}

class HistoryDetailNewOrderResponseView extends StatefulWidget {
  final OrderDetailResponseModel model;
  final String orderStatusName;
  final Set<Marker> markers;
  final Set<Polyline> polyline;
  final double zoomLevel;
  final bool callRestaurant;
  final bool callDriver;
  const HistoryDetailNewOrderResponseView({
    super.key,
    required this.model,
    required this.orderStatusName,
    required this.markers,
    required this.polyline,
    required this.zoomLevel,
    required this.callRestaurant,
    required this.callDriver,
  });

  @override
  State<HistoryDetailNewOrderResponseView> createState() => _HistoryDetailNewOrderResponseViewState();
}

class _HistoryDetailNewOrderResponseViewState extends State<HistoryDetailNewOrderResponseView> with WidgetsBindingObserver {
  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    if (!kIsWeb) {
      final GoogleMapController controller = await _googleMapController.future;
      controller.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(translate.order_from, style: kAppLblOrderTileRegular(context)),
              kAppSpacerVertical(height: 5),
              Text(kAppTrimWord(widget.model.details!.restaurant!.name!, 40), style: kAppLblOrderTileSemiBold(context)),
              kAppSpacerVertical(height: 5),
              if (widget.model.details!.status! == 'created') ...[
                Text(translate.order_detail_status_created, style: kAppLblOrderTileBold(context)),
              ] else if (widget.model.details!.status! == 'accepted') ...[
                Text(translate.order_detail_status_accepted, style: kAppLblOrderTileBold(context)),
              ] else if (widget.model.details!.status! == 'preparing') ...[
                Text(translate.order_detail_status_preparing, style: kAppLblOrderTileBold(context)),
              ] else if (widget.model.details!.status! == 'ready') ...[
                Text(translate.order_detail_status_ready, style: kAppLblOrderTileBold(context)),
              ] else if (widget.model.details!.status! == 'handover') ...[
                Text(translate.order_detail_status_handover, style: kAppLblOrderTileBold(context)),
              ] else if (widget.model.details!.status! == 'ongoing') ...[
                Text(translate.order_detail_status_onway, style: kAppLblOrderTileBold(context)),
              ],
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: (MediaQuery.of(context).size.height / 2.5),
          decoration: BoxDecoration(border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1)),
          child: Center(
            child: !kIsWeb
                ? GoogleMap(
                    key: GlobalKey(),
                    myLocationEnabled: false,
                    compassEnabled: false,
                    tiltGesturesEnabled: false,
                    indoorViewEnabled: false,
                    trafficEnabled: false,
                    buildingsEnabled: false,
                    style: MapStyleHelper.mapStyles,
                    onMapCreated: (GoogleMapController controller) async {
                      if (!_googleMapController.isCompleted) {
                        _googleMapController.complete(controller);
                        CameraPosition nepPos = CameraPosition(target: LatLng(widget.model.details!.restaurant!.location!.coordinates![1], widget.model.details!.restaurant!.location!.coordinates![0]), zoom: widget.zoomLevel);
                        await controller.animateCamera(CameraUpdate.newCameraPosition(nepPos));
                      }
                    },
                    markers: widget.markers,
                    polylines: widget.polyline,
                    mapType: MapType.normal,
                    scrollGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    zoomGesturesEnabled: true,
                    initialCameraPosition: CameraPosition(
                      zoom: widget.zoomLevel,
                      tilt: 0,
                      bearing: 30,
                      target: LatLng(widget.model.details!.restaurant!.location!.coordinates![1], widget.model.details!.restaurant!.location!.coordinates![0]),
                    ),
                  )
                : Text(translate.google_maps_here, style: kAppLblLargeFontBold(context)),
          ),
        ),
        widget.model.details!.orderTo == 'homedelivery' && widget.model.details!.driverInfo!.id!.isNotEmpty ? kAppSpacerVertical(height: 10) : const SizedBox(),
        widget.model.details!.orderTo == 'homedelivery' && widget.model.details!.driverInfo!.id!.isNotEmpty
            ? Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                ),
                padding: const EdgeInsets.only(top: 10),
                margin: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${translate.i_am} ${widget.model.details!.driverInfo!.lastName!} ${translate.your_deliveryman}", style: kAppLblMediumFontBold(context)),
                                kAppSpacerVertical(height: 5),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 1.8,
                                  child: Text("${translate.i_have_completed} ${widget.model.driverOrderCount!}+ ${translate.five_star_deliveries}", maxLines: 3, style: kAppLblTinyFontRegular(context)),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    kAppSpacerVertical(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(translate.pin_otp, style: kAppLblMediumFontSemiBold(context)),
                                        Text(" : ", style: kAppLblMediumFontSemiBold(context)),
                                        Text(widget.model.details!.customerOrderPin!, style: kAppLblMediumFontBold(context)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 60,
                              width: 60,
                              child: CircleAvatar(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CacheNetworkImageWidget(width: 60.0, height: 60.0, imageUrl: widget.model.details!.driverInfo!.image!),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 3,
                            child: InkWell(
                              onTap: () => context.read<HistoryDetailBloc>().add(HistoryDetailCallDriverEvent()),
                              child: SizedBox(
                                width: double.infinity,
                                height: 30,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    widget.callDriver
                                        ? SizedBox(height: 15.0, width: 15.0, child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 3))
                                        : Icon(Icons.call, size: 10, color: Theme.of(context).canvasColor),
                                    kAppSpacerHorizontal(width: 5),
                                    Text(translate.call, style: kAppLblTinyFontRegular(context)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pushNamed(AppRouter.messagesRoute, arguments: [widget.model.details!.driverInfo!.id!, widget.model.details!.driverInfo!.firstName!]),
                              child: Container(
                                width: double.infinity,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.only(bottomRight: Radius.circular(5.0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat_outlined, size: 10, color: Theme.of(context).scaffoldBackgroundColor),
                                    kAppSpacerHorizontal(width: 5),
                                    Text(translate.message, style: kAppLblTinyRegularWhite(context)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
        kAppSpacerVertical(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: ThemeProvider.scaffoldPadding, right: ThemeProvider.scaffoldPadding, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FavouriteOrderWidget(isFavouriteOrder: widget.model.details!.isFavouriteOrder!),
              kAppSpacerVertical(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  widget.model.details!.cartItem!.length,
                  (cartIndex) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            kAppFoodType(widget.model.details!.cartItem![cartIndex].foodType!, height: 10, width: 10),
                            kAppSpacerHorizontal(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("${widget.model.details!.cartItem![cartIndex].quantity!}", style: kAppLblMediumFontSemiBold(context)),
                                    Text(" X ", style: kAppLblMediumFontSemiBold(context)),
                                    Text(kAppTrimWord(widget.model.details!.cartItem![cartIndex].name!, 40), style: kAppLblMediumFontSemiBold(context)),
                                  ],
                                ),
                                Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.5, minWidth: MediaQuery.of(context).size.width / 2.5),
                                  child: Text(widget.model.details!.cartItem![cartIndex].optionName!, maxLines: 4, style: kAppLblTinyFontRegular(context)),
                                ),
                                widget.model.details!.cartItem![cartIndex].instruction!.isNotEmpty
                                    ? Container(
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.5, minWidth: MediaQuery.of(context).size.width / 2.5),
                                        child: Text("${translate.cooking_instruction} : ${widget.model.details!.cartItem![cartIndex].instruction!}", maxLines: 4, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ],
                        ),
                        Text(kAppPriceFormat(widget.model.details!.cartItem![cartIndex].totalPrice!), style: kAppLblMediumFontSemiBold(context)),
                      ],
                    ),
                  ),
                ),
              ),
              kAppSpacerVertical(height: 10),
              Text(translate.order_charges, style: kAppLblMediumFontBold(context)),
              kAppSpacerVertical(height: 10),
              BillingInfoTile(name: translate.item_total, priceTag: '+', price: widget.model.details!.realTotal!),
              BillingInfoTile(name: translate.item_discount, priceTag: '-', price: widget.model.details!.itemDiscount!),
              BillingInfoTile(name: translate.sub_total_amount, priceTag: '+', price: widget.model.details!.itemTotal!),
              BillingInfoTile(name: translate.food_service_charge_amount, priceTag: '+', price: widget.model.details!.foodServiceCharge!),
              BillingInfoTile(name: translate.service_charge, priceTag: '+', price: widget.model.details!.serviceCharge!),
              BillingInfoTile(name: translate.extra_service_charge, priceTag: '+', price: widget.model.details!.extraCharge!),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(translate.delivery_charge, style: kAppLblTinyFontRegularChip(context, color: 'regular')),
                    Text(widget.model.details!.deliveryCharge! > 0 ? '(+) ${widget.model.details!.deliveryCharge!}' : translate.free, style: kAppLblTinyFontBold(context)),
                  ],
                ),
              ),
              BillingInfoTile(name: translate.delivery_partner_tip, priceTag: '+', price: widget.model.details!.deliveryTip!),
              BillingInfoTile(name: translate.package_charge, priceTag: '+', price: widget.model.details!.packageCharge!),
              BillingInfoTile(name: translate.package_charge_tax, priceTag: '+', price: widget.model.details!.packageChargeTax!),
              BillingInfoTile(name: translate.coupon_discount, priceTag: '-', price: widget.model.details!.couponDiscountCharge!),
              BillingInfoTile(name: translate.wallet_money, priceTag: '-', price: widget.model.details!.walletAmount!),
              kAppSpacerVertical(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(translate.grand_total, style: kAppLblMediumFontMedium(context)),
                  Text(kAppPriceFormat(widget.model.details!.grandTotal!), style: kAppLblMediumFontBold(context)),
                ],
              ),
              kAppSpacerVertical(height: 10),
              OrderInfoCard(details: widget.model.details!),
            ],
          ),
        ),
        kAppSpacerVertical(height: 10),
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
          ),
          padding: const EdgeInsets.only(top: 10),
          margin: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(kAppTrimWord(widget.model.details!.restaurant!.name!, 35), style: kAppLblMediumFontBold(context)),
                          kAppSpacerVertical(height: 5),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.8,
                            child: Text(widget.model.details!.restaurant!.address!, maxLines: 3, style: kAppLblTinyFontRegular(context)),
                          ),
                          widget.model.details!.orderTo! == 'selfpickup'
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    kAppSpacerVertical(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(translate.pin_otp, style: kAppLblMediumFontSemiBold(context)),
                                        Text(" : ", style: kAppLblMediumFontSemiBold(context)),
                                        Text(widget.model.details!.customerOrderPin!, style: kAppLblMediumFontBold(context)),
                                      ],
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: CacheNetworkImageWidget(width: 40, height: 60.0, imageUrl: widget.model.details!.restaurant!.cover!),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () => context.read<HistoryDetailBloc>().add(HistoryDetailCallRestaurantEvent()),
                        child: SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              widget.callRestaurant
                                  ? SizedBox(height: 15.0, width: 15.0, child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 3))
                                  : Icon(Icons.call, size: 10, color: Theme.of(context).canvasColor),
                              kAppSpacerHorizontal(width: 5),
                              Text(translate.call, style: kAppLblTinyFontRegular(context)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pushNamed(AppRouter.messagesRoute, arguments: [widget.model.restUserInfo!.id!, widget.model.restUserInfo!.firstName!]),
                        child: Container(
                          width: double.infinity,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(5.0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_outlined, size: 10, color: Theme.of(context).scaffoldBackgroundColor),
                              kAppSpacerHorizontal(width: 5),
                              Text(translate.message, style: kAppLblTinyRegularWhite(context)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        kAppSpacerVertical(height: 20),
      ],
    );
  }
}

class HistoryDetailOngoingOrderResponseView extends StatefulWidget {
  final OrderDetailResponseModel model;
  final String orderStatusName;
  final Set<Marker> markers;
  final Set<Polyline> polyline;
  final double zoomLevel;
  final bool callRestaurant;
  final bool callDriver;
  const HistoryDetailOngoingOrderResponseView({
    super.key,
    required this.model,
    required this.orderStatusName,
    required this.markers,
    required this.polyline,
    required this.zoomLevel,
    required this.callRestaurant,
    required this.callDriver,
  });

  @override
  State<HistoryDetailOngoingOrderResponseView> createState() => _HistoryDetailOngoingOrderResponseViewState();
}

class _HistoryDetailOngoingOrderResponseViewState extends State<HistoryDetailOngoingOrderResponseView> with WidgetsBindingObserver {
  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    if (!kIsWeb) {
      final GoogleMapController controller = await _googleMapController.future;
      controller.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(translate.order_from, style: kAppLblOrderTileRegular(context)),
              kAppSpacerVertical(height: 5),
              Text(kAppTrimWord(widget.model.details!.restaurant!.name!, 40), style: kAppLblOrderTileSemiBold(context)),
              kAppSpacerVertical(height: 5),
              if (widget.model.details!.status! == 'created') ...[
                Text(translate.order_detail_status_created, style: kAppLblOrderTileBold(context)),
              ] else if (widget.model.details!.status! == 'accepted') ...[
                Text(translate.order_detail_status_accepted, style: kAppLblOrderTileBold(context)),
              ] else if (widget.model.details!.status! == 'preparing') ...[
                Text(translate.order_detail_status_preparing, style: kAppLblOrderTileBold(context)),
              ] else if (widget.model.details!.status! == 'ready') ...[
                Text(translate.order_detail_status_ready, style: kAppLblOrderTileBold(context)),
              ] else if (widget.model.details!.status! == 'handover') ...[
                Text(translate.order_detail_status_handover, style: kAppLblOrderTileBold(context)),
              ] else if (widget.model.details!.status! == 'ongoing') ...[
                Text(translate.order_detail_status_onway, style: kAppLblOrderTileBold(context)),
              ],
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: (MediaQuery.of(context).size.height / 2.5),
          decoration: BoxDecoration(border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1)),
          child: Center(
            child: !kIsWeb
                ? GoogleMap(
                    key: GlobalKey(),
                    myLocationEnabled: false,
                    compassEnabled: false,
                    tiltGesturesEnabled: false,
                    indoorViewEnabled: false,
                    trafficEnabled: false,
                    buildingsEnabled: false,
                    style: MapStyleHelper.mapStyles,
                    onMapCreated: (GoogleMapController controller) async {
                      if (!_googleMapController.isCompleted) {
                        _googleMapController.complete(controller);
                        CameraPosition nepPos = CameraPosition(target: LatLng(widget.model.details!.restaurant!.location!.coordinates![1], widget.model.details!.restaurant!.location!.coordinates![0]), zoom: widget.zoomLevel);
                        await controller.animateCamera(CameraUpdate.newCameraPosition(nepPos));
                      }
                    },
                    markers: widget.markers,
                    polylines: widget.polyline,
                    mapType: MapType.normal,
                    scrollGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    zoomGesturesEnabled: true,
                    initialCameraPosition: CameraPosition(
                      zoom: widget.zoomLevel,
                      tilt: 0,
                      bearing: 30,
                      target: LatLng(widget.model.details!.restaurant!.location!.coordinates![1], widget.model.details!.restaurant!.location!.coordinates![0]),
                    ),
                  )
                : Text(translate.google_maps_here, style: kAppLblLargeFontBold(context)),
          ),
        ),
        widget.model.details!.orderTo == 'homedelivery' && widget.model.details!.driverInfo!.id!.isNotEmpty ? kAppSpacerVertical(height: 10) : const SizedBox(),
        widget.model.details!.orderTo == 'homedelivery' && widget.model.details!.driverInfo!.id!.isNotEmpty
            ? Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                ),
                padding: const EdgeInsets.only(top: 10),
                margin: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${translate.i_am} ${widget.model.details!.driverInfo!.lastName!} ${translate.your_deliveryman}", style: kAppLblMediumFontBold(context)),
                                kAppSpacerVertical(height: 5),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 1.8,
                                  child: Text("${translate.i_have_completed} ${widget.model.driverOrderCount!}+ ${translate.five_star_deliveries}", maxLines: 3, style: kAppLblTinyFontRegular(context)),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    kAppSpacerVertical(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(translate.pin_otp, style: kAppLblMediumFontSemiBold(context)),
                                        Text(" : ", style: kAppLblMediumFontSemiBold(context)),
                                        Text(widget.model.details!.customerOrderPin!, style: kAppLblMediumFontBold(context)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 60,
                              width: 60,
                              child: CircleAvatar(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CacheNetworkImageWidget(width: 60.0, height: 60.0, imageUrl: widget.model.details!.driverInfo!.image!),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 3,
                            child: InkWell(
                              onTap: () => context.read<HistoryDetailBloc>().add(HistoryDetailCallDriverEvent()),
                              child: SizedBox(
                                width: double.infinity,
                                height: 30,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    widget.callDriver
                                        ? SizedBox(height: 15.0, width: 15.0, child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 3))
                                        : Icon(Icons.call, size: 10, color: Theme.of(context).canvasColor),
                                    kAppSpacerHorizontal(width: 5),
                                    Text(translate.call, style: kAppLblTinyFontRegular(context)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pushNamed(AppRouter.messagesRoute, arguments: [widget.model.details!.driverInfo!.id!, widget.model.details!.driverInfo!.firstName!]),
                              child: Container(
                                width: double.infinity,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.only(bottomRight: Radius.circular(5.0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat_outlined, size: 10, color: Theme.of(context).scaffoldBackgroundColor),
                                    kAppSpacerHorizontal(width: 5),
                                    Text(translate.message, style: kAppLblTinyRegularWhite(context)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
        kAppSpacerVertical(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: ThemeProvider.scaffoldPadding, right: ThemeProvider.scaffoldPadding, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FavouriteOrderWidget(isFavouriteOrder: widget.model.details!.isFavouriteOrder!),
              kAppSpacerVertical(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  widget.model.details!.cartItem!.length,
                  (cartIndex) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            kAppFoodType(widget.model.details!.cartItem![cartIndex].foodType!, height: 10, width: 10),
                            kAppSpacerHorizontal(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("${widget.model.details!.cartItem![cartIndex].quantity!}", style: kAppLblMediumFontSemiBold(context)),
                                    Text(" X ", style: kAppLblMediumFontSemiBold(context)),
                                    Text(kAppTrimWord(widget.model.details!.cartItem![cartIndex].name!, 40), style: kAppLblMediumFontSemiBold(context)),
                                  ],
                                ),
                                Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.5, minWidth: MediaQuery.of(context).size.width / 2.5),
                                  child: Text(widget.model.details!.cartItem![cartIndex].optionName!, maxLines: 4, style: kAppLblTinyFontRegular(context)),
                                ),
                                widget.model.details!.cartItem![cartIndex].instruction!.isNotEmpty
                                    ? Container(
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.5, minWidth: MediaQuery.of(context).size.width / 2.5),
                                        child: Text("${translate.cooking_instruction} : ${widget.model.details!.cartItem![cartIndex].instruction!}", maxLines: 4, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ],
                        ),
                        Text(kAppPriceFormat(widget.model.details!.cartItem![cartIndex].totalPrice!), style: kAppLblMediumFontSemiBold(context)),
                      ],
                    ),
                  ),
                ),
              ),
              kAppSpacerVertical(height: 10),
              Text(translate.order_charges, style: kAppLblMediumFontBold(context)),
              kAppSpacerVertical(height: 10),
              BillingInfoTile(name: translate.item_total, priceTag: '+', price: widget.model.details!.realTotal!),
              BillingInfoTile(name: translate.item_discount, priceTag: '-', price: widget.model.details!.itemDiscount!),
              BillingInfoTile(name: translate.sub_total_amount, priceTag: '+', price: widget.model.details!.itemTotal!),
              BillingInfoTile(name: translate.food_service_charge_amount, priceTag: '+', price: widget.model.details!.foodServiceCharge!),
              BillingInfoTile(name: translate.service_charge, priceTag: '+', price: widget.model.details!.serviceCharge!),
              BillingInfoTile(name: translate.extra_service_charge, priceTag: '+', price: widget.model.details!.extraCharge!),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(translate.delivery_charge, style: kAppLblTinyFontRegularChip(context, color: 'regular')),
                    Text(widget.model.details!.deliveryCharge! > 0 ? '(+) ${widget.model.details!.deliveryCharge!}' : translate.free, style: kAppLblTinyFontBold(context)),
                  ],
                ),
              ),
              BillingInfoTile(name: translate.delivery_partner_tip, priceTag: '+', price: widget.model.details!.deliveryTip!),
              BillingInfoTile(name: translate.package_charge, priceTag: '+', price: widget.model.details!.packageCharge!),
              BillingInfoTile(name: translate.package_charge_tax, priceTag: '+', price: widget.model.details!.packageChargeTax!),
              BillingInfoTile(name: translate.coupon_discount, priceTag: '-', price: widget.model.details!.couponDiscountCharge!),
              BillingInfoTile(name: translate.wallet_money, priceTag: '-', price: widget.model.details!.walletAmount!),
              kAppSpacerVertical(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(translate.grand_total, style: kAppLblMediumFontMedium(context)),
                  Text(kAppPriceFormat(widget.model.details!.grandTotal!), style: kAppLblMediumFontBold(context)),
                ],
              ),
              kAppSpacerVertical(height: 10),
              OrderInfoCard(details: widget.model.details!),
            ],
          ),
        ),
        kAppSpacerVertical(height: 10),
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
          ),
          padding: const EdgeInsets.only(top: 10),
          margin: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(kAppTrimWord(widget.model.details!.restaurant!.name!, 35), style: kAppLblMediumFontBold(context)),
                          kAppSpacerVertical(height: 5),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.8,
                            child: Text(widget.model.details!.restaurant!.address!, maxLines: 3, style: kAppLblTinyFontRegular(context)),
                          ),
                          widget.model.details!.orderTo! == 'selfpickup'
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    kAppSpacerVertical(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(translate.pin_otp, style: kAppLblMediumFontSemiBold(context)),
                                        Text(" : ", style: kAppLblMediumFontSemiBold(context)),
                                        Text(widget.model.details!.customerOrderPin!, style: kAppLblMediumFontBold(context)),
                                      ],
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: CacheNetworkImageWidget(width: 40, height: 60.0, imageUrl: widget.model.details!.restaurant!.cover!),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () => context.read<HistoryDetailBloc>().add(HistoryDetailCallRestaurantEvent()),
                        child: SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              widget.callRestaurant
                                  ? SizedBox(height: 15.0, width: 15.0, child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 3))
                                  : Icon(Icons.call, size: 10, color: Theme.of(context).canvasColor),
                              kAppSpacerHorizontal(width: 5),
                              Text(translate.call, style: kAppLblTinyFontRegular(context)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pushNamed(AppRouter.messagesRoute, arguments: [widget.model.restUserInfo!.id!, widget.model.restUserInfo!.firstName!]),
                        child: Container(
                          width: double.infinity,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(5.0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_outlined, size: 10, color: Theme.of(context).scaffoldBackgroundColor),
                              kAppSpacerHorizontal(width: 5),
                              Text(translate.message, style: kAppLblTinyRegularWhite(context)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        kAppSpacerVertical(height: 20),
      ],
    );
  }
}

class HistoryDetailCompleteOrderResponseView extends StatelessWidget {
  final OrderDetailResponseModel model;
  final String orderStatusName;
  final bool callRestaurant;
  const HistoryDetailCompleteOrderResponseView({super.key, required this.model, required this.orderStatusName, required this.callRestaurant});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: ThemeProvider.scaffoldPadding, right: ThemeProvider.scaffoldPadding, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.only(bottom: 10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
            ),
            child: Text("${translate.this_order_was} $orderStatusName", style: kAppLblLargeFontMedium(context)),
          ),
          FavouriteOrderWidget(isFavouriteOrder: model.details!.isFavouriteOrder!),
          kAppSpacerVertical(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              model.details!.cartItem!.length,
              (cartIndex) => Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.symmetric(vertical: 5),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        kAppFoodType(model.details!.cartItem![cartIndex].foodType!, height: 10, width: 10),
                        kAppSpacerHorizontal(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("${model.details!.cartItem![cartIndex].quantity!}", style: kAppLblMediumFontSemiBold(context)),
                                Text(" X ", style: kAppLblMediumFontSemiBold(context)),
                                Text(kAppTrimWord(model.details!.cartItem![cartIndex].name!, 40), style: kAppLblMediumFontSemiBold(context)),
                              ],
                            ),
                            Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.5, minWidth: MediaQuery.of(context).size.width / 2.5),
                              child: Text(model.details!.cartItem![cartIndex].optionName!, maxLines: 4, style: kAppLblTinyFontRegular(context)),
                            ),
                            model.details!.cartItem![cartIndex].instruction!.isNotEmpty
                                ? Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.5, minWidth: MediaQuery.of(context).size.width / 2.5),
                                    child: Text("${translate.cooking_instruction} : ${model.details!.cartItem![cartIndex].instruction!}", maxLines: 4, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ],
                    ),
                    Text(kAppPriceFormat(model.details!.cartItem![cartIndex].totalPrice!), style: kAppLblMediumFontSemiBold(context)),
                  ],
                ),
              ),
            ),
          ),
          kAppSpacerVertical(height: 10),
          Text(translate.order_charges, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 10),
          BillingInfoTile(name: translate.item_total, priceTag: '+', price: model.details!.realTotal!),
          BillingInfoTile(name: translate.item_discount, priceTag: '-', price: model.details!.itemDiscount!),
          BillingInfoTile(name: translate.sub_total_amount, priceTag: '+', price: model.details!.itemTotal!),
          BillingInfoTile(name: translate.food_service_charge_amount, priceTag: '+', price: model.details!.foodServiceCharge!),
          BillingInfoTile(name: translate.service_charge, priceTag: '+', price: model.details!.serviceCharge!),
          BillingInfoTile(name: translate.extra_service_charge, priceTag: '+', price: model.details!.extraCharge!),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(translate.delivery_charge, style: kAppLblTinyFontRegularChip(context, color: 'regular')),
                Text(model.details!.deliveryCharge! > 0 ? '(+) ${model.details!.deliveryCharge!}' : translate.free, style: kAppLblTinyFontBold(context)),
              ],
            ),
          ),
          BillingInfoTile(name: translate.delivery_partner_tip, priceTag: '+', price: model.details!.deliveryTip!),
          BillingInfoTile(name: translate.package_charge, priceTag: '+', price: model.details!.packageCharge!),
          BillingInfoTile(name: translate.package_charge_tax, priceTag: '+', price: model.details!.packageChargeTax!),
          BillingInfoTile(name: translate.coupon_discount, priceTag: '-', price: model.details!.couponDiscountCharge!),
          BillingInfoTile(name: translate.wallet_money, priceTag: '-', price: model.details!.walletAmount!),
          kAppSpacerVertical(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(translate.grand_total, style: kAppLblMediumFontMedium(context)),
              Text(kAppPriceFormat(model.details!.grandTotal!), style: kAppLblMediumFontBold(context)),
            ],
          ),
          kAppSpacerVertical(height: 10),
          OrderInfoCard(details: model.details!),
          kAppSpacerVertical(height: 10),
          // Restaurant card: same design + placement as placed/ongoing
          // (under order flow). Guarded for partial pending-payment data.
          if (model.details?.restaurant != null)
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
            ),
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kAppTrimWord(model.details!.restaurant!.name ?? 'Restaurant', 35), style: kAppLblMediumFontBold(context)),
                            kAppSpacerVertical(height: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.8,
                              child: Text(model.details!.restaurant!.address ?? '', maxLines: 3, style: kAppLblTinyFontRegular(context)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: CacheNetworkImageWidget(width: 40, height: 60.0, imageUrl: model.details!.restaurant!.cover ?? ''),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: () => context.read<HistoryDetailBloc>().add(HistoryDetailCallRestaurantEvent()),
                          child: SizedBox(
                            width: double.infinity,
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                callRestaurant
                                    ? SizedBox(height: 15.0, width: 15.0, child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 3))
                                    : Icon(Icons.call, size: 10, color: Theme.of(context).canvasColor),
                                kAppSpacerHorizontal(width: 5),
                                Text(translate.call, style: kAppLblTinyFontRegular(context)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: () {
                            final u = model.restUserInfo;
                            if (u == null || u.id == null || u.id!.isEmpty) return;
                            Navigator.of(context).pushNamed(AppRouter.messagesRoute,
                                arguments: [u.id!, u.firstName ?? 'Restaurant']);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(5.0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_outlined, size: 10, color: Theme.of(context).scaffoldBackgroundColor),
                                kAppSpacerHorizontal(width: 5),
                                Text(translate.message, style: kAppLblTinyRegularWhite(context)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          kAppSpacerVertical(height: 10),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            child: CacheNetworkImageWidget(width: 120.0, height: 80.0, imageUrl: model.restaurantLicense!.image!, fit: BoxFit.contain),
          ),
          kAppSpacerVertical(height: 5),
          Text("${translate.lic_no} ${model.details!.restaurant!.licenseId!} (${model.restaurantLicense!.name!})", style: kAppLblMediumFontRegular(context)),
          kAppSpacerVertical(height: 5),
          InkWell(
            onTap: () async {
              final Uri launchURLString = Uri.parse(model.restaurantLicense!.website!.toString());
              !await launchUrl(launchURLString, mode: LaunchMode.inAppBrowserView);
            },
            child: Text(model.restaurantLicense!.website!.toString(), style: kAppLblMediumFontRegular(context)),
          ),
        ],
      ),
    );
  }
}

/// Enterprise order-info card: collapsed dropdown, icon rows on expand.
/// Replaces three duplicated flat bold stacks (New/Ongoing/Complete).
class OrderInfoCard extends StatelessWidget {
  final OrderDetailConfigModel details;
  const OrderInfoCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final d = details;
    Widget row({required IconData icon, required String label, required String value, VoidCallback? onCopy}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (onCopy != null)
              InkWell(
                onTap: () async {
                  onCopy();
                  try {
                    HapticFeedback.lightImpact();
                  } catch (_) {}
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.copy_outlined, size: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      );
    }

    final bool home = d.orderTo == 'homedelivery';
    // Collapsed dropdown: header carries number + total, rows on expand.
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        title: Text(t.order_details, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        subtitle: Text('#${d.orderNo} • ${kAppPriceFormat(d.grandTotal!)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        children: [
          row(icon: Icons.receipt_long_outlined, label: t.order_number, value: '#${d.orderNo}'),
          row(
              icon: Icons.tag_outlined,
              label: t.order_ref,
              value: d.id!.toUpperCase(),
              onCopy: () => Clipboard.setData(ClipboardData(text: d.id!))),
          row(icon: Icons.payments_outlined, label: t.payment, value: '${d.paymentInfo!.name!} (${kAppPriceFormat(d.grandTotal!)})'),
          row(
              icon: Icons.schedule_outlined,
              label: '${t.date} ${d.scheduleOrder! ? t.schedule : ''}',
              value:
                  '${d.scheduleOrder! ? d.scheduleDate! : d.createdAt!} ${t.at} ${d.scheduleOrder! ? d.scheduleTime! : d.orderAt!}'),
          row(
              icon: Icons.person_outline,
              label: t.receiver,
              value: home ? '${d.receiverName!} (+${d.countryCode!} ${d.receiverContact})' : t.self_pickup),
          if (home)
            row(
                icon: Icons.location_on_outlined,
                label: t.deliver_to,
                value:
                    '${kAppAddressTitle(context, d.deliveryAddressRaw!.title!)} - ${d.deliveryAddressRaw!.flatHouse!}, ${d.deliveryAddressRaw!.locality!}, ${d.deliveryAddressRaw!.landmark!}'),
          if (d.cookingInstruction!.isNotEmpty)
            row(icon: Icons.restaurant_menu_outlined, label: t.cooking_instruction, value: d.cookingInstruction!),
          if (d.deliveryInstructionInfo!.name!.isNotEmpty)
            row(icon: Icons.delivery_dining_outlined, label: t.delivery_instruction, value: d.deliveryInstructionInfo!.name!),
        ],
      ),
    );
  }
}

/// Repay countdown: live MM:SS from the 30-min payment window.
/// Static text would go stale on screen; this ticks every second.
class _RepayCountdown extends StatefulWidget {
  final num elapsedMinutes;
  final String orderId;
  const _RepayCountdown({required this.elapsedMinutes, required this.orderId});

  @override
  State<_RepayCountdown> createState() => _RepayCountdownState();
}

class _RepayCountdownState extends State<_RepayCountdown> {
  late int _remainingSec;
  Timer? _timer;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _remainingSec = (30 * 60 - widget.elapsedMinutes * 60).toInt().clamp(0, 30 * 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSec <= 0) {
        _timer?.cancel();
        // Window over: reload detail once so the bar flips to expired
        // instead of sticking at 00:00 with a dead Repay button.
        if (!_expired) {
          _expired = true;
          try {
            context.read<HistoryDetailBloc>().add(HistoryDetailInitialEvent(id: widget.orderId));
          } catch (_) {}
          setState(() {});
        }
        return;
      }
      setState(() => _remainingSec--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_expired) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 6),
            Text('Refreshing…', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }
    final mm = (_remainingSec ~/ 60).toString().padLeft(2, '0');
    final ss = (_remainingSec % 60).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text('Pay within $mm:$ss',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange)),
        ],
      ),
    );
  }
}

/// Enterprise order journey: 5-stage stepper + order-no copy.
/// Terminal states (cancelled/rejected/refunded/pending_payments) render a
/// single banner instead of a misleading partial journey.
class OrderTimeline extends StatelessWidget {
  final String status;
  final String orderNo;
  final bool payOver;
  const OrderTimeline({super.key, required this.status, required this.orderNo, this.payOver = false});

  static const List<String> _stages = ['created', 'accepted', 'preparing', 'ongoing', 'delivered'];
  static const Map<String, String> _stageLabel = {
    'created': 'Placed',
    'accepted': 'Accepted',
    'preparing': 'Preparing',
    'ongoing': 'On the way',
    'delivered': 'Delivered',
  };
  static const Map<String, IconData> _stageIcon = {
    'created': Icons.receipt_long_outlined,
    'accepted': Icons.check_circle_outline,
    'preparing': Icons.restaurant_menu_outlined,
    'ongoing': Icons.delivery_dining_outlined,
    'delivered': Icons.home_outlined,
  };

  // ready/handover fold into preparing/on-the-way for a 5-step story.
  int _stageIndex(String s) {
    switch (s) {
      case 'created':
        return 0;
      case 'accepted':
        return 1;
      case 'preparing':
      case 'ready':
        return 2;
      case 'handover':
      case 'ongoing':
        return 3;
      case 'delivered':
        return 4;
      default:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final idx = _stageIndex(status);
    if (idx < 0) {
      final bool isPayPending = status == 'pending_payments';
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (isPayPending ? Colors.orange : Colors.red).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: (isPayPending ? Colors.orange : Colors.red).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(isPayPending ? Icons.hourglass_bottom : Icons.info_outline,
                color: isPayPending ? Colors.orange : Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isPayPending
                    ? (payOver
                        ? 'Payment window expired — this order can no longer be paid.'
                        : 'Payment pending — repay from the bar below to confirm this order.')
                    : 'Order $status.',
                style: kAppLblSmallFontRegular(context),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Order #$orderNo',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: orderNo));
                  try {
                    HapticFeedback.lightImpact();
                  } catch (_) {}
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_outlined, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Copy', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _stages.length; i++) ...[
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < idx
                              ? primary
                              : i == idx
                                  ? primary.withValues(alpha: 0.15)
                                  : Colors.grey.shade200,
                          border: Border.all(color: i <= idx ? primary : Colors.grey.shade300, width: 1.5),
                        ),
                        child: Icon(
                          i < idx ? Icons.check : _stageIcon[_stages[i]],
                          size: 18,
                          color: i < idx
                              ? Colors.white
                              : i == idx
                                  ? primary
                                  : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(_stageLabel[_stages[i]]!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: i == idx ? FontWeight.w800 : FontWeight.normal,
                              color: i <= idx ? Colors.black87 : Colors.grey)),
                    ],
                  ),
                ),
                if (i < _stages.length - 1)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 17),
                      height: 2,
                      color: i < idx ? primary : Colors.grey.shade300,
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class BillingInfoTile extends StatelessWidget {
  final String name;
  final String priceTag;
  final double price;
  const BillingInfoTile({super.key, required this.name, required this.priceTag, required this.price});

  @override
  Widget build(BuildContext context) {
    return price > 0
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(name, style: kAppLblTinyFontRegularChip(context, color: 'regular')),
                Text("($priceTag) ${kAppPriceFormat(price)}", style: kAppLblTinyFontBold(context)),
              ],
            ),
          )
        : const SizedBox();
  }
}

class FavouriteOrderWidget extends StatelessWidget {
  final bool isFavouriteOrder;
  const FavouriteOrderWidget({super.key, required this.isFavouriteOrder});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(translate.your_orders, style: kAppLblMediumFontBold(context)),
        InkWell(
          onTap: () => context.read<HistoryDetailBloc>().add(HistoryDetailFavouriteEvent()),
          child: isFavouriteOrder
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                  ),
                  child: Text(translate.remove_from_favourite, style: kAppLblTinyFontBoldCart(context)),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                  ),
                  child: Text(translate.mark_as_favourite, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                ),
        ),
      ],
    );
  }
}

