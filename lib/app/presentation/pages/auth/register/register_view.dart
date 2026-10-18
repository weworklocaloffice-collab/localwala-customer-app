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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/app/core/models/country_code_modal_response_model.dart';
import 'package:user/app/core/models/firebase_sms_otp_verification_response_model.dart';
import 'package:user/app/core/models/otp_modal_response_model.dart';
import 'package:user/app/core/models/web_sms_otp_verification_response_model.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/pages/modals/country_modal/country_modal_view.dart';
import 'package:user/app/presentation/pages/modals/firebase_verification_modal/firebase_verification_modal_view.dart';
import 'package:user/app/presentation/pages/modals/otp_modal/otp_modal_view.dart';
import 'package:user/app/presentation/pages/modals/referral_modal/referral_modal_view.dart';
import 'package:user/app/presentation/pages/auth/register/bloc/register_bloc.dart';
import 'package:user/app/presentation/pages/modals/web_otp_modal/web_otp_modal.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => RegisterBloc()..add(RegisterInitialEvent()), child: const RegisterView());
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  final TextEditingController _countryCodeController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _countryCodeFocusNode = FocusNode();
  final _mobileNumberFocusNode = FocusNode();

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        context.read<RegisterBloc>().add(RegisterEmailUnfocusedEvent());
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        context.read<RegisterBloc>().add(RegisterPasswordUnfocusedEvent());
      }
    });

    _firstNameFocusNode.addListener(() {
      if (!_firstNameFocusNode.hasFocus) {
        context.read<RegisterBloc>().add(RegisterFirstNameUnfocusedEvent());
      }
    });

    _lastNameFocusNode.addListener(() {
      if (!_lastNameFocusNode.hasFocus) {
        context.read<RegisterBloc>().add(RegisterLastNameUnfocusedEvent());
      }
    });

    _countryCodeFocusNode.addListener(() {
      if (!_countryCodeFocusNode.hasFocus) {
        context.read<RegisterBloc>().add(RegisterCountryCodeUnfocusedEvent());
      }
    });

    _mobileNumberFocusNode.addListener(() {
      if (!_mobileNumberFocusNode.hasFocus) {
        context.read<RegisterBloc>().add(RegisterMobileNumberUnfocusedEvent());
      }
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _countryCodeFocusNode.dispose();
    _mobileNumberFocusNode.dispose();

    _firstNameController.dispose();
    _lastNameController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = context.select((RegisterBloc bloc) => bloc.state.isValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status.isLoaded) {
          _countryCodeController.text = '${state.flag} (${state.countryCode.value})';
        } else if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode, fromAuth: true);
        } else if (state.status.isVerify) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return OtpModalScreen(
                      providerName: state.verification.provider!,
                      sentTo: state.verification.mode! == 'email_otp' ? state.email.value.toString() : '${state.countryCode.value.toString()}${state.mobileNumber.value.toString()}',
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
                  context.read<RegisterBloc>().add(
                    RegisterFormSubmitEvent(isEmailVerified: state.verification.mode == 'email_otp' ? true : false, isMobileVerified: state.verification.mode != 'email_otp' ? true : false, otp: otpModalResponse.otp!),
                  );
                }
              });
        } else if (state.status.isSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [0]);
        } else if (state.status.isReferral) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              var height = MediaQuery.of(context).size.height;
              var width = MediaQuery.of(context).size.width;
              return AlertDialog(
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                content: SizedBox(
                  height: height - 400,
                  width: width - 80,
                  child: ReferralModalScreen(message: state.referralMessage, extraContent: state.referralExtraMessage),
                ),
              );
            },
          ).then((value) {
            if (!context.mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [0]);
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
                  if (webSMSOTPResponse.action! == true && webSMSOTPResponse.success! == true && webSMSOTPResponse.dummyOTP!.isNotEmpty) {
                    context.read<RegisterBloc>().add(
                      RegisterFormSubmitEvent(
                        isEmailVerified: state.verification.mode == 'email_otp' ? true : false,
                        isMobileVerified: state.verification.mode != 'email_otp' ? true : false,
                        otp: webSMSOTPResponse.dummyOTP!.toString(),
                      ),
                    );
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
                    context.read<RegisterBloc>().add(RegisterFormFirebaseVerificationSubmitEvent(accessToken: firebaseSMSOTPResponse.token!));
                  } else {
                    showErrorDialog(context, translate.verification_failed, state.extraMessage, state.statusCode, fromAuth: true);
                  }
                }
              });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.register), scrolledUnderElevation: 0),
          body: AbsorbPointer(
            absorbing: state.status.isInProgress ? true : false,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${translate.welcome_to} ${Environments.appName}", textAlign: TextAlign.center, style: kAppLblLargeFontBold(context)),
                    kAppSpacerVertical(height: 10),
                    Text(translate.register_sub_title, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
                    kAppSpacerVertical(height: 40),
                    TextFormField(
                      focusNode: _emailFocusNode,
                      decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.email_outlined), lblText: translate.email, errText: state.email.displayError != null ? translate.form_required : null),
                      style: kAppLblSmallFontMedium(context),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => context.read<RegisterBloc>().add(RegisterEmailChangedEvent(email: value)),
                      textInputAction: TextInputAction.next,
                    ),
                    kAppSpacerVertical(height: 20),
                    TextFormField(
                      focusNode: _passwordFocusNode,
                      decoration: kAppInputDecoration(
                        context,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        lblText: translate.password,
                        errText: state.password.displayError != null ? translate.form_required : null,
                        suffixIcon: Icon(_passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        haveSuffixIcon: true,
                        onPressed: () => setState(() {
                          _passwordVisible = !_passwordVisible;
                        }),
                      ),
                      style: kAppLblSmallFontMedium(context),
                      obscureText: !_passwordVisible,
                      keyboardType: TextInputType.text,
                      onChanged: (value) => context.read<RegisterBloc>().add(RegisterPasswordChangedEvent(password: value)),
                      textInputAction: TextInputAction.done,
                    ),
                    kAppSpacerVertical(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            focusNode: _firstNameFocusNode,
                            controller: _firstNameController,
                            decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.person_outline), lblText: translate.first_name, errText: state.firstName.displayError != null ? translate.form_required : null),
                            style: kAppLblSmallFontMedium(context),
                            keyboardType: TextInputType.text,
                            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                            onChanged: (value) {
                              if (value.startsWith(' ')) {
                                _firstNameController.text = value.trimLeft();
                                _firstNameController.selection = TextSelection.collapsed(offset: _firstNameController.text.length);
                              }
                              if (RegExp(r'^[0-9]').hasMatch(value)) {
                                _firstNameController.text = value.substring(1);
                                _firstNameController.selection = TextSelection.collapsed(offset: _firstNameController.text.length);
                              }
                              context.read<RegisterBloc>().add(RegisterFirstNameChangedEvent(firstName: _firstNameController.text));
                            },
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        kAppSpacerHorizontal(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            focusNode: _lastNameFocusNode,
                            controller: _lastNameController,
                            decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.person_outline), lblText: translate.last_name, errText: state.lastName.displayError != null ? translate.form_required : null),
                            style: kAppLblSmallFontMedium(context),
                            keyboardType: TextInputType.text,
                            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                            onChanged: (value) {
                              if (value.startsWith(' ')) {
                                _lastNameController.text = value.trimLeft();
                                _lastNameController.selection = TextSelection.collapsed(offset: _lastNameController.text.length);
                              }
                              if (RegExp(r'^[0-9]').hasMatch(value)) {
                                _lastNameController.text = value.substring(1);
                                _lastNameController.selection = TextSelection.collapsed(offset: _lastNameController.text.length);
                              }
                              context.read<RegisterBloc>().add(RegisterLastNameChangedEvent(lastName: _lastNameController.text));
                            },
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    kAppSpacerVertical(height: 20),
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
                                      context.read<RegisterBloc>().add(RegisterCountryCodeChangedEvent(countryCode: countryCodeResponse.dialCode!));
                                    }
                                  });
                            },
                          ),
                        ),
                        kAppSpacerHorizontal(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            focusNode: _mobileNumberFocusNode,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                            decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.person_outline), lblText: translate.mobile, errText: state.mobileNumber.displayError != null ? translate.form_required : null),
                            style: kAppLblSmallFontMedium(context),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => context.read<RegisterBloc>().add(RegisterMobileNumberChangedEvent(mobileNumber: value)),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    state.haveReferralSystem
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              kAppSpacerVertical(height: 20),
                              TextFormField(
                                controller: _referralController,
                                decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.monetization_on_outlined), lblText: translate.referral_code),
                                style: kAppLblSmallFontMedium(context),
                                keyboardType: TextInputType.text,
                                onChanged: (value) => context.read<RegisterBloc>().add(RegisterReferralCodeChangedEvent(referralCode: _referralController.text)),
                                textInputAction: TextInputAction.next,
                              ),
                            ],
                          )
                        : kAppSpacerVertical(height: 0),
                    kAppSpacerVertical(height: 20),
                    Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            text: translate.register_term_one,
                            style: kAppLblSmallFontRegular(context),
                            children: <TextSpan>[
                              TextSpan(text: ' '),
                              TextSpan(
                                text: translate.register_term_two,
                                style: kAppLblSmallFontBold(context),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['terms-and-conditions']);
                                  },
                              ),
                              TextSpan(text: ' '),
                              TextSpan(
                                text: translate.and,
                                style: kAppLblSmallFontRegular(context),
                                children: <TextSpan>[
                                  TextSpan(text: ' '),
                                  TextSpan(
                                    text: translate.privacy_policy,
                                    style: kAppLblSmallFontBold(context),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).pushNamed(AppRouter.appPageRoute, arguments: ['privacy-policy']);
                                      },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    kAppSpacerVertical(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isValid
                            ? () => context.read<RegisterBloc>().add(state.signUpVerification ? RegisterFormVerificationSubmitEvent() : RegisterFormSubmitEvent(isEmailVerified: false, isMobileVerified: false, otp: ''))
                            : null,
                        style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                        child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.sign_up_btn),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
// Done //
