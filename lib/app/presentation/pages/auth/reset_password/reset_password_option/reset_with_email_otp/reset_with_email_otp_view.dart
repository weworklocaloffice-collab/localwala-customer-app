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
import 'package:user/app/core/models/otp_modal_response_model.dart';
import 'package:user/app/presentation/pages/auth/reset_password/reset_password_option/reset_with_email_otp/bloc/reset_with_email_otp_bloc.dart';
import 'package:user/app/presentation/pages/modals/otp_modal/otp_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ResetWithEmailOtpScreen extends StatelessWidget {
  const ResetWithEmailOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ResetWithEmailOtpBloc()..add(ResetWithEmailOtpInitialEvent()), child: const ResetWithEmailOtpView());
  }
}

class ResetWithEmailOtpView extends StatefulWidget {
  const ResetWithEmailOtpView({super.key});

  @override
  State<ResetWithEmailOtpView> createState() => _ResetWithEmailOtpViewState();
}

class _ResetWithEmailOtpViewState extends State<ResetWithEmailOtpView> {
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordOneVisible = false;
  bool _passwordTwoVisible = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        context.read<ResetWithEmailOtpBloc>().add(ResetWithOptionOneEmailUnfocusedEvent());
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        context.read<ResetWithEmailOtpBloc>().add(ResetWithOptionOnePasswordUnfocusedEvent());
      }
    });

    _confirmPasswordFocusNode.addListener(() {
      if (!_confirmPasswordFocusNode.hasFocus) {
        context.read<ResetWithEmailOtpBloc>().add(ResetWithOptionOneConfirmPasswordUnfocusedEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEmailValid = context.select((ResetWithEmailOtpBloc bloc) => bloc.state.isEmailValid);
    final isPasswordValid = context.select((ResetWithEmailOtpBloc bloc) => bloc.state.isPasswordValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<ResetWithEmailOtpBloc, ResetWithEmailOtpState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode, fromAuth: true);
        } else if (state.status.isVerify) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return OtpModalScreen(
                      providerName: state.verification.provider!,
                      sentTo: state.email.value.toString(),
                      providerId: state.verification.id!,
                      otpLength: state.verification.otpLength!,
                      canResendOTP: state.verification.canResendOtp!,
                      mode: 'email_otp',
                    );
                  },
                  fullscreenDialog: true,
                ),
              )
              .then((value) {
                if (!context.mounted) return;
                OTPModalResponse otpModalResponse = OTPModalResponse.fromJson(value);
                if (otpModalResponse.action! && otpModalResponse.status!) {
                  context.read<ResetWithEmailOtpBloc>().add(ResetWithOptionOneVerificationSuccessEvent());
                }
              });
        } else if (state.status.isSuccess) {
          showSuccessDialog(context, translate.password_updated).then((value) {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop();
          });
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isInProgress ? true : false,
          child: Padding(
            padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (state.isVerified == false) ...[
                  Text(translate.forgot_your_password, textAlign: TextAlign.center, style: kAppLblLargeFontBold(context)),
                  kAppSpacerVertical(height: 10),
                  Text(translate.email_otp_verification_sub_title, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
                  kAppSpacerVertical(height: 40),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.email_outlined), lblText: translate.email, errText: state.email.displayError != null ? translate.form_required : null),
                    style: kAppLblSmallFontMedium(context),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => context.read<ResetWithEmailOtpBloc>().add(ResetWithOptionOneEmailChangedEvent(email: value)),
                    textInputAction: TextInputAction.next,
                  ),
                  kAppSpacerVertical(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isEmailValid ? () => context.read<ResetWithEmailOtpBloc>().add(ResetWithOptionOneSendVerificationMailEvent()) : null,
                      style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                      child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.verify),
                    ),
                  ),
                ] else if (state.isVerified == true) ...[
                  Text(translate.update_password, textAlign: TextAlign.center, style: kAppLblLargeFontBold(context)),
                  kAppSpacerVertical(height: 10),
                  Text(translate.reset_verified_identity, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
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
                    onChanged: (value) => context.read<ResetWithEmailOtpBloc>().add(ResetWithOptionOnePasswordChangedEvent(password: value)),
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
                      errText: state.confirmedPassword.displayError != null ? translate.form_valid_confirm_password_required : null,
                      suffixIcon: Icon(_passwordTwoVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      haveSuffixIcon: true,
                      onPressed: () => setState(() {
                        _passwordTwoVisible = !_passwordTwoVisible;
                      }),
                    ),
                    style: kAppLblSmallFontMedium(context),
                    obscureText: !_passwordTwoVisible,
                    onChanged: (value) => context.read<ResetWithEmailOtpBloc>().add(ResetWithOptionOneConfirmPasswordChangedEvent(password: value)),
                    textInputAction: TextInputAction.done,
                  ),
                  kAppSpacerVertical(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPasswordValid ? () => context.read<ResetWithEmailOtpBloc>().add(ResetWithOptionOneUpdatePasswordEvent()) : null,
                      style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                      child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.update_password),
                    ),
                  ),
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
