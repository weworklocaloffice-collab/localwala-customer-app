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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/app/presentation/pages/account/@core/bloc/account_bloc.dart';
import 'package:user/app/presentation/pages/account/edit_user_profile/bloc/edit_user_profile_bloc.dart';
import 'package:user/app/presentation/pages/modals/language_translation_modal/language_translation_modal_view.dart';
import 'package:user/app/presentation/styles/app_localization/app_localization_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/loader_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/theme_bloc/theme_bloc.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EditUserProfileBloc, EditUserProfileState>(
          listener: (context, state) {
            if (state.status.isSubmitSuccess) {
              context.read<AccountBloc>().add(AccountInitialEvent());
            }
          },
        ),
      ],
      child: const AccountView(),
    );
  }
}

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(AccountInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    super.build(context);
    return BlocConsumer<AccountBloc, AccountState>(
      listener: (context, state) {
        if (state.status.isLogoutStart) {
          LoaderService.showLoader(context, msg: translate.please_wait);
        } else if (state.status.isLogoutSuccess) {
          LoaderService.hideLoder(context);
          context.read<AccountBloc>().add(AccountInitialEvent());
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
        } else if (state.status.isLogoutFailed) {
          LoaderService.hideLoder(context);
          context.read<AccountBloc>().add(AccountInitialEvent());
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            bottom: PreferredSize(
              preferredSize: state.isAuthorized ? const Size.fromHeight(55) : const Size.fromHeight(0),
              child: state.isAuthorized ? CustomerProfileSection(userCover: state.userCover, userName: state.userName, userEmail: state.userEmail, activityLbl: translate.view_activity) : const SizedBox(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SettingsSection(
                  title: translate.profile,
                  children: [
                    SettingsItem(
                      icon: Icons.account_circle_outlined,
                      label: state.isAuthorized ? translate.your_profile : translate.sign_in_sign_up,
                      onTap: () {
                        if (state.isAuthorized) {
                          Navigator.of(context).pushNamed(AppRouter.editProfileRoute);
                        } else {
                          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
                        }
                      },
                    ),
                    SettingsItem(icon: Icons.attach_money, label: translate.wallet, onTap: () => Navigator.of(context).pushNamed(AppRouter.walletRoute)),
                    SettingsItem(icon: Icons.card_giftcard, label: translate.loyalty_points, onTap: () => Navigator.of(context).pushNamed(AppRouter.loyaltyRoute)),
                    SettingsItem(icon: Icons.chat_outlined, label: translate.chat_messages, onTap: () => Navigator.of(context).pushNamed(AppRouter.chatCardRoute)),
                    SettingsItem(
                      icon: Icons.brightness_4,
                      label: translate.light_mode,
                      showChevron: false,
                      trailing: GestureDetector(
                        onTap: () {
                          context.read<AccountBloc>().add(AccountChangeThemeEvent());
                          context.read<ThemeBloc>().add(ChangeThemeEvent());
                        },
                        child: Icon(state.lightMode ? Icons.toggle_off_outlined : Icons.toggle_on_outlined, size: 25, color: Theme.of(context).canvasColor),
                      ),
                    ),
                  ],
                ),
                SettingsSection(
                  title: translate.food_orders,
                  children: [
                    SettingsItem(icon: Icons.fastfood_outlined, label: translate.your_orders, onTap: () => Navigator.of(context).pushNamed(AppRouter.accountOrderHistoryRoute)),
                    SettingsItem(icon: Icons.favorite_outline_outlined, label: translate.favourite_orders, onTap: () => Navigator.of(context).pushNamed(AppRouter.accountFavouriteOrderRoute)),
                    SettingsItem(icon: Icons.location_history_outlined, label: translate.address_book, onTap: () => Navigator.of(context).pushNamed(AppRouter.addressBookRoute)),
                    SettingsItem(icon: Icons.visibility_off_outlined, label: translate.hidden_restaurants, onTap: () => Navigator.of(context).pushNamed(AppRouter.hiddenRestaurantsRoute)),
                    SettingsItem(icon: Icons.calendar_month_outlined, label: translate.tiffin_subscription_packages, onTap: () => Navigator.of(context).pushNamed(AppRouter.purchasedSubscriptionListRoute)),
                  ],
                ),
                SettingsSection(
                  title: translate.dining,
                  children: [
                    SettingsItem(icon: Icons.table_bar_outlined, label: translate.your_table_bookings, onTap: () => Navigator.of(context).pushNamed(AppRouter.diningBookingRoute)),
                    SettingsItem(
                      icon: Icons.chat_outlined,
                      label: translate.dining_help,
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['dining-frequently-asked-questions']),
                    ),
                    SettingsItem(
                      icon: Icons.question_answer_outlined,
                      label: translate.frequently_asked_questions,
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['frequently-asked-questions']),
                    ),
                  ],
                ),
                SettingsSection(
                  title: translate.transactions,
                  children: [
                    SettingsItem(icon: Icons.trending_up, label: translate.order_transactions, onTap: () => Navigator.of(context).pushNamed(AppRouter.orderTransactionListRoute)),
                    SettingsItem(icon: Icons.trending_up, label: translate.tiffin_subscription_transactions, onTap: () => Navigator.of(context).pushNamed(AppRouter.foodSubscriptionTransactionRoute)),
                    SettingsItem(icon: Icons.trending_up, label: translate.dining_transactions, onTap: () => Navigator.of(context).pushNamed(AppRouter.diningBookingTransactionsRoute)),
                  ],
                ),
                SettingsSection(
                  title: translate.join_us,
                  children: [
                    if (state.vendorRegisterEnable) SettingsItem(icon: Icons.restaurant_menu, label: translate.join_as_restaurant, onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantRegisterRequestRoute)),
                    if (state.driverRegisterEnable) SettingsItem(icon: Icons.pedal_bike_outlined, label: translate.join_as_deliveryman, onTap: () => Navigator.of(context).pushNamed(AppRouter.deliverymanRegisterRequestRoute)),
                    SettingsItem(icon: Icons.card_giftcard, label: translate.referral_code, onTap: () => Navigator.of(context).pushNamed(AppRouter.referralCodeRoute)),
                  ],
                ),
                SettingsSection(
                  title: translate.more,
                  children: [
                    SettingsItem(
                      icon: Icons.translate_outlined,
                      label: translate.choose_language,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: false,
                          enableDrag: false,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          builder: (BuildContext context) {
                            return FractionallySizedBox(heightFactor: 0.7, child: LanguageTranslationModalScreen(selected: state.locale));
                          },
                        ).then((value) {
                          if (!context.mounted) return;
                          if (value != null) {
                            if (value.toString() != state.locale) {
                              context.read<AppLocalizationBloc>().add(ChangeAppLocalizationEvent(defaultLanguage: value));
                              Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [4]);
                            }
                          }
                        });
                      },
                    ),
                    SettingsItem(
                      icon: Icons.info_outline,
                      label: translate.about,
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['about-us']),
                    ),
                    SettingsItem(
                      icon: Icons.privacy_tip_outlined,
                      label: translate.privacy_policy,
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['privacy-policy']),
                    ),
                    SettingsItem(
                      icon: Icons.text_format_sharp,
                      label: translate.terms_and_conditions,
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['terms-and-conditions']),
                    ),
                    SettingsItem(
                      icon: Icons.replay_circle_filled_rounded,
                      label: translate.refund_policy,
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['refund-policy']),
                    ),
                    SettingsItem(
                      icon: Icons.local_shipping_outlined,
                      label: translate.shipping_policy,
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['shipping-policy']),
                    ),
                    SettingsItem(
                      icon: Icons.cancel_outlined,
                      label: translate.cancellation_policy,
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['cancellation-policy']),
                    ),
                    SettingsItem(
                      icon: Icons.help_outline,
                      label: translate.help,
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['help']),
                    ),
                    SettingsItem(
                      icon: Icons.format_quote_rounded,
                      label: translate.frequently_asked_questions,
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['frequently-asked-questions']),
                    ),
                    SettingsItem(icon: Icons.feedback_outlined, label: translate.send_feedback, onTap: () => Navigator.of(context).pushNamed(AppRouter.feedbackRoute)),
                    SettingsItem(icon: Icons.report_gmailerrorred, label: translate.report_a_safety_emergency, onTap: () => Navigator.of(context).pushNamed(AppRouter.reportEmergencyRoute)),
                    SettingsItem(icon: Icons.settings_outlined, label: translate.settings, onTap: () => Navigator.of(context).pushNamed(AppRouter.settingSectionRoute)),
                    if (state.isAuthorized) SettingsItem(icon: Icons.power_settings_new_outlined, label: translate.log_out, onTap: () => context.read<AccountBloc>().add(AccountLogoutEvent())),
                  ],
                ),
                Column(
                  children: [
                    const Divider(height: 1, thickness: 0.5, color: ThemeProvider.greyColorBorder),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: CacheNetworkImageWidget(width: 120.0, height: 40.0, imageUrl: state.appLogo, fit: BoxFit.contain),
                          ),
                          kAppSpacerVertical(height: 12),
                          Text(
                            "v${state.currentVersion}",
                            style: kAppLblTinyFontRegular(context).copyWith(
                              color: ThemeProvider.greyColorText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CustomerProfileSection extends StatelessWidget {
  final String userCover;
  final String userName;
  final String userEmail;
  final String activityLbl;
  const CustomerProfileSection({super.key, required this.userCover, required this.userName, required this.userEmail, required this.activityLbl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: ThemeProvider.scaffoldPadding),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: ThemeProvider.scaffoldPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Theme.of(context).disabledColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(50.0)),
            child: CacheNetworkImageWidget(width: 50.0, height: 50.0, imageUrl: userCover),
          ),
          kAppSpacerHorizontal(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: kAppLblMediumFontBold(context)),
              kAppSpacerVertical(height: 2),
              Text(userEmail, style: kAppLblTinyFontRegular(context)),
              kAppSpacerVertical(height: 2),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRouter.accountActivityRoute),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(activityLbl, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                    kAppSpacerHorizontal(width: 5),
                    Icon(Icons.chevron_right_outlined, size: 12, color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SettingsSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Theme.of(context).disabledColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text(title, style: kAppLblMediumFontSemiBoldWhite(context))],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool showChevron;
  final Widget? trailing;

  const SettingsItem({super.key, required this.icon, required this.label, this.onTap, this.showChevron = true, this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).disabledColor, width: 1.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(50.0)),
                  child: Center(child: Icon(icon, size: 13, color: Theme.of(context).canvasColor)),
                ),
                kAppSpacerHorizontal(width: 10),
                Text(label, style: kAppLblMediumFontRegular(context)),
              ],
            ),
            trailing ?? (showChevron ? Icon(Icons.chevron_right, size: 13, color: Theme.of(context).canvasColor) : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
// Done //
