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

const typeTheme = Typography.whiteMountainView;

enum AppTheme { light, dark }

class ThemeProvider {
  static const Color primaryColor = Color(0xFFEF9173);
  static const Color secondaryColor = Color.fromARGB(255, 254, 223, 212);
  static const Color backgroundColor = Colors.white;
  static const Color pageBackgroundColor = Color.fromARGB(255, 255, 255, 255);
  static const Color canvasColor = Color.fromARGB(255, 0, 0, 0);

  static const Color darkPrimaryColor = Color.fromARGB(255, 255, 255, 255);
  static const Color darkSecondaryColor = Color.fromARGB(255, 40, 37, 37);
  static const Color darkBackgroundColor = Color(0xff393939);
  static const Color darkPageBackgroundColor = Color(0xFF3D3D3D);
  static const Color darkCanvasColor = Color.fromARGB(255, 255, 255, 255);

  static const Color greyColorBorder = Color.fromARGB(255, 203, 197, 197);
  static const Color greyColorText = Color.fromARGB(255, 81, 79, 79);
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color transparentColor = Colors.transparent;
  static const Color blueColor = Colors.blue;
  static const double scaffoldPadding = 16.0;
  static Color lightDisabledColor = Colors.grey.shade50;
  static const double titleTabBarTextSize = 12.0;
  static const Color ratingBgColorLight = Color.fromARGB(255, 80, 152, 82);
  static const Color ratingTextColorLight = Colors.white;
  static const Color ratingStarIconColorLight = Color.fromARGB(255, 205, 186, 16);
  static const Color offerTagTextColorLight = Color.fromARGB(255, 253, 229, 9);
  static const Color whiteColor = Colors.white;

  static const Color shadowColorLight = Color.fromARGB(115, 198, 195, 195);
  static Color gradientBlackColor = Colors.black.withValues(alpha: 0.6);
static const Color darkDisabledColor = Colors.black26;

  static const Color homeHeaderBackgroundColor = Color(0xFFFFE6D3);
  static const Color homeHeaderGradientFrom = Color(0xFFFFE6D3);
  static const Color homeHeaderGradientTo = Color(0xFFFFB87A);
  static const double homeHeaderCollapsedHeight = 64.0;
  static const double homeHeaderBannerMinHeight = 130.0;
  static const double homeHeaderBannerMaxHeight = 210.0;
  static const double homeHeaderBannerDefaultHeight = 170.0;
}

final textTheme = TextTheme(
  displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
  displaySmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
  titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  titleSmall: TextStyle(fontSize: 14),
  bodyLarge: TextStyle(fontSize: 17, height: 1.5),
  bodyMedium: TextStyle(fontSize: 15, height: 1.4),
  bodySmall: TextStyle(fontSize: 14),
  labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  labelMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  labelSmall: TextStyle(fontSize: 13),
);

final appThemeData = {
  AppTheme.light: ThemeData(
    fontFamily: 'regular',
    shadowColor: ThemeProvider.greyColorBorder.withValues(alpha: 0.25),
    brightness: Brightness.light,
    primaryColor: ThemeProvider.primaryColor,
    scaffoldBackgroundColor: ThemeProvider.pageBackgroundColor,
    canvasColor: ThemeProvider.canvasColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: ThemeProvider.pageBackgroundColor,
      titleTextStyle: TextStyle(fontFamily: 'bold', fontSize: 18, color: ThemeProvider.canvasColor),
      iconTheme: IconThemeData(color: ThemeProvider.canvasColor, size: 16),
    ),
    colorScheme: ThemeData().colorScheme.copyWith(
      secondary: ThemeProvider.secondaryColor,
      surface: ThemeProvider.greyColorBorder,
      tertiary: ThemeProvider.greyColorText,
      shadow: ThemeProvider.shadowColorLight,
      inverseSurface: ThemeProvider.blueColor,
    ),
    iconTheme: const IconThemeData(color: ThemeProvider.canvasColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ThemeProvider.primaryColor,
      foregroundColor: ThemeProvider.darkCanvasColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
    disabledColor: ThemeProvider.lightDisabledColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(disabledForegroundColor: Colors.black38, disabledBackgroundColor: ThemeProvider.lightDisabledColor),
    ),
    textTheme: textTheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  AppTheme.dark: ThemeData(
    fontFamily: 'regular',
    shadowColor: ThemeProvider.greyColorBorder.withValues(alpha: 0.25),
    brightness: Brightness.dark,
    primaryColor: ThemeProvider.darkPrimaryColor,
    scaffoldBackgroundColor: ThemeProvider.darkPageBackgroundColor,
    canvasColor: ThemeProvider.darkCanvasColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: ThemeProvider.darkPageBackgroundColor,
      titleTextStyle: TextStyle(fontFamily: 'bold', fontSize: 18, color: ThemeProvider.darkPrimaryColor),
      iconTheme: IconThemeData(color: ThemeProvider.pageBackgroundColor, size: 16),
    ),
    colorScheme: ThemeData().colorScheme.copyWith(
      brightness: Brightness.dark,
      secondary: ThemeProvider.darkSecondaryColor,
      surface: ThemeProvider.darkPrimaryColor,
      tertiary: ThemeProvider.darkPrimaryColor,
      shadow: ThemeProvider.darkBackgroundColor,
      inverseSurface: ThemeProvider.darkPrimaryColor,
    ),
    iconTheme: const IconThemeData(color: ThemeProvider.pageBackgroundColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ThemeProvider.darkPrimaryColor,
      foregroundColor: ThemeProvider.darkBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
    disabledColor: ThemeProvider.darkDisabledColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(disabledForegroundColor: Colors.white60, disabledBackgroundColor: ThemeProvider.darkDisabledColor),
    ),
    textTheme: textTheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
};

