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
import 'package:user/app/presentation/pages/modals/country_modal/country_modal_view.dart';
import 'package:user/app/presentation/pages/modals/social_account_verification_modal/bloc/social_account_verification_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class SocialAccountVerificationModalScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  const SocialAccountVerificationModalScreen({super.key, required this.firstName, required this.lastName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SocialAccountVerificationModalBloc()..add(SocialAccountVerificationModalInitialEvent(firstName: firstName, lastName: lastName)),
      child: const SocialAccountVerificationModalView(),
    );
  }
}

class SocialAccountVerificationModalView extends StatefulWidget {
  const SocialAccountVerificationModalView({super.key});

  @override
  State<SocialAccountVerificationModalView> createState() => _SocialAccountVerificationModalViewState();
}

class _SocialAccountVerificationModalViewState extends State<SocialAccountVerificationModalView> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _countryCodeFocusNode = FocusNode();
  final _mobileNumberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _firstNameFocusNode.addListener(() {
      if (!_firstNameFocusNode.hasFocus) {
        context.read<SocialAccountVerificationModalBloc>().add(SocialAccountVerificationModalFirstNameUnfocusedEvent());
      }
    });

    _lastNameFocusNode.addListener(() {
      if (!_lastNameFocusNode.hasFocus) {
        context.read<SocialAccountVerificationModalBloc>().add(SocialAccountVerificationModalLastNameUnfocusedEvent());
      }
    });

    _countryCodeFocusNode.addListener(() {
      if (!_countryCodeFocusNode.hasFocus) {
        context.read<SocialAccountVerificationModalBloc>().add(SocialAccountVerificationModalCountryCodeUnfocusedEvent());
      }
    });

    _mobileNumberFocusNode.addListener(() {
      if (!_mobileNumberFocusNode.hasFocus) {
        context.read<SocialAccountVerificationModalBloc>().add(SocialAccountVerificationModalMobileNumberUnfocusedEvent());
      }
    });
  }

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _countryCodeFocusNode.dispose();
    _mobileNumberFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = context.select((SocialAccountVerificationModalBloc bloc) => bloc.state.isValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<SocialAccountVerificationModalBloc, SocialAccountVerificationModalState>(
      listener: (context, state) {
        if (state.status.isLoaded) {
          _countryCodeController.text = '${state.flag} (${state.countryCode.value})';
          _firstNameController.text = state.firstName.value;
          _lastNameController.text = state.lastName.value;
        } else if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode, fromAuth: true);
        } else if (state.status.isSuccess) {
          Navigator.of(context, rootNavigator: true).pop({"success": true, "firstName": state.firstName.value, "lastName": state.lastName.value, "country_code": state.countryCode.value, "mobile": state.mobileNumber.value});
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isInProgress ? true : false,
          child: Scaffold(
            appBar: AppBar(
              title: Text(translate.account_not_registered),
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(onPressed: () => Navigator.of(context).pop({"success": false, "firstName": "", "lastName": "", "country_code": "", "mobile": ""}), icon: Icon(Icons.close)),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate.unregister_account_notice, style: kAppLblMediumFontRegular(context)),
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
                            context.read<SocialAccountVerificationModalBloc>().add(SocialAccountVerificationModalFirstNameChangedEvent(firstName: _firstNameController.text));
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
                            context.read<SocialAccountVerificationModalBloc>().add(SocialAccountVerificationModalLastNameChangedEvent(lastName: _lastNameController.text));
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
                                    context.read<SocialAccountVerificationModalBloc>().add(SocialAccountVerificationModalCountryCodeChangedEvent(countryCode: countryCodeResponse.dialCode!));
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
                          onChanged: (value) => context.read<SocialAccountVerificationModalBloc>().add(SocialAccountVerificationModalMobileNumberChangedEvent(mobileNumber: value)),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isValid ? () => context.read<SocialAccountVerificationModalBloc>().add(SocialAccountVerificationModalSubmitEvent()) : null,
                            style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                            child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.submit),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

