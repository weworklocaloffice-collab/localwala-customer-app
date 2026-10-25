import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('hi'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Localwala-customer'**
  String get welcome;

  /// No description provided for @signin.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get signin;

  /// No description provided for @view_activity.
  ///
  /// In en, this message translates to:
  /// **'View activity'**
  String get view_activity;

  /// No description provided for @your_profile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get your_profile;

  /// No description provided for @sign_in_sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign In / Sign Up'**
  String get sign_in_sign_up;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @loyalty_points.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Points'**
  String get loyalty_points;

  /// No description provided for @chat_messages.
  ///
  /// In en, this message translates to:
  /// **'Chat Messages'**
  String get chat_messages;

  /// No description provided for @light_mode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get light_mode;

  /// No description provided for @food_orders.
  ///
  /// In en, this message translates to:
  /// **'Food Orders'**
  String get food_orders;

  /// No description provided for @your_orders.
  ///
  /// In en, this message translates to:
  /// **'Your Orders'**
  String get your_orders;

  /// No description provided for @favourite_orders.
  ///
  /// In en, this message translates to:
  /// **'Favourite Orders'**
  String get favourite_orders;

  /// No description provided for @address_book.
  ///
  /// In en, this message translates to:
  /// **'Address book'**
  String get address_book;

  /// No description provided for @hidden_restaurants.
  ///
  /// In en, this message translates to:
  /// **'Hidden Restaurants'**
  String get hidden_restaurants;

  /// No description provided for @tiffin_subscription_packages.
  ///
  /// In en, this message translates to:
  /// **'Tiffin Subscription Packages'**
  String get tiffin_subscription_packages;

  /// No description provided for @dining.
  ///
  /// In en, this message translates to:
  /// **'Dining'**
  String get dining;

  /// No description provided for @your_table_bookings.
  ///
  /// In en, this message translates to:
  /// **'Your table bookings'**
  String get your_table_bookings;

  /// No description provided for @dining_help.
  ///
  /// In en, this message translates to:
  /// **'Dining Help'**
  String get dining_help;

  /// No description provided for @frequently_asked_questions.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get frequently_asked_questions;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @order_transactions.
  ///
  /// In en, this message translates to:
  /// **'Order Transactions'**
  String get order_transactions;

  /// No description provided for @tiffin_subscription_transactions.
  ///
  /// In en, this message translates to:
  /// **'Tiffin Subscription Transactions'**
  String get tiffin_subscription_transactions;

  /// No description provided for @dining_transactions.
  ///
  /// In en, this message translates to:
  /// **'Dining Transactions'**
  String get dining_transactions;

  /// No description provided for @join_us.
  ///
  /// In en, this message translates to:
  /// **'Join Us'**
  String get join_us;

  /// No description provided for @join_as_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Join as restaurant'**
  String get join_as_restaurant;

  /// No description provided for @join_as_deliveryman.
  ///
  /// In en, this message translates to:
  /// **'Join as deliveryman'**
  String get join_as_deliveryman;

  /// No description provided for @referral_code.
  ///
  /// In en, this message translates to:
  /// **'Referral Code'**
  String get referral_code;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @choose_language.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get choose_language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms_and_conditions;

  /// No description provided for @refund_policy.
  ///
  /// In en, this message translates to:
  /// **'Refund Policy'**
  String get refund_policy;

  /// No description provided for @shipping_policy.
  ///
  /// In en, this message translates to:
  /// **'Shipping Policy'**
  String get shipping_policy;

  /// No description provided for @cancellation_policy.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Policy'**
  String get cancellation_policy;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @send_feedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get send_feedback;

  /// No description provided for @feedback_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Let us know your experience with the app and suggest any improvements. Your feedback helps us serve you better!'**
  String get feedback_sub_title;

  /// No description provided for @report_a_safety_emergency.
  ///
  /// In en, this message translates to:
  /// **'Report a safety emergency'**
  String get report_a_safety_emergency;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get log_out;

  /// No description provided for @please_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get please_wait;

  /// No description provided for @matching_record_not_found.
  ///
  /// In en, this message translates to:
  /// **'No matching records found'**
  String get matching_record_not_found;

  /// No description provided for @no_data_reason_one.
  ///
  /// In en, this message translates to:
  /// **'At this time, we regret to inform you that we currently do not have reasons. We understand how disappointing this may be.'**
  String get no_data_reason_one;

  /// No description provided for @explain_query.
  ///
  /// In en, this message translates to:
  /// **'I need a little more information. Can you please clarify what you\'d like to order?, We couldn\'t make sense of that. Please try rephrasing your request.'**
  String get explain_query;

  /// No description provided for @no_orders.
  ///
  /// In en, this message translates to:
  /// **'No orders, no problem!'**
  String get no_orders;

  /// No description provided for @empty_data.
  ///
  /// In en, this message translates to:
  /// **'Looks like this well\'s dry. No data here! Looks like we hit an empty patch! No data to display here.'**
  String get empty_data;

  /// No description provided for @deliveryman_joining_title.
  ///
  /// In en, this message translates to:
  /// **'Join Our Team as a Delivery Partner â€“ Earn While You Deliver!'**
  String get deliveryman_joining_title;

  /// No description provided for @no_dining_booking.
  ///
  /// In en, this message translates to:
  /// **'No Dining Bookings Found!'**
  String get no_dining_booking;

  /// No description provided for @no_dining_booking_sub_title.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any dining bookings at the moment. Check out our restaurants and make your first reservation today!'**
  String get no_dining_booking_sub_title;

  /// No description provided for @no_subscription.
  ///
  /// In en, this message translates to:
  /// **'No subscription, no problem!'**
  String get no_subscription;

  /// No description provided for @no_subscription_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Your subscription list is eagerly anticipating your next delicious decision, Your subscription list is like a blank canvas, waiting for your culinary masterpiece.'**
  String get no_subscription_sub_title;

  /// No description provided for @unhide_restaurant_title.
  ///
  /// In en, this message translates to:
  /// **'Removed from hidden list'**
  String get unhide_restaurant_title;

  /// No description provided for @unhide_restaurant_sub_title.
  ///
  /// In en, this message translates to:
  /// **'We\'ll begin suggesting this restaurant to you. From now on, we\'ll recommend you try this place.'**
  String get unhide_restaurant_sub_title;

  /// No description provided for @re_auth_required.
  ///
  /// In en, this message translates to:
  /// **'Re-authentication Required'**
  String get re_auth_required;

  /// No description provided for @auth_used_mode.
  ///
  /// In en, this message translates to:
  /// **'You\'re currently using'**
  String get auth_used_mode;

  /// No description provided for @email_auth_otp.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send an OTP to your new email address for verification.'**
  String get email_auth_otp;

  /// No description provided for @phone_auth_otp.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send an OTP to your new mobile number for verification.'**
  String get phone_auth_otp;

  /// No description provided for @relogin_after_password_update.
  ///
  /// In en, this message translates to:
  /// **'To ensure your account\'s security, you have been logged out.If Password changed, Please log in again using your updated credentials.'**
  String get relogin_after_password_update;

  /// No description provided for @select_addon_title.
  ///
  /// In en, this message translates to:
  /// **'Select Addon\'s'**
  String get select_addon_title;

  /// No description provided for @no_review_found_title.
  ///
  /// In en, this message translates to:
  /// **'No review, no problem!'**
  String get no_review_found_title;

  /// No description provided for @no_review_found_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Review list is eagerly anticipating your next delicious decision, Your orders list is like a blank canvas, waiting for your culinary masterpiece.'**
  String get no_review_found_sub_title;

  /// No description provided for @hidden_restaurant_title.
  ///
  /// In en, this message translates to:
  /// **'We have hidden'**
  String get hidden_restaurant_title;

  /// No description provided for @hidden_restaurant_sub_title.
  ///
  /// In en, this message translates to:
  /// **'You can reveal it again from your account section. Please share more details about your decision.'**
  String get hidden_restaurant_sub_title;

  /// No description provided for @campaign_schedule_date.
  ///
  /// In en, this message translates to:
  /// **'Campaign Schedule Date\'s'**
  String get campaign_schedule_date;

  /// No description provided for @campaign_schedule_time.
  ///
  /// In en, this message translates to:
  /// **'Campaign Schedule Time\'s'**
  String get campaign_schedule_time;

  /// No description provided for @dining_campaign.
  ///
  /// In en, this message translates to:
  /// **'Dining in campaign'**
  String get dining_campaign;

  /// No description provided for @view_restaurant_detail.
  ///
  /// In en, this message translates to:
  /// **'View Restaurant Details'**
  String get view_restaurant_detail;

  /// No description provided for @book_table.
  ///
  /// In en, this message translates to:
  /// **'Book Table'**
  String get book_table;

  /// No description provided for @report_fraud.
  ///
  /// In en, this message translates to:
  /// **'Report fraud or bad practices'**
  String get report_fraud;

  /// No description provided for @resend_otp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get code? Resend'**
  String get resend_otp;

  /// No description provided for @otp_verification_privacy.
  ///
  /// In en, this message translates to:
  /// **'Your account security is important to us, and we recommend contacting our support team immediately if you have any concerns.'**
  String get otp_verification_privacy;

  /// No description provided for @rate_food_items.
  ///
  /// In en, this message translates to:
  /// **'Tell us how you\'d rate this food items'**
  String get rate_food_items;

  /// No description provided for @please_rate.
  ///
  /// In en, this message translates to:
  /// **'Please rate'**
  String get please_rate;

  /// No description provided for @i_am.
  ///
  /// In en, this message translates to:
  /// **'I\'m'**
  String get i_am;

  /// No description provided for @your_deliveryman.
  ///
  /// In en, this message translates to:
  /// **'your delivery partner'**
  String get your_deliveryman;

  /// No description provided for @end_service.
  ///
  /// In en, this message translates to:
  /// **'s service'**
  String get end_service;

  /// No description provided for @coupon_terms_and_condition.
  ///
  /// In en, this message translates to:
  /// **'Other T&C\'s may apply'**
  String get coupon_terms_and_condition;

  /// No description provided for @register_sub_title.
  ///
  /// In en, this message translates to:
  /// **'A World of Flavor Awaits - Secure Your Seat with a Quick Register, Your Food Journey Starts Here.'**
  String get register_sub_title;

  /// No description provided for @email_otp_verification_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address we\'ll send you a verification code to reset your password'**
  String get email_otp_verification_sub_title;

  /// No description provided for @reset_verified_identity.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been verified! set your new password'**
  String get reset_verified_identity;

  /// No description provided for @location_title.
  ///
  /// In en, this message translates to:
  /// **'What\'s your location?'**
  String get location_title;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @validity.
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get validity;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @off_day_week.
  ///
  /// In en, this message translates to:
  /// **'Off days in week'**
  String get off_day_week;

  /// No description provided for @restaurant_schedule_order.
  ///
  /// In en, this message translates to:
  /// **'Our restaurant is opening soon! In the meantime, you can place a scheduled order from our available time slots'**
  String get restaurant_schedule_order;

  /// No description provided for @min_order_amount_note.
  ///
  /// In en, this message translates to:
  /// **'Please note that a minimum order value of'**
  String get min_order_amount_note;

  /// No description provided for @min_order_amount_note_required.
  ///
  /// In en, this message translates to:
  /// **'is required to proceed with your order'**
  String get min_order_amount_note_required;

  /// No description provided for @phone_otp_verification_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number we\'ll send you a verification code to reset your password'**
  String get phone_otp_verification_sub_title;

  /// No description provided for @brand_sub_title_one.
  ///
  /// In en, this message translates to:
  /// **'Unleash Your Inner Foodie: Dive into the Delicious Diversity of'**
  String get brand_sub_title_one;

  /// No description provided for @brand_sub_title_two.
  ///
  /// In en, this message translates to:
  /// **'s Restaurant Collection!'**
  String get brand_sub_title_two;

  /// No description provided for @your_activity.
  ///
  /// In en, this message translates to:
  /// **'Your Activity'**
  String get your_activity;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @leave_review.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get leave_review;

  /// No description provided for @about_restaurant.
  ///
  /// In en, this message translates to:
  /// **'About the restaurant'**
  String get about_restaurant;

  /// No description provided for @restaurant_reviews.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Reviews'**
  String get restaurant_reviews;

  /// No description provided for @food_reviews.
  ///
  /// In en, this message translates to:
  /// **'Food Reviews'**
  String get food_reviews;

  /// No description provided for @deliveryman_reviews.
  ///
  /// In en, this message translates to:
  /// **'Deliveryman Reviews'**
  String get deliveryman_reviews;

  /// No description provided for @no_review_found.
  ///
  /// In en, this message translates to:
  /// **'No reviews found. Please try again later or be the first to leave a review.'**
  String get no_review_found;

  /// No description provided for @verified_order.
  ///
  /// In en, this message translates to:
  /// **'Verified order'**
  String get verified_order;

  /// No description provided for @oops_title.
  ///
  /// In en, this message translates to:
  /// **'Opps!'**
  String get oops_title;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @view_menu.
  ///
  /// In en, this message translates to:
  /// **'View menu'**
  String get view_menu;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @subscription_order.
  ///
  /// In en, this message translates to:
  /// **'Subscription Order'**
  String get subscription_order;

  /// No description provided for @my_address_title.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get my_address_title;

  /// No description provided for @add_address.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get add_address;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_title;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @choose_from.
  ///
  /// In en, this message translates to:
  /// **'Choose From'**
  String get choose_from;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @cancel_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel_title;

  /// No description provided for @thank_you_btn.
  ///
  /// In en, this message translates to:
  /// **'Ok, Thank you'**
  String get thank_you_btn;

  /// No description provided for @total_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get total_amount;

  /// No description provided for @grand_total.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grand_total;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @save_btn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save_btn;

  /// No description provided for @error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error_title;

  /// No description provided for @login_back_btn.
  ///
  /// In en, this message translates to:
  /// **'Login back'**
  String get login_back_btn;

  /// No description provided for @understand_btn.
  ///
  /// In en, this message translates to:
  /// **'Ok, I Understand'**
  String get understand_btn;

  /// No description provided for @update_required.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get update_required;

  /// No description provided for @new_version_one.
  ///
  /// In en, this message translates to:
  /// **'A new version'**
  String get new_version_one;

  /// No description provided for @new_version_two.
  ///
  /// In en, this message translates to:
  /// **'of the app is available. Please update to continue.'**
  String get new_version_two;

  /// No description provided for @update_now_btn.
  ///
  /// In en, this message translates to:
  /// **'UPDATE NOW'**
  String get update_now_btn;

  /// No description provided for @success_title.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success_title;

  /// No description provided for @i_thank_you_btn.
  ///
  /// In en, this message translates to:
  /// **'Ok, I Thank you!'**
  String get i_thank_you_btn;

  /// No description provided for @unauthorized_page_title.
  ///
  /// In en, this message translates to:
  /// **'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In'**
  String get unauthorized_page_title;

  /// No description provided for @unauthorized_page_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Continue'**
  String get unauthorized_page_sub_title;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @view_cart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get view_cart;

  /// No description provided for @no_reviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews were found for this item. Be the first to share your experience by leaving a review. Your feedback can help others make informed decisions!'**
  String get no_reviews;

  /// No description provided for @empty_data_two.
  ///
  /// In en, this message translates to:
  /// **'Oops! Looks like we\'ve found a bug in our kitchen, Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get empty_data_two;

  /// No description provided for @empty_data_three.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, no result found. Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get empty_data_three;

  /// No description provided for @no_order_data_one.
  ///
  /// In en, this message translates to:
  /// **'Your orders list is eagerly anticipating your next delicious decision, Your orders list is like a blank canvas, waiting for your culinary masterpiece.'**
  String get no_order_data_one;

  /// No description provided for @saved_address_title.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get saved_address_title;

  /// No description provided for @reservation_details_title.
  ///
  /// In en, this message translates to:
  /// **'Reservation details'**
  String get reservation_details_title;

  /// No description provided for @your_details_title.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get your_details_title;

  /// No description provided for @restaurant_details_title.
  ///
  /// In en, this message translates to:
  /// **'Restaurant details'**
  String get restaurant_details_title;

  /// No description provided for @more_details_title.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get more_details_title;

  /// No description provided for @billing_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Billing Summary'**
  String get billing_summary_title;

  /// No description provided for @transaction_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Transaction detail'**
  String get transaction_detail_title;

  /// No description provided for @looking_for_title.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get looking_for_title;

  /// No description provided for @popular_dining_title.
  ///
  /// In en, this message translates to:
  /// **'Popular Dining'**
  String get popular_dining_title;

  /// No description provided for @discover_dining_title.
  ///
  /// In en, this message translates to:
  /// **'Discover New Dining Delights On'**
  String get discover_dining_title;

  /// No description provided for @dining_restaurant_title.
  ///
  /// In en, this message translates to:
  /// **'All Dining Restaurants'**
  String get dining_restaurant_title;

  /// No description provided for @in_mind_title.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get in_mind_title;

  /// No description provided for @today_trending_title.
  ///
  /// In en, this message translates to:
  /// **'Today\'s trending food'**
  String get today_trending_title;

  /// No description provided for @customer_loved_items_title.
  ///
  /// In en, this message translates to:
  /// **'Top items loved by customers'**
  String get customer_loved_items_title;

  /// No description provided for @most_order_items_title.
  ///
  /// In en, this message translates to:
  /// **'Most order\'s food by customers'**
  String get most_order_items_title;

  /// No description provided for @brand_title.
  ///
  /// In en, this message translates to:
  /// **'Top brands for you'**
  String get brand_title;

  /// No description provided for @popular_restaurant_title.
  ///
  /// In en, this message translates to:
  /// **'Popular Restaurants'**
  String get popular_restaurant_title;

  /// No description provided for @eat_well_title.
  ///
  /// In en, this message translates to:
  /// **'Eat well, spend less.'**
  String get eat_well_title;

  /// No description provided for @global_flavour_title.
  ///
  /// In en, this message translates to:
  /// **'Find with Global Flavors'**
  String get global_flavour_title;

  /// No description provided for @discover_restaurant_title.
  ///
  /// In en, this message translates to:
  /// **'Discover New Delectable Delights On'**
  String get discover_restaurant_title;

  /// No description provided for @new_tiffin_package_title.
  ///
  /// In en, this message translates to:
  /// **'New Subscription Tiffin Packages on'**
  String get new_tiffin_package_title;

  /// No description provided for @restaurant_title.
  ///
  /// In en, this message translates to:
  /// **'All Restaurants'**
  String get restaurant_title;

  /// No description provided for @food_title.
  ///
  /// In en, this message translates to:
  /// **'All food items'**
  String get food_title;

  /// No description provided for @restaurant_campaign_title.
  ///
  /// In en, this message translates to:
  /// **'Restaurants in campaign'**
  String get restaurant_campaign_title;

  /// No description provided for @time_slot_title.
  ///
  /// In en, this message translates to:
  /// **'Time Slots'**
  String get time_slot_title;

  /// No description provided for @food_include_title.
  ///
  /// In en, this message translates to:
  /// **'Foods Included'**
  String get food_include_title;

  /// No description provided for @recent_search_title.
  ///
  /// In en, this message translates to:
  /// **'Your recent searches'**
  String get recent_search_title;

  /// No description provided for @top_outlet_title.
  ///
  /// In en, this message translates to:
  /// **'Top Outlet in'**
  String get top_outlet_title;

  /// No description provided for @gratitude_title.
  ///
  /// In en, this message translates to:
  /// **'GRATITUDE CORNER'**
  String get gratitude_title;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get favourite;

  /// No description provided for @reels.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get reels;

  /// No description provided for @proof_liked_one.
  ///
  /// In en, this message translates to:
  /// **'{name} liked this'**
  String proof_liked_one(Object name);

  /// No description provided for @proof_liked_two.
  ///
  /// In en, this message translates to:
  /// **'{first} and {second} liked this'**
  String proof_liked_two(Object first, Object second);

  /// No description provided for @proof_liked_many_one.
  ///
  /// In en, this message translates to:
  /// **'{first}, {second} and 1 other liked this'**
  String proof_liked_many_one(Object first, Object second);

  /// No description provided for @proof_liked_many_other.
  ///
  /// In en, this message translates to:
  /// **'{first}, {second} and {others} others liked this'**
  String proof_liked_many_other(Object first, Object others, Object second);

  /// No description provided for @reels_empty.
  ///
  /// In en, this message translates to:
  /// **'No reels yet. Check back soon.'**
  String get reels_empty;

  /// No description provided for @session_expired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get session_expired;

  /// No description provided for @reels_sign_in_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep watching reels.'**
  String get reels_sign_in_to_continue;

  /// No description provided for @reels_video_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this reel.'**
  String get reels_video_unavailable;

  /// No description provided for @reels_view_all_comments.
  ///
  /// In en, this message translates to:
  /// **'View all {count} comments'**
  String reels_view_all_comments(int count);

  /// No description provided for @report_reel_title.
  ///
  /// In en, this message translates to:
  /// **'Report reel'**
  String get report_reel_title;

  /// No description provided for @comments_title.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments_title;

  /// No description provided for @comments_empty.
  ///
  /// In en, this message translates to:
  /// **'Be the first to comment.'**
  String get comments_empty;

  /// No description provided for @comment_hint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get comment_hint;

  /// No description provided for @comments_load_more.
  ///
  /// In en, this message translates to:
  /// **'Load more comments'**
  String get comments_load_more;

  /// No description provided for @comments_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load comments.'**
  String get comments_load_failed;

  /// No description provided for @comment_post_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post your comment.'**
  String get comment_post_failed;

  /// No description provided for @reels_sign_in_to_comment.
  ///
  /// In en, this message translates to:
  /// **'Sign in to comment.'**
  String get reels_sign_in_to_comment;

  /// No description provided for @privacy_find_friends.
  ///
  /// In en, this message translates to:
  /// **'Find friends from contacts'**
  String get privacy_find_friends;

  /// No description provided for @privacy_find_friends_sub.
  ///
  /// In en, this message translates to:
  /// **'Match your address book with people on Localwala.'**
  String get privacy_find_friends_sub;

  /// No description provided for @privacy_show_activity.
  ///
  /// In en, this message translates to:
  /// **'Show my activity to people who know me'**
  String get privacy_show_activity;

  /// No description provided for @privacy_show_activity_sub.
  ///
  /// In en, this message translates to:
  /// **'Let matched contacts see your name on likes.'**
  String get privacy_show_activity_sub;

  /// No description provided for @privacy_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh matches'**
  String get privacy_refresh;

  /// No description provided for @privacy_never_synced.
  ///
  /// In en, this message translates to:
  /// **'Never synced on this device.'**
  String get privacy_never_synced;

  /// No description provided for @privacy_last_synced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {date}.'**
  String privacy_last_synced(Object date);

  /// No description provided for @privacy_permission_required.
  ///
  /// In en, this message translates to:
  /// **'Contacts permission is required.'**
  String get privacy_permission_required;

  /// No description provided for @privacy_found.
  ///
  /// In en, this message translates to:
  /// **'Found {count} people you may know.'**
  String privacy_found(Object count);

  /// No description provided for @privacy_up_to_date.
  ///
  /// In en, this message translates to:
  /// **'Already up to date.'**
  String get privacy_up_to_date;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @ratings.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// No description provided for @choose_avatar.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Avatar'**
  String get choose_avatar;

  /// No description provided for @tiffin_package_request_off_days.
  ///
  /// In en, this message translates to:
  /// **'Tiffin Subscription Request Off Days'**
  String get tiffin_package_request_off_days;

  /// No description provided for @tiffin_package_request_off_days_instruction.
  ///
  /// In en, this message translates to:
  /// **'If there are specific days when you do not want to receive your tiffin, you can mark those days as \'Off Days.\' On these days, no orders will be placed or delivered for your subscription.'**
  String get tiffin_package_request_off_days_instruction;

  /// No description provided for @tiffin_off_day_one.
  ///
  /// In en, this message translates to:
  /// **'Note: You cannot select'**
  String get tiffin_off_day_one;

  /// No description provided for @tiffin_off_day_two.
  ///
  /// In en, this message translates to:
  /// **'as off days, as orders are not placed on these days by default.'**
  String get tiffin_off_day_two;

  /// No description provided for @tiffin_off_day_date.
  ///
  /// In en, this message translates to:
  /// **'Select Off Day Date'**
  String get tiffin_off_day_date;

  /// No description provided for @select_reason.
  ///
  /// In en, this message translates to:
  /// **'Select Reason'**
  String get select_reason;

  /// No description provided for @tiffin_package_help.
  ///
  /// In en, this message translates to:
  /// **'Tiffin Subscription Package Help'**
  String get tiffin_package_help;

  /// No description provided for @download_invoice.
  ///
  /// In en, this message translates to:
  /// **'Download invoice'**
  String get download_invoice;

  /// No description provided for @download_summary.
  ///
  /// In en, this message translates to:
  /// **'Download summary'**
  String get download_summary;

  /// No description provided for @add_off_date.
  ///
  /// In en, this message translates to:
  /// **'Add Day Off Date'**
  String get add_off_date;

  /// No description provided for @refund_request.
  ///
  /// In en, this message translates to:
  /// **'Refund Request'**
  String get refund_request;

  /// No description provided for @flat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get flat;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @select_any_one_option.
  ///
  /// In en, this message translates to:
  /// **'Select any 1 option'**
  String get select_any_one_option;

  /// No description provided for @select_min.
  ///
  /// In en, this message translates to:
  /// **'Select min'**
  String get select_min;

  /// No description provided for @and_upto.
  ///
  /// In en, this message translates to:
  /// **'and upto'**
  String get and_upto;

  /// No description provided for @required_food_variation.
  ///
  /// In en, this message translates to:
  /// **'REQUIRED'**
  String get required_food_variation;

  /// No description provided for @food_addon.
  ///
  /// In en, this message translates to:
  /// **'Add On'**
  String get food_addon;

  /// No description provided for @add_to_cart_btn.
  ///
  /// In en, this message translates to:
  /// **'Add To Cart'**
  String get add_to_cart_btn;

  /// No description provided for @system_error_one.
  ///
  /// In en, this message translates to:
  /// **'Oops! It seems like something unexpected happened. Our team has been notified and is working diligently to resolve the issue. We apologize for any inconvenience this may have caused. Thank you for your patience and understanding'**
  String get system_error_one;

  /// No description provided for @undestand_and_go_back.
  ///
  /// In en, this message translates to:
  /// **'Okay, I understand, Go Back'**
  String get undestand_and_go_back;

  /// No description provided for @promo_lbl.
  ///
  /// In en, this message translates to:
  /// **'PROMOTED'**
  String get promo_lbl;

  /// No description provided for @for_two_lbl.
  ///
  /// In en, this message translates to:
  /// **'for two'**
  String get for_two_lbl;

  /// No description provided for @remove_now_btn.
  ///
  /// In en, this message translates to:
  /// **'Remove now'**
  String get remove_now_btn;

  /// No description provided for @undo_btn.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo_btn;

  /// No description provided for @why_btn.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get why_btn;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'added'**
  String get added;

  /// No description provided for @are_you_sure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get are_you_sure;

  /// No description provided for @confirm_delete_account_title.
  ///
  /// In en, this message translates to:
  /// **'Are You Sure You Want to Delete Your Account?'**
  String get confirm_delete_account_title;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorized;

  /// No description provided for @confirm_delete_address.
  ///
  /// In en, this message translates to:
  /// **'If yes this address will be removed from the system and the action cannot be undone'**
  String get confirm_delete_address;

  /// No description provided for @confirm_delete_item.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete it!'**
  String get confirm_delete_item;

  /// No description provided for @confirm_delete_account.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data, including order history, subscriptions, wallet balance, saved addresses, and payment methods, will be permanently deleted.'**
  String get confirm_delete_account;

  /// No description provided for @unauthorized_checkout_access.
  ///
  /// In en, this message translates to:
  /// **'You may not have the necessary permissions to proceed with checkout. Please logging back in to continue or use guest checkout'**
  String get unauthorized_checkout_access;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @cancle.
  ///
  /// In en, this message translates to:
  /// **'Cancle'**
  String get cancle;

  /// No description provided for @guest_checkout.
  ///
  /// In en, this message translates to:
  /// **'Guest Checkout'**
  String get guest_checkout;

  /// No description provided for @confirm_remove_cart_item.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items from this cart?'**
  String get confirm_remove_cart_item;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clear_all;

  /// No description provided for @confirm_remove_restaurant_cart_item_one.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items from this'**
  String get confirm_remove_restaurant_cart_item_one;

  /// No description provided for @confirm_remove_restaurant_cart_item_two.
  ///
  /// In en, this message translates to:
  /// **'cart?'**
  String get confirm_remove_restaurant_cart_item_two;

  /// No description provided for @verification_failed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verification_failed;

  /// No description provided for @please_authorized.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate'**
  String get please_authorized;

  /// No description provided for @image_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Image Uploaded'**
  String get image_uploaded;

  /// No description provided for @profile_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profile_updated;

  /// No description provided for @avatar_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Avatar uploaded'**
  String get avatar_uploaded;

  /// No description provided for @feedback_saved.
  ///
  /// In en, this message translates to:
  /// **'Your Feedback is saved'**
  String get feedback_saved;

  /// No description provided for @report_saved.
  ///
  /// In en, this message translates to:
  /// **'Your Report is saved'**
  String get report_saved;

  /// No description provided for @preferences_updated.
  ///
  /// In en, this message translates to:
  /// **'Preferences updated'**
  String get preferences_updated;

  /// No description provided for @email_updated.
  ///
  /// In en, this message translates to:
  /// **'Email Updated'**
  String get email_updated;

  /// No description provided for @phone_updated.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number Updated'**
  String get phone_updated;

  /// No description provided for @account_deleted.
  ///
  /// In en, this message translates to:
  /// **'Account Deleted!'**
  String get account_deleted;

  /// No description provided for @password_updated.
  ///
  /// In en, this message translates to:
  /// **'Password Updated'**
  String get password_updated;

  /// No description provided for @off_day_request_saved.
  ///
  /// In en, this message translates to:
  /// **'Off Day Request Saved'**
  String get off_day_request_saved;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @refund_request_created.
  ///
  /// In en, this message translates to:
  /// **'Your Refund Request Is Created'**
  String get refund_request_created;

  /// No description provided for @review_saved.
  ///
  /// In en, this message translates to:
  /// **'Review Saved'**
  String get review_saved;

  /// No description provided for @image_deleted.
  ///
  /// In en, this message translates to:
  /// **'Image Deleted'**
  String get image_deleted;

  /// No description provided for @reason_updated.
  ///
  /// In en, this message translates to:
  /// **'Reason updated'**
  String get reason_updated;

  /// No description provided for @file_downloaded_path.
  ///
  /// In en, this message translates to:
  /// **'File Downloaded to'**
  String get file_downloaded_path;

  /// No description provided for @otp_sent.
  ///
  /// In en, this message translates to:
  /// **'OTP Sent'**
  String get otp_sent;

  /// No description provided for @report_sent.
  ///
  /// In en, this message translates to:
  /// **'Report Sent'**
  String get report_sent;

  /// No description provided for @removed_from_list.
  ///
  /// In en, this message translates to:
  /// **'Removed from list'**
  String get removed_from_list;

  /// No description provided for @restaurant_hidden_success.
  ///
  /// In en, this message translates to:
  /// **'You can reveal it again from your account section'**
  String get restaurant_hidden_success;

  /// No description provided for @complaint_saved.
  ///
  /// In en, this message translates to:
  /// **'Complaint Registered'**
  String get complaint_saved;

  /// No description provided for @receiver_name.
  ///
  /// In en, this message translates to:
  /// **'Receiver Name'**
  String get receiver_name;

  /// No description provided for @receiver_contact.
  ///
  /// In en, this message translates to:
  /// **'Receiver Contact'**
  String get receiver_contact;

  /// No description provided for @new_address_title.
  ///
  /// In en, this message translates to:
  /// **'Enter address details'**
  String get new_address_title;

  /// No description provided for @save_address_as.
  ///
  /// In en, this message translates to:
  /// **'Save address as'**
  String get save_address_as;

  /// No description provided for @assist_deliveryman.
  ///
  /// In en, this message translates to:
  /// **'May be used to assist delivery'**
  String get assist_deliveryman;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @address_flat_house.
  ///
  /// In en, this message translates to:
  /// **'Flat / House no / Floor / Building'**
  String get address_flat_house;

  /// No description provided for @adderss_area_locality.
  ///
  /// In en, this message translates to:
  /// **'Area / Sector / Locality'**
  String get adderss_area_locality;

  /// No description provided for @address_landmark.
  ///
  /// In en, this message translates to:
  /// **'Nearby landmark (optional)'**
  String get address_landmark;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get first_name;

  /// No description provided for @last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get last_name;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'Date Of Birth'**
  String get dob;

  /// No description provided for @identity_number.
  ///
  /// In en, this message translates to:
  /// **'Indentity Number'**
  String get identity_number;

  /// No description provided for @country_code.
  ///
  /// In en, this message translates to:
  /// **'Country Code'**
  String get country_code;

  /// No description provided for @form_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get form_required;

  /// No description provided for @cooking_instruction.
  ///
  /// In en, this message translates to:
  /// **'Cooking Instructions'**
  String get cooking_instruction;

  /// No description provided for @add_cooking_request.
  ///
  /// In en, this message translates to:
  /// **'Add cooking requests'**
  String get add_cooking_request;

  /// No description provided for @your_email.
  ///
  /// In en, this message translates to:
  /// **'Your Email'**
  String get your_email;

  /// No description provided for @your_name.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get your_name;

  /// No description provided for @your_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Your Mobile Number'**
  String get your_phone_number;

  /// No description provided for @write_feedback.
  ///
  /// In en, this message translates to:
  /// **'Enter feedback'**
  String get write_feedback;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @enter_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enter_amount;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @write_experience.
  ///
  /// In en, this message translates to:
  /// **'Tell us more about your overall experience.'**
  String get write_experience;

  /// No description provided for @start_typing.
  ///
  /// In en, this message translates to:
  /// **'Start typing here..'**
  String get start_typing;

  /// No description provided for @min_time.
  ///
  /// In en, this message translates to:
  /// **'Min Time'**
  String get min_time;

  /// No description provided for @max_time.
  ///
  /// In en, this message translates to:
  /// **'Max Time'**
  String get max_time;

  /// No description provided for @restaurant_name.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Name'**
  String get restaurant_name;

  /// No description provided for @short_description.
  ///
  /// In en, this message translates to:
  /// **'Short Description'**
  String get short_description;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @rest_lat.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Latitude'**
  String get rest_lat;

  /// No description provided for @rest_lng.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Longitude'**
  String get rest_lng;

  /// No description provided for @cuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get cuisine;

  /// No description provided for @rest_type.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Type'**
  String get rest_type;

  /// No description provided for @rest_facilities.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Facilities'**
  String get rest_facilities;

  /// No description provided for @food_license.
  ///
  /// In en, this message translates to:
  /// **'Food License'**
  String get food_license;

  /// No description provided for @min_order_amount.
  ///
  /// In en, this message translates to:
  /// **'Min Order Amount'**
  String get min_order_amount;

  /// No description provided for @price_for_two.
  ///
  /// In en, this message translates to:
  /// **'Dish Price For Two Persion'**
  String get price_for_two;

  /// No description provided for @appx_delivery_time.
  ///
  /// In en, this message translates to:
  /// **'Approx Delivery Time'**
  String get appx_delivery_time;

  /// No description provided for @social_fb.
  ///
  /// In en, this message translates to:
  /// **'Social Media Facebook URL'**
  String get social_fb;

  /// No description provided for @social_insta.
  ///
  /// In en, this message translates to:
  /// **'Social Media Instagram URL'**
  String get social_insta;

  /// No description provided for @social_x.
  ///
  /// In en, this message translates to:
  /// **'Social Media X URL'**
  String get social_x;

  /// No description provided for @social_yt.
  ///
  /// In en, this message translates to:
  /// **'Social Media Youtube URL'**
  String get social_yt;

  /// No description provided for @social_ll.
  ///
  /// In en, this message translates to:
  /// **'Social Media LinkedIn URL'**
  String get social_ll;

  /// No description provided for @social_pinterest.
  ///
  /// In en, this message translates to:
  /// **'Social Media Pinterest URL'**
  String get social_pinterest;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @save_address_btn.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get save_address_btn;

  /// No description provided for @confirm_delivery_address.
  ///
  /// In en, this message translates to:
  /// **'Confirm delivery location'**
  String get confirm_delivery_address;

  /// No description provided for @locate_me.
  ///
  /// In en, this message translates to:
  /// **'Locate Me'**
  String get locate_me;

  /// No description provided for @select_delivery_location.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Location'**
  String get select_delivery_location;

  /// No description provided for @complete_address.
  ///
  /// In en, this message translates to:
  /// **'Complete address'**
  String get complete_address;

  /// No description provided for @cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get cover;

  /// No description provided for @joining_type.
  ///
  /// In en, this message translates to:
  /// **'Joining Type'**
  String get joining_type;

  /// No description provided for @identity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identity;

  /// No description provided for @identity_proof.
  ///
  /// In en, this message translates to:
  /// **'Identity Proof'**
  String get identity_proof;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @locality.
  ///
  /// In en, this message translates to:
  /// **'Locality'**
  String get locality;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @driving_license.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get driving_license;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @your_dining_booking.
  ///
  /// In en, this message translates to:
  /// **'Your table bookings'**
  String get your_dining_booking;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @booking_created.
  ///
  /// In en, this message translates to:
  /// **'Booking Created!'**
  String get booking_created;

  /// No description provided for @booking_accepted.
  ///
  /// In en, this message translates to:
  /// **'Booking Accepted!'**
  String get booking_accepted;

  /// No description provided for @booking_completed.
  ///
  /// In en, this message translates to:
  /// **'Booking Completed!'**
  String get booking_completed;

  /// No description provided for @booking_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking Cancelled'**
  String get booking_cancelled;

  /// No description provided for @booking_rejected.
  ///
  /// In en, this message translates to:
  /// **'Booking Rejected'**
  String get booking_rejected;

  /// No description provided for @booking_refunded.
  ///
  /// In en, this message translates to:
  /// **'Booking Amount Refunded!'**
  String get booking_refunded;

  /// No description provided for @payment_pending.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending!'**
  String get payment_pending;

  /// No description provided for @dining_support.
  ///
  /// In en, this message translates to:
  /// **'Dining Support'**
  String get dining_support;

  /// No description provided for @dining_detail.
  ///
  /// In en, this message translates to:
  /// **'Dining Booking Information'**
  String get dining_detail;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'Id'**
  String get id;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @guest_number.
  ///
  /// In en, this message translates to:
  /// **'Number of guests'**
  String get guest_number;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @your_special_request.
  ///
  /// In en, this message translates to:
  /// **'Your special request'**
  String get your_special_request;

  /// No description provided for @pre_booking_charge.
  ///
  /// In en, this message translates to:
  /// **'Pre Booking Charge'**
  String get pre_booking_charge;

  /// No description provided for @coupon_cover_charge.
  ///
  /// In en, this message translates to:
  /// **'Coupon Cover Charge'**
  String get coupon_cover_charge;

  /// No description provided for @amount_adjusted_in_final_bill.
  ///
  /// In en, this message translates to:
  /// **'This amount will be adjusted in your final bill'**
  String get amount_adjusted_in_final_bill;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @cancel_booking_btn.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancel_booking_btn;

  /// No description provided for @pay_using.
  ///
  /// In en, this message translates to:
  /// **'PAY USING'**
  String get pay_using;

  /// No description provided for @repay_online.
  ///
  /// In en, this message translates to:
  /// **'Repay Online'**
  String get repay_online;

  /// No description provided for @search_dining_booking.
  ///
  /// In en, this message translates to:
  /// **'Search dining booking'**
  String get search_dining_booking;

  /// No description provided for @search_with_email_or_phone.
  ///
  /// In en, this message translates to:
  /// **'Search by Email or Phone Number'**
  String get search_with_email_or_phone;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @find_dining_booking.
  ///
  /// In en, this message translates to:
  /// **'Find Your Dining Booking!'**
  String get find_dining_booking;

  /// No description provided for @find_dining_booking_sub_title.
  ///
  /// In en, this message translates to:
  /// **'You can locate your dining booking by entering your email or phone number. We\'ll retrieve your booking details using your current authentication, ensuring a seamless and secure experience.'**
  String get find_dining_booking_sub_title;

  /// No description provided for @your_dining_transactions.
  ///
  /// In en, this message translates to:
  /// **'Your Dining transactions'**
  String get your_dining_transactions;

  /// No description provided for @booking_id.
  ///
  /// In en, this message translates to:
  /// **'Booking Id'**
  String get booking_id;

  /// No description provided for @transaction_date.
  ///
  /// In en, this message translates to:
  /// **'Transaction Date'**
  String get transaction_date;

  /// No description provided for @transaction_status.
  ///
  /// In en, this message translates to:
  /// **'Transaction Status'**
  String get transaction_status;

  /// No description provided for @avatar_list.
  ///
  /// In en, this message translates to:
  /// **'Avatar List'**
  String get avatar_list;

  /// No description provided for @update_profile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get update_profile;

  /// No description provided for @submit_feedback.
  ///
  /// In en, this message translates to:
  /// **'Submit feedback'**
  String get submit_feedback;

  /// No description provided for @your_purchased_tiffin_packages.
  ///
  /// In en, this message translates to:
  /// **'Your Purchased Subscription'**
  String get your_purchased_tiffin_packages;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refunded;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @only.
  ///
  /// In en, this message translates to:
  /// **'only'**
  String get only;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @your_tiffin_package_transactions.
  ///
  /// In en, this message translates to:
  /// **'Your Food Subscription Transaction'**
  String get your_tiffin_package_transactions;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @total_orders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get total_orders;

  /// No description provided for @subscription_id.
  ///
  /// In en, this message translates to:
  /// **'Subscription Id'**
  String get subscription_id;

  /// No description provided for @purchase_history.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get purchase_history;

  /// No description provided for @cancel_subscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancel_subscription;

  /// No description provided for @order_was_incomplete_due_to_pending_payment.
  ///
  /// In en, this message translates to:
  /// **'Your Order Was Incomplete Due To Pending Payments'**
  String get order_was_incomplete_due_to_pending_payment;

  /// No description provided for @offer_by.
  ///
  /// In en, this message translates to:
  /// **'Offer By'**
  String get offer_by;

  /// No description provided for @order_charges.
  ///
  /// In en, this message translates to:
  /// **'Order Charges'**
  String get order_charges;

  /// No description provided for @subscription_charge.
  ///
  /// In en, this message translates to:
  /// **'Subscription Charge'**
  String get subscription_charge;

  /// No description provided for @food_service_charge.
  ///
  /// In en, this message translates to:
  /// **'Food Service Charge'**
  String get food_service_charge;

  /// No description provided for @service_charge.
  ///
  /// In en, this message translates to:
  /// **'Service Charge'**
  String get service_charge;

  /// No description provided for @extra_service_charge.
  ///
  /// In en, this message translates to:
  /// **'Extra Service Charge'**
  String get extra_service_charge;

  /// No description provided for @package_charge.
  ///
  /// In en, this message translates to:
  /// **'Packaging Charge'**
  String get package_charge;

  /// No description provided for @package_charge_tax.
  ///
  /// In en, this message translates to:
  /// **'Packaging Charge Tax'**
  String get package_charge_tax;

  /// No description provided for @purchase_details.
  ///
  /// In en, this message translates to:
  /// **'Purchase Details'**
  String get purchase_details;

  /// No description provided for @purchase_id.
  ///
  /// In en, this message translates to:
  /// **'Purchase ID'**
  String get purchase_id;

  /// No description provided for @subscription_started.
  ///
  /// In en, this message translates to:
  /// **'Subscription Started'**
  String get subscription_started;

  /// No description provided for @subscription_model.
  ///
  /// In en, this message translates to:
  /// **'Subscription Model'**
  String get subscription_model;

  /// No description provided for @subscription_slot.
  ///
  /// In en, this message translates to:
  /// **'Subscription Slot'**
  String get subscription_slot;

  /// No description provided for @subscription_off_days.
  ///
  /// In en, this message translates to:
  /// **'Subscription Off Days'**
  String get subscription_off_days;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiver;

  /// No description provided for @deliver_to.
  ///
  /// In en, this message translates to:
  /// **'Deliver To'**
  String get deliver_to;

  /// No description provided for @delivery_instruction.
  ///
  /// In en, this message translates to:
  /// **'Delivery Instruction'**
  String get delivery_instruction;

  /// No description provided for @lic_no.
  ///
  /// In en, this message translates to:
  /// **'Lic. No.'**
  String get lic_no;

  /// No description provided for @your_order_transactions.
  ///
  /// In en, this message translates to:
  /// **'Your Order Transactions'**
  String get your_order_transactions;

  /// No description provided for @order_id.
  ///
  /// In en, this message translates to:
  /// **'Order Id'**
  String get order_id;

  /// No description provided for @refer_now.
  ///
  /// In en, this message translates to:
  /// **'Refer Now'**
  String get refer_now;

  /// No description provided for @refer_safety_emergency.
  ///
  /// In en, this message translates to:
  /// **'Report a Safety Emergency'**
  String get refer_safety_emergency;

  /// No description provided for @refer_safety_emergency_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Kindly use this page to report only serious incidents or accidents. For any order-related inquiries, please reach out to our chat support.'**
  String get refer_safety_emergency_sub_title;

  /// No description provided for @submit_message.
  ///
  /// In en, this message translates to:
  /// **'Submit Message'**
  String get submit_message;

  /// No description provided for @restaurant_register_request_title.
  ///
  /// In en, this message translates to:
  /// **'Partner with us as a restaurant'**
  String get restaurant_register_request_title;

  /// No description provided for @restaurant_logo.
  ///
  /// In en, this message translates to:
  /// **'Restaurant LOGO'**
  String get restaurant_logo;

  /// No description provided for @restaurant_cover.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Cover'**
  String get restaurant_cover;

  /// No description provided for @google_maps_here.
  ///
  /// In en, this message translates to:
  /// **'Google Maps Here'**
  String get google_maps_here;

  /// No description provided for @home_delivery_available.
  ///
  /// In en, this message translates to:
  /// **'Home Delivery Available'**
  String get home_delivery_available;

  /// No description provided for @take_away_available.
  ///
  /// In en, this message translates to:
  /// **'TakeAway Available'**
  String get take_away_available;

  /// No description provided for @schedule_orders.
  ///
  /// In en, this message translates to:
  /// **'Schedule Orders?'**
  String get schedule_orders;

  /// No description provided for @commission_system.
  ///
  /// In en, this message translates to:
  /// **'Commission-Based System'**
  String get commission_system;

  /// No description provided for @commission_system_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Pay a small percentage for each order placed through our platform. This model requires no upfront costs, making it perfect for restaurants looking to grow gradually. Only pay when you earn!'**
  String get commission_system_sub_title;

  /// No description provided for @subscription_system.
  ///
  /// In en, this message translates to:
  /// **'Subscription-Based System'**
  String get subscription_system;

  /// No description provided for @subscription_system_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Choose a flat monthly or yearly fee for unlimited orders. This model is ideal for high-volume restaurants seeking predictable expenses and full control over their profits.'**
  String get subscription_system_sub_title;

  /// No description provided for @choose_subscription_package.
  ///
  /// In en, this message translates to:
  /// **'Choose Subscription Package'**
  String get choose_subscription_package;

  /// No description provided for @enjoy.
  ///
  /// In en, this message translates to:
  /// **'Enjoy'**
  String get enjoy;

  /// No description provided for @a.
  ///
  /// In en, this message translates to:
  /// **'a'**
  String get a;

  /// No description provided for @free_trial_started.
  ///
  /// In en, this message translates to:
  /// **'day free trial to get started.'**
  String get free_trial_started;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @order_limit.
  ///
  /// In en, this message translates to:
  /// **'Order Limit'**
  String get order_limit;

  /// No description provided for @per_month.
  ///
  /// In en, this message translates to:
  /// **'Per Month'**
  String get per_month;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @product_limit.
  ///
  /// In en, this message translates to:
  /// **'Product Limit'**
  String get product_limit;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get pos;

  /// No description provided for @own_deliveryman.
  ///
  /// In en, this message translates to:
  /// **'Own Deliveryman'**
  String get own_deliveryman;

  /// No description provided for @promote_to_system.
  ///
  /// In en, this message translates to:
  /// **'Promote On Entire System'**
  String get promote_to_system;

  /// No description provided for @custom_category.
  ///
  /// In en, this message translates to:
  /// **'Custom Category'**
  String get custom_category;

  /// No description provided for @multi_outlet.
  ///
  /// In en, this message translates to:
  /// **'Multi Outlet'**
  String get multi_outlet;

  /// No description provided for @table_booking.
  ///
  /// In en, this message translates to:
  /// **'Table Booking'**
  String get table_booking;

  /// No description provided for @table_order.
  ///
  /// In en, this message translates to:
  /// **'Table Order'**
  String get table_order;

  /// No description provided for @tittin_subscription_packages.
  ///
  /// In en, this message translates to:
  /// **'Subscription / Tiffin Service'**
  String get tittin_subscription_packages;

  /// No description provided for @waiter_service.
  ///
  /// In en, this message translates to:
  /// **'Waiter Service'**
  String get waiter_service;

  /// No description provided for @own_kitchen_owner_permission.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Owners'**
  String get own_kitchen_owner_permission;

  /// No description provided for @profile_info.
  ///
  /// In en, this message translates to:
  /// **'Profile Info'**
  String get profile_info;

  /// No description provided for @profile_info_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Update your name, bio, and profile picture'**
  String get profile_info_sub_title;

  /// No description provided for @alert_pref.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Preferences'**
  String get alert_pref;

  /// No description provided for @alert_pref_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Choose how you receive updates and reminders'**
  String get alert_pref_sub_title;

  /// No description provided for @user_account.
  ///
  /// In en, this message translates to:
  /// **'User Account'**
  String get user_account;

  /// No description provided for @user_account_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Manage your login details or remove your account'**
  String get user_account_sub_title;

  /// No description provided for @device_access.
  ///
  /// In en, this message translates to:
  /// **'Device Access'**
  String get device_access;

  /// No description provided for @device_access_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Control access to location, camera, and more from your phone settings'**
  String get device_access_sub_title;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @contacts_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Find friends from contacts and control who sees your activity'**
  String get contacts_sub_title;

  /// No description provided for @app_settings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get app_settings;

  /// No description provided for @change_email.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get change_email;

  /// No description provided for @change_email_sub_title.
  ///
  /// In en, this message translates to:
  /// **'To ensure your account\'s security, you have been logged out.If Email Address or Phone Number changed, Please log in again using your updated credentials.'**
  String get change_email_sub_title;

  /// No description provided for @change_mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Change Mobile Number'**
  String get change_mobile_number;

  /// No description provided for @change_mobile_number_sub_title.
  ///
  /// In en, this message translates to:
  /// **'To ensure your account\'s security, you have been logged out.If Email Address or Phone Number changed, Please log in again using your updated credentials.'**
  String get change_mobile_number_sub_title;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @newsletters.
  ///
  /// In en, this message translates to:
  /// **'Newsletters'**
  String get newsletters;

  /// No description provided for @newsletters_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Stay informed with the latest news, updates, and stories from the food world.'**
  String get newsletters_sub_title;

  /// No description provided for @promo_offers.
  ///
  /// In en, this message translates to:
  /// **'Promotions & Offers'**
  String get promo_offers;

  /// No description provided for @promo_offers_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Get alerts about exclusive deals, discounts, and special promotions tailored just for you.'**
  String get promo_offers_sub_title;

  /// No description provided for @push.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get push;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @social_alert.
  ///
  /// In en, this message translates to:
  /// **'Social Activity Alerts'**
  String get social_alert;

  /// No description provided for @social_alert_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Be notified when someone follows you, or interacts with your posts and reviews.'**
  String get social_alert_sub_title;

  /// No description provided for @order_purchase.
  ///
  /// In en, this message translates to:
  /// **'Orders & Purchases'**
  String get order_purchase;

  /// No description provided for @order_purchase_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Track your order updates, membership details, and booking confirmations.'**
  String get order_purchase_sub_title;

  /// No description provided for @account_updates.
  ///
  /// In en, this message translates to:
  /// **'Important Account Updates'**
  String get account_updates;

  /// No description provided for @account_updates_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Receive critical alerts about your account status, security, or changes to our terms.'**
  String get account_updates_sub_title;

  /// No description provided for @update_pref.
  ///
  /// In en, this message translates to:
  /// **'Update Preference'**
  String get update_pref;

  /// No description provided for @update_password.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get update_password;

  /// No description provided for @add_money.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get add_money;

  /// No description provided for @loyalty.
  ///
  /// In en, this message translates to:
  /// **'Loyalty'**
  String get loyalty;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @deposite.
  ///
  /// In en, this message translates to:
  /// **'Deposite'**
  String get deposite;

  /// No description provided for @withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get withdrawal;

  /// No description provided for @transaction_history.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transaction_history;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @no_record_found.
  ///
  /// In en, this message translates to:
  /// **'No Record Found'**
  String get no_record_found;

  /// No description provided for @add_money_to_wallet.
  ///
  /// In en, this message translates to:
  /// **'Add money to wallet'**
  String get add_money_to_wallet;

  /// No description provided for @to_pay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get to_pay;

  /// No description provided for @single_click_payment.
  ///
  /// In en, this message translates to:
  /// **'Single click payments'**
  String get single_click_payment;

  /// No description provided for @no_additional_cost.
  ///
  /// In en, this message translates to:
  /// **'No additional costs'**
  String get no_additional_cost;

  /// No description provided for @valid_till.
  ///
  /// In en, this message translates to:
  /// **'Valid till'**
  String get valid_till;

  /// No description provided for @pay_now.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get pay_now;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @can_earn_cash_in_wallet.
  ///
  /// In en, this message translates to:
  /// **'You Can Earn Cash In Wallet'**
  String get can_earn_cash_in_wallet;

  /// No description provided for @wallet_required.
  ///
  /// In en, this message translates to:
  /// **'* Required'**
  String get wallet_required;

  /// No description provided for @points_to_redeem.
  ///
  /// In en, this message translates to:
  /// **'Points To Redeem'**
  String get points_to_redeem;

  /// No description provided for @points_to.
  ///
  /// In en, this message translates to:
  /// **'Points to'**
  String get points_to;

  /// No description provided for @in_wallet_cash_amount.
  ///
  /// In en, this message translates to:
  /// **'In Wallet Cash Amount'**
  String get in_wallet_cash_amount;

  /// No description provided for @active_points_history.
  ///
  /// In en, this message translates to:
  /// **'Active Points History'**
  String get active_points_history;

  /// No description provided for @received_from_order.
  ///
  /// In en, this message translates to:
  /// **'Received From Order'**
  String get received_from_order;

  /// No description provided for @received_from_coupon.
  ///
  /// In en, this message translates to:
  /// **'Received From Coupon'**
  String get received_from_coupon;

  /// No description provided for @redeem_points_btn.
  ///
  /// In en, this message translates to:
  /// **'Redeem Points'**
  String get redeem_points_btn;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continue_as_guest.
  ///
  /// In en, this message translates to:
  /// **'Continue as a guest'**
  String get continue_as_guest;

  /// No description provided for @welcome_to.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcome_to;

  /// No description provided for @email_otp_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and otp code for sign-in. Feast at Your Fingertips: Seamless Login for Savory Delights!'**
  String get email_otp_sub_title;

  /// No description provided for @email_password_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and password for sign-in. Feast at Your Fingertips: Seamless Login for Savory Delights!'**
  String get email_password_sub_title;

  /// No description provided for @phone_otp_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number and otp for sign-in. Feast at Your Fingertips: Seamless Login for Savory Delights!'**
  String get phone_otp_sub_title;

  /// No description provided for @phone_password_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number and password for sign-in. Feast at Your Fingertips: Seamless Login for Savory Delights!'**
  String get phone_password_sub_title;

  /// No description provided for @remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get remember_me;

  /// No description provided for @sign_in_social_account.
  ///
  /// In en, this message translates to:
  /// **'Sign in with social account'**
  String get sign_in_social_account;

  /// No description provided for @apple_login.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple_login;

  /// No description provided for @please_wait_social.
  ///
  /// In en, this message translates to:
  /// **'Please wait....'**
  String get please_wait_social;

  /// No description provided for @google_login.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google_login;

  /// No description provided for @facebook_login.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook_login;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @sign_up_btn.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up_btn;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dont_have_account;

  /// No description provided for @register_term_one.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get register_term_one;

  /// No description provided for @register_term_two.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get register_term_two;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @self_pickup.
  ///
  /// In en, this message translates to:
  /// **'Self Pickup'**
  String get self_pickup;

  /// No description provided for @forgot_password_title.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgot_password_title;

  /// No description provided for @forgot_your_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgot_your_password;

  /// No description provided for @form_valid_password_required.
  ///
  /// In en, this message translates to:
  /// **'Required - Please ensure the Password entered is valid'**
  String get form_valid_password_required;

  /// No description provided for @form_valid_confirm_password_required.
  ///
  /// In en, this message translates to:
  /// **'Required - Please ensure the Confirm entered is valid & match'**
  String get form_valid_confirm_password_required;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @empty_cart_title.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get empty_cart_title;

  /// No description provided for @empty_cart_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Turn this empty cart into a flavor-packed adventure! Fill it with delicious delights and let your culinary creations take center stage'**
  String get empty_cart_sub_title;

  /// No description provided for @place_order.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get place_order;

  /// No description provided for @home_delivery.
  ///
  /// In en, this message translates to:
  /// **'Home Delivery'**
  String get home_delivery;

  /// No description provided for @take_away.
  ///
  /// In en, this message translates to:
  /// **'Take Away'**
  String get take_away;

  /// No description provided for @schedule_delivery_date.
  ///
  /// In en, this message translates to:
  /// **'Schedule a Delivery Date'**
  String get schedule_delivery_date;

  /// No description provided for @schedule_delivery_date_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Please select between our available time slots below for delivery of your order'**
  String get schedule_delivery_date_sub_title;

  /// No description provided for @schedule_delivery_time.
  ///
  /// In en, this message translates to:
  /// **'Schedule a Delivery Time'**
  String get schedule_delivery_time;

  /// No description provided for @contain_free_item_bogo.
  ///
  /// In en, this message translates to:
  /// **'Contains 1 Free Item'**
  String get contain_free_item_bogo;

  /// No description provided for @free_item.
  ///
  /// In en, this message translates to:
  /// **'Free Item'**
  String get free_item;

  /// No description provided for @free_bogo.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free_bogo;

  /// No description provided for @use_wallet_money.
  ///
  /// In en, this message translates to:
  /// **'Use Wallet Money'**
  String get use_wallet_money;

  /// No description provided for @view_all_coupon.
  ///
  /// In en, this message translates to:
  /// **'View all coupons'**
  String get view_all_coupon;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @delivery_in.
  ///
  /// In en, this message translates to:
  /// **'Delivery in'**
  String get delivery_in;

  /// No description provided for @delivery_at.
  ///
  /// In en, this message translates to:
  /// **'Deliver at'**
  String get delivery_at;

  /// No description provided for @add_delivery_instruction.
  ///
  /// In en, this message translates to:
  /// **'Add instructions for delivery partner'**
  String get add_delivery_instruction;

  /// No description provided for @total_bill.
  ///
  /// In en, this message translates to:
  /// **'Total Bill'**
  String get total_bill;

  /// No description provided for @tax_charge_incl.
  ///
  /// In en, this message translates to:
  /// **'Incl. taxes and charges'**
  String get tax_charge_incl;

  /// No description provided for @schedule_order.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Order'**
  String get schedule_order;

  /// No description provided for @instant_order.
  ///
  /// In en, this message translates to:
  /// **'Instant Order'**
  String get instant_order;

  /// No description provided for @restaurant_open_soon.
  ///
  /// In en, this message translates to:
  /// **'This restaurant opens for food delivery soon'**
  String get restaurant_open_soon;

  /// No description provided for @select_address_for_next_step.
  ///
  /// In en, this message translates to:
  /// **'Select address at next step'**
  String get select_address_for_next_step;

  /// No description provided for @contact_information.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contact_information;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @direct_chat.
  ///
  /// In en, this message translates to:
  /// **'Direct Chat'**
  String get direct_chat;

  /// No description provided for @support_chat.
  ///
  /// In en, this message translates to:
  /// **'Support Chat'**
  String get support_chat;

  /// No description provided for @open_ticket.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open_ticket;

  /// No description provided for @in_progress_ticket.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get in_progress_ticket;

  /// No description provided for @resolved_ticket.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved_ticket;

  /// No description provided for @home_search_bar.
  ///
  /// In en, this message translates to:
  /// **'Search \'pizza\''**
  String get home_search_bar;

  /// No description provided for @maps.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get maps;

  /// No description provided for @view_dining.
  ///
  /// In en, this message translates to:
  /// **'View Dining'**
  String get view_dining;

  /// No description provided for @top_restaurant_and_dish.
  ///
  /// In en, this message translates to:
  /// **'Top Restaurant & Dish'**
  String get top_restaurant_and_dish;

  /// No description provided for @book_table_title.
  ///
  /// In en, this message translates to:
  /// **'Book a table'**
  String get book_table_title;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'guest'**
  String get guest;

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'guests'**
  String get guests;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'offers'**
  String get offers;

  /// No description provided for @no_cover_charge_required.
  ///
  /// In en, this message translates to:
  /// **'No cover charge required'**
  String get no_cover_charge_required;

  /// No description provided for @cover_charge_required.
  ///
  /// In en, this message translates to:
  /// **'cover charge required'**
  String get cover_charge_required;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @login_as_guest.
  ///
  /// In en, this message translates to:
  /// **'Login as guest'**
  String get login_as_guest;

  /// No description provided for @login_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get login_to_continue;

  /// No description provided for @review_booking_detail.
  ///
  /// In en, this message translates to:
  /// **'Review booking details'**
  String get review_booking_detail;

  /// No description provided for @booking_summary.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get booking_summary;

  /// No description provided for @add_special_request.
  ///
  /// In en, this message translates to:
  /// **'Add special request'**
  String get add_special_request;

  /// No description provided for @your_detail.
  ///
  /// In en, this message translates to:
  /// **'Your Detail'**
  String get your_detail;

  /// No description provided for @booking_charge_summary.
  ///
  /// In en, this message translates to:
  /// **'Booking Charge Summary'**
  String get booking_charge_summary;

  /// No description provided for @to_be_paid.
  ///
  /// In en, this message translates to:
  /// **'To be paid'**
  String get to_be_paid;

  /// No description provided for @error_go_back.
  ///
  /// In en, this message translates to:
  /// **'Opps, go back'**
  String get error_go_back;

  /// No description provided for @add_your_details.
  ///
  /// In en, this message translates to:
  /// **'Add your details'**
  String get add_your_details;

  /// No description provided for @confirm_seat.
  ///
  /// In en, this message translates to:
  /// **'Confirm Seat'**
  String get confirm_seat;

  /// No description provided for @confirm_your_seat.
  ///
  /// In en, this message translates to:
  /// **'Confirm your seat'**
  String get confirm_your_seat;

  /// No description provided for @network_issue.
  ///
  /// In en, this message translates to:
  /// **'Network Issues'**
  String get network_issue;

  /// No description provided for @network_issue_sub_title.
  ///
  /// In en, this message translates to:
  /// **'If you are using Wi-Fi or mobile data, ensure that Wi-Fi or mobile data is enabled on your device. Go to the device settings and turn on Wi-Fi or mobile data. Then, select the appropriate Wi-Fi or mobile data network and connect.'**
  String get network_issue_sub_title;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// No description provided for @maintenance_title.
  ///
  /// In en, this message translates to:
  /// **'Apology for the Inconvenience'**
  String get maintenance_title;

  /// No description provided for @maintenance_title_sub_title.
  ///
  /// In en, this message translates to:
  /// **'We\'re currently undergoing scheduled maintenance to improve our services. We apologize for any inconvenience this may cause. Thank you for your patience. If you have urgent issues, please contact our support team at'**
  String get maintenance_title_sub_title;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @not_found_title.
  ///
  /// In en, this message translates to:
  /// **'Broken Content'**
  String get not_found_title;

  /// No description provided for @not_found_title_sub_title.
  ///
  /// In en, this message translates to:
  /// **'If there are links on a website pointing to non-existent pages, users may encounter 404 errors when trying to access those links.'**
  String get not_found_title_sub_title;

  /// No description provided for @server_error_title.
  ///
  /// In en, this message translates to:
  /// **'500 Internal Server Error'**
  String get server_error_title;

  /// No description provided for @server_error_sub_title.
  ///
  /// In en, this message translates to:
  /// **'This is a generic error message that indicates an unspecified problem on the server. It could be due to misconfigurations, server overload, or programming errors'**
  String get server_error_sub_title;

  /// No description provided for @favourite_restaurants.
  ///
  /// In en, this message translates to:
  /// **'Favourite Restaurants'**
  String get favourite_restaurants;

  /// No description provided for @favourite_dishes.
  ///
  /// In en, this message translates to:
  /// **'Favourite Dishes'**
  String get favourite_dishes;

  /// No description provided for @okay_i_understand.
  ///
  /// In en, this message translates to:
  /// **'Okay, I understand'**
  String get okay_i_understand;

  /// No description provided for @history_detail.
  ///
  /// In en, this message translates to:
  /// **'History Detail'**
  String get history_detail;

  /// No description provided for @cancel_order.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancel_order;

  /// No description provided for @review_and_rating.
  ///
  /// In en, this message translates to:
  /// **'Review & Ratings'**
  String get review_and_rating;

  /// No description provided for @order_from.
  ///
  /// In en, this message translates to:
  /// **'Order From'**
  String get order_from;

  /// No description provided for @pin_otp.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin_otp;

  /// No description provided for @item_total.
  ///
  /// In en, this message translates to:
  /// **'Item Total'**
  String get item_total;

  /// No description provided for @item_discount.
  ///
  /// In en, this message translates to:
  /// **'Item Discount'**
  String get item_discount;

  /// No description provided for @sub_total_amount.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get sub_total_amount;

  /// No description provided for @food_service_charge_amount.
  ///
  /// In en, this message translates to:
  /// **'Food Service Charge'**
  String get food_service_charge_amount;

  /// No description provided for @delivery_charge.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charge'**
  String get delivery_charge;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @account_not_registered.
  ///
  /// In en, this message translates to:
  /// **'Account Not Registered'**
  String get account_not_registered;

  /// No description provided for @out_of_stock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get out_of_stock;

  /// No description provided for @add_new_customisation.
  ///
  /// In en, this message translates to:
  /// **'Add new customisation'**
  String get add_new_customisation;

  /// No description provided for @update_cart.
  ///
  /// In en, this message translates to:
  /// **'Update Cart'**
  String get update_cart;

  /// No description provided for @select_restaurant_type.
  ///
  /// In en, this message translates to:
  /// **'Select Restaurant Type'**
  String get select_restaurant_type;

  /// No description provided for @select_restaurant_facilities.
  ///
  /// In en, this message translates to:
  /// **'Select Restaurant Facilities'**
  String get select_restaurant_facilities;

  /// No description provided for @change_deliverytime.
  ///
  /// In en, this message translates to:
  /// **'Change Deliverytime'**
  String get change_deliverytime;

  /// No description provided for @select_cuisine.
  ///
  /// In en, this message translates to:
  /// **'Select Cuisine'**
  String get select_cuisine;

  /// No description provided for @restaurants_near.
  ///
  /// In en, this message translates to:
  /// **'Restaurants Near'**
  String get restaurants_near;

  /// No description provided for @report_issue_on_menu.
  ///
  /// In en, this message translates to:
  /// **'Report an issue on the menu'**
  String get report_issue_on_menu;

  /// No description provided for @report_issue_on_menu_one.
  ///
  /// In en, this message translates to:
  /// **'Please share details about the issue below'**
  String get report_issue_on_menu_one;

  /// No description provided for @report_issue_on_menu_two.
  ///
  /// In en, this message translates to:
  /// **'We will get it corrected as soon as possible'**
  String get report_issue_on_menu_two;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get congratulations;

  /// No description provided for @ok_thanks.
  ///
  /// In en, this message translates to:
  /// **'Ok, Thanks'**
  String get ok_thanks;

  /// No description provided for @i_have_completed.
  ///
  /// In en, this message translates to:
  /// **'I have completed'**
  String get i_have_completed;

  /// No description provided for @five_star_deliveries.
  ///
  /// In en, this message translates to:
  /// **'five-star deliveries'**
  String get five_star_deliveries;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @order_details.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get order_details;

  /// No description provided for @order_number.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get order_number;

  /// No description provided for @order_ref.
  ///
  /// In en, this message translates to:
  /// **'Order Reference'**
  String get order_ref;

  /// No description provided for @remove_from_favourite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get remove_from_favourite;

  /// No description provided for @mark_as_favourite.
  ///
  /// In en, this message translates to:
  /// **'Mark as favourite'**
  String get mark_as_favourite;

  /// No description provided for @this_order_was.
  ///
  /// In en, this message translates to:
  /// **'This order was'**
  String get this_order_was;

  /// No description provided for @customizable.
  ///
  /// In en, this message translates to:
  /// **'Customizable'**
  String get customizable;

  /// No description provided for @buy_subscription.
  ///
  /// In en, this message translates to:
  /// **'Buy Subscription'**
  String get buy_subscription;

  /// No description provided for @food_included.
  ///
  /// In en, this message translates to:
  /// **'Food Included'**
  String get food_included;

  /// No description provided for @select_delivery_slot.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Slot'**
  String get select_delivery_slot;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @mark_all_read.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get mark_all_read;

  /// No description provided for @and_more.
  ///
  /// In en, this message translates to:
  /// **'and more'**
  String get and_more;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @you_have_hidden_restaurant.
  ///
  /// In en, this message translates to:
  /// **'You have hidden this restaurant'**
  String get you_have_hidden_restaurant;

  /// No description provided for @unhide.
  ///
  /// In en, this message translates to:
  /// **'Unhide'**
  String get unhide;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @add_cart.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get add_cart;

  /// No description provided for @enable_location.
  ///
  /// In en, this message translates to:
  /// **'Enable Location Services'**
  String get enable_location;

  /// No description provided for @enable_location_from_app_setting.
  ///
  /// In en, this message translates to:
  /// **'Please go to settings and enable location services for'**
  String get enable_location_from_app_setting;

  /// No description provided for @pay_total.
  ///
  /// In en, this message translates to:
  /// **'Pay total'**
  String get pay_total;

  /// No description provided for @verification_code.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verification_code;

  /// No description provided for @verification_sent_to.
  ///
  /// In en, this message translates to:
  /// **'A verification code has sent to'**
  String get verification_sent_to;

  /// No description provided for @check_email_inbox_verifition.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and enter the verification code below to verify your email address.'**
  String get check_email_inbox_verifition;

  /// No description provided for @check_phone_inbox_verification.
  ///
  /// In en, this message translates to:
  /// **'Please check your SMS inbox and enter the verification code below to verify your mobile number.'**
  String get check_phone_inbox_verification;

  /// No description provided for @save_reviews.
  ///
  /// In en, this message translates to:
  /// **'Save Reviews'**
  String get save_reviews;

  /// No description provided for @write_a_review.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get write_a_review;

  /// No description provided for @upload_max_three_images.
  ///
  /// In en, this message translates to:
  /// **'Upload Photos Max 3 Images'**
  String get upload_max_three_images;

  /// No description provided for @upload_proof.
  ///
  /// In en, this message translates to:
  /// **'Upload Proof'**
  String get upload_proof;

  /// No description provided for @order_help.
  ///
  /// In en, this message translates to:
  /// **'Order Help'**
  String get order_help;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @why_did_you_hide.
  ///
  /// In en, this message translates to:
  /// **'Why did you hide'**
  String get why_did_you_hide;

  /// No description provided for @repeat_last_customization.
  ///
  /// In en, this message translates to:
  /// **'Repeat last used customization?'**
  String get repeat_last_customization;

  /// No description provided for @item_available.
  ///
  /// In en, this message translates to:
  /// **'item available'**
  String get item_available;

  /// No description provided for @bill_summary.
  ///
  /// In en, this message translates to:
  /// **'Bill Summary'**
  String get bill_summary;

  /// No description provided for @cooking_instructions_for_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Cooking instructions for restaurant'**
  String get cooking_instructions_for_restaurant;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @coupon_details.
  ///
  /// In en, this message translates to:
  /// **'Coupon Details'**
  String get coupon_details;

  /// No description provided for @copy_code.
  ///
  /// In en, this message translates to:
  /// **'COPY CODE'**
  String get copy_code;

  /// No description provided for @personalised_offer.
  ///
  /// In en, this message translates to:
  /// **'This offer is personalised for you.'**
  String get personalised_offer;

  /// No description provided for @max_instant_discount_off.
  ///
  /// In en, this message translates to:
  /// **'Maximum instant discount of'**
  String get max_instant_discount_off;

  /// No description provided for @applicable_on_every_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Applicable on every restaurant'**
  String get applicable_on_every_restaurant;

  /// No description provided for @applicable_on_selected_restaurants.
  ///
  /// In en, this message translates to:
  /// **'Applicable only on select restaurants.'**
  String get applicable_on_selected_restaurants;

  /// No description provided for @applicable_max.
  ///
  /// In en, this message translates to:
  /// **'Applicable maximum'**
  String get applicable_max;

  /// No description provided for @times_per_user.
  ///
  /// In en, this message translates to:
  /// **'times per user'**
  String get times_per_user;

  /// No description provided for @applicable_on_every_users.
  ///
  /// In en, this message translates to:
  /// **'Applicable on every users'**
  String get applicable_on_every_users;

  /// No description provided for @applicable_on_selected_users.
  ///
  /// In en, this message translates to:
  /// **'Applicable only on select users'**
  String get applicable_on_selected_users;

  /// No description provided for @dining_charge_summary.
  ///
  /// In en, this message translates to:
  /// **'Dining Charge Summary'**
  String get dining_charge_summary;

  /// No description provided for @cover_charge.
  ///
  /// In en, this message translates to:
  /// **'Cover Charge'**
  String get cover_charge;

  /// No description provided for @save_information.
  ///
  /// In en, this message translates to:
  /// **'Save Information'**
  String get save_information;

  /// No description provided for @mention_any_special_request.
  ///
  /// In en, this message translates to:
  /// **'Mention any special requests'**
  String get mention_any_special_request;

  /// No description provided for @dining_booking_help.
  ///
  /// In en, this message translates to:
  /// **'Dining Booking Help'**
  String get dining_booking_help;

  /// No description provided for @instruction_for_deliveryman.
  ///
  /// In en, this message translates to:
  /// **'Instructions for delivery partner'**
  String get instruction_for_deliveryman;

  /// No description provided for @select_address.
  ///
  /// In en, this message translates to:
  /// **'Select an address'**
  String get select_address;

  /// No description provided for @coupon_for_you.
  ///
  /// In en, this message translates to:
  /// **'Coupons for you'**
  String get coupon_for_you;

  /// No description provided for @view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_details;

  /// No description provided for @min_cart_value.
  ///
  /// In en, this message translates to:
  /// **'Minimum cart value is'**
  String get min_cart_value;

  /// No description provided for @loyalty_points_available.
  ///
  /// In en, this message translates to:
  /// **'Available Loyality Points'**
  String get loyalty_points_available;

  /// No description provided for @bogo_offer.
  ///
  /// In en, this message translates to:
  /// **'Buy One Get One Offer'**
  String get bogo_offer;

  /// No description provided for @free_delivery_offer.
  ///
  /// In en, this message translates to:
  /// **'Available Free Delivery'**
  String get free_delivery_offer;

  /// No description provided for @tap_to_apply.
  ///
  /// In en, this message translates to:
  /// **'TAP TO APPLY'**
  String get tap_to_apply;

  /// No description provided for @complaint_to.
  ///
  /// In en, this message translates to:
  /// **'Complaint to'**
  String get complaint_to;

  /// No description provided for @select_product.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get select_product;

  /// No description provided for @complaint_title.
  ///
  /// In en, this message translates to:
  /// **'Complaint Title'**
  String get complaint_title;

  /// No description provided for @complaint_brief.
  ///
  /// In en, this message translates to:
  /// **'Complaint Brief'**
  String get complaint_brief;

  /// No description provided for @your_cart.
  ///
  /// In en, this message translates to:
  /// **'Your Carts'**
  String get your_cart;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @deliveryman_tip_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Your kindness means a lot! 100% of your tip will go directly to delivery partner'**
  String get deliveryman_tip_sub_title;

  /// No description provided for @enter_location_your_area.
  ///
  /// In en, this message translates to:
  /// **'Enter your area or apartment name'**
  String get enter_location_your_area;

  /// No description provided for @use_current_location.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get use_current_location;

  /// No description provided for @search_results.
  ///
  /// In en, this message translates to:
  /// **'SEARCHES RESULTS'**
  String get search_results;

  /// No description provided for @saved_address.
  ///
  /// In en, this message translates to:
  /// **'SAVED ADDRESS'**
  String get saved_address;

  /// No description provided for @recent_search.
  ///
  /// In en, this message translates to:
  /// **'RECENT SEARCHES'**
  String get recent_search;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @confirm_location.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirm_location;

  /// No description provided for @need_location_for_restaurants.
  ///
  /// In en, this message translates to:
  /// **'We need your location to show available restaurants, dinouts & products.'**
  String get need_location_for_restaurants;

  /// No description provided for @continue_btn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_btn;

  /// No description provided for @enter_location_manually.
  ///
  /// In en, this message translates to:
  /// **'Enter location manually'**
  String get enter_location_manually;

  /// No description provided for @top_restaurants.
  ///
  /// In en, this message translates to:
  /// **'Top Restaurants'**
  String get top_restaurants;

  /// No description provided for @top_brands.
  ///
  /// In en, this message translates to:
  /// **'Top Brands'**
  String get top_brands;

  /// No description provided for @pre_book_offers.
  ///
  /// In en, this message translates to:
  /// **'Pre-book offers'**
  String get pre_book_offers;

  /// No description provided for @walk_in_offers.
  ///
  /// In en, this message translates to:
  /// **'Walk-in offers'**
  String get walk_in_offers;

  /// No description provided for @see_all_reviews.
  ///
  /// In en, this message translates to:
  /// **'See all reviews'**
  String get see_all_reviews;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @average_cost.
  ///
  /// In en, this message translates to:
  /// **'Average Cost'**
  String get average_cost;

  /// No description provided for @joined_on.
  ///
  /// In en, this message translates to:
  /// **'Joined on'**
  String get joined_on;

  /// No description provided for @since.
  ///
  /// In en, this message translates to:
  /// **'since'**
  String get since;

  /// No description provided for @legal_name.
  ///
  /// In en, this message translates to:
  /// **'Legal Name'**
  String get legal_name;

  /// No description provided for @follow_on_social_handle.
  ///
  /// In en, this message translates to:
  /// **'Follow Us On Social Media'**
  String get follow_on_social_handle;

  /// No description provided for @off_day.
  ///
  /// In en, this message translates to:
  /// **'Off Day'**
  String get off_day;

  /// No description provided for @opening_closing_time.
  ///
  /// In en, this message translates to:
  /// **'Opening & Closing Time'**
  String get opening_closing_time;

  /// No description provided for @facilities_features.
  ///
  /// In en, this message translates to:
  /// **'Facilities & Features'**
  String get facilities_features;

  /// No description provided for @trending_foods.
  ///
  /// In en, this message translates to:
  /// **'Trending Foods'**
  String get trending_foods;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @register_request_saved.
  ///
  /// In en, this message translates to:
  /// **'Registration Request Saved Successfully'**
  String get register_request_saved;

  /// No description provided for @register_request_saved_sub_title.
  ///
  /// In en, this message translates to:
  /// **'Thank you for taking the time to register with us. Your request has been securely recorded in our system. Our team is currently reviewing your details to ensure everything is in order.'**
  String get register_request_saved_sub_title;

  /// No description provided for @hidden_restaurant_not_found.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, no restaurants fount in hidden section. Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get hidden_restaurant_not_found;

  /// No description provided for @report_emergency_query.
  ///
  /// In en, this message translates to:
  /// **'Please use this form exclusively for emergencies related to accidents or abuse. For order inquiries or other general questions, kindly contact us through our support portal.'**
  String get report_emergency_query;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @sorry_for_deleting_account.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry to see you go! Deleting your account will permanently remove your personal data, order history, saved addresses, payment methods, and preferences from our system.'**
  String get sorry_for_deleting_account;

  /// No description provided for @delete_reason_one.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone.'**
  String get delete_reason_one;

  /// No description provided for @delete_reason_two.
  ///
  /// In en, this message translates to:
  /// **'All past orders, receipts, and order history will be erased.'**
  String get delete_reason_two;

  /// No description provided for @delete_reason_three.
  ///
  /// In en, this message translates to:
  /// **'You will lose access to any active subscriptions or meal plans.'**
  String get delete_reason_three;

  /// No description provided for @delete_reason_four.
  ///
  /// In en, this message translates to:
  /// **'Any remaining wallet balance, promo codes, or loyalty points will be forfeited.'**
  String get delete_reason_four;

  /// No description provided for @delete_reason_five.
  ///
  /// In en, this message translates to:
  /// **'Your saved addresses and delivery preferences will be removed.'**
  String get delete_reason_five;

  /// No description provided for @delete_reason_six.
  ///
  /// In en, this message translates to:
  /// **'Stored payment methods and billing information will be deleted.'**
  String get delete_reason_six;

  /// No description provided for @delete_reason_seven.
  ///
  /// In en, this message translates to:
  /// **'You will no longer receive notifications or updates about offers or deals.'**
  String get delete_reason_seven;

  /// No description provided for @delete_reason_eight.
  ///
  /// In en, this message translates to:
  /// **'Your profile and login credentials will be deactivated.'**
  String get delete_reason_eight;

  /// No description provided for @delete_reason_nine.
  ///
  /// In en, this message translates to:
  /// **'Invoices or transaction records will no longer be available for download.'**
  String get delete_reason_nine;

  /// No description provided for @comman_error_reason.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, something went wrong!. Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get comman_error_reason;

  /// No description provided for @checkout_error.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, no foods found with restaurant. Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get checkout_error;

  /// No description provided for @type_message.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get type_message;

  /// No description provided for @dining_booking_error.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, online dining booking is no longer available at this location. Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get dining_booking_error;

  /// No description provided for @dining_booking_category_error_one.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, no dining found with category'**
  String get dining_booking_category_error_one;

  /// No description provided for @dining_booking_category_error_two.
  ///
  /// In en, this message translates to:
  /// **'Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get dining_booking_category_error_two;

  /// No description provided for @home_error.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, online ordering is no longer available at this location. Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get home_error;

  /// No description provided for @sign_in_to_purchase.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Purchase'**
  String get sign_in_to_purchase;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get mins;

  /// No description provided for @use_code.
  ///
  /// In en, this message translates to:
  /// **'Use code'**
  String get use_code;

  /// No description provided for @above.
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get above;

  /// No description provided for @restaurant_closed_notice.
  ///
  /// In en, this message translates to:
  /// **'is temporarily closed for maintenance and improvements. We apologize for any inconvenience this may cause and appreciate your understanding. We look forward to welcoming you back soon with an even better dining experience.'**
  String get restaurant_closed_notice;

  /// No description provided for @restaurant_no_food_one.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, no foods found with'**
  String get restaurant_no_food_one;

  /// No description provided for @restaurant_no_food_two.
  ///
  /// In en, this message translates to:
  /// **'Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get restaurant_no_food_two;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @search_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Search restaurant...'**
  String get search_restaurant;

  /// No description provided for @search_query.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search_query;

  /// No description provided for @search_country.
  ///
  /// In en, this message translates to:
  /// **'Search Country'**
  String get search_country;

  /// No description provided for @location_search_query.
  ///
  /// In en, this message translates to:
  /// **'Try Hyderabad, Charminar, Telangana'**
  String get location_search_query;

  /// No description provided for @search_food_query.
  ///
  /// In en, this message translates to:
  /// **'Search food in'**
  String get search_food_query;

  /// No description provided for @restaurant_detail_error_one.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, no detail found with'**
  String get restaurant_detail_error_one;

  /// No description provided for @away.
  ///
  /// In en, this message translates to:
  /// **'away'**
  String get away;

  /// No description provided for @food_category_error_one.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, no foods found with category'**
  String get food_category_error_one;

  /// No description provided for @food_category_error_two.
  ///
  /// In en, this message translates to:
  /// **'Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get food_category_error_two;

  /// No description provided for @restaurant_category_error_one.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, no restaurants found with category'**
  String get restaurant_category_error_one;

  /// No description provided for @restaurant_category_error_two.
  ///
  /// In en, this message translates to:
  /// **'Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get restaurant_category_error_two;

  /// No description provided for @cuisine_category_error_one.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, no restaurants found with cuisine'**
  String get cuisine_category_error_one;

  /// No description provided for @cuisine_category_error_two.
  ///
  /// In en, this message translates to:
  /// **'Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get cuisine_category_error_two;

  /// No description provided for @api_list_response_error.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, something went wrong!. Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get api_list_response_error;

  /// No description provided for @restaurant_direct_review_error.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, no data found. Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get restaurant_direct_review_error;

  /// No description provided for @restaurant_locality_error_one.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, no restaurants found with localities'**
  String get restaurant_locality_error_one;

  /// No description provided for @restaurant_locality_error_two.
  ///
  /// In en, this message translates to:
  /// **'Please accept our heartfelt apologies for any inconvenience this may have caused. Our team is working diligently to resolve the situation and ensure that we can resume our full menu and service as soon as possible.'**
  String get restaurant_locality_error_two;

  /// No description provided for @dining_map_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred on our server, and we\'re unable to process your request at this time. Please try again later, and we apologize for any inconvenience this may cause.'**
  String get dining_map_error;

  /// No description provided for @no_dining_restaurant_error.
  ///
  /// In en, this message translates to:
  /// **'No dining restaurants were found in your vicinity at the moment. Please try adjusting your search criteria or check back later for updated listings in your area.'**
  String get no_dining_restaurant_error;

  /// No description provided for @delivery_partner_tip.
  ///
  /// In en, this message translates to:
  /// **'Delivery Partner Tip'**
  String get delivery_partner_tip;

  /// No description provided for @coupon_discount.
  ///
  /// In en, this message translates to:
  /// **'Coupon Discount'**
  String get coupon_discount;

  /// No description provided for @wallet_money.
  ///
  /// In en, this message translates to:
  /// **'Wallet Money'**
  String get wallet_money;

  /// No description provided for @no_booking_slot.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry, but there are currently no available slots for your selected dining time. Please choose a different time or date, or check back later for updated availability. We apologize for any inconvenience this may cause and appreciate your understanding.'**
  String get no_booking_slot;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'pages'**
  String get pages;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @dishes.
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get dishes;

  /// No description provided for @most_tipped.
  ///
  /// In en, this message translates to:
  /// **'Most Tipped'**
  String get most_tipped;

  /// No description provided for @add_receiver_detail.
  ///
  /// In en, this message translates to:
  /// **'Add receiver details'**
  String get add_receiver_detail;

  /// No description provided for @update_receiver_detail.
  ///
  /// In en, this message translates to:
  /// **'Update receiver details'**
  String get update_receiver_detail;

  /// No description provided for @delivers_to.
  ///
  /// In en, this message translates to:
  /// **'DELIVERS TO'**
  String get delivers_to;

  /// No description provided for @does_not_deliver_to.
  ///
  /// In en, this message translates to:
  /// **'DOES NOT DELIVER TO'**
  String get does_not_deliver_to;

  /// No description provided for @refund_request_forwarded.
  ///
  /// In en, this message translates to:
  /// **'We\'ll forward your request to the restaurant, but please note that the decision to accommodate it is entirely at the restaurant\'s discretion.'**
  String get refund_request_forwarded;

  /// No description provided for @cover_charge_is.
  ///
  /// In en, this message translates to:
  /// **'Cover Charge is'**
  String get cover_charge_is;

  /// No description provided for @cover_charge_not_required.
  ///
  /// In en, this message translates to:
  /// **'No Cover Charge Required'**
  String get cover_charge_not_required;

  /// No description provided for @food_instruction_notice.
  ///
  /// In en, this message translates to:
  /// **'The restaurant will try their best to follow your instructions. However, no cancellation or refund will be possible if yourrequest is not met. Please note - instructions once added can not be removed'**
  String get food_instruction_notice;

  /// No description provided for @unhide_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Unhide this restaurant'**
  String get unhide_restaurant;

  /// No description provided for @hide_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Hide this restaurant'**
  String get hide_restaurant;

  /// No description provided for @unregister_account_notice.
  ///
  /// In en, this message translates to:
  /// **'It looks like you haven\'t registered with this email yet. To get started, please provide your mobile number and a few other details to complete your registration.'**
  String get unregister_account_notice;

  /// No description provided for @order_detail_status_created.
  ///
  /// In en, this message translates to:
  /// **'Your Order is Created ðŸ¥°'**
  String get order_detail_status_created;

  /// No description provided for @order_detail_status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Your Order is Accepted ðŸŽ‰'**
  String get order_detail_status_accepted;

  /// No description provided for @order_detail_status_preparing.
  ///
  /// In en, this message translates to:
  /// **'Your Order is Being Prepared ðŸ˜‹'**
  String get order_detail_status_preparing;

  /// No description provided for @order_detail_status_ready.
  ///
  /// In en, this message translates to:
  /// **'Your Order is Ready ðŸ¤¤'**
  String get order_detail_status_ready;

  /// No description provided for @order_detail_status_handover.
  ///
  /// In en, this message translates to:
  /// **'Your Order is Handover to Driver ðŸ‘¨ðŸ»â€ðŸ¦°'**
  String get order_detail_status_handover;

  /// No description provided for @order_detail_status_onway.
  ///
  /// In en, this message translates to:
  /// **'Your Order is On the way ðŸš´ðŸ»â€â™‚ï¸'**
  String get order_detail_status_onway;

  /// No description provided for @server_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get server_not_found_error;

  /// No description provided for @server_please_authenticate_error.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate'**
  String get server_please_authenticate_error;

  /// No description provided for @server_forbidden_error.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get server_forbidden_error;

  /// No description provided for @server_already_exist_error.
  ///
  /// In en, this message translates to:
  /// **'Already exist'**
  String get server_already_exist_error;

  /// No description provided for @server_incorrect_email_or_password_error.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get server_incorrect_email_or_password_error;

  /// No description provided for @server_unauthorized_error.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get server_unauthorized_error;

  /// No description provided for @server_account_blocked_error.
  ///
  /// In en, this message translates to:
  /// **'Account Blocked'**
  String get server_account_blocked_error;

  /// No description provided for @server_incorrect_phone_or_password_error.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Phone or password'**
  String get server_incorrect_phone_or_password_error;

  /// No description provided for @server_password_reset_failed_error.
  ///
  /// In en, this message translates to:
  /// **'Password reset failed'**
  String get server_password_reset_failed_error;

  /// No description provided for @server_email_verification_failed_error.
  ///
  /// In en, this message translates to:
  /// **'Email verification failed'**
  String get server_email_verification_failed_error;

  /// No description provided for @server_item_already_exist_in_cart_error.
  ///
  /// In en, this message translates to:
  /// **'Item already exist in cart'**
  String get server_item_already_exist_in_cart_error;

  /// No description provided for @server_something_went_wrong_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get server_something_went_wrong_error;

  /// No description provided for @server_addon_not_available_error.
  ///
  /// In en, this message translates to:
  /// **'One of the addon is not available'**
  String get server_addon_not_available_error;

  /// No description provided for @server_variation_not_available_error.
  ///
  /// In en, this message translates to:
  /// **'One of the variation is not available'**
  String get server_variation_not_available_error;

  /// No description provided for @server_already_created_error.
  ///
  /// In en, this message translates to:
  /// **'Already Created'**
  String get server_already_created_error;

  /// No description provided for @server_coupon_already_redemeed_error.
  ///
  /// In en, this message translates to:
  /// **'Coupon Already redemeed'**
  String get server_coupon_already_redemeed_error;

  /// No description provided for @server_bogo_failed_error.
  ///
  /// In en, this message translates to:
  /// **'Please add one more item to validate BOGO offer'**
  String get server_bogo_failed_error;

  /// No description provided for @server_coupon_limit_crossed_error.
  ///
  /// In en, this message translates to:
  /// **'Coupon Limit Crossed'**
  String get server_coupon_limit_crossed_error;

  /// No description provided for @server_already_requested_error.
  ///
  /// In en, this message translates to:
  /// **'Already requested'**
  String get server_already_requested_error;

  /// No description provided for @server_limit_crossed_error.
  ///
  /// In en, this message translates to:
  /// **'Limit Crossed'**
  String get server_limit_crossed_error;

  /// No description provided for @server_wallet_find_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to find wallet'**
  String get server_wallet_find_error;

  /// No description provided for @server_wallet_balance_error.
  ///
  /// In en, this message translates to:
  /// **'Insufficient funds: Withdrawal amount exceeds your available balance'**
  String get server_wallet_balance_error;

  /// No description provided for @server_email_smtp_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to email server. Make sure you have configured the SMTP options'**
  String get server_email_smtp_error;

  /// No description provided for @server_already_saved_error.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get server_already_saved_error;

  /// No description provided for @server_favourite_error.
  ///
  /// In en, this message translates to:
  /// **'item is already in favourite list'**
  String get server_favourite_error;

  /// No description provided for @server_already_hidden_error.
  ///
  /// In en, this message translates to:
  /// **'Already Hidden'**
  String get server_already_hidden_error;

  /// No description provided for @server_another_deliveryman_accepted_order_error.
  ///
  /// In en, this message translates to:
  /// **'Another Deliveryman Accepted Order'**
  String get server_another_deliveryman_accepted_order_error;

  /// No description provided for @server_invalid_deliveryman_error.
  ///
  /// In en, this message translates to:
  /// **'Invalid Deliveryman'**
  String get server_invalid_deliveryman_error;

  /// No description provided for @server_already_assigned_error.
  ///
  /// In en, this message translates to:
  /// **'Already assigned'**
  String get server_already_assigned_error;

  /// No description provided for @server_wrong_otp_error.
  ///
  /// In en, this message translates to:
  /// **'Wrong OTP'**
  String get server_wrong_otp_error;

  /// No description provided for @server_verification_failed_error.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get server_verification_failed_error;

  /// No description provided for @server_credentials_error.
  ///
  /// In en, this message translates to:
  /// **'credentials not found'**
  String get server_credentials_error;

  /// No description provided for @server_cart_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Cart Item not found'**
  String get server_cart_not_found_error;

  /// No description provided for @server_purchase_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Purchase Not Found'**
  String get server_purchase_not_found_error;

  /// No description provided for @server_wallet_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Wallet Not Found'**
  String get server_wallet_not_found_error;

  /// No description provided for @server_no_user_found_email_error.
  ///
  /// In en, this message translates to:
  /// **'No users found with this email'**
  String get server_no_user_found_email_error;

  /// No description provided for @server_no_user_found_mobile_number_error.
  ///
  /// In en, this message translates to:
  /// **'No users found with this mobile number'**
  String get server_no_user_found_mobile_number_error;

  /// No description provided for @server_email_already_taken_error.
  ///
  /// In en, this message translates to:
  /// **'Email already taken'**
  String get server_email_already_taken_error;

  /// No description provided for @server_phone_already_taken_error.
  ///
  /// In en, this message translates to:
  /// **'Phone already taken'**
  String get server_phone_already_taken_error;

  /// No description provided for @server_account_already_created_error.
  ///
  /// In en, this message translates to:
  /// **'Account already created'**
  String get server_account_already_created_error;

  /// No description provided for @server_user_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get server_user_not_found_error;

  /// No description provided for @server_driver_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Driver not found'**
  String get server_driver_not_found_error;

  /// No description provided for @server_detail_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Detail not found'**
  String get server_detail_not_found_error;

  /// No description provided for @server_restaurant_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Restaurant not found'**
  String get server_restaurant_not_found_error;

  /// No description provided for @server_clear_cash_outlet_error.
  ///
  /// In en, this message translates to:
  /// **'Please clear cash in hand amount before deleting account from your account and from outlet'**
  String get server_clear_cash_outlet_error;

  /// No description provided for @server_clear_cash_restaurant_error.
  ///
  /// In en, this message translates to:
  /// **'Please clear cash in hand amount before deleting account'**
  String get server_clear_cash_restaurant_error;

  /// No description provided for @server_deliveryman_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Deliveryman not found'**
  String get server_deliveryman_not_found_error;

  /// No description provided for @server_waiter_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Waiter not found'**
  String get server_waiter_not_found_error;

  /// No description provided for @server_kitchen_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Owner not found'**
  String get server_kitchen_not_found_error;

  /// No description provided for @server_already_taken_error.
  ///
  /// In en, this message translates to:
  /// **'Already taken'**
  String get server_already_taken_error;

  /// No description provided for @server_file_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get server_file_not_found_error;

  /// No description provided for @server_validation_failed_error.
  ///
  /// In en, this message translates to:
  /// **'Validation failed'**
  String get server_validation_failed_error;

  /// No description provided for @server_invalid_file_type_error.
  ///
  /// In en, this message translates to:
  /// **'Invalid file type'**
  String get server_invalid_file_type_error;

  /// No description provided for @server_select_file_upload_error.
  ///
  /// In en, this message translates to:
  /// **'Please select a file to upload!'**
  String get server_select_file_upload_error;

  /// No description provided for @server_account_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get server_account_not_found_error;

  /// No description provided for @server_contact_admin_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please contact administrator'**
  String get server_contact_admin_error;

  /// No description provided for @server_address_missing_errir.
  ///
  /// In en, this message translates to:
  /// **'Address is missing'**
  String get server_address_missing_errir;

  /// No description provided for @server_home_delivery_disabled_error.
  ///
  /// In en, this message translates to:
  /// **'Home Delivery is disabled'**
  String get server_home_delivery_disabled_error;

  /// No description provided for @server_self_pickup_disabled_error.
  ///
  /// In en, this message translates to:
  /// **'Self Pickup is disabled'**
  String get server_self_pickup_disabled_error;

  /// No description provided for @server_instant_order_disabled_error.
  ///
  /// In en, this message translates to:
  /// **'Instant Order is disabled'**
  String get server_instant_order_disabled_error;

  /// No description provided for @server_schedule_order_disabled_error.
  ///
  /// In en, this message translates to:
  /// **'Schedule Order is disabled'**
  String get server_schedule_order_disabled_error;

  /// No description provided for @server_schedule_date_is_invalid_error.
  ///
  /// In en, this message translates to:
  /// **'Schedule Date is invalid'**
  String get server_schedule_date_is_invalid_error;

  /// No description provided for @server_can_not_deliver_to_address_error.
  ///
  /// In en, this message translates to:
  /// **'Can not deliver order to this address'**
  String get server_can_not_deliver_to_address_error;

  /// No description provided for @server_coupon_wallet_can_not_use_same_error.
  ///
  /// In en, this message translates to:
  /// **'Oops! Looks like you\'ve applied a coupon code for your order.Please note that you can\'t use your wallet balance along with a coupon code'**
  String get server_coupon_wallet_can_not_use_same_error;

  /// No description provided for @server_invalid_coupon_not_available_error.
  ///
  /// In en, this message translates to:
  /// **'Opps, Sorry this coupon is not available for you.'**
  String get server_invalid_coupon_not_available_error;

  /// No description provided for @server_food_is_not_available_error.
  ///
  /// In en, this message translates to:
  /// **'One of the food is not available'**
  String get server_food_is_not_available_error;

  /// No description provided for @server_empty_cart_error.
  ///
  /// In en, this message translates to:
  /// **'Cart is Empty'**
  String get server_empty_cart_error;

  /// No description provided for @server_addon_variation_not_available_error.
  ///
  /// In en, this message translates to:
  /// **'One of the addon or variation is not available'**
  String get server_addon_variation_not_available_error;

  /// No description provided for @server_pos_permmission_error.
  ///
  /// In en, this message translates to:
  /// **'Pos Permission Denied'**
  String get server_pos_permmission_error;

  /// No description provided for @server_no_trial_subscription_package_error.
  ///
  /// In en, this message translates to:
  /// **'Oops! Looks like you\'ve applied a trial subscription package, and it is not available as of now, please select payment method!'**
  String get server_no_trial_subscription_package_error;

  /// No description provided for @server_table_order_permission_error.
  ///
  /// In en, this message translates to:
  /// **'Table Order Permission Denied'**
  String get server_table_order_permission_error;

  /// No description provided for @server_invalid_slot_error.
  ///
  /// In en, this message translates to:
  /// **'Invalid Slot'**
  String get server_invalid_slot_error;

  /// No description provided for @server_max_upload_size_error.
  ///
  /// In en, this message translates to:
  /// **'Maximum file size is ##dynamic## MB'**
  String get server_max_upload_size_error;

  /// No description provided for @server_min_cart_error.
  ///
  /// In en, this message translates to:
  /// **'Opps, Sorry. you required minimum ##dynamic## on your cart.'**
  String get server_min_cart_error;

  /// No description provided for @server_min_amount_error.
  ///
  /// In en, this message translates to:
  /// **'Please note that a minimum order value of ##dynamic## is required to proceed with your order'**
  String get server_min_amount_error;

  /// No description provided for @server_out_of_stock_error.
  ///
  /// In en, this message translates to:
  /// **'Sorry, ##dynamic## is currently out of stock and cannot be added to your order.'**
  String get server_out_of_stock_error;

  /// No description provided for @bloc_auth_permission_denied_error.
  ///
  /// In en, this message translates to:
  /// **'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In'**
  String get bloc_auth_permission_denied_error;

  /// No description provided for @bloc_required_input_error.
  ///
  /// In en, this message translates to:
  /// **'Please fill all the required inputs'**
  String get bloc_required_input_error;

  /// No description provided for @bloc_select_subscription_package_error.
  ///
  /// In en, this message translates to:
  /// **'Please select package'**
  String get bloc_select_subscription_package_error;

  /// No description provided for @bloc_variation_limited_error.
  ///
  /// In en, this message translates to:
  /// **'Sorry, our variation limited to ##dynamic## items right now.'**
  String get bloc_variation_limited_error;

  /// No description provided for @bloc_food_limit_error.
  ///
  /// In en, this message translates to:
  /// **'Sorry, You can purchase upto ##dynamic## items on this food'**
  String get bloc_food_limit_error;

  /// No description provided for @bloc_stock_limit_error.
  ///
  /// In en, this message translates to:
  /// **'Sorry, our stock is limited to ##dynamic## items right now.'**
  String get bloc_stock_limit_error;

  /// No description provided for @bloc_coupon_and_wallet_error.
  ///
  /// In en, this message translates to:
  /// **'Oops! Looks like you\'ve applied a coupon code for your order.Please note that you can\'t use your wallet balance along with a coupon code'**
  String get bloc_coupon_and_wallet_error;

  /// No description provided for @bloc_wallet_and_coupon_error.
  ///
  /// In en, this message translates to:
  /// **'Oops! Looks like you\'ve applied a wallet money for your order.Please note that you can\'t use coupon code along with a wallet money'**
  String get bloc_wallet_and_coupon_error;

  /// No description provided for @bloc_login_first_error.
  ///
  /// In en, this message translates to:
  /// **'Please login first'**
  String get bloc_login_first_error;

  /// No description provided for @bloc_location_disable_error.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get bloc_location_disable_error;

  /// No description provided for @bloc_location_permission_error.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied'**
  String get bloc_location_permission_error;

  /// No description provided for @bloc_location_permission_permanently_error.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied, we cannot request permissions.'**
  String get bloc_location_permission_permanently_error;

  /// No description provided for @bloc_coupon_validation_error.
  ///
  /// In en, this message translates to:
  /// **'Opps, Sorry this coupon is not available for you.'**
  String get bloc_coupon_validation_error;

  /// No description provided for @bloc_coupon_validation_min_error.
  ///
  /// In en, this message translates to:
  /// **'Opps, Sorry. you required minimum ##dynamic## on your cart.'**
  String get bloc_coupon_validation_min_error;

  /// No description provided for @bloc_can_not_deliver_address_error.
  ///
  /// In en, this message translates to:
  /// **'Can not deliver to this address'**
  String get bloc_can_not_deliver_address_error;

  /// No description provided for @bloc_food_validation_error.
  ///
  /// In en, this message translates to:
  /// **'Validation Failed, Please select required items'**
  String get bloc_food_validation_error;

  /// No description provided for @bloc_unable_to_download_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to get downloads directory'**
  String get bloc_unable_to_download_error;

  /// No description provided for @bloc_storage_permission_error.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied'**
  String get bloc_storage_permission_error;

  /// No description provided for @bloc_file_not_download_error.
  ///
  /// In en, this message translates to:
  /// **'File cannot be downloaded from the browser. Please use a mobile device to download.'**
  String get bloc_file_not_download_error;

  /// No description provided for @dd_passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get dd_passport;

  /// No description provided for @dd_driving_license.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get dd_driving_license;

  /// No description provided for @dd_nic.
  ///
  /// In en, this message translates to:
  /// **'National Identity Card'**
  String get dd_nic;

  /// No description provided for @dd_freelancer.
  ///
  /// In en, this message translates to:
  /// **'Freelancer'**
  String get dd_freelancer;

  /// No description provided for @dd_salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get dd_salary;

  /// No description provided for @dd_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get dd_male;

  /// No description provided for @dd_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get dd_female;

  /// No description provided for @dd_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get dd_other;

  /// No description provided for @dd_prefer_not_disclose.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to disclose'**
  String get dd_prefer_not_disclose;

  /// No description provided for @dd_report_accident.
  ///
  /// In en, this message translates to:
  /// **'Report an Accident'**
  String get dd_report_accident;

  /// No description provided for @dd_report_incident.
  ///
  /// In en, this message translates to:
  /// **'Report an Incident'**
  String get dd_report_incident;

  /// No description provided for @dd_min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get dd_min;

  /// No description provided for @dd_hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get dd_hour;

  /// No description provided for @dd_yes_home_delivery.
  ///
  /// In en, this message translates to:
  /// **'Yes Home Delivery Available'**
  String get dd_yes_home_delivery;

  /// No description provided for @dd_no_home_delivery.
  ///
  /// In en, this message translates to:
  /// **'No Home Delivery Not Availble'**
  String get dd_no_home_delivery;

  /// No description provided for @dd_yes_takeaway.
  ///
  /// In en, this message translates to:
  /// **'Yes Takeaway Available'**
  String get dd_yes_takeaway;

  /// No description provided for @dd_no_takeaway.
  ///
  /// In en, this message translates to:
  /// **'No Takaway Not Available'**
  String get dd_no_takeaway;

  /// No description provided for @dd_yes_schedule_order.
  ///
  /// In en, this message translates to:
  /// **'Yes can Place Schedule Orders'**
  String get dd_yes_schedule_order;

  /// No description provided for @dd_no_schedule_order.
  ///
  /// In en, this message translates to:
  /// **'No Can Not Place Schedule Orders'**
  String get dd_no_schedule_order;

  /// No description provided for @dd_order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get dd_order;

  /// No description provided for @dd_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get dd_restaurant;

  /// No description provided for @dd_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get dd_food;

  /// No description provided for @dd_deliveryman.
  ///
  /// In en, this message translates to:
  /// **'Deliveryman'**
  String get dd_deliveryman;

  /// No description provided for @order_status_created.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get order_status_created;

  /// No description provided for @order_status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get order_status_accepted;

  /// No description provided for @order_status_preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get order_status_preparing;

  /// No description provided for @order_status_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get order_status_ready;

  /// No description provided for @order_status_handover.
  ///
  /// In en, this message translates to:
  /// **'Handover'**
  String get order_status_handover;

  /// No description provided for @order_status_ongoing.
  ///
  /// In en, this message translates to:
  /// **'On The Way'**
  String get order_status_ongoing;

  /// No description provided for @order_status_delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get order_status_delivered;

  /// No description provided for @order_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get order_status_cancelled;

  /// No description provided for @order_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get order_status_rejected;

  /// No description provided for @order_status_refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get order_status_refunded;

  /// No description provided for @order_status_partially_refunded.
  ///
  /// In en, this message translates to:
  /// **'Partially Refunded'**
  String get order_status_partially_refunded;

  /// No description provided for @order_status_pending_payments.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get order_status_pending_payments;

  /// No description provided for @support_chat_orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get support_chat_orders;

  /// No description provided for @support_chat_dining.
  ///
  /// In en, this message translates to:
  /// **'Dining Booking'**
  String get support_chat_dining;

  /// No description provided for @support_chat_tiffin_subscription.
  ///
  /// In en, this message translates to:
  /// **'Tiffin Subscription'**
  String get support_chat_tiffin_subscription;

  /// No description provided for @support_chat_complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get support_chat_complaints;

  /// No description provided for @support_chat_reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get support_chat_reports;

  /// No description provided for @payment_status_initiated.
  ///
  /// In en, this message translates to:
  /// **'Initiated'**
  String get payment_status_initiated;

  /// No description provided for @payment_status_paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get payment_status_paid;

  /// No description provided for @payment_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get payment_status_cancelled;

  /// No description provided for @tiffin_status_ongoing.
  ///
  /// In en, this message translates to:
  /// **'Your Subscription Package is Ongoing ðŸ¥°'**
  String get tiffin_status_ongoing;

  /// No description provided for @tiffin_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Your Subscription Package is Cancelled ðŸ˜ž'**
  String get tiffin_status_cancelled;

  /// No description provided for @tiffin_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Your Subscription Package is Completed ðŸ™‚'**
  String get tiffin_status_completed;

  /// No description provided for @tiffin_status_refunded.
  ///
  /// In en, this message translates to:
  /// **'Your Subscription Package is Refunded ðŸ’°'**
  String get tiffin_status_refunded;

  /// No description provided for @tiffin_status_partial_refund.
  ///
  /// In en, this message translates to:
  /// **'Your Subscription Package is Partially Refunded ðŸ’°'**
  String get tiffin_status_partial_refund;

  /// No description provided for @tiffin_status_payment_pending.
  ///
  /// In en, this message translates to:
  /// **'Your Subscription Package Payment Are Pending ðŸ’µ'**
  String get tiffin_status_payment_pending;

  /// No description provided for @referral_both_received.
  ///
  /// In en, this message translates to:
  /// **'Congratulations you & your friend have received the ##dynamic## on wallet'**
  String get referral_both_received;

  /// No description provided for @referral_friend_received.
  ///
  /// In en, this message translates to:
  /// **'Congratulations your friend have received the ##dynamic## on wallet'**
  String get referral_friend_received;

  /// No description provided for @referral_you_received.
  ///
  /// In en, this message translates to:
  /// **'Congratulations you have received the ##dynamic## on wallet'**
  String get referral_you_received;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @cookies.
  ///
  /// In en, this message translates to:
  /// **'App Cookies'**
  String get cookies;

  /// No description provided for @show_more.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get show_more;

  /// No description provided for @show_less.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get show_less;

  /// No description provided for @order_success_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Yay! Your Food Order Has Been Placed Successfully'**
  String get order_success_dialog_title;

  /// No description provided for @order_sucess_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'Nice choice! Your order request has been submitted to the restaurant and is currently under review. As soon as the restaurant takes action, weâ€™ll notify you with an update. Thank you for ordering with us.'**
  String get order_sucess_dialog_content;

  /// No description provided for @wallet_success_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Wallet Top-Up Successful'**
  String get wallet_success_dialog_title;

  /// No description provided for @wallet_success_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'Awesome! The amount has been successfully added to your wallet and is ready to use. You can now enjoy a smooth and hassle-free checkout experience using your wallet balance.'**
  String get wallet_success_dialog_content;

  /// No description provided for @dining_success_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Dining Booking Request Submitted'**
  String get dining_success_dialog_title;

  /// No description provided for @dining_success_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'Your dining booking request has been successfully sent to the restaurant and is currently under review. Once the restaurant takes action, weâ€™ll notify you with an update. You can also check your booking status anytime from Account Tab â†’ Your Dining Bookings.'**
  String get dining_success_dialog_content;

  /// No description provided for @tiffin_success_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful â€“ Subscription Set Up'**
  String get tiffin_success_dialog_title;

  /// No description provided for @tiffin_success_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'Weâ€™ve received your payment, and your tiffin subscription is now set up. Meals will be prepared and delivered according to the plan you selected. Subscription details and updates are available under Account Tab â†’ Tiffin Subscription Packages'**
  String get tiffin_success_dialog_content;

  /// No description provided for @coupon_title_one.
  ///
  /// In en, this message translates to:
  /// **'Save ##dynamic_one## with this discount'**
  String get coupon_title_one;

  /// No description provided for @coupon_title_two.
  ///
  /// In en, this message translates to:
  /// **'Save ##dynamic_one## to ##dynamic_two## with this code'**
  String get coupon_title_two;

  /// No description provided for @coupon_title_two_half.
  ///
  /// In en, this message translates to:
  /// **'Save ##dynamic_one## with this code'**
  String get coupon_title_two_half;

  /// No description provided for @coupon_title_three.
  ///
  /// In en, this message translates to:
  /// **'Earn ##dynamic_one## loyality points with this code on your wallet'**
  String get coupon_title_three;

  /// No description provided for @coupon_title_four.
  ///
  /// In en, this message translates to:
  /// **'Buy One Get One Free with this code'**
  String get coupon_title_four;

  /// No description provided for @coupon_title_five.
  ///
  /// In en, this message translates to:
  /// **'Save delivery charges with this code'**
  String get coupon_title_five;

  /// No description provided for @cart_help_one.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Your delivery is free.'**
  String get cart_help_one;

  /// No description provided for @cart_help_two.
  ///
  /// In en, this message translates to:
  /// **'You can apply ##dynamic_one## to get ##dynamic_two## discount'**
  String get cart_help_two;

  /// No description provided for @cart_help_three.
  ///
  /// In en, this message translates to:
  /// **'You can apple ##dynamic_one## to get ##dynamic_two## to ##dynamic_three## with discount'**
  String get cart_help_three;

  /// No description provided for @cart_help_four.
  ///
  /// In en, this message translates to:
  /// **'You can apply ##dynamic_one## to earn ##dynamic_two## loyality points'**
  String get cart_help_four;

  /// No description provided for @cart_help_five.
  ///
  /// In en, this message translates to:
  /// **'You can apply ##dynamic_one## to get buy one get one free'**
  String get cart_help_five;

  /// No description provided for @cart_help_six.
  ///
  /// In en, this message translates to:
  /// **'You can apply ##dynamic_one## to get free delivery'**
  String get cart_help_six;

  /// No description provided for @cart_help_seven.
  ///
  /// In en, this message translates to:
  /// **'we can\'t wait to make your day even more delicious!'**
  String get cart_help_seven;

  /// No description provided for @welcome_title_one.
  ///
  /// In en, this message translates to:
  /// **'Everything You Crave, Delivered Your Way'**
  String get welcome_title_one;

  /// No description provided for @welcome_subtitle_one.
  ///
  /// In en, this message translates to:
  /// **'Order from multiple restaurants, explore nearby outlets, choose delivery or pickup, and enjoy a seamless food ordering experience tailored just for youâ€”fast, reliable, and delicious every time.'**
  String get welcome_subtitle_one;

  /// No description provided for @welcome_title_two.
  ///
  /// In en, this message translates to:
  /// **'Dine Smart with Easy Table Booking & QR Ordering'**
  String get welcome_title_two;

  /// No description provided for @welcome_subtitle_two.
  ///
  /// In en, this message translates to:
  /// **'Reserve tables in advance, scan QR codes to browse menus, place orders directly from your table, and enjoy hassle-free dining without waiting for a waiter.'**
  String get welcome_subtitle_two;

  /// No description provided for @welcome_title_three.
  ///
  /// In en, this message translates to:
  /// **'Daily Meals Made Easy with Tiffin Subscriptions'**
  String get welcome_title_three;

  /// No description provided for @welcome_subtitle_three.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to flexible tiffin plans designed for your lifestyle. Choose your meals, manage schedules, skip days when needed, and enjoy fresh home-style food every day.'**
  String get welcome_subtitle_three;

  /// No description provided for @welcome_title_four.
  ///
  /// In en, this message translates to:
  /// **'Save More with Wallet, Rewards & Exclusive Offers'**
  String get welcome_title_four;

  /// No description provided for @welcome_subtitle_four.
  ///
  /// In en, this message translates to:
  /// **'Earn loyalty points, use wallet balance, apply coupons, and enjoy special campaigns and referral rewardsâ€”making every order more affordable and rewarding.'**
  String get welcome_subtitle_four;

  /// No description provided for @welcome_title_five.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Updates, Support & Smart Communication'**
  String get welcome_title_five;

  /// No description provided for @welcome_subtitle_five.
  ///
  /// In en, this message translates to:
  /// **'Track your orders live, chat instantly for support, receive timely notifications, and stay informed from order placement to deliveryâ€”all in one powerful app.'**
  String get welcome_subtitle_five;

  /// No description provided for @re_search_title.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get re_search_title;

  /// No description provided for @vertical_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get vertical_services;

  /// No description provided for @vertical_meat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get vertical_meat;

  /// No description provided for @re_featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get re_featured;

  /// No description provided for @re_recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get re_recent;

  /// No description provided for @re_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get re_categories;

  /// No description provided for @re_search_buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get re_search_buy;

  /// No description provided for @re_search_rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get re_search_rent;

  /// No description provided for @re_search_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get re_search_all;

  /// No description provided for @re_no_results.
  ///
  /// In en, this message translates to:
  /// **'No properties found'**
  String get re_no_results;

  /// No description provided for @re_no_enquiries.
  ///
  /// In en, this message translates to:
  /// **'You have no enquiries yet'**
  String get re_no_enquiries;

  /// No description provided for @re_my_enquiries.
  ///
  /// In en, this message translates to:
  /// **'My Enquiries'**
  String get re_my_enquiries;

  /// No description provided for @re_submit_enquiry.
  ///
  /// In en, this message translates to:
  /// **'Submit Enquiry'**
  String get re_submit_enquiry;

  /// No description provided for @re_enquiry_message_label.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get re_enquiry_message_label;

  /// No description provided for @re_enquiry_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you are looking for...'**
  String get re_enquiry_message_hint;

  /// No description provided for @re_enquiry_referral_label.
  ///
  /// In en, this message translates to:
  /// **'Referral code (optional)'**
  String get re_enquiry_referral_label;

  /// No description provided for @re_send.
  ///
  /// In en, this message translates to:
  /// **'Send Enquiry'**
  String get re_send;

  /// No description provided for @re_withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Enquiry'**
  String get re_withdraw;

  /// No description provided for @re_withdraw_reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get re_withdraw_reason;

  /// No description provided for @re_withdraw_confirm.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get re_withdraw_confirm;

  /// No description provided for @re_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get re_activity;

  /// No description provided for @re_no_activity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get re_no_activity;

  /// No description provided for @re_property_about.
  ///
  /// In en, this message translates to:
  /// **'About this property'**
  String get re_property_about;

  /// No description provided for @re_enquire.
  ///
  /// In en, this message translates to:
  /// **'Enquire'**
  String get re_enquire;

  /// No description provided for @re_hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get re_hold;

  /// No description provided for @re_area_sqft.
  ///
  /// In en, this message translates to:
  /// **'{area} sq.ft'**
  String re_area_sqft(String area);

  /// No description provided for @re_bhk.
  ///
  /// In en, this message translates to:
  /// **'{count} BHK'**
  String re_bhk(int count);

  /// No description provided for @re_bath.
  ///
  /// In en, this message translates to:
  /// **'{count} Bath'**
  String re_bath(int count);

  /// No description provided for @re_parking.
  ///
  /// In en, this message translates to:
  /// **'{count} Parking'**
  String re_parking(int count);

  /// No description provided for @re_compare_offers_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Compare offers from banks'**
  String get re_compare_offers_subtitle;

  /// No description provided for @re_no_subcategories.
  ///
  /// In en, this message translates to:
  /// **'No subcategories in this group yet.'**
  String get re_no_subcategories;

  /// No description provided for @re_similar.
  ///
  /// In en, this message translates to:
  /// **'Similar properties'**
  String get re_similar;

  /// No description provided for @re_verified_badge.
  ///
  /// In en, this message translates to:
  /// **'This property has been verified by LocalWala.'**
  String get re_verified_badge;

  /// No description provided for @re_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get re_loading;

  /// No description provided for @re_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get re_retry;

  /// No description provided for @re_error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get re_error_generic;

  /// No description provided for @re_search_city_label.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get re_search_city_label;

  /// No description provided for @re_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search by title or keyword'**
  String get re_search_hint;

  /// No description provided for @re_browse_buy_rent.
  ///
  /// In en, this message translates to:
  /// **'Browse — Buy or Rent'**
  String get re_browse_buy_rent;

  /// No description provided for @re_listing_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 listing • Buy or Rent} other{{count} listings • Buy or Rent}}'**
  String re_listing_count(int count);

  /// No description provided for @re_search_loading.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get re_search_loading;

  /// No description provided for @re_filter_price.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get re_filter_price;

  /// No description provided for @re_filter_bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get re_filter_bedrooms;

  /// No description provided for @re_filter_any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get re_filter_any;

  /// No description provided for @re_filter_verified.
  ///
  /// In en, this message translates to:
  /// **'Verified only'**
  String get re_filter_verified;

  /// No description provided for @re_filter_near_me.
  ///
  /// In en, this message translates to:
  /// **'Near me (5 km)'**
  String get re_filter_near_me;

  /// No description provided for @re_filter_clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get re_filter_clear_all;

  /// No description provided for @re_filter_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get re_filter_apply;

  /// No description provided for @re_price_min_label.
  ///
  /// In en, this message translates to:
  /// **'Min (₹)'**
  String get re_price_min_label;

  /// No description provided for @re_price_max_label.
  ///
  /// In en, this message translates to:
  /// **'Max (₹)'**
  String get re_price_max_label;

  /// No description provided for @re_near_me_no_location.
  ///
  /// In en, this message translates to:
  /// **'Set your location to use Near me'**
  String get re_near_me_no_location;

  /// No description provided for @re_categories_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load categories'**
  String get re_categories_failed;

  /// No description provided for @re_search_failed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get re_search_failed;

  /// No description provided for @re_sort_relevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get re_sort_relevance;

  /// No description provided for @re_sort_most_viewed.
  ///
  /// In en, this message translates to:
  /// **'Most viewed'**
  String get re_sort_most_viewed;

  /// No description provided for @re_sort_most_enquired.
  ///
  /// In en, this message translates to:
  /// **'Most enquired'**
  String get re_sort_most_enquired;

  /// No description provided for @re_sort_newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get re_sort_newest;

  /// No description provided for @re_sort_price_high.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get re_sort_price_high;

  /// No description provided for @re_sort_price_low.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get re_sort_price_low;

  /// No description provided for @re_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get re_close;

  /// No description provided for @re_featured_title.
  ///
  /// In en, this message translates to:
  /// **'Featured properties'**
  String get re_featured_title;

  /// No description provided for @re_see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get re_see_all;

  /// No description provided for @re_browse_by_category.
  ///
  /// In en, this message translates to:
  /// **'Browse by category'**
  String get re_browse_by_category;

  /// No description provided for @re_group_apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get re_group_apartment;

  /// No description provided for @re_group_house.
  ///
  /// In en, this message translates to:
  /// **'Houses'**
  String get re_group_house;

  /// No description provided for @re_group_villa.
  ///
  /// In en, this message translates to:
  /// **'Villas'**
  String get re_group_villa;

  /// No description provided for @re_group_plot.
  ///
  /// In en, this message translates to:
  /// **'Plots'**
  String get re_group_plot;

  /// No description provided for @re_group_commercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get re_group_commercial;

  /// No description provided for @re_more_count.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String re_more_count(Object count);

  /// No description provided for @re_search_title_subcategory.
  ///
  /// In en, this message translates to:
  /// **'{label} properties'**
  String re_search_title_subcategory(Object label);

  /// No description provided for @re_popular_title.
  ///
  /// In en, this message translates to:
  /// **'Popular properties'**
  String get re_popular_title;

  /// No description provided for @re_popular_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Most viewed on LocalWala'**
  String get re_popular_subtitle;

  /// No description provided for @re_recent_added_title.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get re_recent_added_title;

  /// No description provided for @re_recent_added_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Fresh on the market'**
  String get re_recent_added_subtitle;

  /// No description provided for @re_most_enquired_title.
  ///
  /// In en, this message translates to:
  /// **'Most enquired'**
  String get re_most_enquired_title;

  /// No description provided for @re_most_enquired_subtitle.
  ///
  /// In en, this message translates to:
  /// **'What other buyers are asking about'**
  String get re_most_enquired_subtitle;

  /// No description provided for @re_premium_title.
  ///
  /// In en, this message translates to:
  /// **'Premium listings'**
  String get re_premium_title;

  /// No description provided for @re_premium_subtitle.
  ///
  /// In en, this message translates to:
  /// **'High-value properties'**
  String get re_premium_subtitle;

  /// No description provided for @re_affordable_title.
  ///
  /// In en, this message translates to:
  /// **'Affordable properties'**
  String get re_affordable_title;

  /// No description provided for @re_affordable_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Best entry-level prices'**
  String get re_affordable_subtitle;

  /// No description provided for @re_saved_title.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get re_saved_title;

  /// No description provided for @re_no_saved.
  ///
  /// In en, this message translates to:
  /// **'You have no saved properties yet'**
  String get re_no_saved;

  /// No description provided for @re_remove_from_saved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get re_remove_from_saved;

  /// No description provided for @re_remove_from_saved_confirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{label}\" from your saved properties?'**
  String re_remove_from_saved_confirm(Object label);

  /// No description provided for @re_unsave_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not unsave property'**
  String get re_unsave_failed;

  /// No description provided for @re_save_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get re_save_tooltip;

  /// No description provided for @re_saved_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get re_saved_tooltip;

  /// No description provided for @re_recently_viewed_title.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed'**
  String get re_recently_viewed_title;

  /// No description provided for @re_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get re_coming_soon;

  /// No description provided for @re_map_title.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get re_map_title;

  /// No description provided for @re_map_view_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get re_map_view_tooltip;

  /// No description provided for @re_map_recenter.
  ///
  /// In en, this message translates to:
  /// **'Recenter'**
  String get re_map_recenter;

  /// No description provided for @re_map_open_property.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get re_map_open_property;

  /// No description provided for @re_hold_list_title.
  ///
  /// In en, this message translates to:
  /// **'My holds'**
  String get re_hold_list_title;

  /// No description provided for @re_hold_list_empty.
  ///
  /// In en, this message translates to:
  /// **'You have no holds yet'**
  String get re_hold_list_empty;

  /// No description provided for @re_hold_terms_title.
  ///
  /// In en, this message translates to:
  /// **'Hold terms'**
  String get re_hold_terms_title;

  /// No description provided for @re_hold_terms_acknowledge.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the hold terms, including the refund matrix.'**
  String get re_hold_terms_acknowledge;

  /// No description provided for @re_hold_terms_pay_cta.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} & hold'**
  String re_hold_terms_pay_cta(Object amount);

  /// No description provided for @re_hold_detail_pay_activate.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} & activate'**
  String re_hold_detail_pay_activate(Object amount);

  /// No description provided for @re_hold_detail_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel hold'**
  String get re_hold_detail_cancel;

  /// No description provided for @re_hold_detail_convert.
  ///
  /// In en, this message translates to:
  /// **'Convert to sale'**
  String get re_hold_detail_convert;

  /// No description provided for @re_visit_request_title.
  ///
  /// In en, this message translates to:
  /// **'Request a visit'**
  String get re_visit_request_title;

  /// No description provided for @re_visit_list_title.
  ///
  /// In en, this message translates to:
  /// **'My visits'**
  String get re_visit_list_title;

  /// No description provided for @re_visit_upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get re_visit_upcoming;

  /// No description provided for @re_visit_past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get re_visit_past;

  /// No description provided for @re_visit_empty.
  ///
  /// In en, this message translates to:
  /// **'No visits yet'**
  String get re_visit_empty;

  /// No description provided for @re_visit_requested.
  ///
  /// In en, this message translates to:
  /// **'Visit request sent'**
  String get re_visit_requested;

  /// No description provided for @re_loan_request_title.
  ///
  /// In en, this message translates to:
  /// **'Request a loan'**
  String get re_loan_request_title;

  /// No description provided for @re_loan_list_title.
  ///
  /// In en, this message translates to:
  /// **'My loans'**
  String get re_loan_list_title;

  /// No description provided for @re_loan_compare_title.
  ///
  /// In en, this message translates to:
  /// **'Compare offers'**
  String get re_loan_compare_title;

  /// No description provided for @re_loan_submit.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get re_loan_submit;

  /// No description provided for @re_loan_empty.
  ///
  /// In en, this message translates to:
  /// **'No loan requests yet'**
  String get re_loan_empty;

  /// No description provided for @re_loan_submitted.
  ///
  /// In en, this message translates to:
  /// **'Loan request sent to banks'**
  String get re_loan_submitted;

  /// No description provided for @re_loan_sort_rate.
  ///
  /// In en, this message translates to:
  /// **'Lowest rate first'**
  String get re_loan_sort_rate;

  /// No description provided for @re_loan_sort_amount.
  ///
  /// In en, this message translates to:
  /// **'Highest amount first'**
  String get re_loan_sort_amount;

  /// No description provided for @re_loan_sort_tenure.
  ///
  /// In en, this message translates to:
  /// **'Shortest tenure first'**
  String get re_loan_sort_tenure;

  /// No description provided for @re_purchases_title.
  ///
  /// In en, this message translates to:
  /// **'My purchases'**
  String get re_purchases_title;

  /// No description provided for @re_purchases_empty.
  ///
  /// In en, this message translates to:
  /// **'You have no purchases yet'**
  String get re_purchases_empty;

  /// No description provided for @re_purchases_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your purchases'**
  String get re_purchases_load_failed;

  /// No description provided for @re_purchase_details.
  ///
  /// In en, this message translates to:
  /// **'Purchase details'**
  String get re_purchase_details;

  /// No description provided for @re_purchase_code.
  ///
  /// In en, this message translates to:
  /// **'Sale code'**
  String get re_purchase_code;

  /// No description provided for @re_purchase_value.
  ///
  /// In en, this message translates to:
  /// **'Sale value'**
  String get re_purchase_value;

  /// No description provided for @re_purchase_hold_applied.
  ///
  /// In en, this message translates to:
  /// **'Hold principal applied'**
  String get re_purchase_hold_applied;

  /// No description provided for @re_purchase_balance.
  ///
  /// In en, this message translates to:
  /// **'Balance payable'**
  String get re_purchase_balance;

  /// No description provided for @re_purchase_date.
  ///
  /// In en, this message translates to:
  /// **'Purchased on'**
  String get re_purchase_date;

  /// No description provided for @re_purchase_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get re_purchase_status;

  /// No description provided for @re_purchase_type_buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get re_purchase_type_buy;

  /// No description provided for @re_purchase_type_rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get re_purchase_type_rent;

  /// No description provided for @re_documents_verified_title.
  ///
  /// In en, this message translates to:
  /// **'Documents verified'**
  String get re_documents_verified_title;

  /// No description provided for @re_documents_verified_on.
  ///
  /// In en, this message translates to:
  /// **'Verified on {date}'**
  String re_documents_verified_on(String date);

  /// No description provided for @re_documents_verified_none.
  ///
  /// In en, this message translates to:
  /// **'No verified documents yet'**
  String get re_documents_verified_none;

  /// No description provided for @re_doc_ownership.
  ///
  /// In en, this message translates to:
  /// **'Ownership'**
  String get re_doc_ownership;

  /// No description provided for @re_doc_approval.
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get re_doc_approval;

  /// No description provided for @re_doc_tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get re_doc_tax;

  /// No description provided for @re_doc_encumbrance.
  ///
  /// In en, this message translates to:
  /// **'Encumbrance'**
  String get re_doc_encumbrance;

  /// No description provided for @re_doc_project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get re_doc_project;

  /// No description provided for @re_doc_seller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get re_doc_seller;

  /// No description provided for @re_doc_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get re_doc_other;

  /// No description provided for @re_doc_requests_title.
  ///
  /// In en, this message translates to:
  /// **'Documents requested'**
  String get re_doc_requests_title;

  /// No description provided for @re_doc_request_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload document'**
  String get re_doc_request_upload;

  /// No description provided for @re_doc_request_sent.
  ///
  /// In en, this message translates to:
  /// **'Document sent to the bank'**
  String get re_doc_request_sent;

  /// No description provided for @re_doc_request_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the document. Please try again.'**
  String get re_doc_request_failed;

  /// No description provided for @re_doc_request_due.
  ///
  /// In en, this message translates to:
  /// **'Needed by {date}'**
  String re_doc_request_due(String date);

  /// No description provided for @re_doc_request_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected: {reason}'**
  String re_doc_request_rejected(String reason);

  /// No description provided for @re_doc_request_status_requested.
  ///
  /// In en, this message translates to:
  /// **'Needed'**
  String get re_doc_request_status_requested;

  /// No description provided for @re_doc_request_status_submitted.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get re_doc_request_status_submitted;

  /// No description provided for @re_doc_request_status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get re_doc_request_status_accepted;

  /// No description provided for @re_doc_request_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get re_doc_request_status_rejected;

  /// No description provided for @re_doc_request_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get re_doc_request_status_cancelled;

  /// No description provided for @re_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get re_status_active;

  /// No description provided for @re_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get re_status_pending;

  /// No description provided for @re_status_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get re_status_closed;

  /// No description provided for @re_status_payment_pending.
  ///
  /// In en, this message translates to:
  /// **'Payment pending'**
  String get re_status_payment_pending;

  /// No description provided for @re_status_expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get re_status_expired;

  /// No description provided for @re_status_converted_to_sale.
  ///
  /// In en, this message translates to:
  /// **'Converted to sale'**
  String get re_status_converted_to_sale;

  /// No description provided for @re_status_refund_pending.
  ///
  /// In en, this message translates to:
  /// **'Refund pending'**
  String get re_status_refund_pending;

  /// No description provided for @re_status_adjusted.
  ///
  /// In en, this message translates to:
  /// **'Adjusted'**
  String get re_status_adjusted;

  /// No description provided for @re_status_awaiting_assignment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting assignment'**
  String get re_status_awaiting_assignment;

  /// No description provided for @re_status_assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get re_status_assigned;

  /// No description provided for @re_status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get re_status_accepted;

  /// No description provided for @re_status_checked_in.
  ///
  /// In en, this message translates to:
  /// **'Executive checked in'**
  String get re_status_checked_in;

  /// No description provided for @re_status_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get re_status_in_progress;

  /// No description provided for @re_status_sent_to_banks.
  ///
  /// In en, this message translates to:
  /// **'Sent to banks'**
  String get re_status_sent_to_banks;

  /// No description provided for @re_status_offers_incoming.
  ///
  /// In en, this message translates to:
  /// **'Offers incoming'**
  String get re_status_offers_incoming;

  /// No description provided for @re_status_offers_received.
  ///
  /// In en, this message translates to:
  /// **'Offers received'**
  String get re_status_offers_received;

  /// No description provided for @re_status_selecting.
  ///
  /// In en, this message translates to:
  /// **'Selecting'**
  String get re_status_selecting;

  /// No description provided for @re_status_bank_selected.
  ///
  /// In en, this message translates to:
  /// **'Bank selected'**
  String get re_status_bank_selected;

  /// No description provided for @re_status_application_started.
  ///
  /// In en, this message translates to:
  /// **'Application started'**
  String get re_status_application_started;

  /// No description provided for @re_status_documents_pending.
  ///
  /// In en, this message translates to:
  /// **'Documents pending'**
  String get re_status_documents_pending;

  /// No description provided for @re_status_under_review.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get re_status_under_review;

  /// No description provided for @re_status_sanctioned.
  ///
  /// In en, this message translates to:
  /// **'Sanctioned'**
  String get re_status_sanctioned;

  /// No description provided for @re_status_disbursed.
  ///
  /// In en, this message translates to:
  /// **'Disbursed'**
  String get re_status_disbursed;

  /// No description provided for @re_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get re_status_rejected;

  /// No description provided for @re_status_withdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get re_status_withdrawn;

  /// No description provided for @re_status_requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get re_status_requested;

  /// No description provided for @re_status_applying_yourself.
  ///
  /// In en, this message translates to:
  /// **'Applying yourself'**
  String get re_status_applying_yourself;

  /// No description provided for @re_status_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get re_status_new;

  /// No description provided for @re_status_contacted.
  ///
  /// In en, this message translates to:
  /// **'Contacted'**
  String get re_status_contacted;

  /// No description provided for @re_status_visit_requested.
  ///
  /// In en, this message translates to:
  /// **'Visit requested'**
  String get re_status_visit_requested;

  /// No description provided for @re_status_visit_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Visit scheduled'**
  String get re_status_visit_scheduled;

  /// No description provided for @re_status_visit_completed.
  ///
  /// In en, this message translates to:
  /// **'Visit completed'**
  String get re_status_visit_completed;

  /// No description provided for @re_status_follow_up.
  ///
  /// In en, this message translates to:
  /// **'Follow up'**
  String get re_status_follow_up;

  /// No description provided for @re_status_hold.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get re_status_hold;

  /// No description provided for @re_status_sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get re_status_sale;

  /// No description provided for @re_status_lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get re_status_lost;

  /// No description provided for @re_expires_short.
  ///
  /// In en, this message translates to:
  /// **'Exp {date}'**
  String re_expires_short(String date);

  /// No description provided for @re_money.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get re_money;

  /// No description provided for @re_principal_held_in_trust.
  ///
  /// In en, this message translates to:
  /// **'Principal (held in trust)'**
  String get re_principal_held_in_trust;

  /// No description provided for @re_service_fee_revenue.
  ///
  /// In en, this message translates to:
  /// **'Service fee (revenue)'**
  String get re_service_fee_revenue;

  /// No description provided for @re_total_paid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get re_total_paid;

  /// No description provided for @re_principal_refund_policy.
  ///
  /// In en, this message translates to:
  /// **'Principal refunded per the §6.2 refund matrix.'**
  String get re_principal_refund_policy;

  /// No description provided for @re_hold_terms_frozen.
  ///
  /// In en, this message translates to:
  /// **'Hold terms (frozen at creation)'**
  String get re_hold_terms_frozen;

  /// No description provided for @re_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get re_duration;

  /// No description provided for @re_grace_period.
  ///
  /// In en, this message translates to:
  /// **'Grace period'**
  String get re_grace_period;

  /// No description provided for @re_cancellation_refundable.
  ///
  /// In en, this message translates to:
  /// **'Cancellation refundable'**
  String get re_cancellation_refundable;

  /// No description provided for @re_expiry_refundable.
  ///
  /// In en, this message translates to:
  /// **'Expiry refundable'**
  String get re_expiry_refundable;

  /// No description provided for @re_fee_refundable_withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Fee refundable on listing withdrawal'**
  String get re_fee_refundable_withdrawal;

  /// No description provided for @re_forfeiture_dual_control.
  ///
  /// In en, this message translates to:
  /// **'Forfeiture requires dual control'**
  String get re_forfeiture_dual_control;

  /// No description provided for @re_timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get re_timeline;

  /// No description provided for @re_placed.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get re_placed;

  /// No description provided for @re_activated.
  ///
  /// In en, this message translates to:
  /// **'Activated'**
  String get re_activated;

  /// No description provided for @re_expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get re_expires;

  /// No description provided for @re_hold_closed_note.
  ///
  /// In en, this message translates to:
  /// **'This hold is closed ({status}). No further action is possible.'**
  String re_hold_closed_note(String status);

  /// No description provided for @re_days_count.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String re_days_count(int count);

  /// No description provided for @re_hours_count.
  ///
  /// In en, this message translates to:
  /// **'{count} h'**
  String re_hours_count(int count);

  /// No description provided for @re_sale_value_label.
  ///
  /// In en, this message translates to:
  /// **'Sale value (₹)'**
  String get re_sale_value_label;

  /// No description provided for @re_convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get re_convert;

  /// No description provided for @re_keep_hold.
  ///
  /// In en, this message translates to:
  /// **'Keep hold'**
  String get re_keep_hold;

  /// No description provided for @re_hold_cancel_body.
  ///
  /// In en, this message translates to:
  /// **'Your principal will be refunded 100% to your original payment method. The service fee is retained because the property was taken off-market and verified while your hold was active.'**
  String get re_hold_cancel_body;

  /// No description provided for @re_hold_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Hold cancelled. Refund initiated.'**
  String get re_hold_cancelled;

  /// No description provided for @re_hold_cancel_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel hold. Please try again.'**
  String get re_hold_cancel_failed;

  /// No description provided for @re_hold_convert_body.
  ///
  /// In en, this message translates to:
  /// **'The hold principal will be applied against the sale consideration. It is never LocalWala revenue.'**
  String get re_hold_convert_body;

  /// No description provided for @re_hold_converted.
  ///
  /// In en, this message translates to:
  /// **'Hold converted to sale.'**
  String get re_hold_converted;

  /// No description provided for @re_hold_convert_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not convert hold. Please try again.'**
  String get re_hold_convert_failed;

  /// No description provided for @re_payment_start_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not start payment. Please try again.'**
  String get re_payment_start_failed;

  /// No description provided for @re_price_breakdown.
  ///
  /// In en, this message translates to:
  /// **'Price breakdown'**
  String get re_price_breakdown;

  /// No description provided for @re_hold_principal.
  ///
  /// In en, this message translates to:
  /// **'Hold principal'**
  String get re_hold_principal;

  /// No description provided for @re_service_fee_percent.
  ///
  /// In en, this message translates to:
  /// **'Service fee ({percent}%)'**
  String re_service_fee_percent(String percent);

  /// No description provided for @re_total_today.
  ///
  /// In en, this message translates to:
  /// **'Total today'**
  String get re_total_today;

  /// No description provided for @re_how_hold_works.
  ///
  /// In en, this message translates to:
  /// **'How the hold works'**
  String get re_how_hold_works;

  /// No description provided for @re_hold_bullet_reserved.
  ///
  /// In en, this message translates to:
  /// **'For {days} days this property is reserved for you. Other customers cannot hold it during this window.'**
  String re_hold_bullet_reserved(int days);

  /// No description provided for @re_hold_bullet_cancel.
  ///
  /// In en, this message translates to:
  /// **'You can cancel any time before the hold converts to a sale. The principal is refunded 100% to your original payment method.'**
  String get re_hold_bullet_cancel;

  /// No description provided for @re_hold_bullet_fee.
  ///
  /// In en, this message translates to:
  /// **'The service fee covers verification, taking the property off-market, and processing your reservation. It is not refunded on cancellation — the work has been done.'**
  String get re_hold_bullet_fee;

  /// No description provided for @re_hold_bullet_principal.
  ///
  /// In en, this message translates to:
  /// **'If the hold converts to a sale, the principal is applied against the purchase consideration. It is never LocalWala revenue.'**
  String get re_hold_bullet_principal;

  /// No description provided for @re_hold_bullet_withdrawn.
  ///
  /// In en, this message translates to:
  /// **'If the listing is withdrawn by the vendor while you hold it, both the principal and the service fee are refunded.'**
  String get re_hold_bullet_withdrawn;

  /// No description provided for @re_hold_bullet_reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders fire 72 hours, 24 hours and 6 hours before the hold expires. If you take no action, the hold lapses and the principal is refunded 100%.'**
  String get re_hold_bullet_reminders;

  /// No description provided for @re_refund_matrix.
  ///
  /// In en, this message translates to:
  /// **'Refund matrix'**
  String get re_refund_matrix;

  /// No description provided for @re_event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get re_event;

  /// No description provided for @re_principal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get re_principal;

  /// No description provided for @re_service_fee.
  ///
  /// In en, this message translates to:
  /// **'Service fee'**
  String get re_service_fee;

  /// No description provided for @re_refund_you_cancel.
  ///
  /// In en, this message translates to:
  /// **'You cancel'**
  String get re_refund_you_cancel;

  /// No description provided for @re_refund_principal_full.
  ///
  /// In en, this message translates to:
  /// **'Principal 100% back'**
  String get re_refund_principal_full;

  /// No description provided for @re_refund_fee_retained.
  ///
  /// In en, this message translates to:
  /// **'Fee retained'**
  String get re_refund_fee_retained;

  /// No description provided for @re_refund_hold_expires.
  ///
  /// In en, this message translates to:
  /// **'Hold expires'**
  String get re_refund_hold_expires;

  /// No description provided for @re_refund_applied_to_sale.
  ///
  /// In en, this message translates to:
  /// **'Applied to sale'**
  String get re_refund_applied_to_sale;

  /// No description provided for @re_refund_fee_earned.
  ///
  /// In en, this message translates to:
  /// **'Already earned'**
  String get re_refund_fee_earned;

  /// No description provided for @re_refund_listing_withdrawn.
  ///
  /// In en, this message translates to:
  /// **'Listing withdrawn'**
  String get re_refund_listing_withdrawn;

  /// No description provided for @re_refund_fee_refunded.
  ///
  /// In en, this message translates to:
  /// **'Fee refunded'**
  String get re_refund_fee_refunded;

  /// No description provided for @re_hold_on_hold_warning.
  ///
  /// In en, this message translates to:
  /// **'This property is already on hold by another customer. You can still place a hold request and it will queue if it expires, but right now you cannot hold this unit.'**
  String get re_hold_on_hold_warning;

  /// No description provided for @re_hold_already_active.
  ///
  /// In en, this message translates to:
  /// **'You already have an active hold on this property.'**
  String get re_hold_already_active;

  /// No description provided for @re_hold_create_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not create hold. Please try again.'**
  String get re_hold_create_failed;

  /// No description provided for @re_enquiry.
  ///
  /// In en, this message translates to:
  /// **'Enquiry'**
  String get re_enquiry;

  /// No description provided for @re_submitted_on.
  ///
  /// In en, this message translates to:
  /// **'Submitted {date}'**
  String re_submitted_on(String date);

  /// No description provided for @re_enquiry_closed_sale.
  ///
  /// In en, this message translates to:
  /// **'This enquiry closed in a sale.'**
  String get re_enquiry_closed_sale;

  /// No description provided for @re_enquiry_closed.
  ///
  /// In en, this message translates to:
  /// **'This enquiry is closed.'**
  String get re_enquiry_closed;

  /// No description provided for @re_withdraw_body.
  ///
  /// In en, this message translates to:
  /// **'This will mark the enquiry as LOST. You can submit a new one later.'**
  String get re_withdraw_body;

  /// No description provided for @re_withdraw_reason_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason.'**
  String get re_withdraw_reason_required;

  /// No description provided for @re_clear_history.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get re_clear_history;

  /// No description provided for @re_clear_history_body.
  ///
  /// In en, this message translates to:
  /// **'Remove every property from your recently viewed list?'**
  String get re_clear_history_body;

  /// No description provided for @re_recently_viewed_empty.
  ///
  /// In en, this message translates to:
  /// **'No recently viewed properties yet'**
  String get re_recently_viewed_empty;

  /// No description provided for @re_location_fallback.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable; showing a city centre'**
  String get re_location_fallback;

  /// No description provided for @re_location_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get re_location_unavailable;

  /// No description provided for @re_nearby_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load nearby properties'**
  String get re_nearby_load_failed;

  /// Fallback title for a property listing
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get re_property;

  /// No description provided for @re_price_on_request.
  ///
  /// In en, this message translates to:
  /// **'Price on request'**
  String get re_price_on_request;

  /// No description provided for @re_property_visit.
  ///
  /// In en, this message translates to:
  /// **'Property visit'**
  String get re_property_visit;

  /// No description provided for @re_with_name.
  ///
  /// In en, this message translates to:
  /// **'with {name}'**
  String re_with_name(String name);

  /// No description provided for @re_day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get re_day;

  /// No description provided for @re_preferred_slot.
  ///
  /// In en, this message translates to:
  /// **'Preferred slot'**
  String get re_preferred_slot;

  /// No description provided for @re_assignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get re_assignment;

  /// No description provided for @re_waiting_assignment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for an executive to be assigned'**
  String get re_waiting_assignment;

  /// No description provided for @re_executive.
  ///
  /// In en, this message translates to:
  /// **'Executive'**
  String get re_executive;

  /// No description provided for @re_not_assigned_yet.
  ///
  /// In en, this message translates to:
  /// **'Not assigned yet — you will be notified.'**
  String get re_not_assigned_yet;

  /// No description provided for @re_cancellation.
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get re_cancellation;

  /// No description provided for @re_visit_geo_note.
  ///
  /// In en, this message translates to:
  /// **'An executive can only check in at the property itself — the visit is geo-verified on arrival.'**
  String get re_visit_geo_note;

  /// No description provided for @re_preferred_day.
  ///
  /// In en, this message translates to:
  /// **'Preferred day'**
  String get re_preferred_day;

  /// No description provided for @re_choose_date.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get re_choose_date;

  /// No description provided for @re_preferred_time.
  ///
  /// In en, this message translates to:
  /// **'Preferred time'**
  String get re_preferred_time;

  /// No description provided for @re_slot_morning.
  ///
  /// In en, this message translates to:
  /// **'Morning · 9am – 12pm'**
  String get re_slot_morning;

  /// No description provided for @re_slot_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon · 12pm – 4pm'**
  String get re_slot_afternoon;

  /// No description provided for @re_slot_evening.
  ///
  /// In en, this message translates to:
  /// **'Evening · 4pm – 7pm'**
  String get re_slot_evening;

  /// No description provided for @re_morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get re_morning;

  /// No description provided for @re_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get re_afternoon;

  /// No description provided for @re_evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get re_evening;

  /// No description provided for @re_visit_note_label.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get re_visit_note_label;

  /// No description provided for @re_visit_note_hint.
  ///
  /// In en, this message translates to:
  /// **'Anything the executive should know…'**
  String get re_visit_note_hint;

  /// No description provided for @re_visit_submit.
  ///
  /// In en, this message translates to:
  /// **'Request visit'**
  String get re_visit_submit;

  /// No description provided for @re_visit_open_exists.
  ///
  /// In en, this message translates to:
  /// **'You already have an open visit request for this enquiry.'**
  String get re_visit_open_exists;

  /// No description provided for @re_visit_pick_later.
  ///
  /// In en, this message translates to:
  /// **'Pick today or a later date.'**
  String get re_visit_pick_later;

  /// No description provided for @re_visit_property_unavailable.
  ///
  /// In en, this message translates to:
  /// **'This property is no longer available to visit.'**
  String get re_visit_property_unavailable;

  /// No description provided for @re_visit_request_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not request the visit. Please try again.'**
  String get re_visit_request_failed;

  /// No description provided for @re_bank_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No banks} =1{1 bank} other{{count} banks}}'**
  String re_bank_count(int count);

  /// No description provided for @re_offer_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No offers} =1{1 offer} other{{count} offers}}'**
  String re_offer_count(int count);

  /// No description provided for @re_requested_amount.
  ///
  /// In en, this message translates to:
  /// **'Requested amount'**
  String get re_requested_amount;

  /// No description provided for @re_tenure.
  ///
  /// In en, this message translates to:
  /// **'Tenure'**
  String get re_tenure;

  /// No description provided for @re_employment.
  ///
  /// In en, this message translates to:
  /// **'Employment'**
  String get re_employment;

  /// No description provided for @re_employment_salaried.
  ///
  /// In en, this message translates to:
  /// **'Salaried'**
  String get re_employment_salaried;

  /// No description provided for @re_employment_self_employed.
  ///
  /// In en, this message translates to:
  /// **'Self employed'**
  String get re_employment_self_employed;

  /// No description provided for @re_employment_business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get re_employment_business;

  /// No description provided for @re_employment_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get re_employment_other;

  /// No description provided for @re_monthly_income.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get re_monthly_income;

  /// No description provided for @re_months_count.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String re_months_count(int count);

  /// No description provided for @re_any_tenure.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get re_any_tenure;

  /// No description provided for @re_banks.
  ///
  /// In en, this message translates to:
  /// **'Banks'**
  String get re_banks;

  /// No description provided for @re_waiting_for_banks.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the request to reach banks…'**
  String get re_waiting_for_banks;

  /// No description provided for @re_bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get re_bank;

  /// No description provided for @re_sanctioned_amount.
  ///
  /// In en, this message translates to:
  /// **'Sanctioned: {amount}'**
  String re_sanctioned_amount(String amount);

  /// No description provided for @re_disbursed_amount.
  ///
  /// In en, this message translates to:
  /// **'Disbursed: {amount}'**
  String re_disbursed_amount(String amount);

  /// No description provided for @re_reason_label.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String re_reason_label(String reason);

  /// No description provided for @re_requested_value.
  ///
  /// In en, this message translates to:
  /// **'Requested {amount}'**
  String re_requested_value(String amount);

  /// No description provided for @re_rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get re_rate;

  /// No description provided for @re_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get re_amount;

  /// No description provided for @re_fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get re_fee;

  /// No description provided for @re_interest_rate.
  ///
  /// In en, this message translates to:
  /// **'{rate}% p.a.'**
  String re_interest_rate(String rate);

  /// No description provided for @re_months_short.
  ///
  /// In en, this message translates to:
  /// **'{count} mo'**
  String re_months_short(int count);

  /// No description provided for @re_no_offers_yet.
  ///
  /// In en, this message translates to:
  /// **'No offers yet — banks are reviewing your request.'**
  String get re_no_offers_yet;

  /// No description provided for @re_loan_select_offer.
  ///
  /// In en, this message translates to:
  /// **'Select this offer'**
  String get re_loan_select_offer;

  /// No description provided for @re_loan_accept_title.
  ///
  /// In en, this message translates to:
  /// **'Accept this offer?'**
  String get re_loan_accept_title;

  /// No description provided for @re_loan_accept_body.
  ///
  /// In en, this message translates to:
  /// **'You are choosing {bank}. The other offers will close and this choice cannot be changed.'**
  String re_loan_accept_body(String bank);

  /// No description provided for @re_loan_accepted.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted. The bank will review your application.'**
  String get re_loan_accepted;

  /// No description provided for @re_loan_accept_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not accept this offer. Please try again.'**
  String get re_loan_accept_failed;

  /// No description provided for @re_loan_selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get re_loan_selected;

  /// No description provided for @re_offer_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get re_offer_status_pending;

  /// No description provided for @re_offer_status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get re_offer_status_accepted;

  /// No description provided for @re_offer_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get re_offer_status_rejected;

  /// No description provided for @re_offer_status_withdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get re_offer_status_withdrawn;

  /// No description provided for @re_loan_amount_question.
  ///
  /// In en, this message translates to:
  /// **'How much do you need?'**
  String get re_loan_amount_question;

  /// No description provided for @re_loan_amount_label.
  ///
  /// In en, this message translates to:
  /// **'Loan amount (₹)'**
  String get re_loan_amount_label;

  /// No description provided for @re_loan_amount_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5000000'**
  String get re_loan_amount_hint;

  /// No description provided for @re_tenure_optional.
  ///
  /// In en, this message translates to:
  /// **'Tenure (optional)'**
  String get re_tenure_optional;

  /// No description provided for @re_repayment_period.
  ///
  /// In en, this message translates to:
  /// **'Repayment period'**
  String get re_repayment_period;

  /// No description provided for @re_months_years.
  ///
  /// In en, this message translates to:
  /// **'{months} months ({years} years)'**
  String re_months_years(int months, int years);

  /// No description provided for @re_monthly_income_label.
  ///
  /// In en, this message translates to:
  /// **'Monthly income (₹)'**
  String get re_monthly_income_label;

  /// No description provided for @re_income_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 75000'**
  String get re_income_hint;

  /// No description provided for @re_loan_open_exists.
  ///
  /// In en, this message translates to:
  /// **'You already have an open loan request for this property.'**
  String get re_loan_open_exists;

  /// No description provided for @re_loan_disabled.
  ///
  /// In en, this message translates to:
  /// **'Requesting a loan is currently disabled.'**
  String get re_loan_disabled;

  /// No description provided for @re_loan_property_unavailable.
  ///
  /// In en, this message translates to:
  /// **'This property is no longer available.'**
  String get re_loan_property_unavailable;

  /// No description provided for @talk_to_agent.
  ///
  /// In en, this message translates to:
  /// **'Talk to an agent'**
  String get talk_to_agent;

  /// No description provided for @stores_entry_title.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores_entry_title;

  /// No description provided for @stores_entry_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Groceries & essentials from local outlets'**
  String get stores_entry_subtitle;

  /// No description provided for @stores_near_you.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No stores nearby yet} =1{1 store near you} other{{count} stores near you}}'**
  String stores_near_you(int count);

  /// No description provided for @stores_set_location_prompt.
  ///
  /// In en, this message translates to:
  /// **'Set your location to see stores near you'**
  String get stores_set_location_prompt;

  /// No description provided for @stores_no_nearby.
  ///
  /// In en, this message translates to:
  /// **'No stores nearby yet'**
  String get stores_no_nearby;

  /// No description provided for @stores_add_address_prompt.
  ///
  /// In en, this message translates to:
  /// **'Add a delivery address to see stores near you'**
  String get stores_add_address_prompt;

  /// No description provided for @stores_reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get stores_reviews;

  /// No description provided for @stores_offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get stores_offers;

  /// No description provided for @stores_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get stores_products;

  /// No description provided for @stores_options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get stores_options;

  /// No description provided for @stores_cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get stores_cart;

  /// No description provided for @stores_your_orders.
  ///
  /// In en, this message translates to:
  /// **'Your orders'**
  String get stores_your_orders;

  /// No description provided for @stores_returns_exchanges.
  ///
  /// In en, this message translates to:
  /// **'Returns & exchanges'**
  String get stores_returns_exchanges;

  /// No description provided for @stores_request_return.
  ///
  /// In en, this message translates to:
  /// **'Request return'**
  String get stores_request_return;

  /// No description provided for @stores_request_exchange.
  ///
  /// In en, this message translates to:
  /// **'Request exchange'**
  String get stores_request_exchange;

  /// No description provided for @stores_return_reason_label.
  ///
  /// In en, this message translates to:
  /// **'What went wrong?'**
  String get stores_return_reason_label;

  /// No description provided for @stores_pay_now.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get stores_pay_now;

  /// No description provided for @stores_cancel_order.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get stores_cancel_order;

  /// No description provided for @stores_review_order.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stores_review_order;

  /// No description provided for @stores_clear_cart.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get stores_clear_cart;

  /// No description provided for @stores_added_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get stores_added_to_cart;

  /// No description provided for @stores_cart_outlet_conflict.
  ///
  /// In en, this message translates to:
  /// **'Your cart has items from another store. Clear it first, or check out there.'**
  String get stores_cart_outlet_conflict;

  /// No description provided for @stores_no_options_available.
  ///
  /// In en, this message translates to:
  /// **'This product has no options available, so it cannot be added to a cart yet.'**
  String get stores_no_options_available;

  /// No description provided for @stores_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get stores_search_hint;

  /// No description provided for @stores_subscribe_created.
  ///
  /// In en, this message translates to:
  /// **'Subscription created.'**
  String get stores_subscribe_created;

  /// No description provided for @restaurantNotCovered.
  ///
  /// In en, this message translates to:
  /// **'This restaurant does not deliver to the selected address â€” pick another address or restaurant'**
  String get restaurantNotCovered;

  /// No description provided for @pay_secure_by.
  ///
  /// In en, this message translates to:
  /// **'100% Secure Payments by '**
  String get pay_secure_by;

  /// No description provided for @pay_upi_recommended.
  ///
  /// In en, this message translates to:
  /// **'UPI (Recommended)'**
  String get pay_upi_recommended;

  /// No description provided for @pay_with_any_upi.
  ///
  /// In en, this message translates to:
  /// **'Pay with any UPI app'**
  String get pay_with_any_upi;

  /// No description provided for @pay_using_upi_id.
  ///
  /// In en, this message translates to:
  /// **'Pay using UPI ID'**
  String get pay_using_upi_id;

  /// No description provided for @pay_card_title.
  ///
  /// In en, this message translates to:
  /// **'Credit / Debit Card'**
  String get pay_card_title;

  /// No description provided for @pay_card_sub.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard, RuPay'**
  String get pay_card_sub;

  /// No description provided for @pay_nb_title.
  ///
  /// In en, this message translates to:
  /// **'Net Banking'**
  String get pay_nb_title;

  /// No description provided for @pay_nb_sub.
  ///
  /// In en, this message translates to:
  /// **'All major banks'**
  String get pay_nb_sub;

  /// No description provided for @pay_wallets_title.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get pay_wallets_title;

  /// No description provided for @pay_wallets_sub.
  ///
  /// In en, this message translates to:
  /// **'Paytm, Amazon Pay etc.'**
  String get pay_wallets_sub;

  /// No description provided for @pay_cod_title.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get pay_cod_title;

  /// No description provided for @pay_cod_sub.
  ///
  /// In en, this message translates to:
  /// **'Pay at your door'**
  String get pay_cod_sub;

  /// No description provided for @pay_methods_hint.
  ///
  /// In en, this message translates to:
  /// **'UPI • Card • NB • Wallet'**
  String get pay_methods_hint;

  /// No description provided for @pay_methods_hint_cod.
  ///
  /// In en, this message translates to:
  /// **'UPI • Card • NB • Wallet • COD'**
  String get pay_methods_hint_cod;

  /// No description provided for @pay_prefix.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay_prefix;

  /// No description provided for @upi_payment_title.
  ///
  /// In en, this message translates to:
  /// **'UPI Payment'**
  String get upi_payment_title;

  /// No description provided for @upi_pay_using.
  ///
  /// In en, this message translates to:
  /// **'Pay using UPI'**
  String get upi_pay_using;

  /// No description provided for @upi_select_app.
  ///
  /// In en, this message translates to:
  /// **'Select your UPI app to complete payment'**
  String get upi_select_app;

  /// No description provided for @upi_or_id.
  ///
  /// In en, this message translates to:
  /// **'Or pay using UPI ID'**
  String get upi_or_id;

  /// No description provided for @upi_id_label.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get upi_id_label;

  /// No description provided for @upi_id_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter UPI ID'**
  String get upi_id_hint;

  /// No description provided for @upi_id_example.
  ///
  /// In en, this message translates to:
  /// **'e.g. name@okhdfcbank'**
  String get upi_id_example;

  /// No description provided for @amount_to_pay.
  ///
  /// In en, this message translates to:
  /// **'Amount to Pay'**
  String get amount_to_pay;

  /// No description provided for @pay_with.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get pay_with;

  /// No description provided for @pay_mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get pay_mobile;

  /// No description provided for @pay_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get pay_email;

  /// No description provided for @pay_mobile_hint.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile'**
  String get pay_mobile_hint;

  /// No description provided for @pay_email_hint.
  ///
  /// In en, this message translates to:
  /// **'you@mail.com'**
  String get pay_email_hint;

  /// No description provided for @pay_card_number.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get pay_card_number;

  /// No description provided for @pay_card_number_hint.
  ///
  /// In en, this message translates to:
  /// **'4111 1111 1111 1111'**
  String get pay_card_number_hint;

  /// No description provided for @pay_card_name.
  ///
  /// In en, this message translates to:
  /// **'Name on card'**
  String get pay_card_name;

  /// No description provided for @pay_card_expiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get pay_card_expiry;

  /// No description provided for @pay_card_expiry_hint.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get pay_card_expiry_hint;

  /// No description provided for @pay_card_cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get pay_card_cvv;

  /// No description provided for @pay_select_bank.
  ///
  /// In en, this message translates to:
  /// **'Select bank'**
  String get pay_select_bank;

  /// No description provided for @pay_select_wallet.
  ///
  /// In en, this message translates to:
  /// **'Select wallet'**
  String get pay_select_wallet;

  /// No description provided for @pay_loading_banks.
  ///
  /// In en, this message translates to:
  /// **'Loading banks…'**
  String get pay_loading_banks;

  /// No description provided for @pay_loading_wallets.
  ///
  /// In en, this message translates to:
  /// **'Loading wallets…'**
  String get pay_loading_wallets;

  /// No description provided for @pay_wallet_note.
  ///
  /// In en, this message translates to:
  /// **'Wallet is charged in-app — no app switch.'**
  String get pay_wallet_note;

  /// No description provided for @pay_paylater_note.
  ///
  /// In en, this message translates to:
  /// **'PayLater via Simpl/LazyPay — enable in Razorpay dashboard'**
  String get pay_paylater_note;

  /// No description provided for @pay_processing_title.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment'**
  String get pay_processing_title;

  /// No description provided for @pay_redirect_title.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to {appName}'**
  String pay_redirect_title(Object appName);

  /// No description provided for @pay_redirect_sub.
  ///
  /// In en, this message translates to:
  /// **'Please complete the payment in your {appName} app'**
  String pay_redirect_sub(Object appName);

  /// No description provided for @pay_step_request.
  ///
  /// In en, this message translates to:
  /// **'Creating secure payment request'**
  String get pay_step_request;

  /// No description provided for @pay_step_open.
  ///
  /// In en, this message translates to:
  /// **'Opening {appName} app'**
  String pay_step_open(Object appName);

  /// No description provided for @pay_step_wait.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment confirmation'**
  String get pay_step_wait;

  /// No description provided for @pay_step_finalize.
  ///
  /// In en, this message translates to:
  /// **'Finalizing your order'**
  String get pay_step_finalize;

  /// No description provided for @pay_dont_back.
  ///
  /// In en, this message translates to:
  /// **'Do not press back or close the app.'**
  String get pay_dont_back;

  /// No description provided for @pay_processing_wait.
  ///
  /// In en, this message translates to:
  /// **'Processing — complete approval in UPI app / 3DS, do not press back or close.'**
  String get pay_processing_wait;

  /// No description provided for @pay_back_blocked.
  ///
  /// In en, this message translates to:
  /// **'Payment processing — please wait, do not go back'**
  String get pay_back_blocked;

  /// No description provided for @pay_enter_mobile.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit mobile number to continue'**
  String get pay_enter_mobile;

  /// No description provided for @pay_enter_email.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email to continue'**
  String get pay_enter_email;

  /// No description provided for @pay_enter_vpa.
  ///
  /// In en, this message translates to:
  /// **'Enter valid UPI ID (name@bank)'**
  String get pay_enter_vpa;

  /// No description provided for @pay_enter_card.
  ///
  /// In en, this message translates to:
  /// **'Enter valid card details'**
  String get pay_enter_card;

  /// No description provided for @pay_app_missing.
  ///
  /// In en, this message translates to:
  /// **'App not installed — enter UPI ID above to pay in-app'**
  String get pay_app_missing;

  /// No description provided for @pay_submit_failed.
  ///
  /// In en, this message translates to:
  /// **'Payment submit failed: {error}'**
  String pay_submit_failed(Object error);

  /// No description provided for @pay_failed_snack.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get pay_failed_snack;

  /// No description provided for @pay_success_title.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get pay_success_title;

  /// No description provided for @pay_success_sub.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed'**
  String get pay_success_sub;

  /// No description provided for @pay_order_id.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get pay_order_id;

  /// No description provided for @pay_total_paid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get pay_total_paid;

  /// No description provided for @pay_method_label.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get pay_method_label;

  /// No description provided for @pay_online.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get pay_online;

  /// No description provided for @pay_eta.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery'**
  String get pay_eta;

  /// No description provided for @pay_track.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get pay_track;

  /// No description provided for @pay_home.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get pay_home;

  /// No description provided for @pay_fail_order.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get pay_fail_order;

  /// No description provided for @pay_fail_wallet.
  ///
  /// In en, this message translates to:
  /// **'Top-up Failed'**
  String get pay_fail_wallet;

  /// No description provided for @pay_fail_dining.
  ///
  /// In en, this message translates to:
  /// **'Booking Payment Failed'**
  String get pay_fail_dining;

  /// No description provided for @pay_fail_tiffin.
  ///
  /// In en, this message translates to:
  /// **'Subscription Payment Failed'**
  String get pay_fail_tiffin;

  /// No description provided for @pay_fail_register.
  ///
  /// In en, this message translates to:
  /// **'Registration Payment Failed'**
  String get pay_fail_register;

  /// No description provided for @pay_fail_msg.
  ///
  /// In en, this message translates to:
  /// **'Your payment could not be completed. No money was charged. Please try again.'**
  String get pay_fail_msg;

  /// No description provided for @pay_try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get pay_try_again;

  /// No description provided for @pay_go_back.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get pay_go_back;

  /// No description provided for @pay_cod_placing.
  ///
  /// In en, this message translates to:
  /// **'Placing your COD order'**
  String get pay_cod_placing;

  /// No description provided for @pay_cod_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait, confirming with the restaurant'**
  String get pay_cod_wait;

  /// No description provided for @pay_upi_switch_hint.
  ///
  /// In en, this message translates to:
  /// **'Or pay via UPI app (switches app):'**
  String get pay_upi_switch_hint;

  /// No description provided for @pay_upi_on_device.
  ///
  /// In en, this message translates to:
  /// **'UPI apps on device: {count}'**
  String pay_upi_on_device(Object count);

  /// No description provided for @pay_card_vpa_inapp.
  ///
  /// In en, this message translates to:
  /// **'VPA  e.g. name@okhdfc'**
  String get pay_card_vpa_inapp;

  /// No description provided for @pay_other_upi.
  ///
  /// In en, this message translates to:
  /// **'Other UPI'**
  String get pay_other_upi;

  /// No description provided for @pay_saved_cards.
  ///
  /// In en, this message translates to:
  /// **'Saved cards'**
  String get pay_saved_cards;

  /// No description provided for @pay_save_card.
  ///
  /// In en, this message translates to:
  /// **'Save card for faster checkout'**
  String get pay_save_card;

  /// No description provided for @pay_save_card_sub.
  ///
  /// In en, this message translates to:
  /// **'Only last 4 digits stored on this device. CVV never saved.'**
  String get pay_save_card_sub;

  /// No description provided for @pay_use.
  ///
  /// In en, this message translates to:
  /// **'USE'**
  String get pay_use;

  /// No description provided for @pay_provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get pay_provider;

  /// No description provided for @pay_bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get pay_bank;

  /// No description provided for @pay_plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get pay_plan;

  /// No description provided for @pay_paylater.
  ///
  /// In en, this message translates to:
  /// **'PayLater'**
  String get pay_paylater;

  /// No description provided for @pay_emi.
  ///
  /// In en, this message translates to:
  /// **'EMI'**
  String get pay_emi;

  /// No description provided for @pay_total_payable.
  ///
  /// In en, this message translates to:
  /// **'Total payable'**
  String get pay_total_payable;

  /// No description provided for @pay_most_used.
  ///
  /// In en, this message translates to:
  /// **'MOST USED'**
  String get pay_most_used;

  /// No description provided for @pay_not_installed.
  ///
  /// In en, this message translates to:
  /// **'Not installed - use ID'**
  String get pay_not_installed;

  /// No description provided for @pay_upi_apps_found.
  ///
  /// In en, this message translates to:
  /// **'{count} UPI apps found on this device'**
  String pay_upi_apps_found(Object count);

  /// No description provided for @pay_select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get pay_select;

  /// No description provided for @dairy_title.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get dairy_title;

  /// No description provided for @dairy_orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get dairy_orders;

  /// No description provided for @dairy_subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get dairy_subscriptions;

  /// No description provided for @dairy_wallet_deposits.
  ///
  /// In en, this message translates to:
  /// **'Wallet & deposits'**
  String get dairy_wallet_deposits;

  /// No description provided for @dairy_support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get dairy_support;

  /// No description provided for @dairy_cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get dairy_cart;

  /// No description provided for @dairy_checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get dairy_checkout;

  /// No description provided for @dairy_outlet.
  ///
  /// In en, this message translates to:
  /// **'Outlet'**
  String get dairy_outlet;

  /// No description provided for @dairy_product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get dairy_product;

  /// No description provided for @dairy_subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get dairy_subscription;

  /// No description provided for @dairy_tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get dairy_tracking;

  /// No description provided for @dairy_new_subscription.
  ///
  /// In en, this message translates to:
  /// **'New subscription'**
  String get dairy_new_subscription;

  /// No description provided for @dairy_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search milk, ghee, paneer…'**
  String get dairy_search_hint;

  /// No description provided for @dairy_filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get dairy_filters;

  /// No description provided for @dairy_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dairy_all;

  /// No description provided for @dairy_products_count.
  ///
  /// In en, this message translates to:
  /// **'{count} product(s)'**
  String dairy_products_count(Object count);

  /// No description provided for @dairy_clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get dairy_clear_filters;

  /// No description provided for @dairy_brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get dairy_brand;

  /// No description provided for @dairy_any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get dairy_any;

  /// No description provided for @dairy_fat_level.
  ///
  /// In en, this message translates to:
  /// **'Fat level'**
  String get dairy_fat_level;

  /// No description provided for @dairy_milk_type.
  ///
  /// In en, this message translates to:
  /// **'Milk type'**
  String get dairy_milk_type;

  /// No description provided for @dairy_price_per_pack.
  ///
  /// In en, this message translates to:
  /// **'Price per pack (₹)'**
  String get dairy_price_per_pack;

  /// No description provided for @dairy_min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get dairy_min;

  /// No description provided for @dairy_max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get dairy_max;

  /// No description provided for @dairy_to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get dairy_to;

  /// No description provided for @dairy_clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get dairy_clear_all;

  /// No description provided for @dairy_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get dairy_apply;

  /// No description provided for @dairy_no_matches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches — try fewer filters.'**
  String get dairy_no_matches;

  /// No description provided for @dairy_out_of_stock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock at the moment.'**
  String get dairy_out_of_stock;

  /// No description provided for @dairy_standard_pack.
  ///
  /// In en, this message translates to:
  /// **'Standard pack'**
  String get dairy_standard_pack;

  /// No description provided for @dairy_add_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get dairy_add_to_cart;

  /// No description provided for @dairy_added_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get dairy_added_to_cart;

  /// No description provided for @dairy_could_not_add.
  ///
  /// In en, this message translates to:
  /// **'Could not add'**
  String get dairy_could_not_add;

  /// No description provided for @dairy_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get dairy_products;

  /// No description provided for @dairy_no_products.
  ///
  /// In en, this message translates to:
  /// **'No products listed yet.'**
  String get dairy_no_products;

  /// No description provided for @dairy_could_not_load_product.
  ///
  /// In en, this message translates to:
  /// **'Could not load product.'**
  String get dairy_could_not_load_product;

  /// No description provided for @dairy_pack_label.
  ///
  /// In en, this message translates to:
  /// **'Pack: {value}'**
  String dairy_pack_label(Object value);

  /// No description provided for @dairy_price_label.
  ///
  /// In en, this message translates to:
  /// **'Price: {value}'**
  String dairy_price_label(Object value);

  /// No description provided for @dairy_could_not_load_outlet.
  ///
  /// In en, this message translates to:
  /// **'Could not load outlet.'**
  String get dairy_could_not_load_outlet;

  /// No description provided for @dairy_verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get dairy_verified;

  /// No description provided for @dairy_pending_review.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get dairy_pending_review;

  /// No description provided for @dairy_rating.
  ///
  /// In en, this message translates to:
  /// **'Rating {value}'**
  String dairy_rating(Object value);

  /// No description provided for @dairy_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get dairy_open;

  /// No description provided for @dairy_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get dairy_closed;

  /// No description provided for @dairy_could_not_load_orders.
  ///
  /// In en, this message translates to:
  /// **'Could not load orders.'**
  String get dairy_could_not_load_orders;

  /// No description provided for @dairy_order_title.
  ///
  /// In en, this message translates to:
  /// **'Order {value}'**
  String dairy_order_title(Object value);

  /// No description provided for @dairy_could_not_load_order.
  ///
  /// In en, this message translates to:
  /// **'Could not load order.'**
  String get dairy_could_not_load_order;

  /// No description provided for @dairy_cancel_order.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get dairy_cancel_order;

  /// No description provided for @dairy_cancel_order_q.
  ///
  /// In en, this message translates to:
  /// **'Cancel order?'**
  String get dairy_cancel_order_q;

  /// No description provided for @dairy_cancel_order_body.
  ///
  /// In en, this message translates to:
  /// **'Stock and any can deposit held for this order are released back.'**
  String get dairy_cancel_order_body;

  /// No description provided for @dairy_keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get dairy_keep;

  /// No description provided for @dairy_order_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get dairy_order_cancelled;

  /// No description provided for @dairy_could_not_cancel.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel'**
  String get dairy_could_not_cancel;

  /// No description provided for @dairy_items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get dairy_items;

  /// No description provided for @dairy_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get dairy_total;

  /// No description provided for @dairy_cash_on_delivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get dairy_cash_on_delivery;

  /// No description provided for @dairy_can_deposit_held.
  ///
  /// In en, this message translates to:
  /// **'Can deposit (held, released on return)'**
  String get dairy_can_deposit_held;

  /// No description provided for @dairy_cans_issued.
  ///
  /// In en, this message translates to:
  /// **'{count} can(s) issued'**
  String dairy_cans_issued(Object count);

  /// No description provided for @dairy_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get dairy_history;

  /// No description provided for @dairy_no_history.
  ///
  /// In en, this message translates to:
  /// **'No status changes recorded yet.'**
  String get dairy_no_history;

  /// No description provided for @dairy_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get dairy_update;

  /// No description provided for @dairy_get_help.
  ///
  /// In en, this message translates to:
  /// **'Get help with this order'**
  String get dairy_get_help;

  /// No description provided for @dairy_from.
  ///
  /// In en, this message translates to:
  /// **'From {value}'**
  String dairy_from(Object value);

  /// No description provided for @dairy_could_not_load_conversations.
  ///
  /// In en, this message translates to:
  /// **'Could not load conversations.'**
  String get dairy_could_not_load_conversations;

  /// No description provided for @dairy_no_conversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet. Open an order in Orders → Track and tap \"Get help with this order\" to start a support chat.'**
  String get dairy_no_conversations;

  /// No description provided for @dairy_wallet_balance.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance'**
  String get dairy_wallet_balance;

  /// No description provided for @dairy_wallet_prepaid_note.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions are prepaid from this wallet, one delivery at a time.'**
  String get dairy_wallet_prepaid_note;

  /// No description provided for @dairy_can_deposits_held.
  ///
  /// In en, this message translates to:
  /// **'Can deposits held'**
  String get dairy_can_deposits_held;

  /// No description provided for @dairy_deposit_note.
  ///
  /// In en, this message translates to:
  /// **'{count} can(s) with you. The deposit is held in your wallet and released automatically when the rider collects the empties back.'**
  String dairy_deposit_note(Object count);

  /// No description provided for @dairy_your_cans.
  ///
  /// In en, this message translates to:
  /// **'Your cans'**
  String get dairy_your_cans;

  /// No description provided for @dairy_recent_transactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get dairy_recent_transactions;

  /// No description provided for @dairy_no_transactions.
  ///
  /// In en, this message translates to:
  /// **'No wallet transactions yet.'**
  String get dairy_no_transactions;

  /// No description provided for @dairy_transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get dairy_transaction;

  /// No description provided for @dairy_can.
  ///
  /// In en, this message translates to:
  /// **'Can'**
  String get dairy_can;

  /// No description provided for @dairy_could_not_load_cart.
  ///
  /// In en, this message translates to:
  /// **'Could not load cart.'**
  String get dairy_could_not_load_cart;

  /// No description provided for @dairy_qty.
  ///
  /// In en, this message translates to:
  /// **'Qty: {value}'**
  String dairy_qty(Object value);

  /// No description provided for @dairy_place_order.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get dairy_place_order;

  /// No description provided for @dairy_order_placed.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get dairy_order_placed;

  /// No description provided for @dairy_checkout_failed.
  ///
  /// In en, this message translates to:
  /// **'Checkout failed.'**
  String get dairy_checkout_failed;

  /// No description provided for @dairy_choose_product.
  ///
  /// In en, this message translates to:
  /// **'Choose a product.'**
  String get dairy_choose_product;

  /// No description provided for @dairy_pick_day.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one delivery day.'**
  String get dairy_pick_day;

  /// No description provided for @dairy_slot_order.
  ///
  /// In en, this message translates to:
  /// **'The delivery window must end after it starts.'**
  String get dairy_slot_order;

  /// No description provided for @dairy_could_not_load_products.
  ///
  /// In en, this message translates to:
  /// **'Could not load products.'**
  String get dairy_could_not_load_products;

  /// No description provided for @dairy_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get dairy_quantity;

  /// No description provided for @dairy_schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get dairy_schedule;

  /// No description provided for @dairy_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dairy_daily;

  /// No description provided for @dairy_alternate_days.
  ///
  /// In en, this message translates to:
  /// **'Alternate days'**
  String get dairy_alternate_days;

  /// No description provided for @dairy_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get dairy_weekly;

  /// No description provided for @dairy_custom_days.
  ///
  /// In en, this message translates to:
  /// **'Custom days'**
  String get dairy_custom_days;

  /// No description provided for @dairy_starts.
  ///
  /// In en, this message translates to:
  /// **'Starts {date}'**
  String dairy_starts(Object date);

  /// No description provided for @dairy_tap_change_date.
  ///
  /// In en, this message translates to:
  /// **'Tap to change the first delivery date'**
  String get dairy_tap_change_date;

  /// No description provided for @dairy_window_start.
  ///
  /// In en, this message translates to:
  /// **'Window start'**
  String get dairy_window_start;

  /// No description provided for @dairy_window_end.
  ///
  /// In en, this message translates to:
  /// **'Window end'**
  String get dairy_window_end;

  /// No description provided for @dairy_delivery_address.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get dairy_delivery_address;

  /// No description provided for @dairy_address_hint.
  ///
  /// In en, this message translates to:
  /// **'Flat, street, locality'**
  String get dairy_address_hint;

  /// No description provided for @dairy_receiver_name.
  ///
  /// In en, this message translates to:
  /// **'Receiver name (optional)'**
  String get dairy_receiver_name;

  /// No description provided for @dairy_receiver_contact.
  ///
  /// In en, this message translates to:
  /// **'Receiver contact (optional)'**
  String get dairy_receiver_contact;

  /// No description provided for @dairy_pay_per_delivery.
  ///
  /// In en, this message translates to:
  /// **'Pay per delivery via'**
  String get dairy_pay_per_delivery;

  /// No description provided for @dairy_payment_gateway.
  ///
  /// In en, this message translates to:
  /// **'Payment gateway'**
  String get dairy_payment_gateway;

  /// No description provided for @dairy_wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get dairy_wallet;

  /// No description provided for @dairy_start_subscription.
  ///
  /// In en, this message translates to:
  /// **'Start subscription'**
  String get dairy_start_subscription;

  /// No description provided for @dairy_subscription_created.
  ///
  /// In en, this message translates to:
  /// **'Subscription created — first delivery per your schedule'**
  String get dairy_subscription_created;

  /// No description provided for @dairy_could_not_create_subscription.
  ///
  /// In en, this message translates to:
  /// **'Could not create subscription.'**
  String get dairy_could_not_create_subscription;

  /// No description provided for @dairy_could_not_load_subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Could not load subscriptions.'**
  String get dairy_could_not_load_subscriptions;

  /// No description provided for @dairy_sku.
  ///
  /// In en, this message translates to:
  /// **'SKU: {value}'**
  String dairy_sku(Object value);

  /// No description provided for @dairy_status_label.
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String dairy_status_label(Object value);

  /// No description provided for @dairy_schedule_label.
  ///
  /// In en, this message translates to:
  /// **'Schedule: {value}'**
  String dairy_schedule_label(Object value);

  /// No description provided for @dairy_quantity_label.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {value}'**
  String dairy_quantity_label(Object value);

  /// No description provided for @dairy_reactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get dairy_reactivate;

  /// No description provided for @dairy_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dairy_cancel;

  /// No description provided for @dairy_subscription_reactivated.
  ///
  /// In en, this message translates to:
  /// **'Subscription reactivated'**
  String get dairy_subscription_reactivated;

  /// No description provided for @dairy_subscription_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled'**
  String get dairy_subscription_cancelled;

  /// No description provided for @dairy_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {value}'**
  String dairy_failed(Object value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
