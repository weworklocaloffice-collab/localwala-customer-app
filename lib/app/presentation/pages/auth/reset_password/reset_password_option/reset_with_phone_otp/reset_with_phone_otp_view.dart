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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/app/core/models/country_code_modal_response_model.dart';
import 'package:user/app/core/models/firebase_sms_otp_verification_response_model.dart';
import 'package:user/app/core/models/otp_modal_response_model.dart';
import 'package:user/app/core/models/web_sms_otp_verification_response_model.dart';
import 'package:user/app/presentation/pages/auth/reset_password/reset_password_option/reset_with_phone_otp/bloc/reset_with_phone_otp_bloc.dart';
import 'package:user/app/presentation/pages/modals/country_modal/country_modal_view.dart';
import 'package:user/app/presentation/pages/modals/firebase_verification_modal/firebase_verification_modal_view.dart';
import 'package:user/app/presentation/pages/modals/otp_modal/otp_modal_view.dart';
import 'package:user/app/presentation/pages/modals/web_otp_modal/web_otp_modal.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ResetWithPhoneOtpScreen extends StatelessWidget {
  const ResetWithPhoneOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ResetWithPhoneOtpBloc()..add(ResetWithPhoneInitialEvent()), child: const ResetWithPhoneOtpView());
  }
}

class ResetWithPhoneOtpView extends StatefulWidget {
  const ResetWithPhoneOtpView({super.key});

  @override
  State<ResetWithPhoneOtpView> createState() => _ResetWithPhoneOtpViewState();
}

