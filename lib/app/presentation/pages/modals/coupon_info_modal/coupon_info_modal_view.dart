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

class CouponInfoModalScreen extends StatelessWidget {
  final String name;
  final String couponType;
  final bool allRestaurants;
  final List<String> restaurant;
  final bool allUsers;
  final List<String> user;
  final String code;
  final String discountType;
  final String id;
  final int limitSameUser;
  final double loyalityPoints;
  final double maxDiscount;
  final double minCartTotal;
  final double minDiscount;
  final String promoLbl;
  const CouponInfoModalScreen({
    super.key,
    required this.name,
    required this.couponType,
    required this.allRestaurants,
    required this.restaurant,
    required this.allUsers,
    required this.user,
    required this.code,
    required this.discountType,
    required this.id,
    required this.limitSameUser,
    required this.loyalityPoints,
    required this.maxDiscount,
    required this.minCartTotal,
    required this.minDiscount,
    required this.promoLbl,
  });

  @override
  Widget build(BuildContext context) {
    return CouponInfoModalView(
      name: name,
      couponType: couponType,
      allRestaurants: allRestaurants,
      restaurant: restaurant,
      allUsers: allUsers,
      user: user,
      code: code,
      discountType: discountType,
      id: id,
      limitSameUser: limitSameUser,
      loyalityPoints: loyalityPoints,
      maxDiscount: maxDiscount,
      minCartTotal: minCartTotal,
      minDiscount: minDiscount,
      promoLbl: promoLbl,
    );
  }
}

class CouponInfoModalView extends StatelessWidget {
  final String name;
  final String couponType;
  final bool allRestaurants;
  final List<String> restaurant;
  final bool allUsers;
  final List<String> user;
  final String code;
  final String discountType;
  final String id;
  final int limitSameUser;
  final double loyalityPoints;
  final double maxDiscount;
  final double minCartTotal;
  final double minDiscount;
  final String promoLbl;
  const CouponInfoModalView({
    super.key,
    required this.name,
    required this.couponType,
    required this.allRestaurants,
    required this.restaurant,
    required this.allUsers,
    required this.user,
    required this.code,
    required this.discountType,
    required this.id,
    required this.limitSameUser,
    required this.loyalityPoints,
    required this.maxDiscount,
    required this.minCartTotal,
    required this.minDiscount,
    required this.promoLbl,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(translate.coupon_details),
        actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  kAppCouponIcon(couponType, 15, 15),
                  kAppSpacerHorizontal(width: 10),
                  Flexible(
                    child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblMediumFontBold(context)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Text(promoLbl, style: kAppCouponLblTinyFontRegular(context)),
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
                  minCartTotal > 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                            kAppSpacerHorizontal(width: 5),
                            Text("${translate.min_cart_value} ${kAppPriceFormat(minCartTotal)}", style: kAppLblTinyFontRegular(context)),
                          ],
                        )
                      : const SizedBox(),
                  minCartTotal > 0 ? kAppSpacerVertical(height: 5) : const SizedBox(),
                  if (couponType == 'default' || couponType == 'restaurant' || couponType == 'firstorder') ...[
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
                  ] else if (couponType == 'loyality') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                        kAppSpacerHorizontal(width: 5),
                        Text(translate.loyalty_points_available, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                    kAppSpacerVertical(height: 5),
                  ] else if (couponType == 'bogo') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                        kAppSpacerHorizontal(width: 5),
                        Text(translate.bogo_offer, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                    kAppSpacerVertical(height: 5),
                  ] else if (couponType == 'freedelivery') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                        kAppSpacerHorizontal(width: 5),
                        Text(translate.free_delivery_offer, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                    kAppSpacerVertical(height: 5),
                  ],
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
// Done //
