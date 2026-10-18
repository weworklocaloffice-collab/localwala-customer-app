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
import 'package:user/app/presentation/pages/dining/restaurant_pre_booking_table/@core/bloc/restaurant_pre_booking_table_bloc.dart';
import 'package:user/app/presentation/pages/modals/dining_charge_summary_modal/dining_charge_summary_modal_view.dart';
import 'package:user/app/presentation/pages/modals/dining_date_list_modal/dining_date_list_modal_view.dart';
import 'package:user/app/presentation/pages/modals/dining_guest_list_modal_view.dart/dining_guest_list_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class RestaurantPreBookingTableScreen extends StatelessWidget {
  final String restaurant;
  final String restaurantName;
  final String restaurantSlug;
  const RestaurantPreBookingTableScreen({super.key, required this.restaurant, required this.restaurantName, required this.restaurantSlug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RestaurantPreBookingTableBloc()..add(RestaurantPreBookingTableInitialEvent(restaurant: restaurant, restaurantName: restaurantName, restaurantSlug: restaurantSlug)),
      child: const RestaurantPreBookingTableView(),
    );
  }
}

class RestaurantPreBookingTableView extends StatelessWidget {
  const RestaurantPreBookingTableView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<RestaurantPreBookingTableBloc, RestaurantPreBookingTableState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isLoginGuestSuccess) {
          Navigator.of(context).pushNamed(AppRouter.confirmPreBookingTableRoute, arguments: [state.restaurantSlug, state.bookingFormatDate, state.bookingGuest, state.bookingSlot, state.selectedCoupon]);
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isLoginGuest || state.status.isValidateCoupon ? true : false,
          child: Scaffold(
            appBar: AppBar(title: Text("${translate.book_table_title} | ${state.restaurantName}"), scrolledUnderElevation: 0),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isInitial) ...[
                    const RestaurantPreBookingTableLoadingView(),
                  ] else if (state.status.isEmpty) ...[
                    const RestaurantPreBookingTableEmptyView(),
                  ] else if (state.status.isFailure) ...[
                    const RestaurantPreBookingTableErrorView(),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          child: CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: state.model.details!.cover!),
                        ),
                        kAppSpacerHorizontal(width: 5),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(kAppTrimWord(state.model.details!.name!, 30), style: kAppLblMediumFontBold(context)),
                              Text(kAppTrimWord(state.model.details!.address!, 60), maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    kAppSpacerVertical(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: FractionallySizedBox(
                                      heightFactor: 0.4,
                                      widthFactor: 0.5,
                                      child: Dialog(
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        insetPadding: const EdgeInsets.only(left: ThemeProvider.scaffoldPadding, top: 100),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                        child: FractionallySizedBox(
                                          child: DiningDateListModalScreen(dates: state.dates, dateFormat: state.bookingFormatDate),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) {
                                if (!context.mounted) return;
                                if (value != null && value.toString().isNotEmpty) {
                                  context.read<RestaurantPreBookingTableBloc>().add(RestaurantPreBookingChangeDateEvent(dateFormat: value.toString()));
                                }
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
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
                                      Icon(Icons.calendar_month_outlined, color: Theme.of(context).primaryColor, size: 14),
                                      kAppSpacerHorizontal(width: 10),
                                      Text(state.bookingDate, style: kAppLblMediumFontBold(context, color: 'regular')),
                                    ],
                                  ),
                                  Icon(Icons.arrow_drop_down_rounded, color: Theme.of(context).primaryColor, size: 14),
                                ],
                              ),
                            ),
                          ),
                        ),
                        kAppSpacerHorizontal(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return Align(
                                    alignment: Alignment.topRight,
                                    child: FractionallySizedBox(
                                      heightFactor: 0.4,
                                      widthFactor: 0.5,
                                      child: Dialog(
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        insetPadding: const EdgeInsets.only(right: ThemeProvider.scaffoldPadding, top: 100),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                        child: FractionallySizedBox(
                                          child: DiningGuestListModalScreen(savedGuest: state.bookingGuest, guestAvailability: state.model.guestAvailability!),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) {
                                if (!context.mounted) return;
                                if (value != null && value.toString().isNotEmpty) {
                                  context.read<RestaurantPreBookingTableBloc>().add(RestaurantPreBookingChangeGuestEvent(guest: int.parse(value.toString())));
                                }
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
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
                                      Icon(Icons.supervised_user_circle_outlined, color: Theme.of(context).primaryColor, size: 14),
                                      kAppSpacerHorizontal(width: 10),
                                      Text("${state.bookingGuest} ${state.bookingGuest == 1 ? translate.guest : translate.guests}", style: kAppLblMediumFontBold(context, color: 'regular')),
                                    ],
                                  ),
                                  Icon(Icons.arrow_drop_down_rounded, color: Theme.of(context).primaryColor, size: 14),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    kAppSpacerVertical(height: 20),
                    state.mealTime.isEmpty
                        ? const RestaurantPreBookingNoSlotView()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              state.mealTime.length > 1
                                  ? Center(
                                      child: IntrinsicWidth(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.shadow, borderRadius: BorderRadius.circular(50)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: List.generate(
                                              state.mealTime.length,
                                              (mealIndex) => GestureDetector(
                                                onTap: () => context.read<RestaurantPreBookingTableBloc>().add(RestaurantPreBookingChangeMealTimeEvent(mealIndex: mealIndex)),
                                                child: Container(
                                                  margin: const EdgeInsets.only(right: 5),
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: state.mealIndexToShow == mealIndex ? Theme.of(context).scaffoldBackgroundColor : ThemeProvider.transparentColor,
                                                    border: Border.all(color: state.mealIndexToShow == mealIndex ? Theme.of(context).primaryColor : ThemeProvider.transparentColor, width: 1.5),
                                                    borderRadius: BorderRadius.circular(50),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      if (state.mealTime[mealIndex].value! == 'breakfast') ...[
                                                        Text(translate.breakfast, style: kAppLblTinyFontRegularChip(context, color: 'regular')),
                                                      ] else if (state.mealTime[mealIndex].value! == 'lunch') ...[
                                                        Text(translate.lunch, style: kAppLblTinyFontRegularChip(context, color: 'regular')),
                                                      ] else if (state.mealTime[mealIndex].value! == 'dinner') ...[
                                                        Text(translate.dinner, style: kAppLblTinyFontRegularChip(context, color: 'regular')),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              state.mealTime.length > 1 ? kAppSpacerVertical(height: 30) : const SizedBox(),
                              GridView.builder(
                                padding: EdgeInsets.zero,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 80),
                                scrollDirection: Axis.vertical,
                                key: UniqueKey(),
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemBuilder: (BuildContext context, int slotIndex) {
                                  return GestureDetector(
                                    onTap: () => context.read<RestaurantPreBookingTableBloc>().add(RestaurantPreBookingSaveSlotEvent(slot: state.mealTime[state.mealIndexToShow].slots![slotIndex])),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width / 3,
                                      height: 80,
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15.0),
                                        border: Border.all(color: state.bookingSlot == state.mealTime[state.mealIndexToShow].slots![slotIndex] ? Theme.of(context).primaryColor : ThemeProvider.lightDisabledColor, width: 1.5),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(state.mealTime[state.mealIndexToShow].slots![slotIndex], style: kAppLblMediumFontBold(context, color: 'regular')),
                                          kAppSpacerVertical(height: 5),
                                          state.mealTime[state.mealIndexToShow].totalOffers! > 0
                                              ? Text("${state.mealTime[state.mealIndexToShow].totalOffers!} ${translate.offers}", style: kAppLblMediumFontBold(context, color: 'primary'))
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                itemCount: state.mealTime[state.mealIndexToShow].slots!.length,
                              ),
                              kAppSpacerVertical(height: 30),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                  state.showCoupon.length,
                                  (couponIndex) => GestureDetector(
                                    onTap: () => context.read<RestaurantPreBookingTableBloc>().add(RestaurantPreBookingSaveCouponEvent(couponId: state.showCoupon[couponIndex].id!)),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15.0),
                                        border: Border.all(color: state.selectedCoupon == state.showCoupon[couponIndex].id ? Theme.of(context).primaryColor : ThemeProvider.lightDisabledColor, width: 1.5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              state.showCoupon[couponIndex].discountType == 'amount'
                                                  ? Text("${translate.flat} ${kAppPriceFormat(state.showCoupon[couponIndex].minDiscount!)} ${translate.off}", style: kAppLblMediumFontBold(context, color: 'regular'))
                                                  : Text(
                                                      "${translate.flat} ${state.showCoupon[couponIndex].minDiscount!}% ${state.showCoupon[couponIndex].maxDiscount! > 0 ? '${translate.to} ${state.showCoupon[couponIndex].maxDiscount!}% ' : ''} ${translate.off}",
                                                      style: kAppLblMediumFontBold(context, color: 'regular'),
                                                    ),
                                              kAppSpacerVertical(height: 5),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width / 1.5,
                                                child: Text(state.showCoupon[couponIndex].name!, maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                              ),
                                              kAppSpacerVertical(height: 5),
                                              Text(
                                                state.showCoupon[couponIndex].preBookingChargeRequired!
                                                    ? '${kAppPriceFormat(state.showCoupon[couponIndex].preBookingChargeAmount!)} ${translate.cover_charge_required}'
                                                    : translate.no_cover_charge_required,
                                                style: kAppLblTinyFontRegular(context),
                                              ),
                                            ],
                                          ),
                                          state.status.isValidateCoupon && state.selectedCoupon == state.showCoupon[couponIndex].id
                                              ? kAppCircularProgress(context, color: 'primary', strokeWidth: 2.0, width: 20.0, height: 20.0, padding: 2.0)
                                              : Icon(
                                                  state.selectedCoupon == state.showCoupon[couponIndex].id ? Icons.radio_button_checked_outlined : Icons.radio_button_off_outlined,
                                                  color: Theme.of(context).primaryColor,
                                                  size: 15,
                                                ),
                                        ],
                                      ),
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
            bottomNavigationBar: state.status.isInitial || state.status.isFailure || state.status.isEmpty
                ? SafeArea(child: const SizedBox())
                : SafeArea(
                    child: SizedBox(
                      height: state.toPay > 0 ? 100 : 60,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            state.toPay > 0
                                ? Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
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
                                                  heightFactor: 0.3,
                                                  child: DiningChargeSummaryModalScreen(
                                                    preBookingCharge: state.model.dinnigSetting!.preBookingChargeRequired! ? state.model.dinnigSetting!.minBookingCharge! : 0,
                                                    couponCoverCharge: state.couponCoverCharge,
                                                    toPay: state.toPay,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text("${translate.to_pay} ${kAppPriceFormat(state.toPay)}", style: kAppLblTinyFontRegular(context)),
                                              Icon(Icons.info_outline, color: Theme.of(context).canvasColor, size: 12),
                                            ],
                                          ),
                                        ),
                                        kAppSpacerVertical(height: 5),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            Row(
                              children: [
                                if (state.canProceed) ...[
                                  Expanded(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: state.isValid
                                            ? () {
                                                Navigator.of(
                                                  context,
                                                ).pushNamed(AppRouter.confirmPreBookingTableRoute, arguments: [state.restaurantSlug, state.bookingFormatDate, state.bookingGuest, state.bookingSlot, state.selectedCoupon]);
                                              }
                                            : null,
                                        style: kAppElevatedButtonStyle(
                                          context,
                                          disabledColor: Theme.of(context).disabledColor,
                                          bgColor: Theme.of(context).primaryColor,
                                          foreColor: Theme.of(context).scaffoldBackgroundColor,
                                          height: 50,
                                        ),
                                        child: Text(translate.proceed),
                                      ),
                                    ),
                                  ),
                                ] else if (state.canProceed == false && state.model.dinnigSetting!.guestBooking!) ...[
                                  Expanded(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: state.isValid
                                            ? () {
                                                context.read<RestaurantPreBookingTableBloc>().add(RestaurantPreBookingTableGuestLoginEvent());
                                              }
                                            : null,
                                        style: kAppElevatedButtonStyle(
                                          context,
                                          disabledColor: Theme.of(context).disabledColor,
                                          bgColor: Theme.of(context).primaryColor,
                                          foreColor: Theme.of(context).scaffoldBackgroundColor,
                                          height: 50,
                                        ),
                                        child: state.status.isLoginGuest ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.login_as_guest),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: state.isValid
                                            ? () {
                                                Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
                                              }
                                            : null,
                                        style: kAppElevatedButtonStyle(
                                          context,
                                          disabledColor: Theme.of(context).disabledColor,
                                          bgColor: Theme.of(context).primaryColor,
                                          foreColor: Theme.of(context).scaffoldBackgroundColor,
                                          height: 50,
                                        ),
                                        child: Text(translate.login_to_continue),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
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

class RestaurantPreBookingNoSlotView extends StatelessWidget {
  const RestaurantPreBookingNoSlotView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.noSlotForDining, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.no_booking_slot, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class RestaurantPreBookingTableLoadingView extends StatelessWidget {
  const RestaurantPreBookingTableLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SkeletonLine(
                style: SkeletonLineStyle(height: 20, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            kAppSpacerHorizontal(width: 5),
            Expanded(
              child: SkeletonLine(
                style: SkeletonLineStyle(height: 20, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        kAppSpacerVertical(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SkeletonLine(
              style: SkeletonLineStyle(height: 20, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(10)),
            ),
          ],
        ),
        kAppSpacerVertical(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SkeletonLine(
              style: SkeletonLineStyle(height: 20, width: MediaQuery.of(context).size.width / 1.2, borderRadius: BorderRadius.circular(10)),
            ),
          ],
        ),
        kAppSpacerVertical(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SkeletonLine(
                style: SkeletonLineStyle(height: 20, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            kAppSpacerHorizontal(width: 5),
            Expanded(
              child: SkeletonLine(
                style: SkeletonLineStyle(height: 20, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        kAppSpacerVertical(height: 20),
        GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 50),
          scrollDirection: Axis.vertical,
          key: UniqueKey(),
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              width: MediaQuery.of(context).size.width / 5,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                child: Container(
                  decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
                  child: const Center(child: SkeletonAvatar(style: SkeletonAvatarStyle(width: 20, height: 10))),
                ),
              ),
            );
          },
          itemCount: 40,
        ),
      ],
    );
  }
}

class RestaurantPreBookingTableEmptyView extends StatelessWidget {
  const RestaurantPreBookingTableEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.cartEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.matching_record_not_found, textAlign: TextAlign.center, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.no_data_reason_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class RestaurantPreBookingTableErrorView extends StatelessWidget {
  const RestaurantPreBookingTableErrorView({super.key});

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

