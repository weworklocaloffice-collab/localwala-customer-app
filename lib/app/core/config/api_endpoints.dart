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

class ApiEndPoints {
  static V1Request v1request = const V1Request();
  static ExternalRequest externalRequest = const ExternalRequest();
}

class V1Request {
  const V1Request();
  String get getUserSettings => 'v1/public/getDefaultSettings/';
  String get getPageContent => 'v1/public/app_pages/getContent/';
  // Auth Request //
  String get userLogin => 'v1/auth/customer/login/';
  String get userLoginWithPhonePassword => 'v1/auth/customer/login_cmp/';
  String get userLoginWithEmailOtSendVerification =>
      'v1/auth/customer/login_eo_verification/';
  String get userLoginWithEmailOtp => 'v1/auth/customer/login_eo/';
  String get userLoginWithPhoneOTPSendVerification =>
      'v1/auth/customer/login_po_verification/';
  String get userLoginWithPhoneOTPVerified => 'v1/auth/customer/login_po/';
  String get userLoginWithPhoneOTPFirebaseverified =>
      'v1/auth/customer/login_po_firebase/';
  String get forgotPasswordWithEmail => 'v1/auth/forgot-password-email/';
  String get forgotPasswordWithPhone => 'v1/auth/forgot-password-phone/';
  String get updatePassword => 'v1/auth/reset-password';
  String get updatePasswordFirebase => 'v1/auth/reset-password-firebase';
  String get refreshToken => 'v1/auth/refresh-tokens-app/';
  String get logout => 'v1/auth/logout/';
  String get verifyUserAccount => 'v1/auth/verifyAccount/';
  String get verifyOTP => 'v1/auth/verifyOTP/';
  String get resendOTP => 'v1/auth/resendOTP/';
  String get webOTPVerification => 'v1/public/verification/otp/';
  String get registerUserAccount => 'v1/auth/register-user-account/';
  String get registerFirebaseUserAccount =>
      'v1/auth/register-user-account-firebase/';
  String get guestAccount => 'v1/auth/register_guest_account/';
  String get userLoginWithGoogleAccount =>
      'v1/auth/customer/login_with_google_account/';
  String get checkMobileNumberExist => 'v1/auth/customer/check_mobile_exist/';
  String get createGoogleUserAccount =>
      'v1/auth/customer/create_google_user_account/';
  String get userLoginWithFacebookAccount =>
      'v1/auth/customer/login_with_facebook_account/';
  String get createFacebookUserAccount =>
      'v1/auth/customer/create_facebook_user_account/';

  // Auth Request //

  // Profile Routes //
  String get getMyProfile => 'v1/users/profile/user/';
  String get updateMyProfile => 'v1/users/profile/update/';
  String get getAvatarList => 'v1/users/profile/user_avatar/';
  String get getMyMediaFiles => 'v1/users/media/photos/';
  String get referralCode => 'v1/users/profile/getReferralCode/';
  // Profile Routes //

  // Restaurant Request //
  String get nearMeRestaurant => 'v1/public/restaurant/near/';
  String get restaurantCovers => 'v1/public/restaurants/covers/';
  String get restaurantInfo => 'v1/public/restaurant/get_restaurant_info/';
  String get hideRestaurant => 'v1/users/hide/restaurant/';
  String get showHiddenRestaurant => 'v1/users/hide/showHiddenRestaurant/';
  String get getHideRestaurantReasons => 'v1/users/hide_reason/restaurant/';
  String get updateHideRestaurantReason =>
      'v1/users/hide_reason/restaurant/update_reason/';
  String get reportIssueReasonList => 'v1/users/report/reasons/';
  String get reportIssueRestaurant => 'v1/users/report/restaurant/';
  String get getMyHiddenRestaurantList => 'v1/users/hide/restaurants/get/';
  String get getRestaurantReview => 'v1/public/restaurant/reviews/';
  String get getRestaurantDetailInformation =>
      'v1/public/restaurant/detail_information/';
  // Restaurant Request //

