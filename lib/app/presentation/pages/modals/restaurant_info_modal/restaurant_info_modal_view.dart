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
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class RestaurantInfoModalScreen extends StatelessWidget {
  final String name;
  final bool isHidden;
  final bool preBooking;
  final bool tiffinSubscription;
  const RestaurantInfoModalScreen({super.key, required this.name, required this.isHidden, required this.preBooking, required this.tiffinSubscription});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(name),
        scrolledUnderElevation: 0,
        actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop('dining'),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
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
                        Icon(Icons.restaurant_menu_outlined, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                        kAppSpacerHorizontal(width: 10),
                        Text(translate.view_restaurant_detail, style: kAppLblMediumFontMedium(context)),
                      ],
                    ),
                    Icon(Icons.chevron_right_outlined, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                  ],
                ),
              ),
            ),
            preBooking
                ? GestureDetector(
                    onTap: () => Navigator.of(context).pop('preBooking'),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
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
                              Icon(Icons.table_restaurant_outlined, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                              kAppSpacerHorizontal(width: 10),
                              Text(translate.book_table, style: kAppLblMediumFontMedium(context)),
                            ],
                          ),
                          Icon(Icons.chevron_right_outlined, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
            tiffinSubscription
                ? GestureDetector(
                    onTap: () => Navigator.of(context).pop('tiffinSubscriptionPackage'),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
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
                              Icon(Icons.lunch_dining_outlined, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                              kAppSpacerHorizontal(width: 10),
                              Text(translate.tiffin_subscription_packages, style: kAppLblMediumFontMedium(context)),
                            ],
                          ),
                          Icon(Icons.chevron_right_outlined, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
            GestureDetector(
              onTap: () => Navigator.of(context).pop('hide'),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
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
                        Icon(Icons.visibility_off_outlined, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                        kAppSpacerHorizontal(width: 10),
                        Text(isHidden ? translate.unhide_restaurant : translate.hide_restaurant, style: kAppLblMediumFontMedium(context)),
                      ],
                    ),
                    Icon(Icons.chevron_right_outlined, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop('report'),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
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
                        Icon(Icons.info_outline_rounded, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                        kAppSpacerHorizontal(width: 10),
                        Text(translate.report_fraud, style: kAppLblMediumFontMedium(context)),
                      ],
                    ),
                    Icon(Icons.chevron_right_outlined, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

