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
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

Future<bool> showErrorDialog(BuildContext context, String serverMessage, String extra, int statusCode, {bool fromAuth = false}) async {
  final Map<String, String> errorMap = {
    "server_not_found_error": "Not found",
    "server_please_authenticate_error": "Please authenticate",
    "server_forbidden_error": "Forbidden",
    "server_already_exist_error": "Already exist",
    "server_incorrect_email_or_password_error": "Incorrect email or password",
    "server_unauthorized_error": "Unauthorized",
    "server_account_blocked_error": "Account Blocked",
    "server_incorrect_phone_or_password_error": "Incorrect Phone or password",
    "server_password_reset_failed_error": "Password reset failed",
    "server_email_verification_failed_error": "Email verification failed",
    "server_item_already_exist_in_cart_error": "Item already exist in cart",
    "server_something_went_wrong_error": "Something went wrong",
    "server_addon_not_available_error": "One of the addon is not available",
    "server_variation_not_available_error": "One of the variation is not available",
    "server_already_created_error": "Already Created",
    "server_coupon_already_redemeed_error": "Coupon Already redemeed",
    "server_bogo_failed_error": "Please add one more item to validate BOGO offer",
    "server_coupon_limit_crossed_error": "Coupon Limit Crossed",
    "server_already_requested_error": "Already requested",
    "server_limit_crossed_error": "Limit Crossed",
    "server_wallet_find_error": "Unable to find wallet",
    "server_wallet_balance_error": "Insufficient funds: Withdrawal amount exceeds your available balance",
    "server_email_smtp_error": "Unable to connect to email server. Make sure you have configured the SMTP options",
    "server_already_saved_error": "Already saved",
    "server_favourite_error": "item is already in favourite list",
    "server_already_hidden_error": "Already Hidden",
    "server_another_deliveryman_accepted_order_error": "Another Deliveryman Accepted Order",
    "server_invalid_deliveryman_error": "Invalid Deliveryman",
    "server_already_assigned_error": "Already assigned",
    "server_wrong_otp_error": "Wrong OTP",
    "server_verification_failed_error": "Verification failed",
    "server_credentials_error": "credentials not found",
    "server_cart_not_found_error": "Cart Item not found",
    "server_purchase_not_found_error": "Purchase Not Found",
    "server_wallet_not_found_error": "Wallet Not Found",
    "server_no_user_found_email_error": "No users found with this email",
    "server_no_user_found_mobile_number_error": "No users found with this mobile number",
    "server_email_already_taken_error": "Email already taken",
    "server_phone_already_taken_error": "Phone already taken",
    "server_account_already_created_error": "Account already created",
    "server_user_not_found_error": "User not found",
    "server_driver_not_found_error": "Driver not found",
    "server_detail_not_found_error": "Detail not found",
    "server_restaurant_not_found_error": "Restaurant not found",
    "server_clear_cash_outlet_error": "Please clear cash in hand amount before deleting account from your account and from outlet",
    "server_clear_cash_restaurant_error": "Please clear cash in hand amount before deleting account",
    "server_deliveryman_not_found_error": "Deliveryman not found",
    "server_waiter_not_found_error": "Waiter not found",
    "server_kitchen_not_found_error": "Kitchen Owner not found",
    "server_already_taken_error": "Already taken",
    "server_file_not_found_error": "File not found",
    "server_validation_failed_error": "Validation failed",
    "server_invalid_file_type_error": "Invalid file type",
    "server_select_file_upload_error": "Please select a file to upload!",
    "server_account_not_found_error": "Account not found",
    "server_contact_admin_error": "Something went wrong, please contact administrator",
    "server_address_missing_errir": "Address is missing",
    "server_home_delivery_disabled_error": "Home Delivery is disabled",
    "server_self_pickup_disabled_error": "Self Pickup is disabled",
    "server_instant_order_disabled_error": "Instant Order is disabled",
    "server_schedule_order_disabled_error": "Schedule Order is disabled",
    "server_schedule_date_is_invalid_error": "Schedule Date is invalid",
    "server_can_not_deliver_to_address_error": "Can not deliver order to this address",
    "server_coupon_wallet_can_not_use_same_error": "Oops! Looks like you've applied a coupon code for your order.Please note that you can't use your wallet balance along with a coupon code",
    "server_invalid_coupon_not_available_error": "Opps, Sorry this coupon is not available for you.",
    "server_food_is_not_available_error": "One of the food is not available",
    "server_empty_cart_error": "Cart is Empty",
    "server_addon_variation_not_available_error": "One of the addon or variation is not available",
    "server_pos_permmission_error": "Pos Permission Denied",
    "server_no_trial_subscription_package_error": "Oops! Looks like you've applied a trial subscription package, and it is not available as of now, please select payment method!",
    "server_table_order_permission_error": "Table Order Permission Denied",
    "server_invalid_slot_error": "Invalid Slot",
    "server_max_upload_size_error": "Maximum file size is ##dynamic## MB",
    "server_min_cart_error": "Opps, Sorry. you required minimum ##dynamic## on your cart.",
    "server_min_amount_error": "Please note that a minimum order value of ##dynamic## is required to proceed with your order",
    "server_out_of_stock_error": "Sorry, ##dynamic## is currently out of stock and cannot be added to your order.",
    "bloc_auth_permission_denied_error": "Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In",
    "bloc_required_input_error": "Please fill all the required inputs",
    "bloc_select_subscription_package_error": "Please select package",
    "bloc_variation_limited_error": "Sorry, our variation limited to ##dynamic## items right now.",
    "bloc_food_limit_error": "Sorry, You can purchase upto ##dynamic## items on this food",
    "bloc_stock_limit_error": "Sorry, our stock is limited to ##dynamic## items right now.",
    "bloc_coupon_and_wallet_error": "Oops! Looks like you've applied a coupon code for your order.Please note that you can't use your wallet balance along with a coupon code",
    "bloc_wallet_and_coupon_error": "Oops! Looks like you've applied a wallet money for your order.Please note that you can't use coupon code along with a wallet money",
    "bloc_login_first_error": "Please login first",
    "bloc_location_disable_error": "Location services are disabled.",
    "bloc_location_permission_error": "Location permissions are denied",
    "bloc_location_permission_permanently_error": "Location permissions are permanently denied, we cannot request permissions.",
    "bloc_coupon_validation_error": "Opps, Sorry this coupon is not available for you.",
    "bloc_coupon_validation_min_error": "Opps, Sorry. you required minimum ##dynamic## on your cart.",
    "bloc_can_not_deliver_address_error": "Can not deliver to this address",
    "bloc_food_validation_error": "Validation Failed, Please select required items",
    "bloc_unable_to_download_error": "Unable to get downloads directory",
    "bloc_storage_permission_error": "Storage permission denied",
    "bloc_file_not_download_error": "File cannot be downloaded from the browser. Please use a mobile device to download.",
  };
  String? key = errorMap.entries.firstWhere((e) => e.value.toLowerCase() == serverMessage.toLowerCase(), orElse: () => const MapEntry('', '')).key;

  String translateServerError(BuildContext context, String serverMessage) {
    switch (key) {
      case "server_not_found_error":
        return AppLocalizations.of(context)!.server_not_found_error;
      case "server_please_authenticate_error":
        return AppLocalizations.of(context)!.server_please_authenticate_error;
      case "server_forbidden_error":
        return AppLocalizations.of(context)!.server_forbidden_error;
      case "server_already_exist_error":
        return AppLocalizations.of(context)!.server_already_exist_error;
      case "server_incorrect_email_or_password_error":
        return AppLocalizations.of(context)!.server_incorrect_email_or_password_error;
      case "server_unauthorized_error":
        return AppLocalizations.of(context)!.server_unauthorized_error;
      case "server_account_blocked_error":
        return AppLocalizations.of(context)!.server_account_blocked_error;
      case "server_incorrect_phone_or_password_error":
        return AppLocalizations.of(context)!.server_incorrect_phone_or_password_error;
      case "server_password_reset_failed_error":
        return AppLocalizations.of(context)!.server_password_reset_failed_error;
      case "server_email_verification_failed_error":
        return AppLocalizations.of(context)!.server_email_verification_failed_error;
      case "server_item_already_exist_in_cart_error":
        return AppLocalizations.of(context)!.server_item_already_exist_in_cart_error;
      case "server_something_went_wrong_error":
        return AppLocalizations.of(context)!.server_something_went_wrong_error;
      case "server_addon_not_available_error":
        return AppLocalizations.of(context)!.server_addon_not_available_error;
      case "server_variation_not_available_error":
        return AppLocalizations.of(context)!.server_variation_not_available_error;
      case "server_already_created_error":
        return AppLocalizations.of(context)!.server_already_created_error;
      case "server_coupon_already_redemeed_error":
        return AppLocalizations.of(context)!.server_coupon_already_redemeed_error;
      case "server_bogo_failed_error":
        return AppLocalizations.of(context)!.server_bogo_failed_error;
      case "server_coupon_limit_crossed_error":
        return AppLocalizations.of(context)!.server_coupon_limit_crossed_error;
      case "server_already_requested_error":
        return AppLocalizations.of(context)!.server_already_requested_error;
      case "server_limit_crossed_error":
        return AppLocalizations.of(context)!.server_limit_crossed_error;
      case "server_wallet_find_error":
        return AppLocalizations.of(context)!.server_wallet_find_error;
      case "server_wallet_balance_error":
        return AppLocalizations.of(context)!.server_wallet_balance_error;
      case "server_email_smtp_error":
        return AppLocalizations.of(context)!.server_email_smtp_error;
      case "server_already_saved_error":
        return AppLocalizations.of(context)!.server_already_saved_error;
      case "server_favourite_error":
        return AppLocalizations.of(context)!.server_favourite_error;
      case "server_already_hidden_error":
        return AppLocalizations.of(context)!.server_already_hidden_error;
      case "server_another_deliveryman_accepted_order_error":
        return AppLocalizations.of(context)!.server_another_deliveryman_accepted_order_error;
      case "server_invalid_deliveryman_error":
        return AppLocalizations.of(context)!.server_invalid_deliveryman_error;
      case "server_already_assigned_error":
        return AppLocalizations.of(context)!.server_already_assigned_error;
      case "server_wrong_otp_error":
        return AppLocalizations.of(context)!.server_wrong_otp_error;
      case "server_verification_failed_error":
        return AppLocalizations.of(context)!.server_verification_failed_error;
      case "server_credentials_error":
        return AppLocalizations.of(context)!.server_credentials_error;
      case "server_cart_not_found_error":
        return AppLocalizations.of(context)!.server_cart_not_found_error;
      case "server_purchase_not_found_error":
        return AppLocalizations.of(context)!.server_purchase_not_found_error;
      case "server_wallet_not_found_error":
        return AppLocalizations.of(context)!.server_wallet_not_found_error;
      case "server_no_user_found_email_error":
        return AppLocalizations.of(context)!.server_no_user_found_email_error;
      case "server_no_user_found_mobile_number_error":
        return AppLocalizations.of(context)!.server_no_user_found_mobile_number_error;
      case "server_email_already_taken_error":
        return AppLocalizations.of(context)!.server_email_already_taken_error;
      case "server_phone_already_taken_error":
        return AppLocalizations.of(context)!.server_phone_already_taken_error;
      case "server_account_already_created_error":
        return AppLocalizations.of(context)!.server_account_already_created_error;
      case "server_user_not_found_error":
        return AppLocalizations.of(context)!.server_user_not_found_error;
      case "server_driver_not_found_error":
        return AppLocalizations.of(context)!.server_driver_not_found_error;
      case "server_detail_not_found_error":
        return AppLocalizations.of(context)!.server_detail_not_found_error;
      case "server_restaurant_not_found_error":
        return AppLocalizations.of(context)!.server_restaurant_not_found_error;
      case "server_clear_cash_outlet_error":
        return AppLocalizations.of(context)!.server_clear_cash_outlet_error;
      case "server_clear_cash_restaurant_error":
        return AppLocalizations.of(context)!.server_clear_cash_restaurant_error;
      case "server_deliveryman_not_found_error":
        return AppLocalizations.of(context)!.server_deliveryman_not_found_error;
      case "server_waiter_not_found_error":
        return AppLocalizations.of(context)!.server_waiter_not_found_error;
      case "server_kitchen_not_found_error":
        return AppLocalizations.of(context)!.server_kitchen_not_found_error;
      case "server_already_taken_error":
        return AppLocalizations.of(context)!.server_already_taken_error;
      case "server_file_not_found_error":
        return AppLocalizations.of(context)!.server_file_not_found_error;
      case "server_validation_failed_error":
        return AppLocalizations.of(context)!.server_validation_failed_error;
      case "server_invalid_file_type_error":
        return AppLocalizations.of(context)!.server_invalid_file_type_error;
      case "server_select_file_upload_error":
        return AppLocalizations.of(context)!.server_select_file_upload_error;
      case "server_account_not_found_error":
        return AppLocalizations.of(context)!.server_account_not_found_error;
      case "server_contact_admin_error":
        return AppLocalizations.of(context)!.server_contact_admin_error;
      case "server_address_missing_errir":
        return AppLocalizations.of(context)!.server_address_missing_errir;
      case "server_home_delivery_disabled_error":
        return AppLocalizations.of(context)!.server_home_delivery_disabled_error;
      case "server_self_pickup_disabled_error":
        return AppLocalizations.of(context)!.server_self_pickup_disabled_error;
      case "server_instant_order_disabled_error":
        return AppLocalizations.of(context)!.server_instant_order_disabled_error;
      case "server_schedule_order_disabled_error":
        return AppLocalizations.of(context)!.server_schedule_order_disabled_error;
      case "server_schedule_date_is_invalid_error":
        return AppLocalizations.of(context)!.server_schedule_date_is_invalid_error;
      case "server_can_not_deliver_to_address_error":
        return AppLocalizations.of(context)!.server_can_not_deliver_to_address_error;
      case "server_coupon_wallet_can_not_use_same_error":
        return AppLocalizations.of(context)!.server_coupon_wallet_can_not_use_same_error;
      case "server_invalid_coupon_not_available_error":
        return AppLocalizations.of(context)!.server_invalid_coupon_not_available_error;
      case "server_food_is_not_available_error":
        return AppLocalizations.of(context)!.server_food_is_not_available_error;
      case "server_empty_cart_error":
        return AppLocalizations.of(context)!.server_empty_cart_error;
      case "server_addon_variation_not_available_error":
        return AppLocalizations.of(context)!.server_addon_variation_not_available_error;
      case "server_pos_permmission_error":
        return AppLocalizations.of(context)!.server_pos_permmission_error;
      case "server_no_trial_subscription_package_error":
        return AppLocalizations.of(context)!.server_no_trial_subscription_package_error;
      case "server_table_order_permission_error":
        return AppLocalizations.of(context)!.server_table_order_permission_error;
      case "server_invalid_slot_error":
        return AppLocalizations.of(context)!.server_invalid_slot_error;
      case "server_max_upload_size_error":
        return AppLocalizations.of(context)!.server_max_upload_size_error;
      case "server_min_cart_error":
        return AppLocalizations.of(context)!.server_min_cart_error;
      case "server_min_amount_error":
        return AppLocalizations.of(context)!.server_min_amount_error;
      case "server_out_of_stock_error":
        return AppLocalizations.of(context)!.server_out_of_stock_error;
      case "bloc_auth_permission_denied_error":
        return AppLocalizations.of(context)!.bloc_auth_permission_denied_error;
      case "bloc_required_input_error":
        return AppLocalizations.of(context)!.bloc_required_input_error;
      case "bloc_select_subscription_package_error":
        return AppLocalizations.of(context)!.bloc_select_subscription_package_error;
      case "bloc_variation_limited_error":
        return AppLocalizations.of(context)!.bloc_variation_limited_error;
      case "bloc_food_limit_error":
        return AppLocalizations.of(context)!.bloc_food_limit_error;
      case "bloc_stock_limit_error":
        return AppLocalizations.of(context)!.bloc_stock_limit_error;
      case "bloc_coupon_and_wallet_error":
        return AppLocalizations.of(context)!.bloc_coupon_and_wallet_error;
      case "bloc_wallet_and_coupon_error":
        return AppLocalizations.of(context)!.bloc_wallet_and_coupon_error;
      case "bloc_login_first_error":
        return AppLocalizations.of(context)!.bloc_login_first_error;
      case "bloc_location_disable_error":
        return AppLocalizations.of(context)!.bloc_location_disable_error;
      case "bloc_location_permission_error":
        return AppLocalizations.of(context)!.bloc_location_permission_error;
      case "bloc_location_permission_permanently_error":
        return AppLocalizations.of(context)!.bloc_location_permission_permanently_error;
      case "bloc_coupon_validation_error":
        return AppLocalizations.of(context)!.bloc_coupon_validation_error;
      case "bloc_coupon_validation_min_error":
        return AppLocalizations.of(context)!.bloc_coupon_validation_min_error;
      case "bloc_can_not_deliver_address_error":
        return AppLocalizations.of(context)!.bloc_can_not_deliver_address_error;
      case "bloc_food_validation_error":
        return AppLocalizations.of(context)!.bloc_food_validation_error;
      case "bloc_unable_to_download_error":
        return AppLocalizations.of(context)!.bloc_unable_to_download_error;
      case "bloc_storage_permission_error":
        return AppLocalizations.of(context)!.bloc_storage_permission_error;
      case "bloc_file_not_download_error":
        return AppLocalizations.of(context)!.bloc_file_not_download_error;

      default:
        return serverMessage;
    }
  }

  final AppLocalizations translate = AppLocalizations.of(context)!;
  final localizedMessage = translateServerError(context, serverMessage);
  final String dynamicMessage = localizedMessage.replaceAll('##dynamic##', extra);
  HapticFeedback.lightImpact();
  return (await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(statusCode == 401 ? AssetsUrl.imageURL.unAuthorizedErrorIcon : AssetsUrl.imageURL.normalErrorIcon, height: 45, width: 45),
              kAppSpacerVertical(height: 10),
              Text(translate.error_title, style: kAppLblLargeFontBold(context)),
              kAppSpacerVertical(height: 10),
              Text(dynamicMessage, style: kAppLblMediumFontRegular(context, color: 'regular')),
            ],
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (statusCode == 401 && fromAuth == false) {
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
                  } else {
                    Navigator.of(context).pop(true);
                  }
                },
                style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                child: statusCode == 401 ? Text(translate.login_back_btn) : Text(translate.understand_btn),
              ),
            ),
          ],
        ),
      )) ??
      false;
}

