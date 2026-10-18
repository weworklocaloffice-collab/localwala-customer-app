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

class DiningChargeSummaryModalScreen extends StatelessWidget {
  final double preBookingCharge;
  final double couponCoverCharge;
  final double toPay;
  const DiningChargeSummaryModalScreen({super.key, required this.preBookingCharge, required this.couponCoverCharge, required this.toPay});

  @override
  Widget build(BuildContext context) {
    return DiningChargeSummaryModalView(preBookingCharge: preBookingCharge, couponCoverCharge: couponCoverCharge, toPay: toPay);
  }
}

class DiningChargeSummaryModalView extends StatelessWidget {
  final double preBookingCharge;
  final double couponCoverCharge;
  final double toPay;
  const DiningChargeSummaryModalView({super.key, required this.preBookingCharge, required this.couponCoverCharge, required this.toPay});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        title: Text(translate.dining_charge_summary),
        actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate.amount_adjusted_in_final_bill, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
            kAppSpacerVertical(height: 20),
            preBookingCharge > 0
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
                            Image.asset(AssetsUrl.iconsURL.billItemTotalIcon, height: 12, width: 12, color: Theme.of(context).canvasColor),
                            kAppSpacerHorizontal(width: 10),
                            Text(translate.pre_booking_charge, style: kAppLblTinyFontRegular(context)),
                          ],
                        ),
                        Text(kAppPriceFormat(preBookingCharge), style: kAppLblTinyFontBold(context)),
                      ],
                    ),
                  )
                : const SizedBox(),
            couponCoverCharge > 0
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
                            Image.asset(AssetsUrl.iconsURL.billItemTotalIcon, height: 12, width: 12, color: Theme.of(context).canvasColor),
                            kAppSpacerHorizontal(width: 10),
                            Text(translate.cover_charge, style: kAppLblTinyFontRegular(context)),
                          ],
                        ),
                        Text(kAppPriceFormat(couponCoverCharge), style: kAppLblTinyFontBold(context)),
                      ],
                    ),
                  )
                : const SizedBox(),
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
                  Text(kAppPriceFormat(toPay), style: kAppLblMediumFontBold(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Done //
