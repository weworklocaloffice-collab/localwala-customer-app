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
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FoodSubscriptionPackageBillingSummaryModalView extends StatelessWidget {
  final int totalOrders;
  final double itemTotal;
  final double serviceCharge;
  final double foodServiceCharge;
  final double extraCharge;
  final double packagingCharges;
  final double packagingChargesTax;
  final double grandTotal;
  const FoodSubscriptionPackageBillingSummaryModalView({
    super.key,
    required this.totalOrders,
    required this.itemTotal,
    required this.serviceCharge,
    required this.foodServiceCharge,
    required this.extraCharge,
    required this.packagingCharges,
    required this.packagingChargesTax,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        title: Text(translate.bill_summary),
        actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
      ),
      body: SingleChildScrollView(
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
                  BillingInfoTile(name: translate.item_total, icon: AssetsUrl.iconsURL.billItemTotalIcon, priceTag: '+', price: itemTotal, totalOrders: totalOrders),
                  BillingInfoTile(name: translate.food_service_charge_amount, icon: AssetsUrl.iconsURL.billTaxIcon, priceTag: '+', price: foodServiceCharge, totalOrders: totalOrders),
                  BillingInfoTile(name: translate.service_charge, icon: AssetsUrl.iconsURL.billTaxIcon, priceTag: '+', price: serviceCharge, totalOrders: totalOrders),
                  BillingInfoTile(name: translate.extra_service_charge, icon: AssetsUrl.iconsURL.billTaxIcon, priceTag: '+', price: extraCharge, totalOrders: totalOrders),
                  BillingInfoTile(name: translate.package_charge, icon: AssetsUrl.iconsURL.billPackageIcon, priceTag: '+', price: packagingCharges, totalOrders: totalOrders),
                  BillingInfoTile(name: translate.package_charge_tax, icon: AssetsUrl.iconsURL.billTaxIcon, priceTag: '+', price: packagingChargesTax, totalOrders: totalOrders),
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
                        Text(kAppPriceFormat(grandTotal), style: kAppLblMediumFontBold(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                      onPressed: () => Navigator.of(context).pop(),
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
  }
}

class BillingInfoTile extends StatelessWidget {
  final String name;
  final String icon;
  final String priceTag;
  final double price;
  final int totalOrders;
  const BillingInfoTile({super.key, required this.name, required this.icon, required this.priceTag, required this.price, required this.totalOrders});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
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
                Text("( X $totalOrders ${translate.orders}) ($priceTag) ${kAppPriceFormat(price)}", style: kAppLblTinyFontBold(context)),
              ],
            ),
          )
        : const SizedBox();
  }
}
// Done //
