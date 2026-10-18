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
import 'package:user/app/core/config/global_settings.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

TextStyle kAppStyleTabTitleStyle(BuildContext context) {
  return TextStyle(fontFamily: 'medium', fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize));
}

TextStyle kAppLblMediumFontBold(BuildContext context, {String color = 'regular'}) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelMedium?.fontSize), fontFamily: 'bold', color: color == 'regular' ? Theme.of(context).canvasColor : Theme.of(context).primaryColor);
}

TextStyle kAppLblMediumFontRegular(BuildContext context, {String color = 'regular'}) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelMedium?.fontSize), fontFamily: 'regular', color: Theme.of(context).canvasColor);
}

TextStyle kAppLblMediumFontMedium(BuildContext context, {String color = 'regular'}) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelMedium?.fontSize), fontFamily: 'medium', color: color == 'regular' ? Theme.of(context).canvasColor : Theme.of(context).primaryColor);
}

TextStyle kAppLblMediumFontMediumGrey(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelMedium?.fontSize), fontFamily: 'medium', color: Theme.of(context).colorScheme.tertiary);
}

TextStyle kAppLblMediumFontRegularError(BuildContext context, {String color = 'regular'}) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelMedium?.fontSize), fontFamily: 'regular', color: ThemeProvider.errorColor);
}

TextStyle kAppLblLargeFontMedium(BuildContext context, {String color = 'regular'}) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelLarge?.fontSize), fontFamily: 'medium', color: Theme.of(context).canvasColor);
}

TextStyle kAppLblSmallFontMedium(BuildContext context, {String color = 'regular'}) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'medium', color: color == 'regular' ? Theme.of(context).canvasColor : Theme.of(context).primaryColor);
}

TextStyle kAppLblSemiBoldFontLarge(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelLarge?.fontSize), fontFamily: 'semibold', color: Theme.of(context).canvasColor);
}

TextStyle kAppLblSemiBoldToggle(BuildContext context, {bool canDeliver = true}) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'semibold', color: canDeliver ? ThemeProvider.successColor : ThemeProvider.errorColor);
}

TextStyle kAppLblSmallFontRegular(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'regular', color: Theme.of(context).canvasColor);
}

TextStyle kAppLblTinyFontRegular(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'regular', color: Theme.of(context).colorScheme.tertiary);
}

TextStyle kAppCouponLblTinyFontRegular(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'regular', color: Theme.of(context).colorScheme.inverseSurface);
}

TextStyle kAppLblTinyFontRegularChip(BuildContext context, {String color = 'regular'}) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'regular', color: color == 'regular' ? Theme.of(context).canvasColor : Theme.of(context).primaryColor);
}

TextStyle kAppLblTinyFontBold(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'bold', color: Theme.of(context).colorScheme.tertiary);
}

TextStyle kAppLblTinyRegularWhite(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'regular', color: Theme.of(context).scaffoldBackgroundColor);
}

TextStyle kAppLblBoldFont(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'bold', color: Theme.of(context).canvasColor);
}

TextStyle kAppLblTinyStrokeRegular(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'regular', color: Theme.of(context).colorScheme.tertiary, decoration: TextDecoration.lineThrough);
}

TextStyle kAppLblTinyBoldOffer(BuildContext context) {
  return TextStyle(fontSize: 10, fontFamily: 'bold', color: ThemeProvider.offerTagTextColorLight);
}

TextStyle kAppLblTinyStrokeFontRegular(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'regular', color: Theme.of(context).colorScheme.tertiary, decoration: TextDecoration.lineThrough);
}

TextStyle kAppLblTinyMediumFontSemi(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'semibold', color: Theme.of(context).canvasColor);
}

TextStyle kAppLblSmallFontBold(BuildContext context, {String color = 'primary'}) {
  return TextStyle(fontFamily: 'bold', color: color == 'primary' ? Theme.of(context).primaryColor : Theme.of(context).canvasColor, fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize));
}

TextStyle kAppLblSmallFontBoldCart(BuildContext context) {
  return TextStyle(fontFamily: 'bold', color: Theme.of(context).scaffoldBackgroundColor, fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize));
}

TextStyle kAppLblTinyFontBoldCart(BuildContext context) {
  return TextStyle(fontFamily: 'medium', color: Theme.of(context).scaffoldBackgroundColor, fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize));
}

