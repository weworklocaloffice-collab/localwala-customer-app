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
import 'package:user/app/presentation/pages/account/@core/account_view.dart';
import 'package:user/app/presentation/pages/account/account_activity/@core/account_activity_view.dart';
import 'package:user/app/presentation/pages/account/account_activity/search_restaurant_activity_section/search_restaurant_activity_section_view.dart';
import 'package:user/app/presentation/pages/account/account_favourite_order_list/account_favourite_order_list_view.dart';
import 'package:user/app/presentation/pages/account/account_history_list/account_history_list_view.dart';
import 'package:user/app/presentation/pages/account/address_book/@core/address_book_view.dart';
import 'package:user/app/presentation/pages/account/deliveryman_register_request/@core/deliveryman_register_request_view.dart';
import 'package:user/app/presentation/pages/account/deliveryman_register_request/deliveryman_register_request_success/deliveryman_register_request_success_view.dart';
import 'package:user/app/presentation/pages/account/dining_booking/@core/dining_booking_view.dart';
import 'package:user/app/presentation/pages/account/dining_booking/dining_booking_help/dining_booking_help_view.dart';
import 'package:user/app/presentation/pages/account/dining_booking/dining_booking_information/dining_booking_information_view.dart';
import 'package:user/app/presentation/pages/account/dining_booking/dining_booking_search/dining_booking_search_view.dart';
import 'package:user/app/presentation/pages/account/dining_booking/dining_booking_transaction/dining_booking_transaction_view.dart';
import 'package:user/app/presentation/pages/account/edit_user_profile/edit_user_profile_view.dart';
import 'package:user/app/presentation/pages/account/feedback_form/feedback_form_view.dart';
import 'package:user/app/presentation/pages/account/food_subscription_list/@core/food_subscription_list_view.dart';
import 'package:user/app/presentation/pages/account/food_subscription_list/food_subscription_transaction_list/food_subscription_transaction_list_view.dart';
import 'package:user/app/presentation/pages/account/food_subscription_list/purchased_food_subscription_info/purchased_food_subscription_info_view.dart';
import 'package:user/app/presentation/pages/account/hidden_restaurants/hidden_restaurants_view.dart';
import 'package:user/app/presentation/pages/account/order_transaction_list/order_transaction_list_view.dart';
import 'package:user/app/presentation/pages/account/referral_code/referral_code_view.dart';
import 'package:user/app/presentation/pages/account/report_emergency/report_emergency_view.dart';
import 'package:user/app/presentation/pages/account/restaurant_register_request/@core/restaurant_register_request_view.dart';
import 'package:user/app/presentation/pages/account/restaurant_register_request/restaurant_register_request_make_payment/restaurant_register_request_make_payment_view.dart';
import 'package:user/app/presentation/pages/account/restaurant_register_request/restaurant_register_request_success/restaurant_register_request_success_view.dart';
import 'package:user/app/presentation/pages/account/setting_section/@core/setting_section_view.dart';
import 'package:user/app/presentation/pages/account/setting_section/account_setting/@core/account_setting_view.dart';
import 'package:user/app/presentation/pages/account/setting_section/account_setting/account_setting_alert_setting/account_setting_alert_setting_view.dart';
import 'package:user/app/presentation/pages/account/setting_section/account_setting/account_setting_change_email/account_setting_change_email_view.dart';
import 'package:user/app/presentation/pages/account/setting_section/account_setting/account_setting_change_mobile/account_setting_change_mobile_view.dart';
import 'package:user/app/presentation/pages/account/setting_section/account_setting/account_setting_delete_account/@core/account_setting_delete_account_view.dart';
import 'package:user/app/presentation/pages/account/setting_section/account_setting/account_setting_delete_account/account_setting_delete_account_submit/account_setting_delete_account_submit_view.dart';
import 'package:user/app/presentation/pages/real_estate/property_search.dart';
import 'package:user/app/presentation/pages/real_estate/property_detail.dart';
import 'package:user/app/presentation/pages/real_estate/enquiry_form.dart';
import 'package:user/app/presentation/pages/real_estate/my_leads.dart';
import 'package:user/app/presentation/pages/real_estate/lead_detail.dart';
import 'package:user/app/presentation/pages/real_estate/saved_properties.dart';
import 'package:user/app/presentation/pages/real_estate/recently_viewed.dart';
import 'package:user/app/presentation/pages/account/setting_section/account_setting/account_setting_update_password/account_setting_update_password_view.dart';
import 'package:user/app/presentation/pages/account/wallet/@core/wallet_view.dart';
import 'package:user/app/presentation/pages/account/wallet/add_wallet_money/@core/add_wallet_money_view.dart';
import 'package:user/app/presentation/pages/account/wallet/loyalty_points/loyalty_view.dart';
import 'package:user/app/presentation/pages/app_pages/app_pages_view.dart';
import 'package:user/app/presentation/pages/auth/reset_password/@core/reset_password_view.dart';
import 'package:user/app/presentation/pages/cart/checkout/checkout_view.dart';
import 'package:user/app/presentation/pages/cart/make_payments/make_payments_view.dart';
import 'package:user/app/presentation/pages/chats/@core/chat_card_view.dart';
import 'package:user/app/presentation/pages/chats/chat_list/chat_list_view.dart';
import 'package:user/app/presentation/pages/chats/messages/message_view.dart';
import 'package:user/app/presentation/pages/chats/support_chat/support_chat_view.dart';
import 'package:user/app/presentation/pages/dining/@core/dining_view.dart';
import 'package:user/app/presentation/pages/dining/dining_campaigns/dining_campaign_view.dart';
import 'package:user/app/presentation/pages/dining/dining_on_maps/dining_on_maps_view.dart';
import 'package:user/app/presentation/pages/dining/dining_search/dining_search_view.dart';
import 'package:user/app/presentation/pages/dining/filter_dining_with_category/filter_dining_with_category_view.dart';
import 'package:user/app/presentation/pages/dining/restaurant_pre_booking_table/confirm_pre_booking_table/confirm_pre_booking_table_view.dart';
import 'package:user/app/presentation/pages/dining/restaurant_pre_booking_table/make_dining_booking_payments/make_dining_booking_payments_view.dart';
import 'package:user/app/presentation/pages/history/history_detail/history_detail_view.dart';
import 'package:user/app/presentation/pages/home/campaign/food_campaign/food_campaign_view.dart';
import 'package:user/app/presentation/pages/home/campaign/restaurant_campaign/restaurant_campaign_view.dart';
import 'package:user/app/presentation/pages/cart/@core/cart_view.dart';
import 'package:user/app/presentation/pages/extra_pages/connection_view.dart';
import 'package:user/app/presentation/pages/extra_pages/maintenance_view.dart';
import 'package:user/app/presentation/pages/extra_pages/not_found_view.dart';
import 'package:user/app/presentation/pages/extra_pages/server_error_view.dart';
import 'package:user/app/features/social/social_privacy_view.dart';
import 'package:user/app/features/jhatka/jhatka_home_view.dart';
import 'package:user/app/features/jhatka/jhatka_outlet_view.dart';
import 'package:user/app/features/jhatka/jhatka_product_view.dart';
import 'package:user/app/features/jhatka/jhatka_cart_view.dart';
import 'package:user/app/features/jhatka/jhatka_orders_view.dart';
import 'package:user/app/features/jhatka/jhatka_tracking_view.dart';
import 'package:user/app/features/jhatka/jhatka_subscriptions_view.dart';
import 'package:user/app/features/jhatka/jhatka_support_view.dart';
import 'package:user/app/features/stores/stores_home_view.dart';
import 'package:user/app/features/stores/stores_outlet_view.dart';
import 'package:user/app/features/stores/stores_product_view.dart';
import 'package:user/app/features/stores/stores_cart_view.dart';
import 'package:user/app/features/stores/stores_checkout_view.dart';
import 'package:user/app/features/stores/stores_orders_view.dart';
import 'package:user/app/features/stores/stores_tracking_view.dart';
import 'package:user/app/features/stores/stores_support_view.dart';
import 'package:user/app/features/stores/stores_subscriptions_view.dart';
import 'package:user/app/features/stores/stores_search_view.dart';
import 'package:user/app/features/stores/stores_subscribe_view.dart';
import 'package:user/app/presentation/pages/favourite/@core/favourite_view.dart';
import 'package:user/app/presentation/pages/history/@core/history_view.dart';
import 'package:user/app/presentation/pages/reel/@core/reels_view.dart';
import 'package:user/app/presentation/pages/home/@core/home_view.dart';
import 'package:user/app/presentation/pages/home/food_subcriptions_info/@core/food_subscriptions_info_view.dart';
import 'package:user/app/presentation/pages/home/food_subcriptions_info/buy_subscription_package/buy_subscription_package_view.dart';
import 'package:user/app/presentation/pages/home/food_subcriptions_info/make_payments_subscription_package/make_payments_subscription_package_view.dart';
import 'package:user/app/presentation/pages/home/notification_list/notification_list_view.dart';
import 'package:user/app/presentation/pages/home/restaurant/@core/restaurant_view.dart';
import 'package:user/app/presentation/pages/home/restaurant/food_search/food_search_view.dart';
import 'package:user/app/presentation/pages/home/restaurant/restaurant_detail_info/restaurant_detail_info_view.dart';
import 'package:user/app/presentation/pages/dining/restaurant_pre_booking_table/@core/restaurant_pre_booking_table_view.dart';
import 'package:user/app/presentation/pages/home/restaurant/restaurant_tiffin_subscription_packages/restaurant_tiffin_subscription_packages_view.dart';
import 'package:user/app/presentation/pages/home/sort/brands/restaurants_by_brands_view.dart';
import 'package:user/app/presentation/pages/home/sort/categories/@core/restaurants_by_category_view.dart';
import 'package:user/app/presentation/pages/home/sort/cuisine/restaurants_by_cuisine_view.dart';
import 'package:user/app/presentation/pages/location/@core/location_view.dart';
import 'package:user/app/presentation/pages/location/location_maps/location_maps_view.dart';
import 'package:user/app/presentation/pages/location/location_search/location_search_view.dart';
import 'package:user/app/presentation/pages/auth/login/@core/login_view.dart';
import 'package:user/app/presentation/pages/auth/register/register_view.dart';
import 'package:user/app/presentation/pages/home/search/search_view.dart';
import 'package:user/app/presentation/pages/modals/single_food_from_banner_modal/single_food_from_banner_modal_view.dart';
import 'package:user/app/presentation/pages/reviews/products_review/products_review_view.dart';
import 'package:user/app/presentation/pages/reviews/restaurants_review/restaurants_review_view.dart';
import 'package:user/app/presentation/pages/splash/splash_view.dart';
import 'package:user/app/presentation/pages/tabs/tabs_view.dart';
import 'package:user/app/presentation/pages/welcome/welcome_view.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String welcomeRoute = '/welcome';
  static const String maintenanceRoute = '/maintenance';
  static const String internetConnectionRoute = '/internet_connection';
  static const String serverErrorRoute = '/server_error';
  static const String notFoundErrorRoute = '/not_found_error';
  static const String initialLocationRoute = '/location';
  static const String locationSearchRoute = '/location_search';
  static const String locationMapsRoute = '/location_maps';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String resetPasswordRoute = '/reset_password';
  static const String accountRoute = '/account';
  static const String cartRoute = '/cart';
  static const String favouriteRoute = '/favourite';
  static const String historyRoute = '/history';
  static const String historyDetailRoute = '/history_detail';
  static const String homeRoute = '/home';
  static const String diningRoutes = '/dining';
  static const String diningSearchRoutes = '/dining_search';
  static const String bottomTabRoute = '/bottom_tabs';
  static const String appPageRoute = '/app_pages';
  static const String searchRoute = '/search';
  static const String foodCampaignRoute = '/food_campaign';
  static const String restaurantCampaignRoute = '/restaurant_campaign';
  static const String restaurantsByCategoryRoute = '/restaurants_by_category';
  static const String restaurantsByCuisineRoute = '/restaurants_by_cuisine';
  static const String restaurantsByBrandsRoute = '/restaurants_by_brands';
  static const String restaurantRoute = '/restaurant';
  static const String checkoutRoute = '/checkout';
  static const String addressBookRoute = '/addressBook';
  static const String walletRoute = '/wallet';
  static const String addWalletMoneyRoute = '/add_wallet_money';
  static const String loyaltyRoute = '/loyalty';
  static const String makePaymentRoute = '/make_payments';
  static const String chatCardRoute = '/chat_card';
  static const String chatListRoute = '/chat_list';
  static const String messagesRoute = '/messages';
  static const String supportChatRoute = '/support_Chat';
  static const String productReviewRoute = '/products_reviews';
  static const String restaurantReviewRoute = '/restaurant_reviews';
  static const String foodSearchRoute = '/food_search';
  static const String restaurantDetailInfoRoute = '/restaurant_dining_info';
  static const String hiddenRestaurantsRoute = '/hidden_restaurants';
  static const String notificationListRoute = '/notification_list';
  static const String singleFoodFromBannerRoute = '/single_food_from_banner';
  static const String foodSubscriptionInfoRoute = '/food_subcriptions_info';
  static const String buyFoodSubscriptionPackageRoute =
      '/buy_food_subscription_package';
  static const String makeSubscriptionTiffinPackagePaymentRoute =
      '/make_subscription_tiffin_package_payment';
  static const String purchasedSubscriptionListRoute =
      '/purchased_subscription_list';
  static const String purchasedFoodSubscriptionInfoRoute =
      '/purchased_food_subscription_info';
  static const String restaurantPreBookingTableRoute =
      '/restaurant_pre_booking_table';
  static const String restaruantTiffinSubscriptionPackagesRoute =
      '/restaurant_tiffin_subscription_packages';
  static const String diningCampaignRoute = '/dining_campaign';
  static const String diningOnMapRoute = '/dining_on_maps';
  static const String filterDiningWithCategoryRoute =
      '/filter_dining_with_category';
  static const String confirmPreBookingTableRoute =
      '/confirm_pre_booking_table';
  static const String makeDiningBookingPaymentRoute =
      '/make_dining_booking_payment';
  static const String diningBookingRoute = '/dining_bookings';
  static const String diningBookingInformationRoute =
      '/dining_booking_information';
  static const String diningBookingHelpRoute = '/dining_booking_help';
  static const String diningBookingSearchRoute = '/dining_booking_search';
  static const String diningBookingTransactionsRoute =
      '/dining_booking_transactions';
  static const String orderTransactionListRoute = '/order_transaction_list';
  static const String foodSubscriptionTransactionRoute =
      '/food_subscritpion_transactions';
  static const String accountOrderHistoryRoute = '/account_order_history';
  static const String accountFavouriteOrderRoute = '/account_favourite_orders';
  static const String feedbackRoute = '/feedback_form';
  static const String reportEmergencyRoute = '/report_emergency';
  static const String editProfileRoute = '/edit_profile';
  static const String accountActivityRoute = '/account_activity';
  static const String searchRestaurantActivitySectionRoute =
      '/search_restaurant_activity_section';
  static const String referralCodeRoute = '/referral_code';
  static const String deliverymanRegisterRequestRoute =
      '/deliveryman_register_request';
  static const String deliverymanRegisterRequestSuccessRoute =
      '/deliveryman_register_request_success';
  static const String restaurantRegisterRequestRoute =
      '/restaurant_register_request';
  static const String restaurantRegisterPaymentRoute =
      '/restaurant_register_payment';
  static const String restaurantRegisterRequestSuccessRoute =
      '/restaurant_register_request_success';
  static const String settingSectionRoute = '/setting_section';
  static const String appSettingRoute = '/app_settings';
  static const String accountSettingAlertSettingRoute =
      '/account_setting_alert_setting';
  static const String accountSettingChangeEmailRoute =
      '/account_setting_change_email';
  static const String accountSettingChangeMobileRoute =
      '/account_setting_change_mobile';
  static const String accountSettingUpdatePasswordRoute =
      '/account_setting_update_password';
  static const String accountSettingDeleteAccountRoute =
      '/account_setting_delete_account';
  static const String accountSettingDeleteAccountSubmitRoute =
      '/account_setting_delete_account_submit';
  static const String reelsRoute = '/reels';
  static const String socialPrivacyRoute = '/social_privacy';
  // Jhatka Routes //
  static const String jhatkaHomeRoute = '/jhatka/home';
  static const String jhatkaOutletRoute = '/jhatka/outlet';
  static const String jhatkaProductRoute = '/jhatka/product';
  static const String jhatkaCartRoute = '/jhatka/cart';
  static const String jhatkaOrdersRoute = '/jhatka/orders';
  static const String jhatkaTrackingRoute = '/jhatka/tracking';
  static const String jhatkaSubscriptionsRoute = '/jhatka/subscriptions';
  static const String jhatkaSupportRoute = '/jhatka/support';
  // Stores Routes //
  static const String storesHomeRoute = '/stores/home';
  static const String storesOutletRoute = '/stores/outlet';
  static const String storesProductRoute = '/stores/product';
  static const String storesCartRoute = '/stores/cart';
  static const String storesCheckoutRoute = '/stores/checkout';
  static const String storesOrdersRoute = '/stores/orders';
  static const String storesTrackingRoute = '/stores/tracking';
  static const String storesSupportRoute = '/stores/support';
  static const String storesSubscriptionsRoute = '/stores/subscriptions';
  static const String storesSubscribeRoute = '/stores/subscribe';
  static const String storesSearchRoute = '/stores/search';
  // Real Estate Routes //
  static const String reSearchRoute = '/real_estate/search';
  static const String rePropertyDetailRoute = '/real_estate/property_detail';
  static const String reEnquiryRoute = '/real_estate/enquiry';
  static const String reLeadsRoute = '/real_estate/leads';
  static const String reLeadDetailRoute = '/real_estate/lead_detail';
  static const String reSavedPropertiesRoute = '/real_estate/saved_properties';
  static const String reRecentlyViewedRoute = '/real_estate/recently_viewed';

  static Route<dynamic> onGenerateRouted(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case initialRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const SplashScreen();
          },
        );

      case welcomeRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const WelcomeScreen();
          },
        );

      case maintenanceRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return MaintenanceScreen(
              businessEmail: args[0],
              businessMobile: args[1],
            );
          },
        );

      case internetConnectionRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const ConnectionScreen();
          },
        );

      case serverErrorRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const ServerErrorScreen();
          },
        );

      case initialLocationRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const LocationScreen();
          },
        );

      case locationSearchRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const LocationSearchScreen();
          },
        );

      case locationMapsRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return LocationMapScreen(
              latitude: args[0],
              longitude: args[1],
              placeId: args[2],
              title: args[3],
              description: args[4],
            );
          },
        );

      case loginRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        );

      case registerRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const RegisterScreen();
          },
        );

      case resetPasswordRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const ResetPasswordScreen();
          },
        );

      case accountRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AccountScreen();
          },
        );

      case cartRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const CartScreen();
          },
        );

      case favouriteRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const FavouriteScreen();
          },
        );

      case historyRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const HistoryScreen();
          },
        );

      case historyDetailRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return HistoryDetailScreen(id: args[0]);
          },
        );

      case homeRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const HomeScreen();
          },
        );

      case diningRoutes:
        return MaterialPageRoute(
          builder: (context) {
            return const DiningScreen();
          },
        );

      case diningSearchRoutes:
        return MaterialPageRoute(
          builder: (context) {
            return const DiningSearchScreen();
          },
        );

      case searchRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const SearchScreen();
          },
        );

      case bottomTabRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return AppBottomTabScreen(
              tabIndex: args.isNotEmpty && args[0] != null && args[0] != ''
                  ? args[0]
                  : 0,
            );
          },
        );

      case reelsRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const ReelsScreen();
          },
        );

      case socialPrivacyRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const SocialPrivacyView();
          },
        );

      case jhatkaHomeRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const JhatkaHomeView();
          },
        );

      case jhatkaOutletRoute:
        List<dynamic> outletArgs = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return JhatkaOutletView(outletId: outletArgs[0] as String);
          },
        );

      case jhatkaProductRoute:
        List<dynamic> productArgs = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return JhatkaProductView(productId: productArgs[0] as String);
          },
        );

      case jhatkaCartRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const JhatkaCartView();
          },
        );

      case jhatkaOrdersRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const JhatkaOrdersView();
          },
        );

      case jhatkaTrackingRoute:
        List<dynamic> trackingArgs = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return JhatkaTrackingView(orderId: trackingArgs[0] as String);
          },
        );

      case jhatkaSubscriptionsRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const JhatkaSubscriptionsView();
          },
        );

      case jhatkaSupportRoute:
        return MaterialPageRoute(
          builder: (context) {
            final dynamic args = routeSettings.arguments;
            return JhatkaSupportView(
              orderId: args is List && args.isNotEmpty
                  ? args[0] as String?
                  : null,
            );
          },
        );

      case storesHomeRoute:
        return MaterialPageRoute(
          builder: (context) {
            final dynamic homeArgs = routeSettings.arguments;
            return StoresHomeView(
              lat: homeArgs is List && homeArgs.isNotEmpty ? homeArgs[0] as double? : null,
              lng: homeArgs is List && homeArgs.length > 1 ? homeArgs[1] as double? : null,
            );
          },
        );

      case storesOutletRoute:
        List<dynamic> storeArgs = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return StoresOutletView(storeId: storeArgs[0] as String);
          },
        );

      case storesProductRoute:
        List<dynamic> storesProductArgs = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return StoresProductView(
              productId: storesProductArgs[0] as String,
              storeId: storesProductArgs[1] as String,
              chainId: storesProductArgs[2] as String,
            );
          },
        );

      case storesCartRoute:
        List<dynamic> storesCartArgs = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return StoresCartView(
              storeId: storesCartArgs[0] as String,
              chainId: storesCartArgs[1] as String,
            );
          },
        );

      case storesCheckoutRoute:
        List<dynamic> storesCheckoutArgs = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return StoresCheckoutView(
              storeId: storesCheckoutArgs[0] as String,
              chainId: storesCheckoutArgs[1] as String,
            );
          },
        );

      case storesSearchRoute:
        List<dynamic> storesSearchArgs = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return StoresSearchView(
              outlet: storesSearchArgs.isNotEmpty ? storesSearchArgs[0] as String? : null,
            );
          },
        );

      case storesSubscribeRoute:
        List<dynamic> storesSubscribeArgs = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return StoresSubscribeView(
              storeId: storesSubscribeArgs[0] as String,
              items: storesSubscribeArgs[1] as List<Map<String, dynamic>>,
            );
          },
        );

      case storesSubscriptionsRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const StoresSubscriptionsView();
          },
        );

      case storesOrdersRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const StoresOrdersView();
          },
        );

      case storesTrackingRoute:
        List<dynamic> storesTrackingArgs = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return StoresTrackingView(orderId: storesTrackingArgs[0] as String);
          },
        );

      case storesSupportRoute:
        List<dynamic> storesSupportArgs = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return StoresSupportView(orderId: storesSupportArgs[0] as String);
          },
        );

      case appPageRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return AppPageScreen(slug: args[0]);
          },
        );

      case foodCampaignRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return FoodCampaignScreen(id: args[0]);
          },
        );

      case restaurantCampaignRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return RestaurantCampaignScreen(id: args[0]);
          },
        );

      case restaurantsByCategoryRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return RestaurantsByCategoryScreen(
              name: args[0],
              slug: args[1],
              city: args[2],
            );
          },
        );

      case restaurantsByCuisineRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return RestaurantsByCuisineScreen(
              name: args[0],
              slug: args[1],
              city: args[2],
            );
          },
        );

      case restaurantsByBrandsRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return RestaurantsByBrandScreen(
              id: args[0],
              name: args[1],
              cover: args[2],
              slug: args[3],
              city: args[4],
            );
          },
        );

      case restaurantRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return RestaurantScreen(id: args[0], slug: args[1], name: args[2]);
          },
        );

      case checkoutRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return CheckoutScreen(name: args[0], restaurant: args[1]);
          },
        );

      case makePaymentRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return MakePaymentScreen(
              paymentId: args[0],
              codPaymentId: args.length > 1 ? (args[1]?.toString() ?? '') : '',
            );
          },
        );

      case addressBookRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AddressBookScreen();
          },
        );

      case walletRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const WalletScreen();
          },
        );

      case addWalletMoneyRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AddWalletMoneyScreen();
          },
        );

      case loyaltyRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const LoyaltyScreen();
          },
        );

      case chatCardRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const ChatCardScreen();
          },
        );

      case chatListRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const ChatListScreen();
          },
        );

      case messagesRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return MessageScreen(receiverId: args[0], name: args[1]);
          },
        );

      case supportChatRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return SupportChatScreen(type: args[0], typeId: args[1]);
          },
        );

      case productReviewRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return ProductsReviewScreen(
              id: args[0],
              name: args[1],
              rating: args[2],
            );
          },
        );

      case restaurantReviewRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return RestaurantsReviewScreen(
              id: args[0],
              name: args[1],
              ratings: args[2],
            );
          },
        );

      case foodSearchRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return FoodSearchScreen(id: args[0], name: args[1]);
          },
        );

      case restaurantDetailInfoRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return RestaurantDetailInfoScreen(
              id: args[0],
              name: args[1],
              slug: args[2],
              campaignId: args[3],
            );
          },
        );

      case hiddenRestaurantsRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const HiddenRestaurantScreen();
          },
        );

      case notificationListRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const NotificationListScreen();
          },
        );

      case singleFoodFromBannerRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return SingleFoodFromBannerModalScreen(id: args[0], name: args[1]);
          },
        );

      case foodSubscriptionInfoRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return FoodSubscriptionsInfoScreen(id: args[0], name: args[1]);
          },
        );

      case buyFoodSubscriptionPackageRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return BuySubscriptionPackageScreen(id: args[0]);
          },
        );

      case makeSubscriptionTiffinPackagePaymentRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return MakePaymentsSubscriptionpackageScreen(paymentId: args[0]);
          },
        );

      case purchasedSubscriptionListRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const FoodSubscriptionListScreen();
          },
        );

      case purchasedFoodSubscriptionInfoRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return PurchasedFoodSubscriptionInfoScreen(purchaseId: args[0]);
          },
        );

      case restaurantPreBookingTableRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return RestaurantPreBookingTableScreen(
              restaurant: args[0],
              restaurantName: args[1],
              restaurantSlug: args[2],
            );
          },
        );

      case restaruantTiffinSubscriptionPackagesRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return RestaurantTiffinSubscriptionPackageScreen(
              restaurant: args[0],
              restaurantName: args[1],
            );
          },
        );

      case diningCampaignRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return DiningCampaignScreen(id: args[0]);
          },
        );

      case diningOnMapRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const DiningOnMapScreen();
          },
        );

      case filterDiningWithCategoryRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return FilterDiningWithCategoryScreen(
              name: args[0],
              slug: args[1],
              city: args[2],
            );
          },
        );

      case confirmPreBookingTableRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return ConfirmPreBookingTableScreen(
              restaurant: args[0],
              selectedDate: args[1],
              selectedGuest: args[2],
              selectedSlot: args[3],
              selectedCoupon: args[4],
            );
          },
        );

      case makeDiningBookingPaymentRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return MakeDiningBookingPaymentScreen(paymentId: args[0]);
          },
        );

      case diningBookingRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const DiningBookingScreen();
          },
        );

      case diningBookingInformationRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return DiningBookingInformationScreen(bookingId: args[0]);
          },
        );

      case diningBookingHelpRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const DiningBookingHelpScreen();
          },
        );

      case diningBookingSearchRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const DiningBookingSearchScreen();
          },
        );

      case diningBookingTransactionsRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const DiningBookingTransactionScreen();
          },
        );

      case orderTransactionListRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const OrderTransactionListScreen();
          },
        );

      case foodSubscriptionTransactionRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const FoodSubscriptionTransactionListScreen();
          },
        );

      case accountOrderHistoryRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AccountHistoryListScreen();
          },
        );

      case accountFavouriteOrderRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AccountFavouriteOrderListScreen();
          },
        );

      case feedbackRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const FeedbackFormScreen();
          },
        );

      case reportEmergencyRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const ReportEmergencyScreen();
          },
        );

      case editProfileRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const EditUserProfileScreen();
          },
        );

      case accountActivityRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AccountActivityScreen();
          },
        );

      case searchRestaurantActivitySectionRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const SearchRestaurantActivitySectionScreen();
          },
        );

      case referralCodeRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const ReferralCodeScreen();
          },
        );

      case deliverymanRegisterRequestRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const DeliverymanRegisterRequestScreen();
          },
        );

      case deliverymanRegisterRequestSuccessRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const DeliverymanRegisterRequestSuccessView();
          },
        );

      case restaurantRegisterRequestRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const RestaurantRegisterRequestScreen();
          },
        );

      case restaurantRegisterPaymentRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return RestaurantRegisterRequestMakePaymentScreen(
              paymentId: args[0],
            );
          },
        );

      case restaurantRegisterRequestSuccessRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const RestaurantRegisterRequestSuccessScreen();
          },
        );

      case settingSectionRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const SettingSectionScreen();
          },
        );

      case appSettingRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AccountSettingScreen();
          },
        );

      case accountSettingChangeEmailRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AccountSettingChangeEmailScreen();
          },
        );

      case accountSettingUpdatePasswordRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AccountSettingUpdatePasswordScreen();
          },
        );

      case accountSettingChangeMobileRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AccountSettingChangeMobileScreen();
          },
        );

      case accountSettingDeleteAccountRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AccountSettingDeleteAccountScreen();
          },
        );

      case accountSettingAlertSettingRoute:
        return MaterialPageRoute(
          builder: (context) {
            return const AccountSettingAlertSettingScreen();
          },
        );

      case accountSettingDeleteAccountSubmitRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return AccountSettingDeleteAccountSubmitScreen(reason: args[0]);
          },
        );

      // Real Estate Routes //
      case reSearchRoute:
        return MaterialPageRoute(builder: (_) => const PropertySearchScreen());

      case rePropertyDetailRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (_) => PropertyDetailScreen(propertyId: args[0] as String),
        );

      case reEnquiryRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (_) => EnquiryFormScreen(
            propertyId: args[0] as String,
            propertyTitle: args.length > 1 ? args[1] as String : '',
          ),
        );

      case reLeadsRoute:
        return MaterialPageRoute(
          builder: (_) => MyLeadsScreen(
            highlightLeadId: routeSettings.arguments as String?,
          ),
        );

      case reLeadDetailRoute:
        List<dynamic> args = routeSettings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (_) => LeadDetailScreen(leadId: args[0] as String),
        );

      case reSavedPropertiesRoute:
        return MaterialPageRoute(builder: (_) => const SavedPropertiesScreen());

      case reRecentlyViewedRoute:
        return MaterialPageRoute(builder: (_) => const RecentlyViewedScreen());

      default:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
    }
  }
}