  // Dining Restaurant Request //
  String get getDiningRestaurant => 'v1/public/dining_restaurant/near/';
  String get getDiningRestaurantOnMaps =>
      'v1/public/dining_restaurant/near_on_map/';
  String get getDiningByCategory =>
      'v1/public/dining_restaurant/find_with_category/';
  // Dining Restaurant Request //

  // Search Request //
  String get globalSearchInitial => 'v1/public/search/global/initial/';
  String get globalSearch => 'v1/public/search/global/';
  String get foodSearchInitial => 'v1/public/search/food/initial/';
  String get foodSearch => 'v1/public/search/food/';
  String get globalDiningSearchInitial =>
      'v1/public/search/global_dining/initial/';
  String get globalDiningSearch => 'v1/public/search/global_dining/';
  // Search Request //

  // Campaign Request //
  String get foodCampaignDetails => 'v1/public/campaign/food_campaign/';
  String get restaurantCampaignDetails =>
      'v1/public/campaign/restaurant_campaign/';
  String get diningCampaignDetail => 'v1/public/campaign/dining_campaign/';
  // Campaign Request //

  // Sort Request //
  String get restaurantsByCuisine => 'v1/public/restaurant/find_with_cuisine/';
  String get restaurantsByCategory =>
      'v1/public/restaurant/find_with_category/';
  String get restaurantsFoodsByCategory =>
      'v1/public/foods/find_foods_with_category/';
  String get restaurantsByBrands => 'v1/public/restaurant/find_with_brands/';
  String get restaurantsByLocalities =>
      'v1/public/restaurant/find_with_localities/';
  // Sort Request //

  // Favourite Routes //
  String get saveFavourite => 'v1/users/favourite/save/';
  String get favouriteRestaurants => 'v1/users/favourite/restaurants/';
  String get favouriteFoods => 'v1/users/favourite/foods/';
  String get deleteFavouriteRestaurant => 'v1/users/favourite/restaurants/';
  String get deleteFavouriteFood => 'v1/users/favourite/foods/';
  // Favourtie Routes //

  // Food Routes //
  String get getSingleFoodInfo => 'v1/public/foods/single_food/';
  String get getFoodReview => 'v1/public/food/reviews/';
  // Food Routes //

  // Cart Routes //
  String get addToCartServer => 'v1/public/cart/addToCart/';
  String get removeCartItemByRestaurantServer =>
      'v1/public/cart/removeCartItemByRestaurant/';
  String get removeCartItemByTrackingServer =>
      'v1/public/cart/removeCartItemByTracking/';
  String get removeCartItemWithUUIDServer =>
      'v1/public/cart/removeFromCartWithUuid/';
  String get removeCartItemWithFoodIDServer =>
      'v1/public/cart/removeFromCartWithFoodId/';
  String get updateFoodQuantityServer => 'v1/public/cart/updateFoodQuantity/';
  String get updateFoodVariationQuantityServer =>
      'v1/public/cart/updateFoodVariationQuantity/';
  // Cart Routes //

  // Address Routes //
  String get saveAddress => 'v1/users/address/save/';
  String get getMyAddresses => 'v1/users/address/deliveryAddressList/';
  String get updateAddress => 'v1/users/address/update/';
  String get deleteAddress => 'v1/users/address/delete/';
  String get getMyAddressListFromRestaurant =>
      'v1/users/address/myAddressListFromRestaurant/';
  // Address Routes //