class _ResetWithPhoneOtpViewState extends State<ResetWithPhoneOtpView> {
  final _countryCodeFocusNode = FocusNode();
  final _mobileNumberFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordOneVisible = false;
  bool _passwordTwoVisible = false;
  @override
  void initState() {
    super.initState();
    _countryCodeFocusNode.addListener(() {
      if (!_countryCodeFocusNode.hasFocus) {
        context.read<ResetWithPhoneOtpBloc>().add(ResetWithPhoneTypeTwoCountryCodeUnfocusedEvent());
      }
    });

    _mobileNumberFocusNode.addListener(() {
      if (!_mobileNumberFocusNode.hasFocus) {
        context.read<ResetWithPhoneOtpBloc>().add(ResetWithPhoneTypeTwoMobileNumberUnfocusedEvent());
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        context.read<ResetWithPhoneOtpBloc>().add(ResetWithOptionTwoPasswordUnfocusedEvent());
      }
    });

    _confirmPasswordFocusNode.addListener(() {
      if (!_confirmPasswordFocusNode.hasFocus) {
        context.read<ResetWithPhoneOtpBloc>().add(ResetWithOptionTwoConfirmPasswordUnfocusedEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPhoneValid = context.select((ResetWithPhoneOtpBloc bloc) => bloc.state.isPhoneValid);
    final isPasswordValid = context.select((ResetWithPhoneOtpBloc bloc) => bloc.state.isPasswordValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<ResetWithPhoneOtpBloc, ResetWithPhoneOtpState>(
      listener: (context, state) {
        if (state.status.isLoaded) {
          _countryCodeController.text = '${state.flag} (${state.countryCode.value})';
        } else if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode, fromAuth: true);
        } else if (state.status.isSuccess) {
          showSuccessDialog(context, translate.password_updated).then((value) {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop();
          });
        } else if (state.status.isVerify) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return OtpModalScreen(
                      providerName: state.verification.provider!,
                      sentTo: '${state.countryCode.value.toString()}${state.mobileNumber.value.toString()}',
                      providerId: state.verification.id!,
                      otpLength: state.verification.otpLength!,
                      canResendOTP: state.verification.canResendOtp!,
                      mode: 'phone_otp',
                    );
                  },
                  fullscreenDialog: true,
                ),
              )
              .then((value) {
                if (!context.mounted) return;
                OTPModalResponse otpModalResponse = OTPModalResponse.fromJson(value);
                if (otpModalResponse.action! && otpModalResponse.status!) {
                  context.read<ResetWithPhoneOtpBloc>().add(ResetWithOptionTwoVerificationSuccessEvent());
                }
              });
        } else if (state.status.isVerifyWeb) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return WebOtpModalScreen(otpId: state.verification.id!, locale: state.locale);
                  },
                  fullscreenDialog: true,
                ),
              )
              .then((value) {
                if (!context.mounted) return;
                if (value != null) {
                  WebSMSOTPVerificationResponseModel webSMSOTPResponse = WebSMSOTPVerificationResponseModel.fromJson(value);
                  if (webSMSOTPResponse.action! == true && webSMSOTPResponse.success! == true) {
                    context.read<ResetWithPhoneOtpBloc>().add(ResetWithOptionTwoVerificationSuccessEvent());
                  } else {
                    showErrorDialog(context, translate.verification_failed, state.extraMessage, state.statusCode, fromAuth: true);
                  }
                }
              });
        } else if (state.status.isVerifyFirebase) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return FirebaseVerificationModalScreen(countryCode: state.countryCode.value, mobileNumber: state.mobileNumber.value);
                  },
                  fullscreenDialog: true,
                ),
              )
              .then((value) {
                if (!context.mounted) return;
                if (value != null) {
                  FirebaseSMSOTPVerificationResponseModel firebaseSMSOTPResponse = FirebaseSMSOTPVerificationResponseModel.fromJson(value);
                  if (firebaseSMSOTPResponse.action! == true && firebaseSMSOTPResponse.status! == true) {
                    context.read<ResetWithPhoneOtpBloc>().add(ResetWithOptionTwoFirebaseVerificationEvent(accessToken: firebaseSMSOTPResponse.token!));
                  } else {
                    showErrorDialog(context, translate.verification_failed, state.extraMessage, state.statusCode, fromAuth: true);
                  }
                }
              });
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isInProgress ? true : false,
          child: Padding(
            padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
            child: Column(
              children: [
                if (state.isVerified == false) ...[
                  Text(translate.forgot_your_password, textAlign: TextAlign.center, style: kAppLblLargeFontBold(context)),
                  kAppSpacerVertical(height: 10),
                  Text(translate.phone_otp_verification_sub_title, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
                  kAppSpacerVertical(height: 40),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _countryCodeController,
                          focusNode: _countryCodeFocusNode,
                          readOnly: true,
                          decoration: kAppInputDecoration(context, lblText: translate.code, errText: state.countryCode.displayError != null ? translate.form_required : null),
                          style: kAppLblSmallFontMedium(context),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onTap: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return CountryCodeModalScreen(code: state.countryCode.value);
                                    },
                                    fullscreenDialog: true,
                                  ),
                                )
                                .then((value) {
                                  if (!context.mounted) return;
                                  CountryCodeModalResponseModel countryCodeResponse = CountryCodeModalResponseModel.fromJson(value);
                                  if (countryCodeResponse.action!) {
                                    _countryCodeController.text = '${countryCodeResponse.flag} (${countryCodeResponse.dialCode})';
                                    context.read<ResetWithPhoneOtpBloc>().add(ResetWithPhoneTypeTwoCountryCodeChangedEvent(countryCode: countryCodeResponse.dialCode!));
                                  }
                                });
                          },
                        ),
                      ),
                      kAppSpacerHorizontal(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _mobileController,
                          focusNode: _mobileNumberFocusNode,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                          decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.person_outline), lblText: translate.mobile, errText: state.mobileNumber.displayError != null ? translate.form_required : null),
                          style: kAppLblSmallFontMedium(context),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => context.read<ResetWithPhoneOtpBloc>().add(ResetWithPhoneTypeTwoMobileNumberChangedEvent(mobileNumber: value)),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  kAppSpacerVertical(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPhoneValid ? () => context.read<ResetWithPhoneOtpBloc>().add(ResetWithPhoneTypeTwoSendVerificationSMSEvent()) : null,
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
                    onChanged: (value) => context.read<ResetWithPhoneOtpBloc>().add(ResetWithOptionTwoPasswordChangedEvent(password: value)),
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
                    onChanged: (value) => context.read<ResetWithPhoneOtpBloc>().add(ResetWithOptionTwoConfirmPasswordChangedEvent(password: value)),
                    textInputAction: TextInputAction.done,
                  ),
                  kAppSpacerVertical(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPasswordValid ? () => context.read<ResetWithPhoneOtpBloc>().add(ResetWithOptionTwoUpdatePasswordEvent()) : null,
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