TextStyle kAppLblSmallFontSemiBold(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'semibold', color: Theme.of(context).canvasColor);
}

TextStyle kAppLblLargeFontBold(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.bodyLarge?.fontSize), fontFamily: 'bold', color: Theme.of(context).canvasColor);
}

TextStyle kAppLblMediumFontSemiBold(BuildContext context, {String color = 'regular'}) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelMedium?.fontSize), fontFamily: 'semibold', color: color == 'regular' ? Theme.of(context).canvasColor : Theme.of(context).primaryColor);
}

TextStyle kAppLblMediumFontSemiBoldWhite(BuildContext context) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelMedium?.fontSize), fontFamily: 'semibold', color: Theme.of(context).scaffoldBackgroundColor);
}

TextStyle kAppThemeToggleLblRegular(BuildContext context, {bool isDarkTheme = false}) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelMedium?.fontSize), fontFamily: 'regular', color: isDarkTheme ? ThemeProvider.darkBackgroundColor : ThemeProvider.backgroundColor);
}

TextStyle kAppThemeToggleLblBold(BuildContext context, {bool isDarkTheme = false}) {
  return TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelMedium?.fontSize), fontFamily: 'bold', color: isDarkTheme ? ThemeProvider.darkBackgroundColor : ThemeProvider.backgroundColor);
}

TextStyle kAppLblOrderTileRegular(BuildContext context) {
  return TextStyle(fontFamily: 'regular', color: Theme.of(context).scaffoldBackgroundColor, fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize));
}

TextStyle kAppLblOrderTileBold(BuildContext context) {
  return TextStyle(fontFamily: 'bold', color: Theme.of(context).scaffoldBackgroundColor, fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize));
}

TextStyle kAppLblOrderTileSemiBold(BuildContext context) {
  return TextStyle(fontFamily: 'semibold', color: Theme.of(context).scaffoldBackgroundColor, fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize));
}

Center kAppCenterCircularProgress(BuildContext context, {String color = 'primary', double strokeWidth = 2.0}) {
  return Center(
    child: CircularProgressIndicator(color: color == 'primary' ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor, strokeWidth: strokeWidth),
  );
}

Container kAppCircularProgress(BuildContext context, {String color = 'primary', double strokeWidth = 2.0, double? width, double? height, double? padding}) {
  return Container(
    width: width!,
    height: height!,
    padding: EdgeInsets.all(padding!),
    child: CircularProgressIndicator(color: color == 'primary' ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor, strokeWidth: strokeWidth),
  );
}

ButtonStyle kAppElevatedButtonStyle(BuildContext context, {required Color disabledColor, required Color bgColor, required Color foreColor, required double height}) {
  return ElevatedButton.styleFrom(
    minimumSize: Size.fromHeight(height),
    disabledBackgroundColor: disabledColor,
    backgroundColor: bgColor,
    foregroundColor: foreColor,
    textStyle: TextStyle(fontFamily: 'semibold', fontSize: kFontFromTheme(context, Theme.of(context).textTheme.bodyMedium?.fontSize)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  );
}

ButtonStyle kAppElevatedButtonOutlineStyle(BuildContext context, {required Color disabledColor, required Color bgColor, required Color foreColor, required Color borderColor, required double height}) {
  return ElevatedButton.styleFrom(
    foregroundColor: foreColor,
    backgroundColor: bgColor,
    shadowColor: bgColor,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
      side: BorderSide(width: 1, color: borderColor),
    ),
  );
}

SizedBox kAppSpacerVertical({double height = 0}) {
  return SizedBox(height: height);
}

SizedBox kAppSpacerHorizontal({double width = 0}) {
  return SizedBox(width: width);
}

ButtonStyle kAppTextButtonColoredStyle(BuildContext context, {required Color bgColor, required Color foreColor}) {
  return TextButton.styleFrom(
    backgroundColor: bgColor,
    foregroundColor: foreColor,
    textStyle: TextStyle(fontFamily: 'semibold', fontSize: kFontFromTheme(context, Theme.of(context).textTheme.bodyMedium?.fontSize)),
  );
}

ButtonStyle kAppTextButtonTransparentStyle(BuildContext context, {required Color foreColor}) {
  return TextButton.styleFrom(
    foregroundColor: foreColor,
    textStyle: TextStyle(fontFamily: 'semibold', fontSize: kFontFromTheme(context, Theme.of(context).textTheme.bodyMedium?.fontSize)),
  );
}