  // Orders Routes //
  String get getOrderSettings => 'v1/users/orders/orderSettings/';
  String get createOrder => 'v1/users/orders/createOrder/';
  String get placeOrder => 'v1/users/orders/placeOrderApp/';
  String get getMyOrderList => 'v1/users/orders/getMyOrderList/';
  String get getOrderDetails => 'v1/users/orders/userOrderDetail/';
  String get repayPendingOrder => 'v1/users/orders/repayPendingOrder/';
  String get switchToCod => 'v1/users/orders/switchToCod/';
  String get cancellationReason => 'v1/users/cancellation/user/';
  String get cancelMyOrder => 'v1/users/orders/cancelMyOrder/';
  String get getRefundReasonList => 'v1/users/refund/reasons/';
  String get createRefundRequest => 'v1/users/refund/request/';
  String get orderDetailsForComplaints => 'v1/users/orders/forComplaint/';
  String get saveFavouriteOrder => 'v1/users/favouriteOrders/save/';
  String get removeFavouriteOrder => 'v1/users/favouriteOrders/remove/';
  String get favouriteOrdersList => 'v1/users/orders/getMyFavouriteOrderList/';
  String get orderDetailsForReview =>
      'v1/users/orders/getOrderDetailsForReview/';
  String get orderSumary => 'v1/users/orders/summary/';
  String get orderInvoice => 'v1/users/orders/invoice/';
  // Orders Routes //

  // Review & Rating Routes //
  String get saveOrderReview => 'v1/users/review/save/';
  String get getRestaurantInfoForDirectReview =>
      'v1/users/review/restaurant/direct/';
  String get saveDirectRestaurantReview =>
      'v1/users/review/restaurant/direct/save';
  String get getMyReviewList => 'v1/users/review/myReviewList/';
  String get searchRestaurantForReview => 'v1/users/review/search/restaurants/';
  // Review & Rating Routes //

  // Complaints Routes //
  String get saveComplaints => 'v1/users/complaints/save/';
  // Complaints Routes //

  // Coupon Routes //
  String get userCoupon => 'v1/users/coupon/userCoupon/';
  String get redeemCoupon => 'v1/users/coupon/redeem/';
  // Coupon Routes //

  // Wallet && Loyalty Points Routes //
  String get getWalletPaymentList => 'v1/users/payments/walletList/';
  String get getWalletInfo => 'v1/users/wallet/getMyWalletData/';
  String get getWalletPaymentLink => 'v1/users/payments/initiate/';
  String get getLoyaltyPoints => 'v1/users/loyaltyPoints/getMyLoyaltyPoints/';
  String get redeemLoyaltyPoints => 'v1/users/loyaltyPoints/redeemPoints/';
  // Wallet && Loyalty Points Routes //

  // Payment Routes //
  String get makePayment => 'v1/public/payments/makePayment/';
  String get paidSuccess => 'v1/public/payments/paid_success/';
  // Payment Routes //

  // Push Notification Token Request //
  String get savePushNotificationToken => 'v1/public/pushTokens/save/';
  String get updatePushNotificationToken => 'v1/public/pushTokens/update/';
  // Push Notification Token Request //

  // Media Routes //
  String get uploadImageFile => 'v1/file/uploadImage/';
  String get removeImageFile => 'v1/users/media/deleteMyImage/';
  String get uploadPublicImageFile => 'v1/public/uploadImage/';
  // Media Routes //

  // Notification Routes //
  String get notificationCount => 'v1/users/notification/count/';
  String get notificationList => 'v1/users/notification/list/';
  String get readAllNotification => 'v1/users/notification/readAll/';
  // Notification Routes //

