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

class SharedPreferencesKey {
  static PublicKeys publicKeys = const PublicKeys();
  static AuthKeys authKeys = const AuthKeys();
}

class PublicKeys {
  const PublicKeys();
  String get introKey => '_intro';
  String get userTrackingId => '_userTrackingId';
  String get businessEmail => '_businessEmail';
  String get businessMobile => '_businessMobile';
  String get companyNameKey => '_companyName';
  String get currencySymbolKey => '_currencySymbol';
  String get currencySide => '_currencySide';
  String get defaultLanguage => '_defaultLanguage';
  String get defaultCountryCode => '_defaultCountryCode';
  String get mediaUrl => '_mediaUrl';
  String get isDark => '_isDark';
  String get userLatitude => '_userLatitude';
  String get userLongitude => '_userLongitude';
  String get userAddress => '_userAddress';
  String get userAddressTitle => '_userAddressTitle';
  String get canEarnBuyFromReferral => '_canEarnBuyFromReferral';
  String get signUpVerification => '_signUpVerification';
  String get userLoginWith => '_userLoginWith';
  String get userResetPasswordWith => '_userResetPasswordWith';
  String get websiteUrl => '_websiteUrl';
  String get loginSkip => '_loginSkip';
  String get localSearchHistory => '_localSearchHistory';
  String get savedInCart => '_cart';
  String get guestCheckout => '_guestCheckout';
  String get userCartId => '_userCartId';
  String get checkoutAddressId => '_checkoutAddressId';
  String get globalSearchHistory => '_globalSearchHistory';
  String get socialAppleSignIn => '_socialAppleSignIn';
  String get socialGoogleSignIn => '_socialGoogleSignIn';
  String get googleOAuthClientId => '_googleOAuthClientId';
  String get googleOAuthServerId => '_googleOAuthServerId';
  String get socialFacebookSignIn => '_socialFacebookSignIn';
  String get vendorSelfRegisterButton => '_vendorSelfRegisterButton';
  String get driverSelfRegisterButton => '_driverSelfRegisterButton';
  String get realEstateRecentlyViewed => '_realEstateRecentlyViewed';
  String get campaignId => '_campaignId';
  String get campaignType => '_campaignType';
  String get isGoogleLoggedIn => '_isGoogleLoggedIn';
  String get isFacebookLoggedIn => '_isFacebookLoggedIn';
  String get androidUrl => '_androidUrl';
  String get androidVersion => '_androidVersion';
  String get iosUrl => '_iosUrl';
  String get iosVersion => '_iosVersion';
  String get appLogo => '_appLogo';
}

class AuthKeys {
  const AuthKeys();
  String get uid => '_uid';
  String get authToken => '_authToken';
  String get authRefreshToken => '_authRefreshToken';
  String get userFirstName => '_userFirstName';
  String get userLastName => '_userLastName';
  String get userCountryCode => '_userCountryCode';
  String get userMobile => '_userMobile';
  String get userCover => '_userCover';
  String get userEmail => '_userEmail';
  String get userRole => '_userRole';
  String get userCartId => '_userCartId';
}

