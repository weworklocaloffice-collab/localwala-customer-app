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
import 'package:user/app/presentation/pages/account/feedback_form/bloc/feedback_form_bloc.dart';
import 'package:user/app/presentation/pages/modals/country_modal/country_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FeedbackFormScreen extends StatelessWidget {
  const FeedbackFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => FeedbackFormBloc()..add(FeedbackFormInitialEvent()), child: const FeedbackFormView());
  }
}

class FeedbackFormView extends StatefulWidget {
  const FeedbackFormView({super.key});

  @override
  State<FeedbackFormView> createState() => _FeedbackFormViewState();
}

class _FeedbackFormViewState extends State<FeedbackFormView> {
  final _nameFocusNode = FocusNode();
  final _countryCodeFocusNode = FocusNode();
  final _numberFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _shortDescriptionFocusNode = FocusNode();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController shortDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        context.read<FeedbackFormBloc>().add(FeedbackFormNameUnfocusedEvent());
      }
    });

    _numberFocusNode.addListener(() {
      if (!_numberFocusNode.hasFocus) {
        context.read<FeedbackFormBloc>().add(FeedbackFormNumberUnfocusedEvent());
      }
    });

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        context.read<FeedbackFormBloc>().add(FeedbackFormEmailUnfocusedEvent());
      }
    });

    _shortDescriptionFocusNode.addListener(() {
      if (!_shortDescriptionFocusNode.hasFocus) {
        context.read<FeedbackFormBloc>().add(FeedbackFormDescriptionUnfocusedEvent());
      }
    });

    nameController.text = '';
    numberController.text = '';
    emailController.text = '';
    shortDescriptionController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final isValid = context.select((FeedbackFormBloc bloc) => bloc.state.isValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<FeedbackFormBloc, FeedbackFormState>(
      listener: (context, state) {
        if (state.status.isInitial) {
          countryCodeController.text = '${state.flag} (${state.userCountryCode.value})';
        } else if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isSuccess) {
          showSuccessDialog(context, translate.feedback_saved).then((value) {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop();
          });
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isSubmit ? true : false,
          child: Scaffold(
            appBar: AppBar(title: Text(translate.send_feedback), scrolledUnderElevation: 0),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppSpacerVertical(height: 20),
                  Text(translate.feedback_sub_title, style: kAppLblTinyFontRegular(context)),
                  kAppSpacerVertical(height: 20),
                  TextFormField(
                    controller: emailController,
                    focusNode: _emailFocusNode,
                    decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.email_outlined), lblText: translate.your_email, errText: state.userEmail.displayError != null ? translate.form_required : null),
                    style: kAppLblSmallFontMedium(context),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => context.read<FeedbackFormBloc>().add(FeedbackFormEmailChangedEvent(email: value)),
                    textInputAction: TextInputAction.next,
                  ),
                  kAppSpacerVertical(height: 20),
                  TextFormField(
                    focusNode: _nameFocusNode,
                    controller: nameController,
                    decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.account_circle_outlined), lblText: translate.your_name, errText: state.userName.displayError != null ? translate.form_required : null),
                    style: kAppLblSmallFontMedium(context),
                    keyboardType: TextInputType.text,
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                    onChanged: (value) {
                      if (value.startsWith(' ')) {
                        nameController.text = value.trimLeft();
                        nameController.selection = TextSelection.collapsed(offset: nameController.text.length);
                      }
                      if (RegExp(r'^[0-9]').hasMatch(value)) {
                        nameController.text = value.substring(1);
                        nameController.selection = TextSelection.collapsed(offset: nameController.text.length);
                      }
                      context.read<FeedbackFormBloc>().add(FeedbackFormNameChangedEvent(name: nameController.text));
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  kAppSpacerVertical(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: countryCodeController,
                          focusNode: _countryCodeFocusNode,
                          readOnly: true,
                          decoration: kAppInputDecoration(context, lblText: translate.code, errText: state.userCountryCode.displayError != null ? translate.form_required : null),
                          style: kAppLblSmallFontMedium(context),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onTap: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return CountryCodeModalScreen(code: state.userCountryCode.value);
                                    },
                                    fullscreenDialog: true,
                                  ),
                                )
                                .then((value) {
                                  if (!context.mounted) return;
                                  CountryCodeModalResponseModel countryCodeResponse = CountryCodeModalResponseModel.fromJson(value);
                                  if (countryCodeResponse.action!) {
                                    setState(() {
                                      countryCodeController.text = '${countryCodeResponse.flag} (${countryCodeResponse.dialCode})';
                                    });
                                    context.read<FeedbackFormBloc>().add(FeedbackFormCountryCodeChangedEvent(flag: countryCodeResponse.flag!, countryCode: countryCodeResponse.dialCode!));
                                  }
                                });
                          },
                        ),
                      ),
                      kAppSpacerHorizontal(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          focusNode: _numberFocusNode,
                          controller: numberController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                          decoration: kAppInputDecoration(
                            context,
                            prefixIcon: const Icon(Icons.call_outlined),
                            lblText: translate.your_phone_number,
                            errText: state.userContact.displayError != null ? translate.form_required : null,
                          ),
                          style: kAppLblSmallFontMedium(context),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => context.read<FeedbackFormBloc>().add(FeedbackFormNumberChangedEvent(number: value)),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  kAppSpacerVertical(height: 20),
                  TextFormField(
                    focusNode: _shortDescriptionFocusNode,
                    controller: shortDescriptionController,
                    decoration: kAppInputDecoration(context, lblText: translate.write_feedback, errText: state.userContact.displayError != null ? translate.form_required : null),
                    maxLines: 5,
                    style: kAppLblSmallFontMedium(context),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => context.read<FeedbackFormBloc>().add(FeedbackFormDescriptionChangedEvent(text: value)),
                    textInputAction: TextInputAction.done,
                  ),
                  kAppSpacerVertical(height: 20),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
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
                            onPressed: isValid ? () => context.read<FeedbackFormBloc>().add(FeedbackFormSubmitEvent()) : null,
                            style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                            child: state.status.isSubmit ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.submit_feedback),
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
// Done //
