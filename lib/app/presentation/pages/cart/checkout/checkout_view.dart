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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/coupon_list_response_model.dart';
import 'package:user/app/core/models/delivery_address_modal_response_model.dart';
import 'package:user/app/core/models/delivery_instruction_modal_response_model.dart';
import 'package:user/app/core/models/receiver_modal_response_model.dart';
import 'package:user/app/presentation/pages/cart/checkout/bloc/checkout_bloc.dart';
import 'package:user/app/presentation/pages/modals/billing_summary_modal/billing_summary_modal_view.dart';
import 'package:user/app/presentation/pages/modals/change_receiver_info_modal/change_receiver_info_modal_view.dart';
import 'package:user/app/presentation/pages/modals/coupon_list_modal/coupon_list_modal_view.dart';
import 'package:user/app/presentation/pages/modals/delivery_address_list_modal/delivery_address_list_modal_view.dart';
import 'package:user/app/presentation/pages/modals/delivery_instructions_modal/delivery_instructions_modal_view.dart';
import 'package:user/app/presentation/pages/modals/food_instructions_modal/food_instructions_modal_view.dart';
import 'package:user/app/presentation/pages/modals/payment_success_modal/payment_success_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/app/services/custom_time_picker_widget.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class CheckoutScreen extends StatefulWidget {
  final String name;
  final String restaurant;
  const CheckoutScreen({super.key, required this.name, required this.restaurant});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CheckoutBloc>().add(CheckoutInitialEvent(name: widget.name, restaurant: widget.restaurant));
  }

  bool isNumbericAddressTitle(String value) {
    if (value.isEmpty) return false;
    return num.tryParse(value) != null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCartError || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isEmpty) {
          Navigator.of(context).maybePop();
        } else if (state.status.isOrderPlaced) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            builder: (BuildContext context) {
              return FractionallySizedBox(heightFactor: 0.7, child: PaymentSuccessModalScreen(from: 'order'));
            },
          ).then((value) {
            if (!context.mounted) return;
            if (value != null && value != '' && value.toString() == 'true') {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [2]);
            }
          });
        } else if (state.status.isMakePayment) {
          // Pass COD id so the payment screen can offer Cash on Delivery
          // alongside UPI/Card/NB/Wallets. Empty = COD unavailable there.
          String codId = '';
          try {
            final pays = state.orderSettings.payments ?? [];
            for (final p in pays) {
              if ((p.slug ?? '').toLowerCase() == 'cod') {
                codId = p.id ?? '';
                break;
              }
            }
          } catch (_) {}
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.makePaymentRoute, (Route<dynamic> route) => false, arguments: [state.paymentURL, codId]);
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isPlacingOrder ? true : false,
          child: Scaffold(
            appBar: AppBar(scrolledUnderElevation: 0, title: Text(widget.name)),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  if (state.status.isLoading) ...[
                    const CheckoutLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const CheckoutErrorView(),
                  ] else if (state.status.isEmpty) ...[
                    const CheckoutEmptyView(),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          state.permissionList.contains('homedelivery') && state.permissionList.contains('takeaway')
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () => context.read<CheckoutBloc>().add(CheckoutChangeOrderToEvent(orderTo: 'homedelivery')),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                        width: MediaQuery.of(context).size.width / 2.3,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: state.orderTo == 'homedelivery' ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              AssetsUrl.imageURL.checkoutDelivery,
                                              height: 20,
                                              width: 20,
                                              color: state.orderTo == 'homedelivery' ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).canvasColor,
                                            ),
                                            kAppSpacerHorizontal(width: 10),
                                            Text(translate.home_delivery, style: state.orderTo == 'homedelivery' ? kAppLblMediumFontSemiBoldWhite(context) : kAppLblMediumFontSemiBold(context)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => context.read<CheckoutBloc>().add(CheckoutChangeOrderToEvent(orderTo: 'selfpickup')),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                        width: MediaQuery.of(context).size.width / 2.3,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: state.orderTo == 'selfpickup' ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(AssetsUrl.imageURL.checkoutTakeaway, height: 20, width: 20, color: state.orderTo == 'selfpickup' ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).canvasColor),
                                            kAppSpacerHorizontal(width: 10),
                                            Text(translate.take_away, style: state.orderTo == 'selfpickup' ? kAppLblMediumFontSemiBoldWhite(context) : kAppLblMediumFontSemiBold(context)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          state.permissionList.contains('homedelivery') && state.permissionList.contains('takeaway') ? kAppSpacerVertical(height: 10) : const SizedBox(),
                          state.permissionList.contains('schedule')
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(translate.schedule_delivery_date, style: kAppLblMediumFontBold(context)),
                                      kAppSpacerVertical(height: 5),
                                      Text(translate.schedule_delivery_date_sub_title, style: kAppLblTinyFontRegular(context)),
                                      kAppSpacerVertical(height: 5),
                                      CustomDatePickerTimeline(
                                        startDate: DateTime.now(),
                                        daysCount: state.customerCanOrderWithinDays,
                                        locale: Locale(state.locale),
                                        onDateChange: (newDate) {
                                          context.read<CheckoutBloc>().add(CheckoutScheduleDateEvent(date: newDate));
                                        },
                                      ),
                                      kAppSpacerVertical(height: 10),
                                      Text(translate.schedule_delivery_time, style: kAppLblMediumFontBold(context)),
                                      kAppSpacerVertical(height: 5),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          children: state.timeSlots
                                              .map(
                                                (e) => InkWell(
                                                  onTap: () => context.read<CheckoutBloc>().add(CheckoutScheduleTimeEvent(time: e)),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                    margin: const EdgeInsets.only(left: 5),
                                                    decoration: BoxDecoration(
                                                      color: state.scheduleTime == e ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,
                                                      borderRadius: BorderRadius.circular(5),
                                                      border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                                    ),
                                                    child: Text(e, style: state.scheduleTime == e ? kAppLblMediumFontSemiBoldWhite(context) : kAppLblMediumFontSemiBold(context)),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(
                                    state.inCart.length,
                                    (foodIndex) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(kAppTrimWord(state.inCart[foodIndex].name!, 50), style: kAppLblMediumFontBold(context)),
                                                kAppSpacerVertical(height: 5),
                                                state.inCart[foodIndex].discount! <= 0
                                                    ? Text(kAppPriceFormat(state.inCart[foodIndex].price!), style: kAppLblTinyMediumFontSemi(context))
                                                    : Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(kAppPriceFormat(state.inCart[foodIndex].price!), style: kAppLblTinyStrokeFontRegular(context)),
                                                          kAppSpacerHorizontal(width: 5),
                                                          Text(kAppPriceFormat(state.inCart[foodIndex].offerPrice!), style: kAppLblTinyMediumFontSemi(context)),
                                                        ],
                                                      ),
                                                kAppSpacerVertical(height: 5),
                                                state.inCart[foodIndex].optionName!.isNotEmpty
                                                    ? Container(
                                                        padding: const EdgeInsets.only(right: 5),
                                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.8, minWidth: MediaQuery.of(context).size.width / 2.5),
                                                        child: Text(state.inCart[foodIndex].optionName!, maxLines: 4, style: kAppLblTinyFontRegular(context)),
                                                      )
                                                    : const SizedBox(),
                                                state.inCart[foodIndex].containBOGOItem!
                                                    ? Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          kAppSpacerVertical(height: 5),
                                                          Text(translate.contain_free_item_bogo, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                                        ],
                                                      )
                                                    : const SizedBox(),
                                                state.inCart[foodIndex].isBOGOApplied!
                                                    ? Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          kAppSpacerVertical(height: 5),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Icon(Icons.check_circle, size: 10, color: Theme.of(context).primaryColor),
                                                              kAppSpacerHorizontal(width: 5),
                                                              Text(translate.free_item, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
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
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(5),
                                                    border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    mainAxisSize: MainAxisSize.max,
                                                    children: [
                                                      InkWell(
                                                        onTap: () => context.read<CheckoutBloc>().add(CheckoutQuantityEvent(id: state.inCart[foodIndex].id!, uuid: state.inCart[foodIndex].uuid!, action: 'decrease')),
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(right: 15, left: 5),
                                                          child: Icon(Icons.remove, size: 18, color: Theme.of(context).primaryColor),
                                                        ),
                                                      ),
                                                      Text("${state.inCart[foodIndex].quantity!}", style: kAppLblSmallFontBold(context, color: 'primary')),
                                                      InkWell(
                                                        onTap: () => context.read<CheckoutBloc>().add(CheckoutQuantityEvent(id: state.inCart[foodIndex].id!, uuid: state.inCart[foodIndex].uuid!, action: 'increase')),
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 15, right: 5),
                                                          child: Icon(Icons.add, size: 18, color: Theme.of(context).primaryColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                kAppSpacerVertical(height: 5),
                                                state.inCart[foodIndex].totalPrice! > 0
                                                    ? Text(kAppPriceFormat(state.inCart[foodIndex].totalPrice!), style: kAppLblTinyMediumFontSemi(context))
                                                    : Text(translate.free_bogo, style: kAppLblTinyMediumFontSemi(context)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                kAppSpacerVertical(height: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(vertical: 5),
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                isDismissible: false,
                                                enableDrag: false,
                                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                                builder: (BuildContext context) {
                                                  return FractionallySizedBox(heightFactor: 0.7, child: FoodInstructionsModalScreen(instructions: state.foodInstruction));
                                                },
                                              ).then((value) {
                                                if (!context.mounted) return;
                                                if (value != null && value != '') {
                                                  if (value == false || value == 'false') {
                                                    context.read<CheckoutBloc>().add(CheckoutInstructionsEvent(instructions: ''));
                                                  } else {
                                                    context.read<CheckoutBloc>().add(CheckoutInstructionsEvent(instructions: value));
                                                  }
                                                }
                                              });
                                            },
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(Icons.history_edu_outlined, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                                                kAppSpacerHorizontal(width: 10),
                                                Text(state.foodInstruction.isEmpty ? translate.add_cooking_request : translate.cooking_instruction, style: kAppLblMediumFontMedium(context)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    state.foodInstruction.isNotEmpty ? kAppSpacerVertical(height: 5) : const SizedBox(),
                                    state.foodInstruction.isNotEmpty
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(vertical: 3),
                                            padding: const EdgeInsets.symmetric(vertical: 3),
                                            child: Text(state.foodInstruction, style: kAppLblTinyFontRegular(context)),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          state.orderSettings.customer != null &&
                                  state.orderSettings.customer!.id!.isNotEmpty &&
                                  state.orderSettings.customer!.canEarnBuyFromWallet! == true &&
                                  state.orderSettings.wallet != null &&
                                  state.orderSettings.wallet!.id!.isNotEmpty &&
                                  state.orderSettings.wallet!.balance! > 0
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    kAppSpacerVertical(height: 10),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                      ),
                                      child: InkWell(
                                        onTap: () => context.read<CheckoutBloc>().add(CheckoutWalletUseEvent()),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.wallet_rounded, size: 15, color: Theme.of(context).canvasColor),
                                                kAppSpacerHorizontal(width: 10),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(translate.use_wallet_money, style: kAppLblTinyFontBold(context)),
                                                    Text(kAppPriceFormat(state.orderSettings.wallet!.balance!), style: kAppLblTinyFontRegularChip(context)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Icon(state.walletUsed ? Icons.check_box_rounded : Icons.check_box_outline_blank, size: 15, color: state.walletUsed ? Theme.of(context).primaryColor : Theme.of(context).canvasColor),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          kAppSpacerVertical(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                            ),
                            child: state.couponUsed == false
                                ? InkWell(
                                    onTap: () {
                                      if (state.walletUsed == false) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          isDismissible: false,
                                          enableDrag: false,
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(0.0))),
                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                          builder: (BuildContext context) {
                                            return FractionallySizedBox(
                                              heightFactor: 0.9,
                                              child: CouponListModalScreen(
                                                restaurant: state.restaurant,
                                                itemTotal: state.itemTotal,
                                                latitude: state.deliveryLatitude,
                                                longitude: state.deliveryLongitude,
                                                trackingId: state.trackingId,
                                              ),
                                            );
                                          },
                                        ).then((value) {
                                          if (!context.mounted) return;
                                          if (value != null && value != '') {
                                            CouponConfigModel couponData = CouponConfigModel.fromJson(value, state.locale);
                                            context.read<CheckoutBloc>().add(CheckoutCouponCodeResponseEvent(coupon: couponData));
                                          }
                                        });
                                      } else {
                                        context.read<CheckoutBloc>().add(CheckoutCouponValidationErrorEvent());
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(AssetsUrl.iconsURL.couponIcon, height: 15, width: 15, color: Theme.of(context).canvasColor),
                                            kAppSpacerHorizontal(width: 10),
                                            Text(translate.view_all_coupon, style: kAppLblMediumFontBold(context)),
                                          ],
                                        ),
                                        Icon(Icons.keyboard_arrow_right_outlined, size: Theme.of(context).textTheme.bodyMedium?.fontSize, color: Theme.of(context).canvasColor),
                                      ],
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            isDismissible: false,
                                            enableDrag: false,
                                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(0.0))),
                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                            builder: (BuildContext context) {
                                              return FractionallySizedBox(
                                                heightFactor: 0.9,
                                                child: CouponListModalScreen(
                                                  restaurant: state.restaurant,
                                                  itemTotal: state.itemTotal,
                                                  latitude: state.deliveryLatitude,
                                                  longitude: state.deliveryLongitude,
                                                  trackingId: state.trackingId,
                                                ),
                                              );
                                            },
                                          ).then((value) {
                                            if (!context.mounted) return;
                                            if (value != null && value != '') {
                                              CouponConfigModel couponData = CouponConfigModel.fromJson(value, state.locale);
                                              context.read<CheckoutBloc>().add(CheckoutCouponCodeResponseEvent(coupon: couponData));
                                            }
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.check_circle, size: 15, color: Theme.of(context).primaryColor),
                                            kAppSpacerHorizontal(width: 10),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(state.couponTitle, style: kAppLblTinyFontBold(context)),
                                                Text(translate.view_all_coupon, style: kAppLblTinyFontRegularChip(context)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => context.read<CheckoutBloc>().add(CheckoutRemoveCouponEvent()),
                                        child: Text(translate.remove, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                      ),
                                    ],
                                  ),
                          ),
                          kAppSpacerVertical(height: 10),
                          state.deliveryAddressId.isNotEmpty && state.orderSettings.address!.id!.isNotEmpty && state.orderTo == 'homedelivery'
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        padding: const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(AssetsUrl.iconsURL.timeTag, height: 15, width: 15, color: Theme.of(context).canvasColor),
                                            kAppSpacerHorizontal(width: 10),
                                            Text(translate.delivery_in, style: kAppLblMediumFontMedium(context)),
                                            Text(" - ", style: kAppLblMediumFontMedium(context)),
                                            Text(kAppDeliveryTimeName(context, state.orderSettings.restaurant!.approxDeliveryTime!), style: kAppLblMediumFontBold(context)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        padding: const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                                        ),
                                        child: InkWell(
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
                                                  child: DeliveryAddressListModalScreen(deliveryArea: state.orderSettings.business!.deliveryArea!, restaurant: state.restaurant, deliveryAddressId: state.deliveryAddressId),
                                                );
                                              },
                                            ).then((value) {
                                              if (!context.mounted) return;
                                              if (value != null && value != '') {
                                                DeliveryAddressModalResponseModel savedData = DeliveryAddressModalResponseModel.fromJson(value);
                                                context.read<CheckoutBloc>().add(CheckoutDeliveryAddressChangeEvent(selected: savedData));
                                              }
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    kAppAddressTitleIcon(context, state.orderSettings.address!.title!, 15, 15),
                                                    kAppSpacerHorizontal(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Flexible(child: Text(translate.delivery_at, style: kAppLblMediumFontMedium(context), overflow: TextOverflow.ellipsis)),
                                                              Text(" ", style: kAppLblMediumFontMedium(context)),
                                                              Flexible(child: Text(kAppAddressTitle(context, int.parse(state.addressTitle)), style: kAppLblMediumFontBold(context), overflow: TextOverflow.ellipsis)),
                                                            ],
                                                          ),
                                                          Text(state.addressSubTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(Icons.keyboard_arrow_right_outlined, size: Theme.of(context).textTheme.bodyMedium?.fontSize, color: Theme.of(context).canvasColor),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Coverage warning (Batch G-3): advisory banner when the
                                      // kitchen cannot serve the picked pin. createOrder
                                      // still enforces — this only warns early.
                                      state.coversRestaurant == false
                                          ? Container(
                                              width: MediaQuery.of(context).size.width,
                                              margin: const EdgeInsets.symmetric(vertical: 5),
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0),
                                                border: Border.all(color: Colors.red, width: 1.5),
                                              ),
                                              child: Text(
                                                translate.restaurantNotCovered,
                                                style: kAppLblTinyFontRegular(context),
                                              ),
                                            )
                                          : const SizedBox(),
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        padding: const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                                        ),
                                        child: InkWell(
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
                                                  child: DeliveryInstructionModalScreen(
                                                    deliveryInstructionId: state.deliveryInstructionId,
                                                    deliveryInstructionList: jsonEncode(state.orderSettings.instruction!).toString(),
                                                    addressTitle: kAppAddressTitle(context, int.parse(state.addressTitle)),
                                                    addressSubtitle: state.addressSubTitle,
                                                  ),
                                                );
                                              },
                                            ).then((value) {
                                              if (!context.mounted) return;
                                              if (value != null && value != '') {
                                                if (value == false || value == 'false') {
                                                  context.read<CheckoutBloc>().add(CheckoutDeliveryInstructionClearEvent());
                                                } else {
                                                  DeliveryInstructionModalResponseModel instructionData = DeliveryInstructionModalResponseModel.fromJson(value);
                                                  if (instructionData.id != null && instructionData.name != null) {
                                                    context.read<CheckoutBloc>().add(CheckoutDeliveryInstructionChangeEvent(data: instructionData));
                                                  }
                                                }
                                              }
                                            });
                                          },
                                          child: state.deliveryInstructionId.isNotEmpty
                                              ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(5),
                                                          child: CacheNetworkImageWidget(width: 15, height: 15.0, imageUrl: state.deliveryInstructionImage),
                                                        ),
                                                        kAppSpacerHorizontal(width: 10),
                                                        Text(kAppTrimWord(state.deliveryInstruction, 30), style: kAppLblMediumFontBold(context)),
                                                      ],
                                                    ),
                                                    Icon(Icons.edit_square, size: Theme.of(context).textTheme.bodyMedium?.fontSize, color: Theme.of(context).canvasColor),
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Icon(Icons.history_edu_outlined, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                                                        kAppSpacerHorizontal(width: 10),
                                                        state.deliveryInstruction.isEmpty ? Text(translate.add_delivery_instruction, style: kAppLblMediumFontMedium(context)) : const SizedBox(),
                                                      ],
                                                    ),
                                                    Icon(Icons.keyboard_arrow_right_outlined, size: Theme.of(context).textTheme.bodyMedium?.fontSize, color: Theme.of(context).canvasColor),
                                                  ],
                                                ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        padding: const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                                        ),
                                        child: InkWell(
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
                                                  child: ChangeReceiverInfoModalScreen(
                                                    orderTo: state.orderTo,
                                                    addressTitle: isNumbericAddressTitle(state.addressTitle) ? kAppAddressTitle(context, int.parse(state.addressTitle.toString())) : state.addressTitle,
                                                    addressSubtitle: state.addressSubTitle,
                                                    receiverName: state.receiverName,
                                                    receiverCountryCode: state.receiverCountryCode,
                                                    receiverPhoneNumber: state.receiverContact,
                                                  ),
                                                );
                                              },
                                            ).then((value) {
                                              if (!context.mounted) return;
                                              if (value != null && value != '') {
                                                ReceiverModalResponseModel newReceiverInfo = ReceiverModalResponseModel.fromJson(value);
                                                if (newReceiverInfo.name!.isNotEmpty && newReceiverInfo.countryCode!.isNotEmpty && newReceiverInfo.phoneNumber!.isNotEmpty) {
                                                  context.read<CheckoutBloc>().add(CheckoutReceiverChangeEvent(name: newReceiverInfo.name!, countryCode: newReceiverInfo.countryCode!, phoneNumber: newReceiverInfo.phoneNumber!));
                                                }
                                              }
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(AssetsUrl.iconsURL.phoneCallIcon, height: 15, width: 15, color: Theme.of(context).canvasColor),
                                                  kAppSpacerHorizontal(width: 10),
                                                  Text(state.receiverName, style: kAppLblMediumFontMedium(context)),
                                                  Text(",", style: kAppLblMediumFontMedium(context)),
                                                  Text("+${state.receiverCountryCode}-${state.receiverContact}", style: kAppLblMediumFontBold(context)),
                                                ],
                                              ),
                                              Icon(Icons.keyboard_arrow_right_outlined, size: Theme.of(context).textTheme.bodyMedium?.fontSize, color: Theme.of(context).canvasColor),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          state.orderTo == 'selfpickup' && state.receiverName.isNotEmpty && state.receiverContact.isNotEmpty
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        padding: const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                                        ),
                                        child: InkWell(
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
                                                  child: ChangeReceiverInfoModalScreen(
                                                    orderTo: state.orderTo,
                                                    addressTitle: isNumbericAddressTitle(state.addressTitle) ? kAppAddressTitle(context, int.parse(state.addressTitle.toString())) : state.addressTitle,
                                                    addressSubtitle: state.addressSubTitle,
                                                    receiverName: state.receiverName,
                                                    receiverCountryCode: state.receiverCountryCode,
                                                    receiverPhoneNumber: state.receiverContact,
                                                  ),
                                                );
                                              },
                                            ).then((value) {
                                              if (!context.mounted) return;
                                              if (value != null && value != '') {
                                                ReceiverModalResponseModel newReceiverInfo = ReceiverModalResponseModel.fromJson(value);
                                                if (newReceiverInfo.name!.isNotEmpty && newReceiverInfo.countryCode!.isNotEmpty && newReceiverInfo.phoneNumber!.isNotEmpty) {
                                                  context.read<CheckoutBloc>().add(CheckoutReceiverChangeEvent(name: newReceiverInfo.name!, countryCode: newReceiverInfo.countryCode!, phoneNumber: newReceiverInfo.phoneNumber!));
                                                }
                                              }
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(AssetsUrl.iconsURL.phoneCallIcon, height: 15, width: 15, color: Theme.of(context).canvasColor),
                                                  kAppSpacerHorizontal(width: 10),
                                                  Text(state.receiverName, style: kAppLblMediumFontMedium(context)),
                                                  Text(",", style: kAppLblMediumFontMedium(context)),
                                                  Text("+${state.receiverCountryCode}-${state.receiverContact}", style: kAppLblMediumFontBold(context)),
                                                ],
                                              ),
                                              Icon(Icons.keyboard_arrow_right_outlined, size: Theme.of(context).textTheme.bodyMedium?.fontSize, color: Theme.of(context).canvasColor),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
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
                                      child: BillingSummaryModalScreen(
                                        orderTo: state.orderTo,
                                        realTotal: state.realPrice,
                                        itemTotal: state.itemTotal,
                                        itemDiscount: state.itemDiscount,
                                        couponDiscount: state.couponDiscount,
                                        couponCode: state.couponUsed && state.couponData.id!.isNotEmpty ? state.couponData.code! : '',
                                        walletAmount: state.walletAmount,
                                        serviceCharge: state.serviceCharge,
                                        serviceChargeName: state.serviceChargeName,
                                        foodServiceCharge: state.foodServiceCharge,
                                        foodServiceChargeName: state.foodServiceChargeName,
                                        deliveryGratitude: jsonEncode(state.orderSettings.gratitudes!).toString(),
                                        deliveryTip: state.deliveryTip,
                                        extraCharge: state.extraCharge,
                                        deliveryCharge: state.deliveryCharge,
                                        packagingCharges: state.packagingCharges,
                                        packagingChargesTax: state.packagingChargesTax,
                                        grandTotal: state.grandTotal,
                                      ),
                                    );
                                  },
                                ).then((value) {
                                  if (!context.mounted) return;
                                  if (value != null && value != '') {
                                    context.read<CheckoutBloc>().add(CheckoutBillingInfoExtraChargeEvent(deliveryTip: double.parse(value.toString())));
                                  }
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(AssetsUrl.iconsURL.billIcon, height: 15, width: 15, color: Theme.of(context).canvasColor),
                                      kAppSpacerHorizontal(width: 10),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(translate.total_bill, style: kAppLblMediumFontMedium(context)),
                                              Text(" ", style: kAppLblMediumFontMedium(context)),
                                              Text(kAppPriceFormat(state.grandTotal), style: kAppLblMediumFontBold(context)),
                                            ],
                                          ),
                                          Text(translate.tax_charge_incl, style: kAppLblTinyFontRegular(context)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.keyboard_arrow_right_outlined, size: Theme.of(context).textTheme.bodyMedium?.fontSize, color: Theme.of(context).canvasColor),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: SizedBox(
                height: 110,
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
                      ] else if (state.isMinAmountSatisfied && state.deliveryAddressId.isNotEmpty && state.orderSettings.address!.id!.isNotEmpty && state.orderTo == 'homedelivery' && state.canDeliverNow == true) ...[
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
                                  Text(state.paymentName == 'Online Payment' ? translate.pay_online : state.paymentName, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblMediumFontRegular(context)),
                                  Text(translate.pay_methods_hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                ],
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                            Expanded(
                              flex: 3,
                              child: InkWell(
                                onTap: () => context.read<CheckoutBloc>().add(CheckoutCreateOrderEvent()),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                  width: double.infinity,
                                  height: 60.0,
                                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                                  child: state.status.isPlacingOrder
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
                                                    Text(translate.place_order, style: kAppLblMediumFontSemiBoldWhite(context)),
                                                    Icon(Icons.arrow_right, color: Theme.of(context).scaffoldBackgroundColor, size: 14),
                                                  ],
                                                ),
                                                kAppSpacerVertical(height: 3),
                                                Text(state.scheduleOrder == true ? translate.schedule_order : translate.instant_order, textAlign: TextAlign.end, style: kAppLblTinyFontBoldCart(context)),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (state.canDeliverNow == false && !state.permissionList.contains('schedule')) ...[
                        Center(child: Text(translate.restaurant_open_soon, style: kAppLblMediumFontBold(context))),
                      ] else if (state.canDeliverNow == false && state.permissionList.contains('schedule')) ...[
                        Center(child: Text(translate.restaurant_schedule_order, style: kAppLblMediumFontBold(context))),
                      ] else if (state.isMinAmountSatisfied && state.orderTo == 'selfpickup' && state.canDeliverNow == true && state.receiverName.isNotEmpty && state.receiverContact.isNotEmpty) ...[
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
                                  Text(state.paymentName == 'Online Payment' ? translate.pay_online : state.paymentName, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblMediumFontRegular(context)),
                                  Text(translate.pay_methods_hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                ],
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                            Expanded(
                              flex: 3,
                              child: InkWell(
                                onTap: () => context.read<CheckoutBloc>().add(CheckoutCreateOrderEvent()),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                                  child: state.status.isPlacingOrder
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
                                                    Text(translate.place_order, style: kAppLblMediumFontSemiBoldWhite(context)),
                                                    Icon(Icons.arrow_right, color: Theme.of(context).scaffoldBackgroundColor, size: 14),
                                                  ],
                                                ),
                                                kAppSpacerVertical(height: 3),
                                                Text(state.scheduleOrder == true ? translate.schedule_order : translate.instant_order, textAlign: TextAlign.end, style: kAppLblTinyFontBoldCart(context)),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (state.canDeliverNow == true && state.deliveryAddressId.isEmpty && state.orderTo == 'homedelivery') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          width: double.infinity,
                          height: 40.0,
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                          child: InkWell(
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
                                    child: DeliveryAddressListModalScreen(deliveryArea: state.orderSettings.business!.deliveryArea!, restaurant: state.restaurant, deliveryAddressId: state.deliveryAddressId),
                                  );
                                },
                              ).then((value) {
                                if (!context.mounted) return;
                                if (value != null && value != '') {
                                  DeliveryAddressModalResponseModel savedData = DeliveryAddressModalResponseModel.fromJson(value);
                                  context.read<CheckoutBloc>().add(CheckoutDeliveryAddressChangeEvent(selected: savedData));
                                }
                              });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(translate.select_address_for_next_step, style: kAppLblMediumFontSemiBoldWhite(context)),
                                Icon(Icons.arrow_right, color: Theme.of(context).scaffoldBackgroundColor, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ] else if (state.isMinAmountSatisfied && state.orderTo == 'selfpickup' && state.canDeliverNow == true && state.receiverName.isEmpty && state.receiverContact.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          width: double.infinity,
                          height: 40.0,
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                          child: InkWell(
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
                                    child: ChangeReceiverInfoModalScreen(
                                      orderTo: state.orderTo,
                                      addressTitle: isNumbericAddressTitle(state.addressTitle) ? kAppAddressTitle(context, int.parse(state.addressTitle.toString())) : state.addressTitle,
                                      addressSubtitle: state.addressSubTitle,
                                      receiverName: state.receiverName,
                                      receiverCountryCode: state.receiverCountryCode,
                                      receiverPhoneNumber: state.receiverContact,
                                    ),
                                  );
                                },
                              ).then((value) {
                                if (!context.mounted) return;
                                if (value != null && value != '') {
                                  ReceiverModalResponseModel newReceiverInfo = ReceiverModalResponseModel.fromJson(value);
                                  if (newReceiverInfo.name!.isNotEmpty && newReceiverInfo.countryCode!.isNotEmpty && newReceiverInfo.phoneNumber!.isNotEmpty) {
                                    context.read<CheckoutBloc>().add(CheckoutReceiverChangeEvent(name: newReceiverInfo.name!, countryCode: newReceiverInfo.countryCode!, phoneNumber: newReceiverInfo.phoneNumber!));
                                  }
                                }
                              });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(translate.contact_information, style: kAppLblMediumFontSemiBoldWhite(context)),
                                Icon(Icons.arrow_right, color: Theme.of(context).scaffoldBackgroundColor, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ] else if (state.itemTotal < state.orderSettings.restaurant!.minOrderAmount!) ...[
                        Text("${translate.min_order_amount_note} ${kAppPriceFormat(state.orderSettings.restaurant!.minOrderAmount!)} ${translate.min_order_amount_note_required}", style: kAppLblMediumFontBold(context)),
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

class CheckoutLoadingView extends StatelessWidget {
  const CheckoutLoadingView({super.key});

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
      ),
    );
  }
}

class CheckoutErrorView extends StatelessWidget {
  const CheckoutErrorView({super.key});

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
            Text(translate.checkout_error, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          ],
        ),
      ),
    );
  }
}

class CheckoutEmptyView extends StatelessWidget {
  const CheckoutEmptyView({super.key});

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
            Text(translate.checkout_error, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          ],
        ),
      ),
    );
  }
}
// Done //
