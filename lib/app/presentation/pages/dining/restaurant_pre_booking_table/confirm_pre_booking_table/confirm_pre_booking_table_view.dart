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
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/dining_booking_user_detail_modal_response_model.dart';
import 'package:user/app/presentation/pages/dining/restaurant_pre_booking_table/confirm_pre_booking_table/bloc/confirm_pre_booking_table_bloc.dart';
import 'package:user/app/presentation/pages/modals/dining_booking_request_modal/dining_booking_request_modal_view.dart';
import 'package:user/app/presentation/pages/modals/dining_booking_user_detail_modal/dining_booking_user_detail_modal_view.dart';
import 'package:user/app/presentation/pages/modals/payment_success_modal/payment_success_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ConfirmPreBookingTableScreen extends StatelessWidget {
  final String restaurant;
  final String selectedDate;
  final int selectedGuest;
  final String selectedSlot;
  final String selectedCoupon;
  const ConfirmPreBookingTableScreen({super.key, required this.restaurant, required this.selectedDate, required this.selectedGuest, required this.selectedSlot, required this.selectedCoupon});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ConfirmPreBookingTableBloc()..add(ConfirmPreBookingTableInitialEvent(restaurant: restaurant, selectedDate: selectedDate, selectedGuest: selectedGuest, selectedSlot: selectedSlot, selectedCoupon: selectedCoupon)),
      child: const ConfirmPreBookingTableView(),
    );
  }
}