  // Subscription Tiffin Packages Routes //
  String get getSubscriptionTiffinInfo => 'v1/public/tiffin_packages/info/';
  String get buySubscriptionTiffinInfo => 'v1/users/tiffin_packages/buy/';
  String get purchaseTiffinSubscription =>
      'v1/users/tiffin_packages/purchase_tiffin_package/';
  String get purchasedSubscriptionList => 'v1/users/tiffin_packages/purchased/';
  String get purchasedSubscriptionInfo =>
      'v1/users/tiffin_packages/purchased/info/';
  String get repayTiffinSubscriptionPackage =>
      'v1/users/tiffin_packages/repayPendingSubscriptionPackage/';
  String get tiffinSubscriptionCancellationReason =>
      'v1/users/tiffin_subscription_cancel_reason/user/';
  String get tiffinSubscriptionRequestOffDay =>
      'v1/users/tiffin_packages/requestOffDay/';
  String get userCancelTiffinSubscriptionPackage =>
      'v1/users/tiffin_packages/userCancelTiffinSubscription/';
  String get tiffinSubscriptionRefundReason =>
      'v1/users/tiffin_subscription_refund/reasons';
  String get tiffinSubscriptionRefundRequest =>
      'v1/users/tiffin_subscription_refund/sendRefundRequest/';
  String get tiffinSubscriptionListFromRestaurant =>
      'v1/public/tiffin_packages/from_restaurant/';
  String get tiffinSubscriptionDownloadSummary =>
      'v1/users/tiffin_packages/summary/';
  String get tiffinSubscriptionDownloadInvoice =>
      'v1/users/tiffin_packages/invoice/';
  // Subscription Tiffin Packages Routes //

  // Dining Booking Routes //
  String get getDiningBookingInformation => 'v1/public/dining_booking/info/';
  String get getDiningBookingConfirmation => 'v1/users/dining_booking/confirm/';
  String get verifyDiningCoupon => 'v1/users/dining_coupon/redeem/';
  String get createDiningBooking => 'v1/users/dining_booking/create/';
  String get getDiningBookingList => 'v1/users/dining_booking/list/';
  String get searchDiningBookingList => 'v1/users/dining_booking/search/';
  String get diningBookingDetailInformation =>
      'v1/users/dining_booking/information/';
  String get repayPendingBookingPayment =>
      'v1/users/dining_booking/repayPendingBooking/';
  String get diningBookingCancellationReasonList =>
      'v1/users/dining_booking/cancellation/user/';
  String get cancelDiningBooking =>
      'v1/users/dining_booking/cancelMyDiningBooking/';
  String get diningBookingRefundReason =>
      'v1/users/dining_booking_refund/reasons/';
  String get diningBookingRefundRequest =>
      'v1/users/dining_booking_refund/request/';
  String get diningBookingSummary => 'v1/users/dining_booking/summary/';
  String get diningBookingInvoice => 'v1/users/dining_booking/invoice/';
  // Dining Booking Routes //

  // Tranactions Routes //
  String get orderPaymentTransaction => 'v1/users/transaction/orders/';
  String get diningPaymentTransaction => 'v1/users/transaction/booking/';
  String get foodSubscriptionPaymentTransaction =>
      'v1/users/transaction/food_subscription/';
  // Tranactions Routes //

  // Phone Number Routes //
  String get fetchRestaurantPhoneNumber => 'v1/public/restaurant/call/';
  String get fetchDriverPhoneNUmber => 'v1/users/driver/call/';
  // Phone Number Routes //

  // Chat Messages Routes //
  String get fetchChatMessages => 'v1/users/chat_room/fetchMessages/';
  String get sendChatMessage => 'v1/users/chat_room/sendMessage/';
  String get chatList => 'v1/users/chat_room/list/';
  String get getChatConversion => 'v1/users/chat_room/conversion/';
  // Chat Messages Routes //

  // Support Chat Message Routes //
  String get fetchSupportChatMessages =>
      'v1/users/support_chat_room/fetchMessages/';
  String get supportChatList => 'v1/users/support_chat_room/list/';
  String get sendSupportChatMessage =>
      'v1/users/support_chat_room/sendMessage/';
  String get supportChatChips => 'v1/users/support_chat_room/chips';
  String get getSupportChatConversion =>
      'v1/users/support_chat_room/conversion/';

  // Enterprise bot-first -> human handover routes (v1/users/support_chat_room/*)
  String get supportBotStart => 'v1/users/support_chat_room/bot/start';
  String get supportBotMessage => 'v1/users/support_chat_room/bot/message';
  String get supportQueueStatus => 'v1/users/support_chat_room/queue/';
  String get supportHandover => 'v1/users/support_chat_room/handover/';
  String get supportCsat => 'v1/users/support_chat_room/csat/';
  String get supportReopen => 'v1/users/support_chat_room/reopen/';
  // Support Chat Message Routes //

