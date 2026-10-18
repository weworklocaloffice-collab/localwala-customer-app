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
import 'package:user/app/presentation/pages/modals/change_receiver_info_modal/bloc/change_receiver_info_modal_bloc.dart';
import 'package:user/app/presentation/pages/modals/country_modal/country_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ChangeReceiverInfoModalScreen extends StatelessWidget {
  final String orderTo;
  final String addressTitle;
  final String addressSubtitle;
  final String receiverName;
  final String receiverCountryCode;
  final String receiverPhoneNumber;
  const ChangeReceiverInfoModalScreen({
    super.key,
    required this.orderTo,
    required this.addressTitle,
    required this.addressSubtitle,
    required this.receiverName,
    required this.receiverCountryCode,
    required this.receiverPhoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangeReceiverInfoModalBloc()
        ..add(
          ChangeReceiverInfoModalInitialEvent(
            orderTo: orderTo,
            addressTitle: addressTitle,
            addressSubtitle: addressSubtitle,
            receiverName: receiverName,
            receiverCountryCode: receiverCountryCode,
            receiverPhoneNumber: receiverPhoneNumber,
          ),
        ),
      child: ChangeReceiverInfoModalView(receiverName: receiverName, receiverContact: receiverPhoneNumber),
    );
  }
}

class ChangeReceiverInfoModalView extends StatefulWidget {
  final String receiverName;
  final String receiverContact;
  const ChangeReceiverInfoModalView({super.key, required this.receiverName, required this.receiverContact});

  @override
  State<ChangeReceiverInfoModalView> createState() => _ChangeReceiverInfoModalViewState();
}

class _ChangeReceiverInfoModalViewState extends State<ChangeReceiverInfoModalView> {
  final _nameFocusNode = FocusNode();
  final _countryCodeFocusNode = FocusNode();
  final _numberFocusNode = FocusNode();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        context.read<ChangeReceiverInfoModalBloc>().add(ChangeReceiverNameUnfocused());
      }
    });

    _numberFocusNode.addListener(() {
      if (!_numberFocusNode.hasFocus) {
        context.read<ChangeReceiverInfoModalBloc>().add(ChangeReceiverNumberUnfocused());
      }
    });
    nameController.text = widget.receiverName;
    numberController.text = widget.receiverContact;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<ChangeReceiverInfoModalBloc, ChangeReceiverInfoModalState>(
      listener: (context, state) {
        if (state.status.isInitial) {
          countryCodeController.text = '${state.flag} (${state.countryCode.value})';
        } else if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode);
        } else if (state.status.isSuccess) {
          Navigator.of(context).pop({"name": state.receiverName.value.toString(), "countryCode": state.countryCode.value.toString().replaceAll('+', ''), "phoneNumber": state.receiverNumber.value.toString()});
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isInProgress ? true : false,
          child: Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              toolbarHeight: 80,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.receiverName.value.isEmpty ? translate.add_receiver_detail : translate.update_receiver_detail),
                  state.receiverName.value.isNotEmpty && state.orderTo == 'homedelivery'
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(state.addressTitle, style: kAppLblTinyFontBold(context)),
                            const Text(" - "),
                            Flexible(
                              child: Text(state.addressSubtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
              actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kAppSpacerVertical(height: 20),
                    TextFormField(
                      focusNode: _nameFocusNode,
                      controller: nameController,
                      decoration: kAppInputDecoration(context, lblText: translate.receiver_name, errText: state.receiverName.displayError != null ? translate.form_required : null),
                      style: kAppLblSmallFontMedium(context),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => context.read<ChangeReceiverInfoModalBloc>().add(ChangeReceiverNameChanged(name: value)),
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
                                      setState(() {
                                        countryCodeController.text = '${countryCodeResponse.flag} (${countryCodeResponse.dialCode})';
                                      });
                                      context.read<ChangeReceiverInfoModalBloc>().add(ChangeReceiverCountryCodeChanged(flag: countryCodeResponse.flag!, countryCode: countryCodeResponse.dialCode!));
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
                            decoration: kAppInputDecoration(context, lblText: translate.receiver_contact, errText: state.receiverNumber.displayError != null ? translate.form_required : null),
                            style: kAppLblSmallFontMedium(context),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => context.read<ChangeReceiverInfoModalBloc>().add(ChangeReceiverNumberChanged(number: value)),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    kAppSpacerVertical(height: 20),
                  ],
                ),
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
                            onPressed: () => context.read<ChangeReceiverInfoModalBloc>().add(ChangeReceiverSubmitted()),
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
          ),
        );
      },
    );
  }
}

