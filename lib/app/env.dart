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

class Environments {
  static const String appName = 'Localwala-Customer'; // Required
  static const String companyName = 'weworklocal pvt ltd'; // Required
  static const String apiBaseURL = 'https://localwala.tech/'; // Required
  static const String googleMapsKey = 'AIzaSyCLCTAc__MeePzQmK9lL_HEipNFGy3VuS8'; // Required
  static const String defaultLanguage = 'en'; // Required
  static const String defaultCountryCode = '+91'; // append + // Required
  static const int payPendingAmountBeforeMinutesOffCreation = 30; // Use Only Minutes
  static const supportedLanguages = [Locale('en'), Locale('ar'), Locale('hi'), Locale('es')];
}

class LanguageEntityModel {
  final String code;
  final String value;
  final String locale;
  final String title;
  final String activeImage;
  final String deactiveImage;
  final String description;
  final String selectText;

  const LanguageEntityModel({required this.code, required this.value, required this.locale, required this.title, required this.activeImage, required this.deactiveImage, required this.description, required this.selectText});
}

class AppSupportedLanguagesModel {
  const AppSupportedLanguagesModel._();

  static const languages = [
    LanguageEntityModel(
      code: 'en',
      value: 'English',
      locale: 'en_US',
      title: 'Select Language',
      activeImage: 'assets/images/languages/usa-active.png',
      deactiveImage: 'assets/images/languages/usa-deactive.png',
      description: "Please select your preferred language for a seamless experience with our food delivery app. Choose English to navigate, order, and enjoy your meals with ease.",
      selectText: 'Select',
    ),
    LanguageEntityModel(
      code: 'ar',
      value: 'عربي',
      locale: 'ar_SA',
      title: 'اختر اللغة',
      activeImage: 'assets/images/languages/arabic-active.png',
      deactiveImage: 'assets/images/languages/arabic-deactive.png',
      description: "يرجى تحديد لغتك المفضلة للحصول على تجربة سلسة مع تطبيق توصيل الطعام الخاص بنا. اختر اللغة العربية للتنقل وطلب والاستمتاع بوجباتك بكل سهولة.",
      selectText: 'حدده',
    ),
    LanguageEntityModel(
      code: 'hi',
      value: 'हिंदी',
      locale: 'hi_IN',
      title: 'भाषा चुने',
      activeImage: 'assets/images/languages/india-active.png',
      deactiveImage: 'assets/images/languages/india-deactive.png',
      description: "हमारे फ़ूड डिलीवरी ऐप के साथ सहज अनुभव के लिए कृपया अपनी पसंदीदा भाषा चुनें। आसानी से नेविगेट करने, ऑर्डर करने और अपने भोजन का आनंद लेने के लिए हिंदी चुनें।",
      selectText: 'चुनें',
    ),
    LanguageEntityModel(
      code: 'es',
      value: 'Español',
      locale: 'es_ES',
      title: 'Seleccionar idioma',
      activeImage: 'assets/images/languages/spanish-active.png',
      deactiveImage: 'assets/images/languages/spanish-deactive.png',
      description: "Seleccione su idioma preferido para disfrutar de una experiencia perfecta con nuestra aplicación de entrega de alimentos. Elija español para navegar, ordenar y disfrutar sus comidas con facilidad.",
      selectText: 'Selecciónelo',
    ),
  ];
}
