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
import 'package:user/app/core/models/buy_subscription_tiffin_package_response_model.dart';
import 'package:user/app/core/models/delivery_address_modal_response_model.dart';
import 'package:user/app/core/models/delivery_instruction_modal_response_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/receiver_modal_response_model.dart';
import 'package:user/app/presentation/pages/home/food_subcriptions_info/buy_subscription_package/bloc/buy_subscription_package_bloc.dart';
import 'package:user/app/presentation/pages/modals/change_receiver_info_modal/change_receiver_info_modal_view.dart';
import 'package:user/app/presentation/pages/modals/delivery_address_list_modal/delivery_address_list_modal_view.dart';
import 'package:user/app/presentation/pages/modals/delivery_instructions_modal/delivery_instructions_modal_view.dart';
import 'package:user/app/presentation/pages/modals/food_instructions_modal/food_instructions_modal_view.dart';
import 'package:user/app/presentation/pages/modals/food_subscription_package_billing_summary_modal/food_subscription_package_billing_summary_modal_view.dart';
import 'package:user/app/presentation/pages/modals/subscription_food_info_modal/subscription_food_info_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class BuySubscriptionPackageScreen extends StatelessWidget {
  final String id;
  const BuySubscriptionPackageScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BuySubscriptionPackageBloc()..add(BuySubscriptionPackageInitialEvent(id: id)),
      child: const BuySubscriptionPackageView(),
    );
  }
}

class BuySubscriptionPackageView extends StatelessWidget {
  const BuySubscriptionPackageView({super.key});

