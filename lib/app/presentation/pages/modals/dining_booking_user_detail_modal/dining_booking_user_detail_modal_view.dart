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
import 'package:formz/formz.dart';
import 'package:user/app/core/models/country_code_modal_response_model.dart';
import 'package:user/app/presentation/pages/modals/country_modal/country_modal_view.dart';
import 'package:user/app/presentation/pages/modals/dining_booking_user_detail_modal/bloc/dining_booking_user_detail_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DiningBookingUserDetailModalScreen extends StatelessWidget {
  final String userName;
  final String userCountryCode;
  final String userPhoneNumber;
  final String userEmail;
  const DiningBookingUserDetailModalScreen({super.key, required this.userName, required this.userCountryCode, required this.userPhoneNumber, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiningBookingUserDetailModalBloc()..add(DiningBookingUserDetailModalInitialEvent(userName: userName, userCountryCode: userCountryCode, userPhoneNumber: userPhoneNumber, userEmail: userEmail)),
      child: DiningBookingUserDetailModalView(userName: userName, userCountryCode: userCountryCode, userPhoneNumber: userPhoneNumber, userEmail: userEmail),
    );
  }
}

class DiningBookingUserDetailModalView extends StatefulWidget {
  final String userName;
  final String userCountryCode;
  final String userPhoneNumber;
  final String userEmail;
  const DiningBookingUserDetailModalView({super.key, required this.userName, required this.userCountryCode, required this.userPhoneNumber, required this.userEmail});

  @override
  State<DiningBookingUserDetailModalView> createState() => _DiningBookingUserDetailModalViewState();
}

class _DiningBookingUserDetailModalViewState extends State<DiningBookingUserDetailModalView> {
  final _nameFocusNode = FocusNode();
  final _countryCodeFocusNode = FocusNode();
  final _numberFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        context.read<DiningBookingUserDetailModalBloc>().add(DiningBookingUserDetailModalNameUnfocusedEvent());
      }
    });

    _numberFocusNode.addListener(() {
      if (!_numberFocusNode.hasFocus) {
        context.read<DiningBookingUserDetailModalBloc>().add(DiningBookingUserDetailModalNumberUnfocusedEvent());
      }
    });

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        context.read<DiningBookingUserDetailModalBloc>().add(DiningBookingUserDetailModalEmailUnfocusedEvent());
      }
    });

    nameController.text = widget.userName;
    numberController.text = widget.userPhoneNumber;
    emailController.text = widget.userEmail;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<DiningBookingUserDetailModalBloc, DiningBookingUserDetailModalState>(
      listener: (context, state) {
        if (state.status.isInitial) {
          countryCodeController.text = '${state.flag} (${state.userCountryCode.value})';
        } else if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode);
        } else if (state.status.isSuccess) {
          Navigator.of(
            context,
          ).pop({"name": state.userName.value.toString(), "countryCode": state.userCountryCode.value.toString().replaceAll('+', ''), "phoneNumber": state.userContact.value.toString(), "email": state.userEmail.value.toString()});
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            title: Text(translate.add_your_details),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kAppSpacerVertical(height: 20),
                TextFormField(
                  controller: emailController,
                  focusNode: _emailFocusNode,
                  decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.email_outlined), lblText: translate.your_email, errText: state.userEmail.displayError != null ? translate.form_required : null),
                  style: kAppLblSmallFontMedium(context),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => context.read<DiningBookingUserDetailModalBloc>().add(DiningBookingUserDetailModalEmailChangedEvent(email: value)),
                  textInputAction: TextInputAction.next,
                ),
                kAppSpacerVertical(height: 20),
                TextFormField(
                  focusNode: _nameFocusNode,
                  controller: nameController,
                  decoration: kAppInputDecoration(context, lblText: translate.your_name, errText: state.userName.displayError != null ? translate.form_required : null),
                  style: kAppLblSmallFontMedium(context),
                  keyboardType: TextInputType.text,
                  onChanged: (value) => context.read<DiningBookingUserDetailModalBloc>().add(DiningBookingUserDetailModalNameChangedEvent(name: value)),
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
                                  context.read<DiningBookingUserDetailModalBloc>().add(DiningBookingUserDetailModalCountryCodeChangedEvent(flag: countryCodeResponse.flag!, countryCode: countryCodeResponse.dialCode!));
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
                        decoration: kAppInputDecoration(context, lblText: translate.your_phone_number, errText: state.userContact.displayError != null ? translate.form_required : null),
                        style: kAppLblSmallFontMedium(context),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => context.read<DiningBookingUserDetailModalBloc>().add(DiningBookingUserDetailModalNumberChangedEvent(number: value)),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
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
                          onPressed: () => context.read<DiningBookingUserDetailModalBloc>().add(DiningBookingUserDetailModalSubmitEvent()),
                          style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                          child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.save_information),
                        ),
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
