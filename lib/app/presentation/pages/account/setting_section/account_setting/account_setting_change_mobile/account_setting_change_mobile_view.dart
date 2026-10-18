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
import 'package:user/app/presentation/pages/account/setting_section/account_setting/account_setting_change_mobile/bloc/account_setting_change_mobile_bloc.dart';
import 'package:user/app/presentation/pages/modals/country_modal/country_modal_view.dart';
import 'package:user/app/presentation/pages/modals/firebase_verification_modal/firebase_verification_modal_view.dart';
import 'package:user/app/presentation/pages/modals/otp_modal/otp_modal_view.dart';
import 'package:user/app/presentation/pages/modals/web_otp_modal/web_otp_modal.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AccountSettingChangeMobileScreen extends StatelessWidget {
  const AccountSettingChangeMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => AccountSettingChangeMobileBloc()..add(AccountSettingChangeMobileInitialEvent()), child: const AccountSettingChangeMobileView());
  }
}

class AccountSettingChangeMobileView extends StatefulWidget {
  const AccountSettingChangeMobileView({super.key});

  @override
  State<AccountSettingChangeMobileView> createState() => _AccountSettingChangeMobileViewState();
}

class _AccountSettingChangeMobileViewState extends State<AccountSettingChangeMobileView> {
  final _countryCodeFocusNode = FocusNode();
  final _mobileNumberFocusNode = FocusNode();

  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _countryCodeFocusNode.addListener(() {
      if (!_countryCodeFocusNode.hasFocus) {
        context.read<AccountSettingChangeMobileBloc>().add(AccountSettingChangeMobileCountryCodeUnfocusedEvent());
      }
    });

    _mobileNumberFocusNode.addListener(() {
      if (!_mobileNumberFocusNode.hasFocus) {
        context.read<AccountSettingChangeMobileBloc>().add(AccountSettingChangeMobileNumberUnfocusedEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPhoneValid = context.select((AccountSettingChangeMobileBloc bloc) => bloc.state.isPhoneValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<AccountSettingChangeMobileBloc, AccountSettingChangeMobileState>(
      listener: (context, state) {
        if (state.status.isLoaded) {
          _countryCodeController.text = '${state.flag} (${state.countryCode.value})';
        } else if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode, fromAuth: false);
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
                  context.read<AccountSettingChangeMobileBloc>().add(AccountSettingChangeMobileVerificationSuccessEvent());
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
                    context.read<AccountSettingChangeMobileBloc>().add(AccountSettingChangeMobileVerificationSuccessEvent());
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
                    context.read<AccountSettingChangeMobileBloc>().add(AccountSettingChangeMobileFirebaseVerificationEvent(accessToken: firebaseSMSOTPResponse.token!));
                  } else {
                    showErrorDialog(context, translate.verification_failed, state.extraMessage, state.statusCode, fromAuth: true);
                  }
                }
              });
        } else if (state.status.isSuccess) {
          showSuccessDialog(context, translate.phone_updated).then((value) {
            if (!context.mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
          });
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isInProgress ? true : false,
          child: Scaffold(
            appBar: AppBar(title: Text(translate.change_mobile_number), scrolledUnderElevation: 0),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate.re_auth_required, style: kAppLblMediumFontBold(context)),
                  kAppSpacerVertical(height: 10),
                  Text(translate.change_mobile_number_sub_title, style: kAppLblTinyFontRegular(context)),
                  kAppSpacerVertical(height: 10),
                  Text("${translate.auth_used_mode} ${state.userMobileNumber} ${translate.phone_auth_otp}", style: kAppLblTinyFontRegular(context)),
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
                                    context.read<AccountSettingChangeMobileBloc>().add(AccountSettingChangeMobileCountryCodeChangedEvent(countryCode: countryCodeResponse.dialCode!));
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
                          decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.person_outline), lblText: translate.mobile, errText: state.mobileNumber.displayError != null ? translate.form_required : null),
                          style: kAppLblSmallFontMedium(context),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                          onChanged: (value) => context.read<AccountSettingChangeMobileBloc>().add(AccountSettingChangeMobileNumberChangedEvent(mobileNumber: value)),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  kAppSpacerVertical(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPhoneValid ? () => context.read<AccountSettingChangeMobileBloc>().add(AccountSettingChangeMobileSubmitEvent()) : null,
                      style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                      child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.verify),
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