  // Feedback & Report Emergecy Routes //
  String get saveFeedbackForm => 'v1/public/feedback_form/save/';
  String get saveReportEmergencyForm => 'v1/public/report_emergency/save/';
  // Feedback & Report Emergecy Routes //

  String get localityByCity => 'v1/public/localities_from_city/';

  // Deliveryman Register Request Routes //
  String get deliverymanGetBasicRegisterRequestDetail =>
      'v1/public/deliveryman_joining/getBasicDataDeliverymanRequest/';
  String get deliverymanJoiningRequest =>
      'v1/public/deliveryman_joining/request/';
  // Deliveryman Register Request Routes //

  // Restaurant Register Restaurant Routes //
  String get restaurantRegisterRequestBasicDetail =>
      'v1/public/register/getBasicDataRestaurantRequest';
  String get restaurantRegisterRequest =>
      'v1/public/restaurant_joining/request/';
  String get getActiveCuisine => 'v1/public/restaurant/activeCuisine/';
  String get getActiveRestaurantType => 'v1/public/restaurant/activeType/';
  String get getActiveRestaurantFacility =>
      'v1/public/restaurant/activeFacility/';
  String get checkRegisterStatus => 'v1/auth/check-register-status/';
  // Restaurant Register Restaurant Routes //

  // Account Setting Routes //
  String get updateAccountPassword =>
      'v1/users/account_setting/update_password/';
  String get updateAccountEmail => 'v1/users/account_setting/update_email/';
  String get updateAccountEmailAfterVerification =>
      'v1/users/account_setting/update_email_after_verification/';
  String get updateAccountMobileNumber =>
      'v1/users/account_setting/update_mobile_number/';
  String get updateAccountMobileNumberAfterVerification =>
      'v1/users/account_setting/update_mobile_number_after_verification/';
  String get updateAccountMobileNumberAfterFirebaseVerification =>
      'v1/users/account_setting/update_mobile_number_after_firebase_verification/';
  String get accountDeleteReasonList => 'v1/users/delete_account_reason_list/';
  String get deleteUserAccount => 'v1/users/account_setting/delete_account/';
  String get userNotificationSetting =>
      'v1/users/account_setting/notification_setting/';
  String get updateNotificationSetting =>
      'v1/users/account_setting/notification_setting/';
  String get updateUserLocale => 'v1/users/account_setting/update_locale';
  // Account Setting Routes //

  // Social Routes //
  String get syncContacts => 'v1/social/contacts/sync/';
  String get socialPrivacy => 'v1/social/privacy/';
  // Social Routes //

  // Reels Routes //
  String get reelsFeed => 'v1/reels/feed/';
  String reelLike(String id) => 'v1/reels/$id/like/';
  String reelSave(String id) => 'v1/reels/$id/save/';
  String reelShare(String id) => 'v1/reels/$id/share/';
  String reelView(String id) => 'v1/reels/$id/view/';
  String reelComments(String id) => 'v1/reels/$id/comments/';
  String reelComment(String id) => 'v1/reels/$id/comment/';
  String reelReport(String id) => 'v1/reels/$id/report/';
  // Reels Routes //

  // Real Estate public (guest) //
  String get reCategories => 'v1/realestate/public/categories';
  String get reCategoriesGrouped => 'v1/realestate/public/categories/grouped';
  String reCategoryByKey(String key) => 'v1/realestate/public/categories/$key';
  String get reSearchProperties => 'v1/realestate/public/properties';
  String get reFeaturedProperties => 'v1/realestate/public/properties/featured';
  String get reRecentProperties => 'v1/realestate/public/properties/recent';
  String get rePropertyFilters => 'v1/realestate/public/properties/filters';
  String rePropertyByCode(String code) =>
      'v1/realestate/public/properties/by-code/$code';
  String rePropertyById(String id) => 'v1/realestate/public/properties/$id';
  String reSimilarProperties(String id) =>
      'v1/realestate/public/properties/$id/similar';
  String get reNearbyProperties => 'v1/realestate/public/properties/nearby';

