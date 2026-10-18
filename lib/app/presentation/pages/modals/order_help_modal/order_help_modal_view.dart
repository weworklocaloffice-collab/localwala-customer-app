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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/presentation/pages/modals/order_help_modal/bloc/order_help_modal_bloc.dart';
import 'package:user/app/presentation/pages/modals/refund_request_reason_list_modal/refund_request_reason_list_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class OrderHelpModalScreen extends StatelessWidget {
  final String orderId;
  final int orderNumber;
  final String orderStatus;
  final String paymentMode;
  final bool refundRequestEnable;
  final String restaurant;
  final String payment;
  final bool subscriptionOrder;
  const OrderHelpModalScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentMode,
    required this.refundRequestEnable,
    required this.restaurant,
    required this.payment,
    required this.subscriptionOrder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderHelpModalBloc()
        ..add(
          OrderHelpModalInitialEvent(
            orderId: orderId,
            orderNumber: orderNumber,
            orderStatus: orderStatus,
            paymentMode: paymentMode,
            refundRequestEnable: refundRequestEnable,
            restaurant: restaurant,
            payment: payment,
            subscriptionOrder: subscriptionOrder,
          ),
        ),
      child: const OrderHelpModalView(),
    );
  }
}

class OrderHelpModalView extends StatelessWidget {
  const OrderHelpModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<OrderHelpModalBloc, OrderHelpModalState>(
      listener: (context, state) {
        if (state.status.isRefundRequestFailed || state.status.isOrderSummaryDownloadFailed || state.status.isOrderInvoiceDownloadFailed || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isRefundRequestSuccess) {
          showSuccessDialog(context, translate.refund_request_created);
        } else if (state.status.isOrderSummaryDownloadSuccess || state.status.isOrderInvoiceDownloadSuccess) {
          showSuccessDialog(context, '${translate.file_downloaded_path} ${state.downloadPath}');
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isRefundRequestStarted || state.status.isOrderInvoiceDownloadStarted || state.status.isOrderSummaryDownloadStarted ? true : false,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0,
              title: Text(translate.order_help),
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop({'action': 'none', 'value': 'none'}),
                  icon: FaIcon(FontAwesomeIcons.xmark, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => context.read<OrderHelpModalBloc>().add(OrderHelpModalOrderInvoiceEvent()),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.receipt, size: 14, color: Theme.of(context).canvasColor),
                              kAppSpacerHorizontal(width: 10),
                              Text(translate.download_invoice, style: kAppLblMediumFontBold(context, color: 'regular')),
                            ],
                          ),
                          state.status.isOrderInvoiceDownloadStarted ? kAppCircularProgress(context, color: 'primary', strokeWidth: 2.0, width: 20.0, height: 20.0, padding: 2.0) : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                  kAppSpacerVertical(height: 5),
                  GestureDetector(
                    onTap: () => context.read<OrderHelpModalBloc>().add(OrderHelpModalOrderSummaryEvent()),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.fileExcel, size: 14, color: Theme.of(context).canvasColor),
                              kAppSpacerHorizontal(width: 10),
                              Text(translate.download_summary, style: kAppLblMediumFontBold(context, color: 'regular')),
                            ],
                          ),
                          state.status.isOrderSummaryDownloadStarted ? kAppCircularProgress(context, color: 'primary', strokeWidth: 2.0, width: 20.0, height: 20.0, padding: 2.0) : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                  kAppSpacerVertical(height: 5),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop({'action': 'navigate', 'value': 'complaints'}),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.circleQuestion, size: 14, color: Theme.of(context).canvasColor),
                          kAppSpacerHorizontal(width: 10),
                          Text(translate.complaints, style: kAppLblMediumFontBold(context, color: 'regular')),
                        ],
                      ),
                    ),
                  ),
                  state.orderStatus != 'pending_payments' && state.canRequestRefund && state.refundRequestEnable ? kAppSpacerVertical(height: 5) : const SizedBox(),
                  state.orderStatus != 'pending_payments' && state.canRequestRefund && state.refundRequestEnable
                      ? GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              isDismissible: true,
                              enableDrag: false,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              builder: (BuildContext context) {
                                return const FractionallySizedBox(heightFactor: 0.7, child: RefundRequestReasonListModalScreen());
                              },
                            ).then((value) {
                              if (!context.mounted) return;
                              if (value != null && value.toString().isNotEmpty) {
                                context.read<OrderHelpModalBloc>().add(OrderHelpModalRefundRequestEvent(reasonId: value.toString()));
                              }
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FaIcon(FontAwesomeIcons.fileExcel, size: 14, color: Theme.of(context).canvasColor),
                                    kAppSpacerHorizontal(width: 10),
                                    Text(translate.refund_request, style: kAppLblMediumFontBold(context, color: 'regular')),
                                  ],
                                ),
                                state.status.isRefundRequestStarted ? kAppCircularProgress(context, color: 'primary', strokeWidth: 2.0, width: 20.0, height: 20.0, padding: 2.0) : const SizedBox(),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
// Done //
