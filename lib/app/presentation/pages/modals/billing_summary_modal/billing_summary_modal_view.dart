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
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/modals/billing_summary_modal/bloc/billing_summary_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class BillingSummaryModalScreen extends StatelessWidget {
  final String orderTo;
  final double realTotal;
  final double itemTotal;
  final double itemDiscount;
  final double couponDiscount;
  final String couponCode;
  final double walletAmount;
  final double serviceCharge;
  final String serviceChargeName;
  final double foodServiceCharge;
  final String foodServiceChargeName;
  final String deliveryGratitude;
  final double deliveryTip;
  final double extraCharge;
  final double deliveryCharge;
  final double packagingCharges;
  final double packagingChargesTax;
  final double grandTotal;

  const BillingSummaryModalScreen({
    super.key,
    required this.orderTo,
    required this.realTotal,
    required this.itemTotal,
    required this.itemDiscount,
    required this.couponDiscount,
    required this.couponCode,
    required this.walletAmount,
    required this.serviceCharge,
    required this.serviceChargeName,
    required this.foodServiceCharge,
    required this.foodServiceChargeName,
    required this.deliveryGratitude,
    required this.deliveryTip,
    required this.extraCharge,
    required this.deliveryCharge,
    required this.packagingCharges,
    required this.packagingChargesTax,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BillingSummaryModalBloc()
        ..add(
          BillingSummaryModalInitialEvent(
            orderTo: orderTo,
            realTotal: realTotal,
            itemTotal: itemTotal,
            itemDiscount: itemDiscount,
            couponDiscount: couponDiscount,
            couponCode: couponCode,
            walletAmount: walletAmount,
            serviceCharge: serviceCharge,
            serviceChargeName: serviceChargeName,
            foodServiceCharge: foodServiceCharge,
            foodServiceChargeName: foodServiceChargeName,
            deliveryGratitude: deliveryGratitude,
            deliveryTip: deliveryTip,
            extraCharge: extraCharge,
            deliveryCharge: deliveryCharge,
            packagingCharges: packagingCharges,
            packagingChargesTax: packagingChargesTax,
            grandTotal: grandTotal,
          ),
        ),
      child: const BillingSummaryModalView(),
    );
  }
}

class BillingSummaryModalView extends StatelessWidget {
  const BillingSummaryModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<BillingSummaryModalBloc, BillingSummaryModalState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Text(translate.bill_summary),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        BillingInfoTile(name: translate.item_total, icon: AssetsUrl.iconsURL.billItemTotalIcon, priceTag: '+', price: state.realTotal),
                        BillingInfoTile(name: translate.item_discount, icon: AssetsUrl.iconsURL.billDiscountIcon, priceTag: '-', price: state.itemDiscount),
                        BillingInfoTile(name: translate.sub_total_amount, icon: AssetsUrl.iconsURL.billItemTotalIcon, priceTag: '+', price: state.itemTotal),
                        BillingInfoTile(name: '${translate.food_service_charge_amount} (${state.foodServiceChargeName})', icon: AssetsUrl.iconsURL.billTaxIcon, priceTag: '+', price: state.foodServiceCharge),
                        BillingInfoTile(name: '${translate.service_charge} (${state.serviceChargeName})', icon: AssetsUrl.iconsURL.billTaxIcon, priceTag: '+', price: state.serviceCharge),
                        BillingInfoTile(name: translate.extra_service_charge, icon: AssetsUrl.iconsURL.billTaxIcon, priceTag: '+', price: state.extraCharge),
                        BillingInfoTile(name: translate.delivery_charge, icon: AssetsUrl.iconsURL.billDeliveryIcon, priceTag: '+', price: state.deliveryCharge),
                        BillingInfoTile(name: translate.delivery_partner_tip, icon: AssetsUrl.iconsURL.billDeliveryIcon, priceTag: '+', price: state.deliveryTip),
                        BillingInfoTile(name: translate.package_charge, icon: AssetsUrl.iconsURL.billPackageIcon, priceTag: '+', price: state.packagingCharges),
                        BillingInfoTile(name: translate.package_charge_tax, icon: AssetsUrl.iconsURL.billTaxIcon, priceTag: '+', price: state.packagingChargesTax),
                        BillingInfoTile(name: '${translate.coupon_discount} (${state.couponCode})', icon: AssetsUrl.iconsURL.billDiscountIcon, priceTag: '-', price: state.couponDiscount),
                        BillingInfoTile(name: translate.wallet_money, icon: AssetsUrl.iconsURL.billDiscountIcon, priceTag: '-', price: state.walletAmount),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.only(bottom: 5, top: 10),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(translate.grand_total, style: kAppLblMediumFontMedium(context)),
                              Text(kAppPriceFormat(state.grandTotal), style: kAppLblMediumFontBold(context)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  state.orderTo == 'homedelivery'
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            kAppSpacerVertical(height: 10),
                            kAppTitleDivider(context, translate.gratitude_title, 0),
                            kAppSpacerVertical(height: 10),
                            Container(
                              width: MediaQuery.of(context).size.width,
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
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                                        child: Image.asset(AssetsUrl.imageURL.deliveryGratitude, width: MediaQuery.of(context).size.width, height: 100.0, fit: BoxFit.fill),
                                      ),
                                      Positioned(
                                        left: 0,
                                        top: 5,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${translate.tip} ${translate.your_deliveryman}", style: kAppLblTinyFontBold(context)),
                                            kAppSpacerVertical(height: 2),
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width / 2,
                                              child: Text(
                                                translate.deliveryman_tip_sub_title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: kAppLblTinyFontRegularChip(context, color: 'regular'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  kAppSpacerVertical(height: 10),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: state.gratitudeList
                                          .map(
                                            (e) => InkWell(
                                              onTap: () => context.read<BillingSummaryModalBloc>().add(BillingSummaryModalDeliveryGratitudeEvent(tip: e.price!)),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                margin: const EdgeInsets.only(left: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  border: Border.all(color: state.deliveryTip.toString() == e.price!.toString() ? Theme.of(context).primaryColor : ThemeProvider.lightDisabledColor, width: 1.5),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(e.mostTipped! ? translate.most_tipped : '', style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                                    Text(kAppPriceFormat(e.price!), style: kAppLblTinyFontRegular(context)),
                                                    kAppSpacerVertical(height: 5),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: ThemeProvider.scaffoldPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(state.deliveryTip),
                          style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                          child: Text(translate.save_btn),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BillingInfoTile extends StatelessWidget {
  final String name;
  final String icon;
  final String priceTag;
  final double price;
  const BillingInfoTile({super.key, required this.name, required this.icon, required this.priceTag, required this.price});

  @override
  Widget build(BuildContext context) {
    return price > 0
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(icon, height: 12, width: 12, color: Theme.of(context).canvasColor),
                    kAppSpacerHorizontal(width: 10),
                    Text(name, style: kAppLblTinyFontRegular(context)),
                  ],
                ),
                Text("($priceTag) ${kAppPriceFormat(price)}", style: kAppLblTinyFontBold(context)),
              ],
            ),
          )
        : const SizedBox();
  }
}

