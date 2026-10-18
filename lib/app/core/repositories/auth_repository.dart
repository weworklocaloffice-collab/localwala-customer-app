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

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/core/models/request/account_update_email_after_verification_request_model.dart';
import 'package:user/app/core/models/request/account_update_email_request_model.dart';
import 'package:user/app/core/models/request/account_update_mobile_number_after_firebase_verification_request_model.dart';
import 'package:user/app/core/models/request/account_update_mobile_number_after_verification_request_model.dart';
import 'package:user/app/core/models/request/account_update_mobile_number_request_model.dart';
import 'package:user/app/core/models/request/account_update_notification_setting_request_model.dart';
import 'package:user/app/core/models/request/account_update_password_request_model.dart';
import 'package:user/app/core/models/request/check_mobile_number_exist_request_model.dart';
import 'package:user/app/core/models/request/check_restaurant_register_request_model.dart';
import 'package:user/app/core/models/request/deliveryman_joining_request_model.dart';
import 'package:user/app/core/models/request/email_otp_login_request_model.dart';
import 'package:user/app/core/models/request/email_otp_send_verification_mail_request_model.dart';
import 'package:user/app/core/models/request/email_password_login_request_model.dart';
import 'package:user/app/core/models/request/facebook_account_login_request_model.dart';
import 'package:user/app/core/models/request/feedback_form_request_model.dart';
import 'package:user/app/core/models/request/forgot_password_with_email_request_model.dart';
import 'package:user/app/core/models/request/forgot_password_with_phone_request_model.dart';
import 'package:user/app/core/models/request/google_account_login_request_model.dart';
import 'package:user/app/core/models/request/otp_request_model.dart';
import 'package:user/app/core/models/request/phone_otp_firebase_verify_request_model.dart';
import 'package:user/app/core/models/request/phone_otp_send_verification_sms_request_model.dart';
import 'package:user/app/core/models/request/phone_otp_verified_request_model.dart';
import 'package:user/app/core/models/request/phone_password_login_request_model.dart';
import 'package:user/app/core/models/request/push_notification_token_request_model.dart';
import 'package:user/app/core/models/request/register_facebook_user_account_request_model.dart';
import 'package:user/app/core/models/request/register_firebase_request_model.dart';
import 'package:user/app/core/models/request/register_google_user_account_request_model.dart';
import 'package:user/app/core/models/request/register_request_model.dart';
import 'package:user/app/core/models/request/report_emergency_request_model.dart';
import 'package:user/app/core/models/request/restaurant_joining_request_model.dart';
import 'package:user/app/core/models/request/update_locale_request_model.dart';
import 'package:user/app/core/models/request/update_password_firebase_request_model.dart';
import 'package:user/app/core/models/request/update_password_request_model.dart';
import 'package:user/app/core/models/request/update_user_profile_request_model.dart';
import 'package:user/app/core/models/request/user_account_delete_request_model.dart';
import 'package:user/app/core/models/user_login_response_model.dart';
import 'package:user/app/core/models/user_register_response_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/services/shared_pref.dart';

class AuthRepository {
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();
  final ApiRequestService _apiRequestService = ApiRequestService();

  Future<void> saveEvent(String eventName, Map<String, String> eventParam, String screenClasss, String screenName) async {
    if (!kIsWeb) {
      FirebaseAnalytics analytics = FirebaseAnalytics.instance;
      await analytics.logEvent(name: eventName, parameters: eventParam);
      await analytics.logScreenView(screenClass: screenClasss, screenName: screenName);
    }
  }