  bool isNumbericAddressTitle(String value) {
    if (value.isEmpty) return false;
    return num.tryParse(value) != null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<BuySubscriptionPackageBloc, BuySubscriptionPackageState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isMakePayment) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.makeSubscriptionTiffinPackagePaymentRoute, (Route<dynamic> route) => false, arguments: [state.paymentURL]);
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isPlacingOrder ? true : false,
          child: Scaffold(
            appBar: AppBar(title: Text(translate.buy_subscription), scrolledUnderElevation: 0),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const BuySubscriptionPackageLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const BuySubscriptionPackageErroView(),
                  ] else ...[
                    Text(state.info.details!.name!, style: kAppLblMediumFontBold(context)),
                    kAppSpacerVertical(height: 5),
                    Text(state.info.details!.shortDescription!, style: kAppLblTinyFontRegular(context)),
                    kAppSpacerVertical(height: 20),
                    state.info.details!.discount! <= 0
                        ? Text(kAppPriceFormat(state.info.details!.price!), style: kAppLblTinyMediumFontSemi(context))
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(kAppPriceFormat(state.info.details!.price!), style: kAppLblTinyStrokeFontRegular(context)),
                              kAppSpacerHorizontal(width: 5),
                              Text(kAppPriceFormat(state.info.details!.offerPrice!), style: kAppLblTinyMediumFontSemi(context)),
                            ],
                          ),
                    kAppSpacerVertical(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(translate.availability, style: kAppLblTinyFontRegular(context)),
                        kAppSpacerHorizontal(width: 10),
                        Text(kAppTiffinKind(context, state.info.details!.available!), style: kAppLblTinyFontBold(context)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(translate.validity, style: kAppLblTinyFontRegular(context)),
                        kAppSpacerHorizontal(width: 10),
                        Text("${state.info.details!.totalOrder!} ${translate.days}", style: kAppLblTinyFontBold(context)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(translate.support, style: kAppLblTinyFontRegular(context)),
                        kAppSpacerHorizontal(width: 10),
                        Text(
                          '${state.info.details!.orderTo! == 'homedelivery' ? translate.home_delivery : translate.take_away}${state.info.details!.orderTo! == 'homedelivery' ? ' (${state.info.details!.deliveryArea} ${state.info.findMode!.toUpperCase()})' : ''}',
                          style: kAppLblTinyFontBold(context),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(translate.off_day_week, style: kAppLblTinyFontRegular(context)),
                        kAppSpacerHorizontal(width: 10),
                        Text(state.info.details!.offDayName!, style: kAppLblTinyFontBold(context)),
                      ],
                    ),
                    kAppSpacerVertical(height: 20),
                    Text(translate.schedule_delivery_time, style: kAppLblMediumFontBold(context)),
                    kAppSpacerVertical(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: state.info.details!.timeSlots!
                            .map(
                              (e) => InkWell(
                                onTap: () => context.read<BuySubscriptionPackageBloc>().add(BuySubscriptionPackageSlotSelectEvent(slot: '${e.startTime!} - ${e.endTime!}')),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  margin: const EdgeInsets.only(left: 5),
                                  decoration: BoxDecoration(
                                    color: state.savedSlot == '${e.startTime!} - ${e.endTime!}' ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                  ),
                                  child: Text(
                                    "${e.displayStartTime!} - ${e.displayEndTime!}",
                                    style: state.savedSlot == '${e.startTime!} - ${e.endTime!}' ? kAppLblMediumFontSemiBoldWhite(context) : kAppLblMediumFontSemiBold(context),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    kAppSpacerVertical(height: 20),
                    Text(translate.food_included, style: kAppLblMediumFontBold(context)),
                    kAppSpacerVertical(height: 10),
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 230),
                      scrollDirection: Axis.vertical,
                      key: UniqueKey(),
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 230,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                            child: BuySubscriptionsInfoFoodInfoBlock(
                              model: state.info.foods![index],
                              canAddAddons: state.info.details!.canSelectAddon!,
                              canAddVariations: state.info.details!.canSelectVariation!,
                              totalOrders: state.info.details!.totalOrder!,
                              inCart: state.inCart,
                              appLocale: state.appLocale,
                            ),
                          ),
                        );
                      },
                      itemCount: state.info.foods!.length,
                    ),
                    kAppSpacerVertical(height: 20),
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
                                        context.read<BuySubscriptionPackageBloc>().add(BuySubscriptionPackageInstructionsEvent(instructions: ''));
                                      } else {
                                        context.read<BuySubscriptionPackageBloc>().add(BuySubscriptionPackageInstructionsEvent(instructions: value));
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
                    kAppSpacerVertical(height: 10),
                    state.deliveryAddressId.isNotEmpty && state.info.details!.orderTo! == 'homedelivery'
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
                                            heightFactor: 0.7,
                                            child: DeliveryAddressListModalScreen(deliveryArea: state.info.details!.deliveryArea!, restaurant: state.info.details!.restaurants!.id!, deliveryAddressId: state.deliveryAddressId),
                                          );
                                        },
                                      ).then((value) {
                                        if (!context.mounted) return;
                                        if (value != null && value != '') {
                                          DeliveryAddressModalResponseModel savedData = DeliveryAddressModalResponseModel.fromJson(value);
                                          context.read<BuySubscriptionPackageBloc>().add(BuySubscriptionPackageDeliveryAddressChangeEvent(selected: savedData));
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
                                            kAppAddressTitleIcon(context, state.addressTitleNumber, 15, 15),
                                            kAppSpacerHorizontal(width: 10),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(translate.delivery_at, style: kAppLblMediumFontMedium(context)),
                                                    Text(" ", style: kAppLblMediumFontMedium(context)),
                                                    Text(kAppAddressTitle(context, int.parse(state.addressTitle.toString())), style: kAppLblMediumFontBold(context)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width / 1.3,
                                                  child: Text(state.addressSubTitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                                ),
                                              ],
                                            ),
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
                                            heightFactor: 0.7,
                                            child: DeliveryInstructionModalScreen(
                                              deliveryInstructionId: state.deliveryInstructionId,
                                              deliveryInstructionList: jsonEncode(state.info.instruction!).toString(),
                                              addressTitle: kAppAddressTitle(context, int.parse(state.addressTitle.toString())),
                                              addressSubtitle: state.addressSubTitle,
                                            ),
                                          );
                                        },
                                      ).then((value) {
                                        if (!context.mounted) return;
                                        if (value != null && value != '') {
                                          if (value == false || value == 'false') {
                                            context.read<BuySubscriptionPackageBloc>().add(BuySubscriptionPackageDeliveryInstructionClearEvent());
                                          } else {
                                            DeliveryInstructionModalResponseModel instructionData = DeliveryInstructionModalResponseModel.fromJson(value);
                                            if (instructionData.id != null && instructionData.name != null) {
                                              context.read<BuySubscriptionPackageBloc>().add(BuySubscriptionPackageDeliveryInstructionChangeEvent(data: instructionData));
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
                                              orderTo: state.info.details!.orderTo!,
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
                                            context.read<BuySubscriptionPackageBloc>().add(
                                              BuySubscriptionPackageReceiverChangeEvent(name: newReceiverInfo.name!, countryCode: newReceiverInfo.countryCode!, phoneNumber: newReceiverInfo.phoneNumber!),
                                            );
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
                                            child: FoodSubscriptionPackageBillingSummaryModalView(
                                              totalOrders: state.info.details!.totalOrder!,
                                              itemTotal: state.itemTotal,
                                              serviceCharge: state.serviceCharge,
                                              foodServiceCharge: state.foodServiceCharge,
                                              extraCharge: state.extraCharge,
                                              packagingCharges: state.packagingCharges,
                                              packagingChargesTax: state.packagingChargesTax,
                                              grandTotal: state.grandTotal,
                                            ),
                                          );
                                        },
                                      );
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
                          )
                        : const SizedBox(),
                    state.info.details!.orderTo! == 'selfpickup'
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
                                state.receiverContact.isNotEmpty && state.receiverName.isNotEmpty
                                    ? Container(
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
                                                    orderTo: state.info.details!.orderTo!,
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
                                                  context.read<BuySubscriptionPackageBloc>().add(
                                                    BuySubscriptionPackageReceiverChangeEvent(name: newReceiverInfo.name!, countryCode: newReceiverInfo.countryCode!, phoneNumber: newReceiverInfo.phoneNumber!),
                                                  );
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
                                            child: FoodSubscriptionPackageBillingSummaryModalView(
                                              totalOrders: state.info.details!.totalOrder!,
                                              itemTotal: state.itemTotal,
                                              serviceCharge: state.serviceCharge,
                                              foodServiceCharge: state.foodServiceCharge,
                                              extraCharge: state.extraCharge,
                                              packagingCharges: state.packagingCharges,
                                              packagingChargesTax: state.packagingChargesTax,
                                              grandTotal: state.grandTotal,
                                            ),
                                          );
                                        },
                                      );
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
                          )
                        : const SizedBox(),
                    Text(translate.terms_and_conditions, style: kAppLblMediumFontBold(context)),
                    kAppSpacerVertical(height: 20),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      margin: const EdgeInsets.only(bottom: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: state.info.details!.notice!.map((item) {
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
                      ] else if (state.deliveryAddressId.isNotEmpty && state.info.details!.orderTo! == 'homedelivery' && state.savedSlot.isNotEmpty) ...[
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
                                onTap: () => context.read<BuySubscriptionPackageBloc>().add(BuySubscriptionPackageCreateOrderEvent()),
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
                                                Text("${state.info.details!.totalOrder!} ${translate.orders}", textAlign: TextAlign.end, style: kAppLblTinyFontBoldCart(context)),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (state.info.details!.orderTo! == 'selfpickup' && state.savedSlot.isNotEmpty && state.receiverContact.isNotEmpty && state.receiverName.isNotEmpty) ...[
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
                                onTap: () => context.read<BuySubscriptionPackageBloc>().add(BuySubscriptionPackageCreateOrderEvent()),
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
                                                Text("${state.info.details!.totalOrder!} ${translate.orders}", textAlign: TextAlign.end, style: kAppLblTinyFontBoldCart(context)),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (state.info.details!.orderTo! == 'selfpickup' && state.savedSlot.isNotEmpty && state.receiverContact.isEmpty && state.receiverName.isEmpty) ...[
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
                                      orderTo: state.info.details!.orderTo!,
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
                                    context.read<BuySubscriptionPackageBloc>().add(
                                      BuySubscriptionPackageReceiverChangeEvent(name: newReceiverInfo.name!, countryCode: newReceiverInfo.countryCode!, phoneNumber: newReceiverInfo.phoneNumber!),
                                    );
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
                      ] else if (state.deliveryAddressId.isEmpty && state.info.details!.orderTo! == 'homedelivery') ...[
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
                                    child: DeliveryAddressListModalScreen(deliveryArea: state.info.details!.deliveryArea!, restaurant: state.info.details!.restaurants!.id!, deliveryAddressId: state.deliveryAddressId),
                                  );
                                },
                              ).then((value) {
                                if (!context.mounted) return;
                                if (value != null && value != '') {
                                  DeliveryAddressModalResponseModel savedData = DeliveryAddressModalResponseModel.fromJson(value);
                                  context.read<BuySubscriptionPackageBloc>().add(BuySubscriptionPackageDeliveryAddressChangeEvent(selected: savedData));
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
                      ] else if (state.savedSlot.isEmpty) ...[
                        Center(child: Text(translate.select_delivery_slot, style: kAppLblMediumFontBold(context))),
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

class BuySubscriptionsInfoFoodInfoBlock extends StatelessWidget {
  final FoodInSubscriptionPackageInfoModel model;
  final bool canAddAddons;
  final bool canAddVariations;
  final int totalOrders;
  final List<FoodInCartModel> inCart;
  final String appLocale;
  const BuySubscriptionsInfoFoodInfoBlock({super.key, required this.model, required this.canAddAddons, required this.canAddVariations, required this.totalOrders, required this.inCart, required this.appLocale});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return InkWell(
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
              child: SubscriptionFoodInfoModalScreen(id: model.id!, data: jsonEncode(model), totalOrders: totalOrders, canAddAddons: canAddAddons, canAddVariations: canAddVariations, inCart: jsonEncode(inCart)),
            );
          },
        ).then((value) {
          if (!context.mounted) return;
          if (value != null) {
            FoodInfoModalResponseModel foodInfoModalResponse = FoodInfoModalResponseModel.fromJson(value, appLocale);
            context.read<BuySubscriptionPackageBloc>().add(BuySubscriptionPackageFoodModalResponseEvent(id: model.id!, response: foodInfoModalResponse));
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                  child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 100.0, imageUrl: model.image!),
                ),
                Positioned(left: 5, bottom: 5, child: kAppFoodType(model.foodType!)),
                model.discount! > 0
                    ? Positioned(
                        left: 0,
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: ThemeProvider.darkBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(AssetsUrl.imageURL.offerTag, height: 10, width: 10),
                              kAppSpacerHorizontal(width: 5),
                              Text(
                                model.discountType == '%' ? '${translate.flat} ${model.discount}% ${translate.off}' : '${translate.flat} ${kAppPriceFormat(model.discount!)} ${translate.off}',
                                style: kAppLblTinyBoldOffer(context),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
                canAddAddons || canAddVariations
                    ? Positioned(
                        bottom: 5,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: const BoxDecoration(color: ThemeProvider.darkBackgroundColor),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [Text(translate.customizable, style: kAppLblTinyBoldOffer(context))],
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                kAppSpacerVertical(height: 5),
                Text(kAppTrimWord(model.name!, 20), style: kAppLblMediumFontBold(context)),
                kAppSpacerVertical(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        border: Border.all(color: ThemeProvider.ratingStarIconColorLight, width: 0.5),
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                      ),
                      child: kAppFoodRatingStar(model.rating!, iconSize: 12),
                    ),
                    kAppSpacerHorizontal(width: 5),
                    Text("${model.totalRating!} ${translate.ratings}", style: kAppLblTinyFontRegular(context)),
                  ],
                ),
                kAppSpacerVertical(height: 5),
                model.discount! <= 0
                    ? Text(kAppPriceFormat(model.price!), style: kAppLblTinyMediumFontSemi(context))
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(kAppPriceFormat(model.price!), style: kAppLblTinyStrokeFontRegular(context)),
                          kAppSpacerHorizontal(width: 5),
                          Text(kAppPriceFormat(model.offerPrice!), style: kAppLblTinyMediumFontSemi(context)),
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BuySubscriptionPackageLoadingView extends StatelessWidget {
  const BuySubscriptionPackageLoadingView({super.key});

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

class BuySubscriptionPackageErroView extends StatelessWidget {
  const BuySubscriptionPackageErroView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.system_error_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          kAppSpacerVertical(height: 30),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: kAppTextButtonColoredStyle(context, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor),
            child: Text(translate.undestand_and_go_back),
          ),
        ],
      ),
    );
  }
}

