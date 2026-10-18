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
import 'package:flutter/services.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DiningCouponInfoModalScreen extends StatelessWidget {
  final String name;
  final bool allRestaurants;
  final List<String> restaurant;
  final bool allUsers;
  final List<String> user;
  final String code;
  final String discountType;
  final String id;
  final int limitSameUser;
  final double maxDiscount;
  final double minDiscount;
  final bool preBookingChargeRequired;
  final double preBookingChargeAmount;
  final String availability;
  const DiningCouponInfoModalScreen({
    super.key,
    required this.name,
    required this.allRestaurants,
    required this.restaurant,
    required this.allUsers,
    required this.user,
    required this.code,
    required this.discountType,
    required this.id,
    required this.limitSameUser,
    required this.maxDiscount,
    required this.minDiscount,
    required this.preBookingChargeRequired,
    required this.preBookingChargeAmount,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    return DiningCouponInfoModalView(
      name: name,
      allRestaurants: allRestaurants,
      restaurant: restaurant,
      allUsers: allUsers,
      user: user,
      code: code,
      discountType: discountType,
      id: id,
      limitSameUser: limitSameUser,
      maxDiscount: maxDiscount,
      minDiscount: minDiscount,
      preBookingChargeRequired: preBookingChargeRequired,
      preBookingChargeAmount: preBookingChargeAmount,
      availability: availability,
    );
  }
}

class DiningCouponInfoModalView extends StatelessWidget {
  final String name;
  final bool allRestaurants;
  final List<String> restaurant;
  final bool allUsers;
  final List<String> user;
  final String code;
  final String discountType;
  final String id;
  final int limitSameUser;
  final double maxDiscount;
  final double minDiscount;
  final bool preBookingChargeRequired;
  final double preBookingChargeAmount;
  final String availability;
  const DiningCouponInfoModalView({
    super.key,
    required this.name,
    required this.allRestaurants,
    required this.restaurant,
    required this.allUsers,
    required this.user,
    required this.code,
    required this.discountType,
    required this.id,
    required this.limitSameUser,
    required this.maxDiscount,
    required this.minDiscount,
    required this.preBookingChargeRequired,
    required this.preBookingChargeAmount,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        title: Text(translate.coupon_details),
        actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Text(kAppTrimWord(name, 55), style: kAppLblMediumFontBold(context)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                    child: Text(code, style: kAppLblTinyFontRegular(context)),
                  ),
                  InkWell(
                    onTap: () async {
                      showSuccessDialog(context, translate.copied);
                      await Clipboard.setData(ClipboardData(text: code));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(translate.copy_code, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                        kAppSpacerHorizontal(width: 5),
                        Icon(Icons.content_copy_outlined, size: 12, color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                      kAppSpacerHorizontal(width: 5),
                      Text(translate.personalised_offer, style: kAppLblTinyFontRegular(context)),
                    ],
                  ),
                  kAppSpacerVertical(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                      kAppSpacerHorizontal(width: 5),
                      Text("${translate.availability} ${translate.to} $availability", style: kAppLblTinyFontRegular(context)),
                    ],
                  ),
                  kAppSpacerVertical(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                      kAppSpacerHorizontal(width: 5),
                      Text(preBookingChargeRequired ? "${translate.cover_charge_is} ${kAppPriceFormat(preBookingChargeAmount)}" : translate.cover_charge_not_required, style: kAppLblTinyFontRegular(context)),
                    ],
                  ),
                  kAppSpacerVertical(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                      kAppSpacerHorizontal(width: 5),
                      discountType == 'amount'
                          ? Text("${translate.max_instant_discount_off} ${kAppPriceFormat(minDiscount)}", style: kAppLblTinyFontRegular(context))
                          : Text("${translate.max_instant_discount_off} ${maxDiscount > 0 ? kAppPriceFormat(minDiscount) : kAppPriceFormat(maxDiscount)}", style: kAppLblTinyFontRegular(context)),
                    ],
                  ),
                  kAppSpacerVertical(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                      kAppSpacerHorizontal(width: 5),
                      Text(allRestaurants ? translate.applicable_on_every_restaurant : translate.applicable_on_selected_restaurants, style: kAppLblTinyFontRegular(context)),
                    ],
                  ),
                  kAppSpacerVertical(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                      kAppSpacerHorizontal(width: 5),
                      Text("${translate.applicable_max} $limitSameUser ${translate.times_per_user}", style: kAppLblTinyFontRegular(context)),
                    ],
                  ),
                  kAppSpacerVertical(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                      kAppSpacerHorizontal(width: 5),
                      Text(allUsers ? translate.applicable_on_every_users : translate.applicable_on_selected_users, style: kAppLblTinyFontRegular(context)),
                    ],
                  ),
                  kAppSpacerVertical(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                      kAppSpacerHorizontal(width: 5),
                      Text(translate.coupon_terms_and_condition, style: kAppLblTinyFontRegular(context)),
                    ],
                  ),
                  kAppSpacerVertical(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