  Future<String> userId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
  }

  Future<String> userFirstName() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userFirstName) ?? '';
  }

  Future<String> userLastName() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userLastName) ?? '';
  }

  Future<String> userEmail() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userEmail) ?? '';
  }

  Future<String> userMobile() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userMobile) ?? '';
  }

  Future<String> userCountryCode() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userCountryCode) ?? '';
  }

  Future<String> userCover() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userCover) ?? '';
  }

  Future<DioApiResponse> savePushNotificationToken(PushNotificationTokenRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.savePushNotificationToken, body: param);
  }

  Future<String> userLoginWith() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.userLoginWith) ?? '';
  }

  Future<String> websiteURL() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.websiteUrl) ?? '';
  }

  Future<String> userResetPasswordWith() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.userResetPasswordWith) ?? '';
  }

  Future<bool> isGuestCheckout() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.guestCheckout);
  }

  Future<bool> haveLocation() async {
    bool userLatitude = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.userLatitude);
    bool userLongitude = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.userLongitude);
    if (userLatitude && userLongitude) {
      return true;
    }
    return false;
  }

  Future<bool> isAuthorized() async {
    bool uid = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.authKeys.uid);
    bool authToken = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.authKeys.authToken);
    String? userRole = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userRole);
    if (uid && authToken && userRole != null && userRole != '' && userRole.isNotEmpty && userRole == 'user') {
      return true;
    }
    return false;
  }

  Future<String> getRefreshToken() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.authRefreshToken) ?? '';
  }

  Future<DioApiResponse> logout(String refreshToken) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.logout, body: {'refreshToken': refreshToken});
  }

  Future<void> skipLogin() async {
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.loginSkip, true);
  }

  Future<String> getDefaultCountryCode() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultCountryCode) ?? '';
  }

  Future<bool> getReferralSystemStatus() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.canEarnBuyFromReferral);
  }

  Future<bool> haveVerificationOnSignUp() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.signUpVerification);
  }

  Future<DioApiResponse> loginWithEmailPassword(EmailPasswordLoginRequest login) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.userLogin, body: login);
  }

  Future<DioApiResponse> loginWithPhonePassword(PhonePasswordLoginRequestModel login) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.userLoginWithPhonePassword, body: login);
  }

  Future<DioApiResponse> loginWithEmailOtpSendEmailVerificationMail(LoginWithEmailOtpSendVerificationMailRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.userLoginWithEmailOtSendVerification, body: param);
  }

  Future<DioApiResponse> loginWithEmailOtp(LoginWithEmailOtpRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.userLoginWithEmailOtp, body: param);
  }

  Future<DioApiResponse> loginWithPhoneOtpSendVerificationSMS(LoginWithPhoneOtpSendVerificationSMSRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.userLoginWithPhoneOTPSendVerification, body: param);
  }

  Future<DioApiResponse> loginWithPhoneOtpVerified(PhoneOTPVerifiedLoginRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.userLoginWithPhoneOTPVerified, body: param);
  }

  Future<DioApiResponse> loginWithPhoneOtpFirebaseVerified(PhoneOTPFirebaseVerifyRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.userLoginWithPhoneOTPFirebaseverified, body: param);
  }

  Future<DioApiResponse> forgotPasswordWithEmail(ForgotPasswordWithEmailRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.forgotPasswordWithEmail, body: param);
  }

  Future<DioApiResponse> forgotPasswordWithPhone(ForgotPasswordWithPhoneRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.forgotPasswordWithPhone, body: param);
  }

  Future<DioApiResponse> updatePassword(UpdatePasswordRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.updatePassword, body: param);
  }

  Future<DioApiResponse> updatePasswordFirebase(UpdatePasswordFirebaseRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.updatePasswordFirebase, body: param);
  }

  Future<DioApiResponse> registerGuestAccount(String agent, String locale) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.guestAccount}$agent/$locale');
  }

  Future<DioApiResponse> verifySignupAccount(UserRegisterRequest register) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.verifyUserAccount, body: register);
  }

  Future<DioApiResponse> createUserAccount(UserRegisterRequest register) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.registerUserAccount, body: register);
  }

  Future<DioApiResponse> createUserFirebaseAccount(UserFirebaseRegisterRequest register) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.registerFirebaseUserAccount, body: register);
  }

  Future<DioApiResponse> verifyOTP(OTPRequest otp) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.verifyOTP, body: otp);
  }

  Future<DioApiResponse> resendOTP(String id) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.resendOTP}$id/');
  }

  Future<DioApiResponse> getPageContent(String slug) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.getPageContent}$slug/');
  }

  Future<List<AppDefaultCountryCodeConfigModel>> getCountryList() async {
    final jsonString = await rootBundle.loadString(AssetsUrl.localURL.countryCodeList);
    final listOfJsonElements = jsonDecode(jsonString) as List;
    return listOfJsonElements.map((jsonElement) => AppDefaultCountryCodeConfigModel.fromJson(jsonElement)).toList();
  }

  Future<void> saveRegisterResponse(UserRegisterResponseModel response) async {
    await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.uid, response.user!.id!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.authToken, response.tokens!.access!.token!);
    if (response.tokens != null && response.tokens!.refresh != null && response.tokens!.refresh!.token!.isNotEmpty) {
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.authRefreshToken, response.tokens!.refresh!.token!);
    }
    if (response.user!.id!.isNotEmpty) {
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userFirstName, response.user!.firstName!);
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userLastName, response.user!.lastName!);
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userCover, response.user!.image!);
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userEmail, response.user!.email!);
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userCountryCode, response.user!.countryCode!.toString());
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userMobile, response.user!.mobile!);
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userRole, response.user!.role!);
    }
  }

  Future<void> saveLoginResponse(UserLoginResponseModel response) async {
    await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.uid, response.user!.id!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.authToken, response.tokens!.access!.token!);
    if (response.tokens != null && response.tokens!.refresh != null && response.tokens!.refresh!.token!.isNotEmpty) {
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.authRefreshToken, response.tokens!.refresh!.token!);
    }
    if (response.user!.id!.isNotEmpty) {
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userFirstName, response.user!.firstName!);
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userLastName, response.user!.lastName!);
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userCover, response.user!.image!);
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userEmail, response.user!.email!);
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userCountryCode, response.user!.countryCode!.toString());
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userMobile, response.user!.mobile!);
      await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userRole, response.user!.role!);
    }
  }

  Future<void> updateProfileInfo(String firstName, String lastName, String image) async {
    await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userFirstName, firstName);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userLastName, lastName);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.userCover, image);
  }

  Future<void> onLogoutSuccess() async {
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.authRefreshToken);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.authToken);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.uid);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.publicKeys.checkoutAddressId);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userFirstName);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userLastName);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userMobile);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userCountryCode);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userCover);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userRole);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.publicKeys.isGoogleLoggedIn);
  }

  Future<String> getLocale() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultLanguage) ?? '';
  }

  Future<String> appLogo() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.appLogo) ?? '';
  }

  Future<DioApiResponse> updatePushNotificationToken(PushNotificationTokenRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.updatePushNotificationToken, body: param);
  }

  Future<bool> currentTheme() async {
    final isDarkTheme = await (_sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.isDark));
    return isDarkTheme;
  }

  Future<DioApiResponse> submitFeedbackForm(FeedbackFormRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.saveFeedbackForm, body: param);
  }

  Future<DioApiResponse> submitReportEmergencyForm(ReportEmergencyFormRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.saveReportEmergencyForm, body: param);
  }

  Future<DioApiResponse> getMyProfile(String id) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.getMyProfile}$id');
  }

  Future<DioApiResponse> updateMyProfile(String id, UpdateUserProfileRequestModel param) async {
    return await _apiRequestService.patch('${ApiEndPoints.v1request.updateMyProfile}$id', body: param);
  }

  Future<DioApiResponse> getAvatarList() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.getAvatarList);
  }

  Future<DioApiResponse> uploadMediaImage(XFile file, String uid) async {
    return await _apiRequestService.uploadImageFile(ApiEndPoints.v1request.uploadImageFile, uid, file);
  }

  Future<DioApiResponse> getMyReviewList(String user) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.getMyReviewList}$user');
  }

  Future<DioApiResponse> getMyMediaFiles(String user) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.getMyMediaFiles}$user');
  }

  Future<bool> isAppleSignInEnabled() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.socialAppleSignIn);
  }

  Future<bool> isGoogleSignInEnabled() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.socialGoogleSignIn);
  }

  Future<bool> isFacebookSignInEnabled() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.socialFacebookSignIn);
  }

  Future<DioApiResponse> getReferralCode(String id) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.referralCode}$id');
  }

  Future<bool> isVendorSelfRegisterEnable() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.vendorSelfRegisterButton);
  }

  Future<bool> isDriverSelfRegisterEnable() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.driverSelfRegisterButton);
  }

  Future<DioApiResponse> uploadMediaImagePublic(XFile file, String uid) async {
    return await _apiRequestService.uploadImageFile(ApiEndPoints.v1request.uploadPublicImageFile, uid, file);
  }

  Future<DioApiResponse> deliverymanGetBasicRegisterRequestDetail() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.deliverymanGetBasicRegisterRequestDetail);
  }

  Future<DioApiResponse> delivermanJoiningRequest(DeliverymanJoiningRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.deliverymanJoiningRequest, body: param);
  }

  Future<DioApiResponse> getRestaurantRegisterRequestBasicDetail() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.restaurantRegisterRequestBasicDetail);
  }

  Future<DioApiResponse> getActiveCuisine() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.getActiveCuisine);
  }

  Future<DioApiResponse> getActiveRestaurantType() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.getActiveRestaurantType);
  }

  Future<DioApiResponse> getActiveRestaurantFacility() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.getActiveRestaurantFacility);
  }

  Future<DioApiResponse> checkRegisterStatus(CheckRestaurantRegisterStatusRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.checkRegisterStatus, body: param);
  }

  Future<DioApiResponse> registerRequest(RestaurantJoiningRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.restaurantRegisterRequest, body: param);
  }

  Future<DioApiResponse> loginWithGoogleAccount(GoogleAccountLoginRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.userLoginWithGoogleAccount, body: param);
  }

  Future<void> saveGoogleLogin() async {
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.isGoogleLoggedIn, true);
  }

  Future<void> saveFacebookLogin() async {
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.isFacebookLoggedIn, true);
  }

  Future<bool> isGoogleLoggedIn() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.isGoogleLoggedIn);
  }

  Future<bool> isFacebookLoggedIn() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.isFacebookLoggedIn);
  }

  Future<DioApiResponse> checkMobileNumberExist(CheckMobileNumberExistRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.checkMobileNumberExist, body: param);
  }

  Future<DioApiResponse> registerGoogleUserAccount(RegisterGoogleUserAccountRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.createGoogleUserAccount, body: param);
  }

  Future<DioApiResponse> loginWithFacebookAccount(FacebookAccountLoginRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.userLoginWithFacebookAccount, body: param);
  }

  Future<DioApiResponse> registerFacebookUserAccount(RegisterFacebookUserAccountRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.createFacebookUserAccount, body: param);
  }

  Future<DioApiResponse> updateAccountPassword(AccountUpdatePasswordRequestModel param) async {
    final String userId = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    return await _apiRequestService.patch('${ApiEndPoints.v1request.updateAccountPassword}$userId', body: param);
  }

  Future<DioApiResponse> updateAccountEmail(AccountUpdateEmailRequestModel param) async {
    final String userId = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    return await _apiRequestService.patch('${ApiEndPoints.v1request.updateAccountEmail}$userId', body: param);
  }

  Future<DioApiResponse> updateAccountEmailAfterVerification(AccountUpdateEmailAfterVerificationRequestModel param) async {
    final String userId = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    return await _apiRequestService.patch('${ApiEndPoints.v1request.updateAccountEmailAfterVerification}$userId', body: param);
  }

  Future<DioApiResponse> updateAccountMobileNumber(AccountUpdateMobileNumberRequestModel param) async {
    final String userId = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    return await _apiRequestService.patch('${ApiEndPoints.v1request.updateAccountMobileNumber}$userId', body: param);
  }

  Future<DioApiResponse> updateAccountMobileNumberAfterVerification(AccountUpdateMobileNumberAfterVerificationRequestModel param) async {
    final String userId = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    return await _apiRequestService.patch('${ApiEndPoints.v1request.updateAccountMobileNumberAfterVerification}$userId', body: param);
  }

  Future<DioApiResponse> updateAccountMobileNumberAfterFirebaseVerification(AccountUpdateMobileNumberAfterFirebaseVerificationRequestModel param) async {
    final String userId = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    return await _apiRequestService.patch('${ApiEndPoints.v1request.updateAccountMobileNumberAfterFirebaseVerification}$userId', body: param);
  }

  Future<DioApiResponse> getAccountDeleteReason() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.accountDeleteReasonList);
  }

  Future<DioApiResponse> userAccountDelete(UserAccountDeleteRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.deleteUserAccount, body: param);
  }

  Future<DioApiResponse> userNotificationSetting() async {
    final String userId = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    return await _apiRequestService.get('${ApiEndPoints.v1request.userNotificationSetting}$userId');
  }

  Future<DioApiResponse> updateNotificationSetting(String id, AccountUpdateNotificationSettingRequestModel param) async {
    return await _apiRequestService.patch('${ApiEndPoints.v1request.updateNotificationSetting}$id', body: param);
  }

  Future<String> googleOAuthClientId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.googleOAuthClientId) ?? '';
  }

  Future<String> googleOAuthServerId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.googleOAuthServerId) ?? '';
  }

  Future<String> getMediaUrl() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.mediaUrl) ?? '';
  }

  Future<DioApiResponse> localityByCity(String id) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.localityByCity}$id');
  }

  Future<DioApiResponse> updateLocale(UpdateLocaleRequestModel param) async {
    return await _apiRequestService.patch(ApiEndPoints.v1request.updateUserLocale, body: param);
  }
}

