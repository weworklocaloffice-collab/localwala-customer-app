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
import 'package:url_launcher/url_launcher.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/purchased_tiffin_subscription_info_response_model.dart';
import 'package:user/app/presentation/pages/account/food_subscription_list/purchased_food_subscription_info/bloc/purchased_food_subscription_info_bloc.dart';
import 'package:user/app/presentation/pages/modals/tiffin_subscription_cancellation_reason_list_modal/tiffin_subscription_cancellation_reason_list_modal_view.dart';
import 'package:user/app/presentation/pages/modals/tiffin_subscription_package_help_modal/tiffin_subscription_package_help_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class PurchasedFoodSubscriptionInfoScreen extends StatelessWidget {
  final String purchaseId;
  const PurchasedFoodSubscriptionInfoScreen({super.key, required this.purchaseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PurchasedFoodSubscriptionInfoBloc()..add(PurchasedFoodSubscriptionInfoInitialEvent(purchaseId: purchaseId)),
      child: const PurchasedFoodSubscriptionInfoView(),
    );
  }
}

class PurchasedFoodSubscriptionInfoView extends StatelessWidget {
  const PurchasedFoodSubscriptionInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<PurchasedFoodSubscriptionInfoBloc, PurchasedFoodSubscriptionInfoState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isRepaySubscriptionFailed) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isRepaySubscriptionSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.makeSubscriptionTiffinPackagePaymentRoute, (Route<dynamic> route) => false, arguments: [state.paymentURL]);
        } else if (state.status.isCancelSuccess) {
          Navigator.of(context).pop({"type": "refresh", "value": "hard"});
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isRepaySubscriptionRequested || state.status.isCancelRequested ? true : false,
          child: Scaffold(
            appBar: AppBar(
              title: Text(translate.purchase_history),
              scrolledUnderElevation: 0,
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRouter.supportChatRoute, arguments: ['tiffin_subscription', state.purchaseId]),
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
                          child: TiffinSubscriptionPackageHelpModalScreen(
                            purchaseId: state.purchaseId,
                            purchaseStatus: state.info.details!.status!,
                            subscriptionPackage: state.info.details!.package!.id!,
                            restaurant: state.info.details!.restaurant!.id!,
                            payment: state.info.details!.paymentInfo!.id!,
                            refundRequestEnable: state.info.businessSettings!.refundRequest!,
                            requestedOffDates: state.info.details!.requestedOffDates!,
                            offDays: state.info.details!.offDays!,
                            totalOrders: state.info.details!.totalOrder!,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const PurchasedFoodSubscriptionInfoLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const PurchasedFoodSubscriptionInfoErrorView(),
                  ] else ...[
                    PurchasedFoodSubscriptionInfoResponseView(model: state.info, callRestaurant: state.callRestaurant!),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: SizedBox(
                height: state.status.isSuccess || state.status.isCancelRequested || state.status.isCancelFailed || state.status.isRepaySubscriptionRequested || state.status.isRepaySubscriptionFailed ? 80 : 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.status.isSuccess || state.status.isCancelRequested || state.status.isCancelFailed) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.info.details!.status! == 'created' && state.info.orderSettings!.userCanCancelTiffinSubscriptionPackage!) ...[
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
                                              return const FractionallySizedBox(heightFactor: 0.7, child: TiffinSubscriptionCancellationReasonListModalScreen());
                                            },
                                          ).then((value) {
                                            if (!context.mounted) return;
                                            if (value != null && value.toString().isNotEmpty) {
                                              context.read<PurchasedFoodSubscriptionInfoBloc>().add(PurchasedFoodSubscriptionInfoCancelPackageEvent(reasonId: value.toString()));
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
                                        child: state.status.isCancelRequested ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.cancel_subscription),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [Text(kAppTiffinPackageStatus(context, state.statusName!), style: kAppLblSmallFontRegular(context))],
                              ),
                            ],
                          ],
                        ),
                      ] else if (state.status.isSuccess || state.status.isRepaySubscriptionRequested || state.status.isRepaySubscriptionFailed) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.info.details!.status! == 'pending_payments' && state.isPendingPaymentTimeOver == false) ...[
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
                                    child: InkWell(
                                      onTap: () => context.read<PurchasedFoodSubscriptionInfoBloc>().add(PurchasedFoodSubscriptionInfoRepayPackageEvent()),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                        width: double.infinity,
                                        height: 60.0,
                                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                                        child: state.status.isRepaySubscriptionRequested
                                            ? Center(child: kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0))
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(kAppPriceFormat(double.parse(state.info.details!.grandTotal!.toString())), style: kAppLblMediumFontSemiBoldWhite(context)),
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
                            ] else if (state.info.details!.status! == 'pending_payments' && state.isPendingPaymentTimeOver == true) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [Text(translate.order_was_incomplete_due_to_pending_payment, style: kAppLblSmallFontRegular(context))],
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