  // Real Estate customer (auth) //
  String get reCreateEnquiry => 'v1/realestate/customer/properties';
  String get reMyLeads => 'v1/realestate/customer/leads';
  String reMyLeadById(String id) => 'v1/realestate/customer/leads/$id';
  String reWithdrawLead(String id) =>
      'v1/realestate/customer/leads/$id/withdraw';
  String reLeadActivity(String id) =>
      'v1/realestate/customer/leads/$id/activity';
  // Saved properties (Favourite with type: 'property') — reuses the
  // shared Favourite model; the customer route is the consumer.
  String get reSavedProperties => 'v1/realestate/customer/saved-properties';
  String reSavedPropertyStatus(String id) =>
      'v1/realestate/customer/saved-properties/$id/status';
  String reSavedProperty(String id) =>
      'v1/realestate/customer/saved-properties/$id';

  // Holds — customer money in trust (BR-13). Create → pay via the
  // `property_hold` payment branch → ACTIVE. Cancel creates the PENDING
  // refund; the `property_hold_refund` branch completes it.
  String get reCreateHold => 'v1/realestate/customer/holds';
  String get reMyHolds => 'v1/realestate/customer/holds';
  String reMyHoldById(String id) => 'v1/realestate/customer/holds/$id';
  // Pay a PENDING_PAYMENT hold: creates the `property_hold` initiation
  // and returns its id as payLink for the shared MakePayment screen.
  // On gateway confirm the hold becomes ACTIVE (2 ledger rows).
  String rePayHold(String id) => 'v1/realestate/customer/holds/$id/pay';
  String reCancelHold(String id) => 'v1/realestate/customer/holds/$id/cancel';
  String reConvertHoldToSale(String id) =>
      'v1/realestate/customer/holds/$id/convert_to_sale';

  // Site visits (Flow 11). The customer asks; the assignment engine
  // assigns — there is no executive/status field in the body.
  String get reRequestVisit => 'v1/realestate/customer/visits';
  String get reMyVisits => 'v1/realestate/customer/visits';
  String reMyVisitById(String id) => 'v1/realestate/customer/visits/$id';

  // Loans (Flow 12). POST fans the request out to every active bank as
  // one application each; GET returns requests with applications +
  // offers nested, so list, detail and compare are one call each.
  String get reRequestLoan => 'v1/realestate/customer/loans';
  String get reMyLoans => 'v1/realestate/customer/loans';
  String reMyLoanById(String id) => 'v1/realestate/customer/loans/$id';
  // Choose one bank offer; the server closes the losing offers and moves
  // the selected application to DOCUMENTS_PENDING for bank review.
  String reAcceptLoanOffer(String requestId, String offerId) =>
      'v1/realestate/customer/loans/$requestId/offers/$offerId/accept';

  // Purchases (sale history). A purchase is a recorded sale - created by
  // the hold conversion, never by the customer. Read-only for the
  // customer: the tenant comes from the token.
  String get reMyPurchases => 'v1/realestate/customer/purchases';
  String reMyPurchaseById(String id) =>
      'v1/realestate/customer/purchases/$id';

  // Property verification metadata (BR-18). Types only - never a file
  // url, never a filename.
  String rePropertyVerification(String id) =>
      'v1/realestate/public/properties/$id/verification';

  // Document requests (Flow 12 underwriting). The bank asks for a
  // document; the customer answers with an uploaded file.
  String get reMyDocumentRequests =>
      'v1/realestate/customer/document-requests';
  String reSubmitDocumentRequest(String id) =>
      'v1/realestate/customer/document-requests/$id/submit';
}

class ExternalRequest {
  const ExternalRequest();
  String get googlePlaces =>
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
}
