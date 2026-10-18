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
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/account/dining_booking/dining_booking_information/bloc/dining_booking_information_bloc.dart';
import 'package:user/app/presentation/pages/modals/dining_booking_cancellation_reason_list_modal/dining_booking_cancellation_reason_list_modal_view.dart';
import 'package:user/app/presentation/pages/modals/dining_booking_information_help_modal/dining_booking_information_help_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DiningBookingInformationScreen extends StatelessWidget {
  final String bookingId;
  const DiningBookingInformationScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiningBookingInformationBloc()..add(DiningBookingInformationInitialEvent(bookingId: bookingId)),
      child: const DiningBookingInformationView(),
    );
  }
}

class DiningBookingInformationView extends StatelessWidget {
  const DiningBookingInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<DiningBookingInformationBloc, DiningBookingInformationState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError || state.status.isRepayOrderFailed || state.status.isCancelFailed) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isRepayOrderSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.makeDiningBookingPaymentRoute, (Route<dynamic> route) => false, arguments: [state.paymentURL]);
        } else if (state.status.isCancelSuccess) {
          Navigator.of(context).pop({"type": "refresh", "value": "hard"});
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isRepayOrderRequested || state.status.isCancelRequested ? true : false,
          child: Scaffold(
            appBar: AppBar(
              title: Text(translate.dining_detail),
              scrolledUnderElevation: 0,
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRouter.supportChatRoute, arguments: ['dining', state.bookingId]),
                  label: Text(
                    translate.support,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'semibold'),
                  ),
                  icon: Icon(Icons.chat_outlined, color: Theme.of(context).primaryColor, size: 14),
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
                          child: DiningBookingInformationHelpModalScreen(
                            bookingId: state.model.details!.id!,
                            bookingStatus: state.model.details!.status!,
                            paymentMode: state.model.details!.paymentInfo!.paymentWay!,
                            refundRequestEnable: state.model.businessSettings!.refundRequest!,
                            restaurant: state.model.details!.restaurant!.id!,
                            payment: state.model.details!.paymentInfo!.id!,
                          ),
                        );
                      },
                    );
                  },
                  icon: FaIcon(FontAwesomeIcons.ellipsisVertical, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const DiningBookingInformationLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const DiningBookingInformationErrorView(),
                  ] else ...[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (state.model.details!.status! == 'created') ...[
                            Image.asset(AssetsUrl.imageURL.bookingCreated, height: 80.0, width: 80.0),
                            kAppSpacerVertical(height: 20),
                            Text(translate.booking_created, style: kAppLblLargeFontBold(context)),
                          ] else if (state.model.details!.status! == 'pending_payments') ...[
                            Image.asset(AssetsUrl.imageURL.bookingPayment, height: 80.0, width: 80.0),
                            kAppSpacerVertical(height: 20),
                            Text(translate.payment_pending, style: kAppLblLargeFontBold(context)),
                          ] else if (state.model.details!.status! == 'accepted') ...[
                            Image.asset(AssetsUrl.imageURL.bookingApproved, height: 80.0, width: 80.0),
                            kAppSpacerVertical(height: 20),
                            Text(translate.booking_accepted, style: kAppLblLargeFontBold(context)),
                          ] else if (state.model.details!.status! == 'completed') ...[
                            Image.asset(AssetsUrl.imageURL.bookingCompleted, height: 80.0, width: 80.0),
                            kAppSpacerVertical(height: 20),
                            Text(translate.booking_completed, style: kAppLblLargeFontBold(context)),
                          ] else if (state.model.details!.status! == 'cancelled') ...[
                            Image.asset(AssetsUrl.imageURL.bookingCancelled, height: 80.0, width: 80.0),
                            kAppSpacerVertical(height: 20),
                            Text(translate.booking_cancelled, style: kAppLblLargeFontBold(context)),
                          ] else if (state.model.details!.status! == 'rejected') ...[
                            Image.asset(AssetsUrl.imageURL.bookingRejected, height: 80.0, width: 80.0),
                            kAppSpacerVertical(height: 20),
                            Text(translate.booking_rejected, style: kAppLblLargeFontBold(context)),
                          ] else if (state.model.details!.status! == 'refunded' || state.model.details!.status! == 'partially_refunded') ...[
                            Image.asset(AssetsUrl.imageURL.bookingPayment, height: 80.0, width: 80.0),
                            kAppSpacerVertical(height: 20),
                            Text(translate.booking_refunded, style: kAppLblLargeFontBold(context)),
                          ],
                        ],
                      ),
                    ),
                    kAppSpacerVertical(height: 10),
                    kAppTitleDivider(context, translate.reservation_details_title, 0),
                    kAppSpacerVertical(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.tag, color: Theme.of(context).canvasColor, size: 14),
                                kAppSpacerHorizontal(width: 10),
                                Text("${translate.id} : ${state.model.details!.id!}", style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_month_outlined, color: Theme.of(context).canvasColor, size: 14),
                                kAppSpacerHorizontal(width: 10),
                                Text("${translate.scheduled} : ${state.model.details!.bookingDate!} ${translate.at} ${state.model.details!.bookingSlot!}", style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.supervised_user_circle_outlined, color: Theme.of(context).canvasColor, size: 14),
                                kAppSpacerHorizontal(width: 10),
                                Text("${translate.guest_number} : ${state.model.details!.guest!}", style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    kAppSpacerVertical(height: 20),
                    kAppTitleDivider(context, translate.your_details_title, 0),
                    kAppSpacerVertical(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.account_circle_outlined, color: Theme.of(context).canvasColor, size: 14),
                                kAppSpacerHorizontal(width: 10),
                                Text("${translate.name} : ${state.model.details!.userName}", style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.email_outlined, color: Theme.of(context).canvasColor, size: 14),
                                kAppSpacerHorizontal(width: 10),
                                Text("${translate.email} : ${state.model.details!.userEmail}", style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.call_outlined, color: Theme.of(context).canvasColor, size: 14),
                                kAppSpacerHorizontal(width: 10),
                                Text("${translate.phone} : +${state.model.details!.userCountryCode} ${state.model.details!.userContact!}", style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    kAppSpacerVertical(height: 20),
                    kAppTitleDivider(context, translate.restaurant_details_title, 0),
                    kAppSpacerVertical(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
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
                                      Text(kAppTrimWord(state.model.details!.restaurant!.name!, 35), style: kAppLblMediumFontBold(context)),
                                      kAppSpacerVertical(height: 5),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width / 1.8,
                                        child: Text(state.model.details!.restaurant!.address!, maxLines: 3, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: CacheNetworkImageWidget(width: 40, height: 60.0, imageUrl: state.model.details!.restaurant!.cover!),
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
                                  child: GestureDetector(
                                    onTap: () => context.read<DiningBookingInformationBloc>().add(DiningBookingInformationRestaurantDirectionEvent()),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 30,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.directions_outlined, size: 10, color: Theme.of(context).canvasColor),
                                          kAppSpacerHorizontal(width: 5),
                                          Text(translate.direction, style: kAppLblTinyFontRegular(context)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: GestureDetector(
                                    onTap: () => context.read<DiningBookingInformationBloc>().add(DiningBookingInformationRestaurantCallEvent()),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 30,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.call, size: 10, color: Theme.of(context).canvasColor),
                                          kAppSpacerHorizontal(width: 5),
                                          Text(translate.call, style: kAppLblTinyFontRegular(context)),
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
                    state.model.details!.diningcoupons!.id!.isNotEmpty || state.model.details!.specialRequest!.isNotEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              kAppSpacerVertical(height: 20),
                              kAppTitleDivider(context, translate.more_details_title, 0),
                              state.model.details!.diningcoupons!.id!.isNotEmpty
                                  ? Container(
                                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(AssetsUrl.imageURL.couponDining, height: 15.0, width: 15.0),
                                          kAppSpacerHorizontal(width: 10),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              state.model.details!.diningcoupons!.discountType! == 'amount'
                                                  ? Text("${translate.flat} ${kAppPriceFormat(state.model.details!.diningcoupons!.minDiscount!)} ${translate.off}", style: kAppLblMediumFontSemiBold(context, color: 'regular'))
                                                  : Text(
                                                      '${translate.flat} ${state.model.details!.diningcoupons!.minDiscount!}% ${state.model.details!.diningcoupons!.maxDiscount! > 0 ? '${translate.to} ${state.model.details!.diningcoupons!.maxDiscount!}% ' : ''} ${translate.off}',
                                                      style: kAppLblMediumFontSemiBold(context, color: 'regular'),
                                                    ),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width / 1.4,
                                                child: Text(state.model.details!.diningcoupons!.name!, maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              state.model.details!.specialRequest!.isNotEmpty
                                  ? Container(
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Icon(Icons.history_edu_outlined, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                                              kAppSpacerHorizontal(width: 10),
                                              Text(translate.your_special_request, style: kAppLblMediumFontMedium(context)),
                                            ],
                                          ),
                                          kAppSpacerVertical(height: 5),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width / 1.2,
                                            child: Text(state.model.details!.specialRequest!, maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          )
                        : const SizedBox(),
                    state.model.details!.grandTotal! > 0
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              kAppSpacerVertical(height: 20),
                              kAppTitleDivider(context, translate.billing_summary_title, 0),
                              kAppSpacerVertical(height: 20),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    state.model.details!.preBookingCharge! > 0
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(vertical: 2),
                                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(translate.pre_booking_charge, style: kAppLblTinyFontRegular(context)),
                                                Text(kAppPriceFormat(state.model.details!.preBookingCharge!), style: kAppLblTinyFontRegular(context)),
                                              ],
                                            ),
                                          )
                                        : const SizedBox(),
                                    state.model.details!.couponCoverCharge! > 0
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(vertical: 2),
                                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(translate.coupon_cover_charge, style: kAppLblTinyFontRegular(context)),
                                                Text(kAppPriceFormat(state.model.details!.couponCoverCharge!), style: kAppLblTinyFontRegular(context)),
                                              ],
                                            ),
                                          )
                                        : const SizedBox(),
                                    Container(
                                      padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 10),
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(width: 1.5, color: ThemeProvider.lightDisabledColor)),
                                      ),
                                      child: Text(translate.amount_adjusted_in_final_bill, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 5, bottom: 10),
                                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("${translate.paid} (${state.model.details!.paymentInfo!.name!})", style: kAppLblTinyFontBold(context)),
                                          Text(kAppPriceFormat(state.model.details!.grandTotal!), style: kAppLblTinyFontBold(context)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    state.model.details!.transaction!.id!.isNotEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              kAppSpacerVertical(height: 20),
                              kAppTitleDivider(context, translate.transaction_detail_title, 0),
                              kAppSpacerVertical(height: 20),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.attach_money_outlined, color: Theme.of(context).canvasColor, size: 14),
                                          kAppSpacerHorizontal(width: 10),
                                          Text("${translate.id} : ${state.model.details!.transaction!.id!}", style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.calendar_month_outlined, color: Theme.of(context).canvasColor, size: 14),
                                          kAppSpacerHorizontal(width: 10),
                                          Text("${translate.date} : ${state.model.details!.transaction!.createdAt!}", style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: state.status.isLoading || state.status.isFailure
                ? SafeArea(child: const SizedBox())
                : SafeArea(
                    child: SizedBox(
                      height: state.canPayPending || state.canCancelBooking ? 80 : 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.canCancelBooking) ...[
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
                                              return const FractionallySizedBox(heightFactor: 0.7, child: DiningBookingCancellationReasonListModalScreen());
                                            },
                                          ).then((value) {
                                            if (!context.mounted) return;
                                            if (value != null && value.toString().isNotEmpty) {
                                              context.read<DiningBookingInformationBloc>().add(DiningBookingInformationCancelMyBookingEvent(reasonId: value.toString()));
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
                                        child: state.status.isCancelRequested ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.cancel_booking_btn),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (state.canPayPending) ...[
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
                                        Text(translate.pay_methods_hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                      ],
                                    ),
                                  ),
                                  const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                                  Expanded(
                                    flex: 3,
                                    child: GestureDetector(
                                      onTap: () => context.read<DiningBookingInformationBloc>().add(DiningBookingInformationRepayBookingEvent()),
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
                                                      Text(kAppPriceFormat(double.parse(state.model.details!.grandTotal!.toString())), style: kAppLblMediumFontSemiBoldWhite(context)),
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

class DiningBookingInformationLoadingView extends StatelessWidget {
  const DiningBookingInformationLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
            children: List.generate(2, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                ),
                child: Column(
                  children: [
                    SkeletonLine(
                      style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
                    ),
                    const SizedBox(height: 5),
                    SkeletonLine(
                      style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
                    ),
                    const SizedBox(height: 5),
                    SkeletonLine(
                      style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
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
              );
            }),
          ),
        ),
      ],
    );
  }
}

class DiningBookingInformationErrorView extends StatelessWidget {
  const DiningBookingInformationErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.empty_data_two, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}
// Done //