InputDecoration kAppInputDecoration(BuildContext context, {Icon? prefixIcon, Icon? suffixIcon, bool? haveSuffixIcon = false, VoidCallback? onPressed, required String? lblText, String? errText}) {
  return InputDecoration(
    prefixIcon: prefixIcon,
    iconColor: Theme.of(context).canvasColor,
    prefixIconColor: Theme.of(context).canvasColor,
    suffixIconColor: Theme.of(context).canvasColor,
    suffixIcon: haveSuffixIcon == false ? suffixIcon : IconButton(onPressed: onPressed, icon: suffixIcon!),
    labelText: lblText,
    errorText: errText,
    labelStyle: TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelMedium?.fontSize), fontFamily: 'medium', color: Theme.of(context).canvasColor),
    errorStyle: TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelMedium?.fontSize), fontFamily: 'medium'),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).canvasColor)),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).canvasColor),
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

ButtonStyle kAppOutlineButtonStyle(BuildContext context, {String? foreColor = 'primary', double? radius}) {
  return OutlinedButton.styleFrom(
    textStyle: TextStyle(fontFamily: 'semibold', fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize)),
    foregroundColor: foreColor == 'primary' ? Theme.of(context).primaryColor : Theme.of(context).canvasColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius!)),
  );
}

Container kAppLine(BuildContext context) {
  return Container(height: 1, width: double.infinity, color: Colors.grey[300]);
}

TextStyle kAppTitleStyle(BuildContext context) {
  return TextStyle(fontFamily: 'bold', fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), color: Theme.of(context).canvasColor);
}

TextStyle kAppTitleSubStyle(BuildContext context) {
  return TextStyle(fontFamily: 'regular', fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), color: Theme.of(context).canvasColor);
}

String kAppPriceFormat(double price) {
  return GlobalSettings.globalCurrencySide == 'left' ? '${GlobalSettings.globalCurrencySymbol}$price' : '$price${GlobalSettings.globalCurrencySymbol}';
}

int kSubscriptionPackageDays(String dayName) {
  if (dayName == 'week') {
    return 7;
  } else if (dayName == 'fortnight') {
    return 15;
  } else if (dayName == 'month') {
    return 30;
  }
  return 7;
}

Widget kAppFoodType(String type, {double height = 15, double width = 15}) {
  if (type == 'veg') {
    return Image.asset(AssetsUrl.imageURL.foodVegType, height: height, width: width);
  } else if (type == 'nonveg') {
    return Image.asset(AssetsUrl.imageURL.foodNonVegType, height: height, width: width);
  } else if (type == 'vegan') {
    return Image.asset(AssetsUrl.imageURL.foodVeganType, height: height, width: width);
  }
  return SizedBox(height: height, width: width);
}

Image kAppAddressTitleIcon(BuildContext context, int num, double height, double width) {
  if (num == 0) {
    return Image.asset(AssetsUrl.imageURL.addressHome, height: height, width: width, color: Theme.of(context).canvasColor);
  } else if (num == 1) {
    return Image.asset(AssetsUrl.imageURL.addressWork, height: height, width: width, color: Theme.of(context).canvasColor);
  } else if (num == 2) {
    return Image.asset(AssetsUrl.imageURL.addressHotel, height: height, width: width, color: Theme.of(context).canvasColor);
  } else if (num == 3) {
    return Image.asset(AssetsUrl.imageURL.addressOther, height: height, width: width, color: Theme.of(context).canvasColor);
  }
  return Image.asset(AssetsUrl.imageURL.addressOther, height: height, width: width, color: Theme.of(context).canvasColor);
}

Image kAppCouponIcon(String name, double height, double width) {
  if (name == 'default') {
    return Image.asset(AssetsUrl.imageURL.couponDefault, height: height, width: width);
  } else if (name == 'restaurant') {
    return Image.asset(AssetsUrl.imageURL.couponRestaurant, height: height, width: width);
  } else if (name == 'freedelivery') {
    return Image.asset(AssetsUrl.imageURL.couponFreeDelivery, height: height, width: width);
  } else if (name == 'firstorder') {
    return Image.asset(AssetsUrl.imageURL.couponFirstOrder, height: height, width: width);
  } else if (name == 'loyality') {
    return Image.asset(AssetsUrl.imageURL.couponLoyality, height: height, width: width);
  } else if (name == 'bogo') {
    return Image.asset(AssetsUrl.imageURL.couponBOGO, height: height, width: width);
  }
  return Image.asset(AssetsUrl.imageURL.couponDefault, height: height, width: width);
}

