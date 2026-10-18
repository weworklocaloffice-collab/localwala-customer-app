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

class AssetsUrl {
  static ImageURL imageURL = const ImageURL();
  static LocalURL localURL = const LocalURL();
  static IconsURL iconsURL = const IconsURL();
}

class ImageURL {
  const ImageURL();

  String get googleSocialLogin => 'assets/images/other/google.png';
  String get appleSocialLogin => 'assets/images/other/apple.png';
  String get facebookSocialLogin => 'assets/images/other/facebook.png';
  String get placeholderImage => 'assets/images/other/placeholder.jpeg';

  String get welcomeOne => 'assets/images/other/welcome_one.png';
  String get welcomeTwo => 'assets/images/other/welcome_two.png';
  String get welcomeThree => 'assets/images/other/welcome_three.png';
  String get welcomeFour => 'assets/images/other/welcome_four.png';
  String get welcomeFive => 'assets/images/other/welcome_five.png';

  String get foodVegType => 'assets/images/other/veg.png';
  String get foodNonVegType => 'assets/images/other/nonveg.png';
  String get foodVeganType => 'assets/images/other/vegan.png';

  String get errorNotFound => 'assets/images/error/404.png';
  String get errorInternet => 'assets/images/error/internetfailed.png';
  String get errorMaintenance => 'assets/images/error/maintenance.png';
  String get errorServer => 'assets/images/error/server.png';

  String get referralModal => 'assets/images/other/referral.png';

  String get locationMap => 'assets/images/other/location-map.png';
  String get locationPermission => 'assets/images/other/location-permission.png';
  String get locationPin => 'assets/images/other/location-pin.png';
  String get unauthorized => 'assets/images/other/unauthorized.png';
  String get noSlotForDining => 'assets/images/other/no-slot-for-dining.png';

  String get homeEmpty => 'assets/images/other/home-empty.png';
  String get cartEmpty => 'assets/images/other/empty-cart.png';

  String get offerTag => 'assets/images/other/offer.png';

  String get deliveryGratitude => 'assets/images/other/gratitude.png';

  String get addressHome => 'assets/images/other/address-home.png';
  String get addressHotel => 'assets/images/other/address-hotel.png';
  String get addressWork => 'assets/images/other/address-work.png';
  String get addressOther => 'assets/images/other/address-other.png';

  String get checkoutDelivery => 'assets/images/other/checkout-delivery.png';
  String get checkoutTakeaway => 'assets/images/other/checkout-takeaway.png';

  String get couponDefault => 'assets/images/other/coupon-percentage.png';
  String get couponRestaurant => 'assets/images/other/coupon-restaurant.png';
  String get couponFreeDelivery => 'assets/images/other/coupon-free-delivery.png';
  String get couponFirstOrder => 'assets/images/other/coupon-first-order.png';
  String get couponLoyality => 'assets/images/other/coupon-coin.png';
  String get couponBOGO => 'assets/images/other/coupon-buy-one-get-one-free.png';
  String get couponDining => 'assets/images/other/coupon-dining.png';

  String get notDelivered => 'assets/images/other/not_delivered.png';

  String get moneyDeposite => 'assets/images/other/deposite.png';
  String get moneyWithdrawal => 'assets/images/other/withdrawal.png';
  String get noMoney => 'assets/images/other/no-money.png';

  String get loyaltyPointsCoupon => 'assets/images/other/points-coupon.png';
  String get loyaltyPointsOrders => 'assets/images/other/points-orders.png';

  String get pureVegImage => 'assets/images/other/pure-veg.png';

  String get restaurantMarkerColor => 'assets/images/icons/marker_restaurant_color.png';
  String get userMarkerColor => 'assets/images/icons/marker_user_color.png';

  String get bookingApproved => 'assets/images/other/booking_approved.png';
  String get bookingCancelled => 'assets/images/other/booking_cancelled.png';
  String get bookingCompleted => 'assets/images/other/booking_completed.png';
  String get bookingCreated => 'assets/images/other/booking_created.png';
  String get bookingPayment => 'assets/images/other/booking_payment.png';
  String get bookingRejected => 'assets/images/other/booking_rejected.png';

  String get normalErrorIcon => 'assets/images/other/normal-error-icon.png';
  String get unAuthorizedErrorIcon => 'assets/images/other/unauthorized-error-icon.png';

