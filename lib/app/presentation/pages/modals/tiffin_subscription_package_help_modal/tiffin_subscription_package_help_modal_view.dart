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
import 'package:user/app/presentation/pages/modals/tiffin_subscription_package_help_modal/bloc/tiffin_subscription_package_help_modal_bloc.dart';
import 'package:user/app/presentation/pages/modals/tiffin_subscription_refund_reason_list_modal/tiffin_subscription_refund_reason_list_modal_view.dart';
import 'package:user/app/presentation/pages/modals/tiffin_subscription_request_off_days_modal/tiffin_subscription_request_off_days_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class TiffinSubscriptionPackageHelpModalScreen extends StatelessWidget {
  final String purchaseId;
  final String purchaseStatus;
  final String subscriptionPackage;
  final String restaurant;
  final String payment;
  final List<String> requestedOffDates;
  final List<String> offDays;
  final int totalOrders;
  final bool refundRequestEnable;
  const TiffinSubscriptionPackageHelpModalScreen({
    super.key,
    required this.purchaseId,
    required this.purchaseStatus,
    required this.subscriptionPackage,
    required this.restaurant,
    required this.payment,
    required this.requestedOffDates,
    required this.offDays,
    required this.totalOrders,
    required this.refundRequestEnable,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TiffinSubscriptionPackageHelpModalBloc()
        ..add(
          TiffinSubscriptionPackageHelpModalInitialEvent(
            purchaseId: purchaseId,
            purchaseStatus: purchaseStatus,
            refundRequestEnable: refundRequestEnable,
            subscriptionPackage: subscriptionPackage,
            restaurant: restaurant,
            payment: payment,
            requestedOffDates: requestedOffDates,
            offDays: offDays,
            totalOrders: totalOrders,
          ),
        ),
      child: const TiffinSubscriptionPackageHelpModalView(),
    );
  }
}

class TiffinSubscriptionPackageHelpModalView extends StatelessWidget {
  const TiffinSubscriptionPackageHelpModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<TiffinSubscriptionPackageHelpModalBloc, TiffinSubscriptionPackageHelpModalState>(
      listener: (context, state) {
        if (state.status.isRefundRequestFailed || state.status.isSummaryDownloadFailed || state.status.isInvoiceDownloadFailed || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isRefundRequestSuccess) {
          showSuccessDialog(context, translate.refund_request_created);
        } else if (state.status.isSummaryDownloadSuccess || state.status.isInvoiceDownloadSuccess) {
          showSuccessDialog(context, '${translate.file_downloaded_path} ${state.downloadPath}');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            title: Text(translate.tiffin_package_help),
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.read<TiffinSubscriptionPackageHelpModalBloc>().add(TiffinSubscriptionPackageHelpModalInvoiceEvent()),
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
                        state.status.isInvoiceDownloadStarted ? kAppCircularProgress(context, color: 'primary', strokeWidth: 2.0, width: 20.0, height: 20.0, padding: 2.0) : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                kAppSpacerVertical(height: 5),
                GestureDetector(
                  onTap: () => context.read<TiffinSubscriptionPackageHelpModalBloc>().add(TiffinSubscriptionPackageHelpModalSummaryEvent()),
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
                        state.status.isSummaryDownloadStarted ? kAppCircularProgress(context, color: 'primary', strokeWidth: 2.0, width: 20.0, height: 20.0, padding: 2.0) : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                state.purchaseStatus == 'created'
                    ? GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            isDismissible: false,
                            enableDrag: false,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            builder: (BuildContext context) {
                              return FractionallySizedBox(
                                heightFactor: 0.7,
                                child: TiffinSubscriptionRequestOffDaysModalScreen(requestedOffDates: state.requestedOffDates, offDays: state.offDays, totalOrders: state.totalOrders, purchaseId: state.purchaseId),
                              );
                            },
                          );
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.calendarDays, size: 14, color: Theme.of(context).canvasColor),
                              kAppSpacerHorizontal(width: 10),
                              Text(translate.add_off_date, style: kAppLblMediumFontBold(context, color: 'regular')),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
                state.purchaseStatus != 'pending_payments' && state.refundRequestEnable ? kAppSpacerVertical(height: 5) : const SizedBox(),
                state.purchaseStatus != 'pending_payments' && state.refundRequestEnable
                    ? GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            isDismissible: false,
                            enableDrag: false,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            builder: (BuildContext context) {
                              return const FractionallySizedBox(heightFactor: 0.7, child: TiffinSubscriptionREfundReasonListModalScreen());
                            },
                          ).then((value) {
                            if (!context.mounted) return;
                            if (value != null && value.toString().isNotEmpty) {
                              context.read<TiffinSubscriptionPackageHelpModalBloc>().add(TiffinSubscriptionPackageHelpModalRefundRequestEvent(reasonId: value.toString()));
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
        );
      },
    );
  }
}
// Done //