String kAppAddressTitle(BuildContext context, int num) {
  switch (num) {
    case 0:
      return AppLocalizations.of(context)!.home;
    case 1:
      return AppLocalizations.of(context)!.work;
    case 2:
      return AppLocalizations.of(context)!.hotel;
    case 3:
      return AppLocalizations.of(context)!.other;
    default:
      return AppLocalizations.of(context)!.other;
  }
}

String kAppPaymentStatus(BuildContext context, String type) {
  switch (type) {
    case 'initiated':
      return AppLocalizations.of(context)!.payment_status_initiated;
    case 'paid':
      return AppLocalizations.of(context)!.payment_status_paid;
    case 'cancelled':
      return AppLocalizations.of(context)!.payment_status_cancelled;
    default:
      return AppLocalizations.of(context)!.payment_status_initiated;
  }
}

String kAppSupportChatType(BuildContext context, String type) {
  switch (type) {
    case 'orders':
      return AppLocalizations.of(context)!.support_chat_orders;
    case 'dining':
      return AppLocalizations.of(context)!.support_chat_dining;
    case 'tiffin_subscription':
      return AppLocalizations.of(context)!.support_chat_tiffin_subscription;
    case 'complaints':
      return AppLocalizations.of(context)!.support_chat_complaints;
    case 'reports':
      return AppLocalizations.of(context)!.support_chat_reports;
    default:
      return type;
  }
}

Row kAppFoodRatingStar(double rating, {double iconSize = 10}) {
  return Row(
    children: [
      Icon(rating >= 1 ? Icons.star_rate_rounded : Icons.star_border_rounded, size: iconSize, color: rating >= 1 ? ThemeProvider.ratingStarIconColorLight : ThemeProvider.greyColorBorder),
      Icon(rating >= 2 ? Icons.star_rate_rounded : Icons.star_border_rounded, size: iconSize, color: rating >= 2 ? ThemeProvider.ratingStarIconColorLight : ThemeProvider.greyColorBorder),
      Icon(rating >= 3 ? Icons.star_rate_rounded : Icons.star_border_rounded, size: iconSize, color: rating >= 3 ? ThemeProvider.ratingStarIconColorLight : ThemeProvider.greyColorBorder),
      Icon(rating >= 4 ? Icons.star_rate_rounded : Icons.star_border_rounded, size: iconSize, color: rating >= 4 ? ThemeProvider.ratingStarIconColorLight : ThemeProvider.greyColorBorder),
      Icon(rating >= 5 ? Icons.star_rate_rounded : Icons.star_border_rounded, size: iconSize, color: rating >= 5 ? ThemeProvider.ratingStarIconColorLight : ThemeProvider.greyColorBorder),
    ],
  );
}

