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
import 'package:user/app/presentation/pages/account/setting_section/account_setting/account_setting_update_password/bloc/account_setting_update_password_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AccountSettingUpdatePasswordScreen extends StatelessWidget {
  const AccountSettingUpdatePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => AccountSettingUpdatePasswordBloc()..add(AccountSettingUpdatePasswordInitialEvent()), child: const AccountSettingUpdatePasswordView());
  }
}

class AccountSettingUpdatePasswordView extends StatefulWidget {
  const AccountSettingUpdatePasswordView({super.key});

  @override
  State<AccountSettingUpdatePasswordView> createState() => _AccountSettingUpdatePasswordViewState();
}

class _AccountSettingUpdatePasswordViewState extends State<AccountSettingUpdatePasswordView> {
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordOneVisible = false;
  bool _passwordTwoVisible = false;

  @override
  void initState() {
    super.initState();

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        context.read<AccountSettingUpdatePasswordBloc>().add(AccountSettingUpdatePasswordPasswordUnfocusedEvent());
      }
    });

    _confirmPasswordFocusNode.addListener(() {
      if (!_confirmPasswordFocusNode.hasFocus) {
        context.read<AccountSettingUpdatePasswordBloc>().add(AccountSettingUpdatePasswordConfirmPasswordUnfocusedEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordValid = context.select((AccountSettingUpdatePasswordBloc bloc) => bloc.state.isPasswordValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<AccountSettingUpdatePasswordBloc, AccountSettingUpdatePasswordState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode, fromAuth: false);
        } else if (state.status.isSuccess) {
          showSuccessDialog(context, translate.password_updated).then((value) {
            if (!context.mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
          });
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isInProgress ? true : false,
          child: Scaffold(
            appBar: AppBar(title: Text(translate.update_password), scrolledUnderElevation: 0),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate.re_auth_required, style: kAppLblMediumFontBold(context)),
                  kAppSpacerVertical(height: 10),
                  Text(translate.relogin_after_password_update, style: kAppLblTinyFontRegular(context)),
                  kAppSpacerVertical(height: 40),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    decoration: kAppInputDecoration(
                      context,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      lblText: translate.password,
                      errText: state.password.displayError != null ? translate.form_valid_password_required : null,
                      suffixIcon: Icon(_passwordOneVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      haveSuffixIcon: true,
                      onPressed: () => setState(() {
                        _passwordOneVisible = !_passwordOneVisible;
                      }),
                    ),
                    style: kAppLblSmallFontMedium(context),
                    obscureText: !_passwordOneVisible,
                    onChanged: (value) => context.read<AccountSettingUpdatePasswordBloc>().add(AccountSettingUpdatePasswordPasswordChangedEvent(password: value)),
                    textInputAction: TextInputAction.next,
                  ),
                  kAppSpacerVertical(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    decoration: kAppInputDecoration(
                      context,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      lblText: translate.confirm_password,
                      errText: state.confirmedPassword.displayError != null ? translate.form_required : null,
                      suffixIcon: Icon(_passwordTwoVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      haveSuffixIcon: true,
                      onPressed: () => setState(() {
                        _passwordTwoVisible = !_passwordTwoVisible;
                      }),
                    ),
                    style: kAppLblSmallFontMedium(context),
                    obscureText: !_passwordTwoVisible,
                    onChanged: (value) => context.read<AccountSettingUpdatePasswordBloc>().add(AccountSettingUpdatePasswordConfirmPasswordChangedEvent(password: value)),
                    textInputAction: TextInputAction.done,
                  ),
                  kAppSpacerVertical(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPasswordValid ? () => context.read<AccountSettingUpdatePasswordBloc>().add(AccountSettingUpdatePasswordSubmitEvent()) : null,
                      style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                      child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.update_password),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
// Done //