class ConfirmPreBookingTableView extends StatelessWidget {
  const ConfirmPreBookingTableView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<ConfirmPreBookingTableBloc, ConfirmPreBookingTableState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isBookingPlaced) {
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
        } else if (state.status.isMakePayment) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.makeDiningBookingPaymentRoute, (Route<dynamic> route) => false, arguments: [state.paymentURL]);
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isMakeBooking ? true : false,
          child: Scaffold(
            appBar: AppBar(title: Text(translate.review_booking_detail), scrolledUnderElevation: 0),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const ConfirmPreBookingTableLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const ConfirmPreBookingTableErrorView(),
                  ] else ...[
                    Text(translate.booking_summary, style: kAppLblMediumFontBold(context)),
                    kAppSpacerVertical(height: 10),
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
                                Icon(Icons.calendar_month_outlined, color: Theme.of(context).canvasColor, size: 14),
                                kAppSpacerHorizontal(width: 10),
                                Text("${state.formatedDate} ${translate.at} ${state.selectedSlot}", style: kAppLblMediumFontSemiBold(context, color: 'regular')),
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
                                Text("${state.selectedGuest} ${state.selectedGuest == 1 ? translate.guest : translate.guests}", style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5, bottom: 10),
                            padding: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: state.selectedCoupon.isNotEmpty && state.model.coupon!.id! == state.selectedCoupon ? 10 : 5),
                            decoration: BoxDecoration(
                              border: state.selectedCoupon.isNotEmpty && state.model.coupon!.id! == state.selectedCoupon ? Border(bottom: BorderSide(width: 1.5, color: ThemeProvider.lightDisabledColor)) : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: Theme.of(context).canvasColor, size: 14),
                                kAppSpacerHorizontal(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(state.model.restaurant!.name!, style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width / 1.4,
                                      child: Text(state.model.restaurant!.address!, maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          state.selectedCoupon.isNotEmpty && state.model.coupon!.id! == state.selectedCoupon
                              ? Container(
                                  margin: const EdgeInsets.only(top: 5, bottom: 10),
                                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
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
                                          state.model.coupon!.discountType! == 'amount'
                                              ? Text("${translate.flat} ${kAppPriceFormat(state.model.coupon!.minDiscount!)} ${translate.off}", style: kAppLblMediumFontSemiBold(context, color: 'regular'))
                                              : Text(
                                                  "${translate.off} ${state.model.coupon!.minDiscount!}% ${state.model.coupon!.maxDiscount! > 0 ? '${translate.to} ${state.model.coupon!.maxDiscount!}% ' : ''} ${translate.off}",
                                                  style: kAppLblMediumFontSemiBold(context, color: 'regular'),
                                                ),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width / 1.4,
                                            child: Text(state.model.coupon!.name!, maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            isDismissible: false,
                            enableDrag: false,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            builder: (BuildContext context) {
                              return FractionallySizedBox(heightFactor: 0.65, child: DiningBookingRequestModalScreen(requestText: state.userSpecialRequest));
                            },
                          ).then((value) {
                            if (!context.mounted) return;
                            if (value != null && value != '') {
                              if (value == false || value == 'false') {
                                context.read<ConfirmPreBookingTableBloc>().add(ConfirmPreBookingSpecialRequestChangeEvent(instructions: ''));
                              } else {
                                context.read<ConfirmPreBookingTableBloc>().add(ConfirmPreBookingSpecialRequestChangeEvent(instructions: value));
                              }
                            }
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history_edu_outlined, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                                    kAppSpacerHorizontal(width: 10),
                                    Text(translate.add_special_request, style: kAppLblMediumFontMedium(context)),
                                  ],
                                ),
                                Icon(Icons.chevron_right, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                              ],
                            ),
                            state.userSpecialRequest.isNotEmpty ? kAppSpacerVertical(height: 5) : const SizedBox(),
                            state.userSpecialRequest.isNotEmpty
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width / 1.2,
                                    child: Text(state.userSpecialRequest, maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    state.isValid
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              kAppSpacerVertical(height: 10),
                              Text(translate.your_detail, style: kAppLblMediumFontBold(context)),
                              kAppSpacerVertical(height: 10),
                              GestureDetector(
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
                                        heightFactor: 0.65,
                                        child: DiningBookingUserDetailModalScreen(userName: state.userName, userCountryCode: state.userContryCode, userPhoneNumber: state.userContact, userEmail: state.userEmail),
                                      );
                                    },
                                  ).then((value) {
                                    if (!context.mounted) return;
                                    if (value != null && value != '') {
                                      DiningBookingUserDetailModalResponseModel userInfoDetail = DiningBookingUserDetailModalResponseModel.fromJson(value);
                                      if (userInfoDetail.name!.isNotEmpty && userInfoDetail.countryCode!.isNotEmpty && userInfoDetail.phoneNumber!.isNotEmpty) {
                                        context.read<ConfirmPreBookingTableBloc>().add(
                                          ConfirmPreBookingUserInfoChangeEvent(name: userInfoDetail.name!, countryCode: userInfoDetail.countryCode!, phoneNumber: userInfoDetail.phoneNumber!, email: userInfoDetail.email!),
                                        );
                                      }
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
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(state.userName, style: kAppLblTinyFontBold(context)),
                                          Text(state.userEmail, style: kAppLblTinyFontRegular(context)),
                                          Text("+${state.userContryCode} ${state.userContact}", style: kAppLblTinyFontRegular(context)),
                                        ],
                                      ),
                                      Text(translate.edit, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    state.grandTotal > 0
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              kAppSpacerVertical(height: 10),
                              Text(translate.booking_charge_summary, style: kAppLblMediumFontBold(context)),
                              kAppSpacerVertical(height: 10),
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
                                    state.model.dinnigSetting!.preBookingChargeRequired! && state.model.dinnigSetting!.minBookingCharge! > 0
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(vertical: 2),
                                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(translate.pre_booking_charge, style: kAppLblTinyFontRegular(context)),
                                                Text(kAppPriceFormat(state.model.dinnigSetting!.minBookingCharge!), style: kAppLblTinyFontRegular(context)),
                                              ],
                                            ),
                                          )
                                        : const SizedBox(),
                                    state.selectedCoupon.isNotEmpty && state.model.coupon!.id! == state.selectedCoupon && state.model.coupon!.preBookingChargeRequired!
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(vertical: 2),
                                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(translate.coupon_cover_charge, style: kAppLblTinyFontRegular(context)),
                                                Text(kAppPriceFormat(state.model.coupon!.preBookingChargeAmount!), style: kAppLblTinyFontRegular(context)),
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
                                          Text(translate.to_be_paid, style: kAppLblTinyFontBold(context)),
                                          Text(kAppPriceFormat(state.grandTotal), style: kAppLblTinyFontBold(context)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        kAppSpacerVertical(height: 10),
                        Text(translate.terms_and_conditions, style: kAppLblMediumFontBold(context)),
                        kAppSpacerVertical(height: 10),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
                      margin: const EdgeInsets.only(bottom: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: state.model.notices!.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.brightness_1, size: 5, color: Theme.of(context).canvasColor),
                                const SizedBox(width: 8),
                                Expanded(child: Text(item.name!, style: kAppLblSmallFontRegular(context))),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: SizedBox(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.status.isLoading) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 2,
                              child: SkeletonLine(
                                style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                            Expanded(
                              flex: 3,
                              child: SkeletonLine(
                                style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ] else if (state.status.isFailure) ...[
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50),
                                  child: Text(translate.error_go_back),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        if (state.isValid == false) ...[
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
                                      return FractionallySizedBox(
                                        heightFactor: 0.65,
                                        child: DiningBookingUserDetailModalScreen(userName: state.userName, userCountryCode: state.userContryCode, userPhoneNumber: state.userContact, userEmail: state.userEmail),
                                      );
                                    },
                                  ).then((value) {
                                    if (!context.mounted) return;
                                    if (value != null && value != '') {
                                      DiningBookingUserDetailModalResponseModel userInfoDetail = DiningBookingUserDetailModalResponseModel.fromJson(value);
                                      if (userInfoDetail.name!.isNotEmpty && userInfoDetail.countryCode!.isNotEmpty && userInfoDetail.phoneNumber!.isNotEmpty) {
                                        context.read<ConfirmPreBookingTableBloc>().add(
                                          ConfirmPreBookingUserInfoChangeEvent(name: userInfoDetail.name!, countryCode: userInfoDetail.countryCode!, phoneNumber: userInfoDetail.phoneNumber!, email: userInfoDetail.email!),
                                        );
                                      }
                                    }
                                  });
                                },
                                style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50),
                                child: Text(translate.add_your_details),
                              ),
                            ),
                          ),
                        ] else if (state.grandTotal > 0) ...[
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
                                  onTap: () => context.read<ConfirmPreBookingTableBloc>().add(ConfirmPreBookingSubmitEvent()),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                    width: double.infinity,
                                    height: 60.0,
                                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                                    child: state.status.isMakeBooking
                                        ? Center(child: kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0))
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(kAppPriceFormat(state.grandTotal), textAlign: TextAlign.start, style: kAppLblMediumFontSemiBoldWhite(context)),
                                                  kAppSpacerVertical(height: 3),
                                                  Text(translate.total, textAlign: TextAlign.start, style: kAppLblTinyFontBoldCart(context)),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Text(translate.pay_now, style: kAppLblMediumFontSemiBoldWhite(context)),
                                                      Icon(Icons.arrow_right, color: Theme.of(context).scaffoldBackgroundColor, size: 14),
                                                    ],
                                                  ),
                                                  kAppSpacerVertical(height: 3),
                                                  Text(translate.confirm_seat, textAlign: TextAlign.end, style: kAppLblTinyFontBoldCart(context)),
                                                ],
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.read<ConfirmPreBookingTableBloc>().add(ConfirmPreBookingSubmitEvent()),
                                style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50),
                                child: state.status.isMakeBooking ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.confirm_your_seat),
                              ),
                            ),
                          ),
                        ],
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

class ConfirmPreBookingTableLoadingView extends StatelessWidget {
  const ConfirmPreBookingTableLoadingView({super.key});

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

class ConfirmPreBookingTableErrorView extends StatelessWidget {
  const ConfirmPreBookingTableErrorView({super.key});

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