Padding kAppTitleDivider(BuildContext context, String title, double padding) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: padding),
    child: Row(
      children: <Widget>[
        const Expanded(child: Divider(thickness: 0.5)),
        Expanded(
          child: Text(
            title,
            style: kAppLblMediumFontSemiBold(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Expanded(child: Divider(thickness: 0.5)),
      ],
    ),
  );
}

String kAppTrimWord(String text, int length) {
  return text.length > length ? '${text.substring(0, length)}...' : text;
}

String kAppDDTranslate(BuildContext context, String key) {
  switch (key) {
    case 'dd_passport':
      return AppLocalizations.of(context)!.dd_passport;
    case 'dd_driving_license':
      return AppLocalizations.of(context)!.dd_driving_license;
    case 'dd_nic':
      return AppLocalizations.of(context)!.dd_nic;
    case 'dd_freelancer':
      return AppLocalizations.of(context)!.dd_freelancer;
    case 'dd_salary':
      return AppLocalizations.of(context)!.dd_salary;
    case 'dd_male':
      return AppLocalizations.of(context)!.dd_male;
    case 'dd_female':
      return AppLocalizations.of(context)!.dd_female;
    case 'dd_other':
      return AppLocalizations.of(context)!.dd_other;
    case 'dd_prefer_not_disclose':
      return AppLocalizations.of(context)!.dd_prefer_not_disclose;
    case 'dd_report_accident':
      return AppLocalizations.of(context)!.dd_report_accident;
    case 'dd_report_incident':
      return AppLocalizations.of(context)!.dd_report_incident;
    case 'dd_min':
      return AppLocalizations.of(context)!.dd_min;
    case 'dd_hour':
      return AppLocalizations.of(context)!.dd_hour;
    case 'dd_yes_home_delivery':
      return AppLocalizations.of(context)!.dd_yes_home_delivery;
    case 'dd_no_home_delivery':
      return AppLocalizations.of(context)!.dd_no_home_delivery;
    case 'dd_yes_takeaway':
      return AppLocalizations.of(context)!.dd_yes_takeaway;
    case 'dd_no_takeaway':
      return AppLocalizations.of(context)!.dd_no_takeaway;
    case 'dd_yes_schedule_order':
      return AppLocalizations.of(context)!.dd_yes_schedule_order;
    case 'dd_no_schedule_order':
      return AppLocalizations.of(context)!.dd_no_schedule_order;
    case 'dd_order':
      return AppLocalizations.of(context)!.dd_order;
    case 'dd_restaurant':
      return AppLocalizations.of(context)!.dd_restaurant;
    case 'dd_food':
      return AppLocalizations.of(context)!.dd_food;
    case 'dd_deliveryman':
      return AppLocalizations.of(context)!.dd_deliveryman;
    default:
      return key;
  }
}

String kAppTiffinPackageStatus(BuildContext context, String key) {
  switch (key) {
    case 'tiffin_status_ongoing':
      return AppLocalizations.of(context)!.tiffin_status_ongoing;
    case 'tiffin_status_cancelled':
      return AppLocalizations.of(context)!.tiffin_status_cancelled;
    case 'tiffin_status_completed':
      return AppLocalizations.of(context)!.tiffin_status_completed;
    case 'tiffin_status_refunded':
      return AppLocalizations.of(context)!.tiffin_status_refunded;
    case 'tiffin_status_partial_refund':
      return AppLocalizations.of(context)!.tiffin_status_partial_refund;
    case 'tiffin_status_payment_pending':
      return AppLocalizations.of(context)!.tiffin_status_payment_pending;
    default:
      return key;
  }
}

String kAppRegularOrderStatus(BuildContext context, String key) {
  switch (key) {
    case 'created':
      return AppLocalizations.of(context)!.order_status_created;
    case 'accepted':
      return AppLocalizations.of(context)!.order_status_accepted;
    case 'preparing':
      return AppLocalizations.of(context)!.order_status_preparing;
    case 'ready':
      return AppLocalizations.of(context)!.order_status_ready;
    case 'handover':
      return AppLocalizations.of(context)!.order_status_handover;
    case 'ongoing':
      return AppLocalizations.of(context)!.order_status_ongoing;
    case 'delivered':
      return AppLocalizations.of(context)!.order_status_delivered;
    case 'cancelled':
      return AppLocalizations.of(context)!.order_status_cancelled;
    case 'rejected':
      return AppLocalizations.of(context)!.order_status_rejected;
    case 'refunded':
      return AppLocalizations.of(context)!.order_status_refunded;
    case 'partially_refunded':
      return AppLocalizations.of(context)!.order_status_partially_refunded;
    case 'pending_payments':
      return AppLocalizations.of(context)!.order_status_pending_payments;
    default:
      return key;
  }
}

Widget kAppSysCacheMarker() {
  return const SizedBox(height: 42, width: 7, child: SizedBox(height: 9, width: 25));
}

String kAppReferralMessage(BuildContext context, String key, String extraContent) {
  String keyName(String key) {
    switch (key) {
      case 'referral_both_received':
        return AppLocalizations.of(context)!.referral_both_received;
      case 'referral_friend_received':
        return AppLocalizations.of(context)!.referral_friend_received;
      case 'referral_you_received':
        return AppLocalizations.of(context)!.referral_you_received;
      default:
        return key;
    }
  }

  final localizedMessage = keyName(key);
  final String dynamicMessage = localizedMessage.replaceAll('##dynamic##', extraContent);
  return dynamicMessage;
}

String kAppTiffinKind(BuildContext context, String key) {
  switch (key) {
    case 'breakfast':
      return AppLocalizations.of(context)!.breakfast;
    case 'lunch':
      return AppLocalizations.of(context)!.lunch;
    case 'dinner':
      return AppLocalizations.of(context)!.dinner;
    default:
      return key;
  }
}

String kAppPageName(BuildContext context, String slug) {
  switch (slug) {
    case 'about-us':
      return AppLocalizations.of(context)!.about;
    case 'privacy-policy':
      return AppLocalizations.of(context)!.privacy_policy;
    case 'terms-and-conditions':
      return AppLocalizations.of(context)!.terms_and_conditions;
    case 'refund-policy':
      return AppLocalizations.of(context)!.refund_policy;
    case 'shipping-policy':
      return AppLocalizations.of(context)!.shipping_policy;
    case 'cancellation-policy':
      return AppLocalizations.of(context)!.cancellation_policy;
    case 'cookies':
      return AppLocalizations.of(context)!.cookies;
    case 'help':
      return AppLocalizations.of(context)!.help;
    case 'frequently-asked-questions':
      return AppLocalizations.of(context)!.frequently_asked_questions;
    case 'dining-frequently-asked-questions':
      return AppLocalizations.of(context)!.dining_help;
    default:
      return AppLocalizations.of(context)!.about;
  }
}

String kAppDeliveryTimeName(BuildContext context, String time) {
  String returnString = time.replaceAll('to', AppLocalizations.of(context)!.to).replaceAll('min', AppLocalizations.of(context)!.dd_min).replaceAll('hour', AppLocalizations.of(context)!.dd_hour);
  return returnString;
}

String kAppOrderCouponTitle(BuildContext context, String key, String tExtraOne, String tExtraTwo) {
  String keyValue = '';
  if (key == 'coupon_title_one') {
    keyValue = AppLocalizations.of(context)!.coupon_title_one;
  } else if (key == 'coupon_title_two') {
    keyValue = AppLocalizations.of(context)!.coupon_title_two;
  } else if (key == 'coupon_title_two_half') {
    keyValue = AppLocalizations.of(context)!.coupon_title_two_half;
  } else if (key == 'coupon_title_three') {
    keyValue = AppLocalizations.of(context)!.coupon_title_three;
  } else if (key == 'coupon_title_four') {
    keyValue = AppLocalizations.of(context)!.coupon_title_four;
  } else if (key == 'coupon_title_five') {
    keyValue = AppLocalizations.of(context)!.coupon_title_five;
  }
  final String dynamicMessage = keyValue.replaceAll('##dynamic_one##', tExtraOne).replaceAll('##dynamic_two##', tExtraTwo);
  return kAppTrimWord(dynamicMessage, 40);
}

String kAppCartHelperText(BuildContext context, String key, String tExtraOne, String tExtraTwo, String tExtraThree) {
  String keyValue = '';
  if (key == 'cart_help_one') {
    keyValue = AppLocalizations.of(context)!.cart_help_one;
  } else if (key == 'cart_help_two') {
    keyValue = AppLocalizations.of(context)!.cart_help_two;
  } else if (key == 'cart_help_three') {
    keyValue = AppLocalizations.of(context)!.cart_help_three;
  } else if (key == 'cart_help_four') {
    keyValue = AppLocalizations.of(context)!.cart_help_four;
  } else if (key == 'cart_help_five') {
    keyValue = AppLocalizations.of(context)!.cart_help_five;
  } else if (key == 'cart_help_six') {
    keyValue = AppLocalizations.of(context)!.cart_help_six;
  } else if (key == 'cart_help_seven') {
    keyValue = AppLocalizations.of(context)!.cart_help_seven;
  }
  final String dynamicMessage = keyValue.replaceAll('##dynamic_one##', tExtraOne).replaceAll('##dynamic_two##', tExtraTwo).replaceAll('##dynamic_three##', tExtraThree);
  return dynamicMessage;
}

double kFontFromTheme(BuildContext context, double? size) {
  if (size == null) return 14;

  double width = MediaQuery.of(context).size.width;

  if (width < 360) return size * 0.9;
  if (width < 400) return size;
  if (width < 600) return size * 1.05;

  return size * 1.1;
}