  String get successIcon => 'assets/images/other/success-icon.png';
  String get forceUpdateIcon => 'assets/images/other/force-update.png';

  String get referralCodeIcon => 'assets/images/other/referral-code.png';

  String get subscriptionPermission => 'assets/images/other/subscription-permission.png';
  String get subscriptionNoPermission => 'assets/images/other/subscription-no-permission.png';

  String get registerRequestSaved => 'assets/images/other/register-request-saved.png';

  String get socialFacebook => 'assets/images/other/social_facebook.png';
  String get socialInstagram => 'assets/images/other/social_instagram.png';
  String get socialX => 'assets/images/other/social_twitter.png';
  String get socialYoutube => 'assets/images/other/social_youtube.png';
  String get socialLinkedIn => 'assets/images/other/social_linkedin.png';
  String get socialPinterest => 'assets/images/other/social_pinterest.png';

  String get splashIcon => 'assets/images/other/splash_icon.png';
  String get successPaymentIcon => 'assets/images/other/success_payment.png';
}

class LocalURL {
  const LocalURL();
  String get countryCodeList => 'assets/jsons/countryCodes.json';
}

class IconsURL {
  const IconsURL();
  String get bottomTabDelivery => 'assets/images/tabs/delivery.png';
  String get bottomTabDining => 'assets/images/tabs/dining.png';
  String get bottomTabHistory => 'assets/images/tabs/history.png';
  String get bottomTabFavourite => 'assets/images/tabs/favourite.png';
  String get bottomTabFavouriteActive => 'assets/images/tabs/favourite_active.png';
  String get bottomTabAccount => 'assets/images/tabs/account.png';

  String get priceTag => 'assets/images/icons/cash.png';
  String get timeTag => 'assets/images/icons/clock.png';
  String get starTag => 'assets/images/icons/star.png';
  String get locationMarkerTag => 'assets/images/icons/location.png';

  String get favouriteFull => 'assets/images/icons/heart_full.png';
  String get favouriteEmpty => 'assets/images/icons/heart_empty.png';
  String get closeIcon => 'assets/images/icons/close.png';

  String get couponIcon => 'assets/images/icons/coupons.png';

  String get billIcon => 'assets/images/other/bill.png';
  String get phoneCallIcon => 'assets/images/other/phone-call.png';

  String get billDeliveryIcon => 'assets/images/other/bill-delivery.png';
  String get billDiscountIcon => 'assets/images/other/bill-discount.png';
  String get billItemTotalIcon => 'assets/images/other/bill-item-total.png';
  String get billPackageIcon => 'assets/images/other/bill-package.png';
  String get billTaxIcon => 'assets/images/other/bill-tax.png';

  String get driverMarker => 'assets/images/icons/marker_deliveryman.png';
  String get restaurantMarker => 'assets/images/icons/marker_restaurant.png';
  String get userMarker => 'assets/images/icons/marker_user.png';

  String get rate1EmojiOff => 'assets/images/ratings/1-star-off-emoji.png';
  String get rate1EmojiOn => 'assets/images/ratings/1-star-on-emoji.png';

  String get rate2EmojiOff => 'assets/images/ratings/2-star-off-emoji.png';
  String get rate2EmojiOn => 'assets/images/ratings/2-star-on-emoji.png';

  String get rate3EmojiOff => 'assets/images/ratings/3-star-off-emoji.png';
  String get rate3EmojiOn => 'assets/images/ratings/3-star-on-emoji.png';

  String get rate4EmojiOff => 'assets/images/ratings/4-star-off-emoji.png';
  String get rate4EmojiOn => 'assets/images/ratings/4-star-on-emoji.png';

  String get rate5EmojiOff => 'assets/images/ratings/5-star-off-emoji.png';
  String get rate5EmojiOn => 'assets/images/ratings/5-star-on-emoji.png';

  String get rateEmojiOff => 'assets/images/ratings/star-off-emoji.png';

  String get starRatingOff => 'assets/images/ratings/star-off.png';
  String get starRatingOn => 'assets/images/ratings/star-on.png';
}

class SysFlags {
  static const String c1 = "RJ-FDR-LIB-9X7A-ECIT-UA";
  static const String c2 = "FDR-LIB-RJ-2025";
  static const int m1 = 0x2A + 0x19;
}

