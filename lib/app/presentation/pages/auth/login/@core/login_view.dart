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
import 'package:user/app/env.dart';
import 'package:user/app/presentation/pages/auth/login/@core/bloc/login_bloc.dart';
import 'package:user/app/presentation/pages/auth/login/login_options/email_otp/email_otp_login_view.dart';
import 'package:user/app/presentation/pages/auth/login/login_options/email_password/email_password_login_view.dart';
import 'package:user/app/presentation/pages/auth/login/login_options/phone_otp/phone_otp_login_view.dart';
import 'package:user/app/presentation/pages/auth/login/login_options/phone_password/phone_password_login_view.dart';
import 'package:user/app/presentation/pages/modals/language_translation_modal/language_translation_modal_view.dart';
import 'package:user/app/presentation/styles/app_localization/app_localization_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/loader_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/theme_bloc/theme_bloc.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => LoginBloc()..add(LoginInitialEvent()), child: const LoginView());
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isHome) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [0]);
        } else if (state.status.isLocation) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.initialLocationRoute, (Route<dynamic> route) => false);
        } else if (state.status.isGuestRegisterStart) {
          LoaderService.showLoader(context, msg: translate.please_wait);
        } else if (state.status.isGuestRegisterFailed) {
          LoaderService.hideLoder(context);
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode, fromAuth: true);
        } else if (state.status.isGuestRegisterHome) {
          LoaderService.hideLoder(context);
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [0]);
        } else if (state.status.isGuestRegisterLocation) {
          LoaderService.hideLoder(context);
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.initialLocationRoute, (Route<dynamic> route) => false);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => context.read<ThemeBloc>().add(ChangeThemeEvent()),
              icon: Icon(Icons.light_mode, color: Theme.of(context).iconTheme.color),
            ),
            title: Text(translate.login),
            actions: <Widget>[
              AppSupportedLanguagesModel.languages.isNotEmpty && AppSupportedLanguagesModel.languages.length > 1
                  ? IconButton(
                      onPressed: () {
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
                              context.read<LoginBloc>().add(LoginLanguageChangeEvent(locale: value));
                            }
                          }
                        });
                      },
                      icon: FaIcon(FontAwesomeIcons.language, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).iconTheme.color),
                    )
                  : const SizedBox(),
              TextButton(
                onPressed: () => context.read<LoginBloc>().add(LoginSkipEvent()),
                child: Text(translate.skip, style: kAppLblMediumFontBold(context)),
              ),
            ],
          ),
          bottomNavigationBar: state.guestCheckout == true
              ? SafeArea(
                  child: SizedBox(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: ThemeProvider.scaffoldPadding),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.read<LoginBloc>().add(LoginGuestAccountEvent()),
                                style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50),
                                child: Text(translate.continue_as_guest),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.userLoginWith == 'email_password') ...[
                  LoginWithEmailPasswordScreen(),
                ] else if (state.userLoginWith == 'phone_password') ...[
                  LoginWithPhonePasswordScreen(),
                ] else if (state.userLoginWith == 'phone_otp') ...[
                  LoginWithPhoneOtpScreen(),
                ] else if (state.userLoginWith == 'email_otp') ...[
                  LoginWithEmailOtpScreen(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
// Done //