class PurchasedFoodSubscriptionInfoResponseView extends StatelessWidget {
  final PurchasedTiffinSubscriptionPackageInfoResponseModel model;
  final bool callRestaurant;
  const PurchasedFoodSubscriptionInfoResponseView({super.key, required this.model, required this.callRestaurant});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: ThemeProvider.scaffoldPadding, right: ThemeProvider.scaffoldPadding, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${translate.offer_by} : ${model.details!.restaurant!.name!}", style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(model.details!.package!.name!, style: kAppLblMediumFontBold(context)),
          Text(model.details!.package!.shortDescription!, style: kAppLblTinyFontRegular(context)),
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
          BillingInfoTile(name: translate.subscription_charge, priceTag: '+', price: model.details!.itemTotal!),
          BillingInfoTile(name: translate.food_service_charge, priceTag: '+', price: model.details!.foodServiceCharge!),
          BillingInfoTile(name: translate.service_charge, priceTag: '+', price: model.details!.serviceCharge!),
          BillingInfoTile(name: translate.extra_service_charge, priceTag: '+', price: model.details!.extraCharge!),
          BillingInfoTile(name: translate.package_charge, priceTag: '+', price: model.details!.packageCharge!),
          BillingInfoTile(name: translate.package_charge_tax, priceTag: '+', price: model.details!.packageChargeTax!),
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
          Text(translate.purchase_details, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(translate.purchase_id, style: kAppLblBoldFont(context)),
              Text(model.details!.id!.toUpperCase(), style: kAppLblBoldFont(context)),
            ],
          ),
          kAppSpacerVertical(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(translate.subscription_started, style: kAppLblBoldFont(context)),
              Text(model.details!.startDate!.toUpperCase(), style: kAppLblBoldFont(context)),
            ],
          ),
          kAppSpacerVertical(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(translate.subscription_model, style: kAppLblBoldFont(context)),
              Text(model.details!.orderTo! == 'homedelivery' ? translate.home_delivery : translate.take_away, style: kAppLblBoldFont(context)),
            ],
          ),
          kAppSpacerVertical(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(translate.subscription_slot, style: kAppLblBoldFont(context)),
              Text("${model.details!.slot!.toUpperCase()} (${model.details!.orderAt!.toUpperCase()})", style: kAppLblBoldFont(context)),
            ],
          ),
          kAppSpacerVertical(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(translate.subscription_off_days, style: kAppLblBoldFont(context)),
              Text(model.details!.offDayName!.toUpperCase(), style: kAppLblBoldFont(context)),
            ],
          ),
          kAppSpacerVertical(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(translate.payment, style: kAppLblBoldFont(context)),
              Text("${model.details!.paymentInfo!.name!} (${kAppPriceFormat(model.details!.grandTotal!)})", style: kAppLblBoldFont(context)),
            ],
          ),
          kAppSpacerVertical(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(translate.receiver, style: kAppLblBoldFont(context)),
              Text(model.details!.orderTo! == 'homedelivery' ? '${model.details!.receiverName!} (+${model.details!.countryCode!} ${model.details!.receiverContact})' : translate.self_pickup, style: kAppLblBoldFont(context)),
            ],
          ),
          model.details!.orderTo! == 'homedelivery' ? kAppSpacerVertical(height: 10) : const SizedBox(),
          model.details!.orderTo! == 'homedelivery'
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translate.deliver_to, style: kAppLblBoldFont(context)),
                    Text(
                      '${kAppAddressTitle(context, model.details!.deliveryAddress!.title!)} - ${model.details!.deliveryAddress!.flatHouse!}, ${model.details!.deliveryAddress!.locality!}, ${model.details!.deliveryAddress!.landmark!}',
                      style: kAppLblBoldFont(context),
                    ),
                  ],
                )
              : const SizedBox(),
          model.details!.cookingInstruction!.isNotEmpty ? kAppSpacerVertical(height: 10) : const SizedBox(),
          model.details!.cookingInstruction!.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translate.cooking_instruction, style: kAppLblBoldFont(context)),
                    Text(model.details!.cookingInstruction!, style: kAppLblBoldFont(context)),
                  ],
                )
              : const SizedBox(),
          model.details!.deliveryInstructionInfo!.name!.isNotEmpty ? kAppSpacerVertical(height: 10) : const SizedBox(),
          model.details!.deliveryInstructionInfo!.name!.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translate.delivery_instruction, style: kAppLblBoldFont(context)),
                    Text(model.details!.deliveryInstructionInfo!.name!, style: kAppLblBoldFont(context)),
                  ],
                )
              : const SizedBox(),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.only(bottom: 10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
            ),
            child: const Text(""),
          ),
          kAppSpacerVertical(height: 10),
          InkWell(
            onTap: () => context.read<PurchasedFoodSubscriptionInfoBloc>().add(PurchasedFoodSubscriptionInfoCallRestaurantEvent()),
            child: callRestaurant
                ? SizedBox(height: 15.0, width: 15.0, child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 3))
                : Text("${translate.call} ${model.details!.restaurant!.name!} (+${model.restUserInfo!.countryCode!} ${model.restUserInfo!.mobile!})", style: kAppLblMediumFontBold(context, color: 'primary')),
          ),
          kAppSpacerVertical(height: 30),
          Text(model.details!.restaurant!.name!, style: kAppLblMediumFontRegular(context)),
          kAppSpacerVertical(height: 5),
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

class PurchasedFoodSubscriptionInfoLoadingView extends StatelessWidget {
  const PurchasedFoodSubscriptionInfoLoadingView({super.key});

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

class PurchasedFoodSubscriptionInfoErrorView extends StatelessWidget {
  const PurchasedFoodSubscriptionInfoErrorView({super.key});

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
// Done //
