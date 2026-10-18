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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/otp_modal_response_model.dart';
import 'package:user/app/core/models/social_account_verification_modal_response_model.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/pages/auth/login/login_options/email_otp/bloc/login_with_email_otp_bloc.dart';
import 'package:user/app/presentation/pages/modals/otp_modal/otp_modal_view.dart';
import 'package:user/app/presentation/pages/modals/social_account_verification_modal/social_account_verification_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class LoginWithEmailOtpScreen extends StatelessWidget {
  const LoginWithEmailOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => LoginWithEmailOtpBloc()..add(LoginWithEmailOtpInitialEvent()), child: LoginWithEmailOtpView());
  }
}

class LoginWithEmailOtpView extends StatefulWidget {
  const LoginWithEmailOtpView({super.key});

  @override
  State<LoginWithEmailOtpView> createState() => _LoginWithEmailOtpViewState();
}

class _LoginWithEmailOtpViewState extends State<LoginWithEmailOtpView> {
  final _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        context.read<LoginWithEmailOtpBloc>().add(LoginWithEmailOtpUnfocusedEvent());
      }
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = context.select((LoginWithEmailOtpBloc bloc) => bloc.state.isValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<LoginWithEmailOtpBloc, LoginWithEmailOtpState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode, fromAuth: true);
        } else if (state.status.isSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [0]);
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
                      mode: state.verification.mode!,
                    );
                  },
                  fullscreenDialog: true,
                ),
              )
              .then((value) {
                if (!context.mounted) return;
                OTPModalResponse otpModalResponse = OTPModalResponse.fromJson(value);
                if (otpModalResponse.action! && otpModalResponse.status!) {
                  context.read<LoginWithEmailOtpBloc>().add(LoginWithEmailOtpLoginNowEvent(otp: otpModalResponse.otp!));
                }
              });
        } else if (state.status.isLocation) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.initialLocationRoute, (Route<dynamic> route) => false);
        } else if (state.status.isSocialVerification) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            builder: (BuildContext context) {
              return FractionallySizedBox(
                heightFactor: 0.7,
                child: SocialAccountVerificationModalScreen(firstName: state.unVerifiedAccountResponseModel.firstName!, lastName: state.unVerifiedAccountResponseModel.lastName!),
              );
            },
          ).then((value) {
            if (!context.mounted) return;
            if (value != null && value.toString().isNotEmpty) {
              SocialAccountVerificationModalResponseModel socialDetail = SocialAccountVerificationModalResponseModel.fromJson(value);
              if (socialDetail.success!) {
                if (state.unVerifiedAccountResponseModel.provider! == 'google') {
                  context.read<LoginWithEmailOtpBloc>().add(LoginWithEmailOtpRegisterGoogleAccountEvent(model: socialDetail));
                } else if (state.unVerifiedAccountResponseModel.provider! == 'facebook') {
                  context.read<LoginWithEmailOtpBloc>().add(LoginWithEmailOtpRegisterFacebookAccountEvent(model: socialDetail));
                }
              }
            }
          });
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: AbsorbPointer(
            absorbing: state.status.isInProgress ? true : false,
            child: Padding(
              padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${translate.welcome_to} ${Environments.appName}", textAlign: TextAlign.center, style: kAppLblLargeFontBold(context)),
                  kAppSpacerVertical(height: 10),
                  Text(translate.email_otp_sub_title, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
                  kAppSpacerVertical(height: 40),
                  TextFormField(
                    initialValue: state.email.value,
                    focusNode: _emailFocusNode,
                    decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.email_outlined), lblText: translate.email, errText: state.email.displayError != null ? translate.form_required : null),
                    style: kAppLblSmallFontMedium(context),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => context.read<LoginWithEmailOtpBloc>().add(LoginWithEmailOtpChangedEvent(email: value)),
                    textInputAction: TextInputAction.next,
                  ),
                  kAppSpacerVertical(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: Theme.of(context).primaryColor,
                          title: Text(translate.remember_me, style: kAppLblMediumFontRegular(context)),
                          value: state.remember.value,
                          onChanged: (value) => context.read<LoginWithEmailOtpBloc>().add(LoginWithEmailOtpRememberChangedEvent(checked: value!)),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    ],
                  ),
                  kAppSpacerVertical(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isValid ? () => context.read<LoginWithEmailOtpBloc>().add(LoginWithEmailOtpFormSubmitEvent()) : null,
                      style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                      child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.verify),
                    ),
                  ),
                  Column(
                    children: [
                      kAppSpacerVertical(height: 20),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: translate.dont_have_account,
                            style: kAppLblMediumFontRegular(context),
                            children: <TextSpan>[
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: translate.register,
                                style: kAppLblMediumFontBold(context, color: 'primary'),
                                recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).pushNamed(AppRouter.registerRoute),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  kAppSpacerVertical(height: 20),
                  state.appleSignInEnabled || state.googleSignInEnabled || state.facebookSignInEnabled
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [Text(translate.sign_in_social_account, textAlign: TextAlign.center, style: kAppLblMediumFontSemiBold(context))],
                        )
                      : const SizedBox(),
                  kAppSpacerVertical(height: 20),
                  state.appleSignInEnabled
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton.icon(
                            icon: Image.asset(AssetsUrl.imageURL.appleSocialLogin, width: 15, height: 15),
                            label: Text(translate.apple_login, style: kAppLblMediumFontSemiBold(context)),
                            onPressed: () {},
                            style: kAppElevatedButtonOutlineStyle(
                              context,
                              disabledColor: Theme.of(context).disabledColor,
                              bgColor: ThemeProvider.transparentColor,
                              foreColor: Theme.of(context).canvasColor,
                              borderColor: Theme.of(context).canvasColor,
                              height: 50,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  state.appleSignInEnabled ? kAppSpacerVertical(height: 10) : const SizedBox(),
                  state.googleSignInEnabled
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton.icon(
                            icon: state.googleSocialLoginClicked ? Icon(Icons.refresh) : Image.asset(AssetsUrl.imageURL.googleSocialLogin, width: 15, height: 15),
                            label: Text(state.googleSocialLoginClicked ? translate.please_wait_social : translate.google_login, style: kAppLblMediumFontSemiBold(context)),
                            onPressed: () => context.read<LoginWithEmailOtpBloc>().add(LoginWithEmailOtpGoogleAccountEvent()),
                            style: kAppElevatedButtonOutlineStyle(
                              context,
                              disabledColor: Theme.of(context).disabledColor,
                              bgColor: ThemeProvider.transparentColor,
                              foreColor: Theme.of(context).canvasColor,
                              borderColor: Theme.of(context).canvasColor,
                              height: 50,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  state.googleSignInEnabled ? kAppSpacerVertical(height: 10) : const SizedBox(),
                  state.facebookSignInEnabled
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton.icon(
                            icon: state.facebookSocialLoginClicked ? Icon(Icons.refresh) : Image.asset(AssetsUrl.imageURL.facebookSocialLogin, width: 15, height: 15),
                            label: Text(state.facebookSocialLoginClicked ? translate.please_wait_social : translate.facebook_login, style: kAppLblMediumFontSemiBold(context)),
                            onPressed: () => context.read<LoginWithEmailOtpBloc>().add(LoginWithEmailOtpFacebookAccountEvent()),
                            style: kAppElevatedButtonOutlineStyle(
                              context,
                              disabledColor: Theme.of(context).disabledColor,
                              bgColor: ThemeProvider.transparentColor,
                              foreColor: Theme.of(context).canvasColor,
                              borderColor: Theme.of(context).canvasColor,
                              height: 50,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

