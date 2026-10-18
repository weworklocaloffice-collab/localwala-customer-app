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
import 'package:user/app/presentation/pages/account/address_book/address_action/bloc/address_action_bloc.dart';
import 'package:user/app/presentation/pages/modals/country_modal/country_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AddressActionScreen extends StatelessWidget {
  final bool isNew;
  final String id;
  final double latitude;
  final double longitude;
  final int title;
  final String receiverName;
  final String countryCode;
  final String receiverContact;
  final String flatHouse;
  final String locality;
  final String landmark;
  const AddressActionScreen({
    super.key,
    required this.isNew,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.receiverName,
    required this.countryCode,
    required this.receiverContact,
    required this.flatHouse,
    required this.locality,
    required this.landmark,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddressActionBloc()
        ..add(
          AddressActionInitialEvent(
            isNew: isNew,
            id: id,
            latitude: latitude,
            longitude: longitude,
            title: title,
            receiverName: receiverName,
            countryCode: countryCode,
            receiverContact: receiverContact,
            flatHouse: flatHouse,
            locality: locality,
            landmark: landmark,
          ),
        ),
      child: AddressActionView(receiverName: receiverName, receiverContact: receiverContact, flatHouse: flatHouse, locality: locality, landmark: landmark),
    );
  }
}

class AddressActionView extends StatefulWidget {
  final String receiverName;
  final String receiverContact;
  final String flatHouse;
  final String locality;
  final String landmark;
  const AddressActionView({super.key, required this.receiverName, required this.receiverContact, required this.flatHouse, required this.locality, required this.landmark});

  @override
  State<AddressActionView> createState() => _AddressActionViewState();
}

class _AddressActionViewState extends State<AddressActionView> {
  final _nameFocusNode = FocusNode();
  final _countryCodeFocusNode = FocusNode();
  final _numberFocusNode = FocusNode();
  final _houseFocusNode = FocusNode();
  final _localityFocusNode = FocusNode();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        context.read<AddressActionBloc>().add(AddressActionNameUnfocused());
      }
    });

    _numberFocusNode.addListener(() {
      if (!_numberFocusNode.hasFocus) {
        context.read<AddressActionBloc>().add(AddressActionNumberUnfocused());
      }
    });

    _houseFocusNode.addListener(() {
      if (!_houseFocusNode.hasFocus) {
        context.read<AddressActionBloc>().add(AddressActionHouseUnfocused());
      }
    });

    _localityFocusNode.addListener(() {
      if (!_localityFocusNode.hasFocus) {
        context.read<AddressActionBloc>().add(AddressActionLocalityUnfocused());
      }
    });
    nameController.text = widget.receiverName;
    numberController.text = widget.receiverContact;
    houseController.text = widget.flatHouse;
    localityController.text = widget.locality;
    landmarkController.text = widget.landmark;
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _numberFocusNode.dispose();
    _houseFocusNode.dispose();
    _localityFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<AddressActionBloc, AddressActionState>(
      listener: (context, state) {
        if (state.status.isInitial) {
          countryCodeController.text = '${state.flag} (${state.countryCode.value})';
        } else if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode);
        } else if (state.status.isSuccess) {
          Navigator.of(context, rootNavigator: true).pop(true);
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isInProgress ? true : false,
          child: Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              title: Text(translate.new_address_title),
              actions: [IconButton(onPressed: () => Navigator.of(context).pop(false), icon: const Icon(Icons.close))],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translate.save_address_as, style: kAppLblTinyFontRegularChip(context, color: 'regular')),
                    kAppSpacerVertical(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => context.read<AddressActionBloc>().add(AddressActionTitleChangeEvent(title: 0)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: state.title == 0 ? Theme.of(context).primaryColor : Theme.of(context).canvasColor, width: 1),
                            ),
                            child: Text(translate.home, style: kAppLblTinyFontRegularChip(context, color: state.title == 0 ? 'primary' : 'regular')),
                          ),
                        ),
                        kAppSpacerHorizontal(width: 10),
                        InkWell(
                          onTap: () => context.read<AddressActionBloc>().add(AddressActionTitleChangeEvent(title: 1)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: state.title == 1 ? Theme.of(context).primaryColor : Theme.of(context).canvasColor, width: 1),
                            ),
                            child: Text(translate.work, style: kAppLblTinyFontRegularChip(context, color: state.title == 1 ? 'primary' : 'regular')),
                          ),
                        ),
                        kAppSpacerHorizontal(width: 10),
                        InkWell(
                          onTap: () => context.read<AddressActionBloc>().add(AddressActionTitleChangeEvent(title: 2)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: state.title == 2 ? Theme.of(context).primaryColor : Theme.of(context).canvasColor, width: 1),
                            ),
                            child: Text(translate.hotel, style: kAppLblTinyFontRegularChip(context, color: state.title == 2 ? 'primary' : 'regular')),
                          ),
                        ),
                        kAppSpacerHorizontal(width: 10),
                        InkWell(
                          onTap: () => context.read<AddressActionBloc>().add(AddressActionTitleChangeEvent(title: 3)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: state.title == 3 ? Theme.of(context).primaryColor : Theme.of(context).canvasColor, width: 1),
                            ),
                            child: Text(translate.other, style: kAppLblTinyFontRegularChip(context, color: state.title == 3 ? 'primary' : 'regular')),
                          ),
                        ),
                      ],
                    ),
                    kAppSpacerVertical(height: 20),
                    TextFormField(
                      focusNode: _nameFocusNode,
                      controller: nameController,
                      decoration: kAppInputDecoration(context, lblText: translate.receiver_name, errText: state.receiverName.displayError != null ? translate.form_required : null),
                      style: kAppLblSmallFontMedium(context),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => context.read<AddressActionBloc>().add(AddressActionNameChanged(name: value)),
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
                                      context.read<AddressActionBloc>().add(AddressActionCountryCodeChanged(flag: countryCodeResponse.flag!, countryCode: countryCodeResponse.dialCode!));
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
                            onChanged: (value) => context.read<AddressActionBloc>().add(AddressActionNumberChanged(number: value)),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    Text(translate.assist_deliveryman, style: kAppLblTinyFontRegularChip(context, color: 'regular')),
                    kAppSpacerVertical(height: 20),
                    TextFormField(
                      focusNode: _houseFocusNode,
                      controller: houseController,
                      decoration: kAppInputDecoration(context, lblText: translate.address_flat_house, errText: state.houseName.displayError != null ? translate.form_required : null),
                      style: kAppLblSmallFontMedium(context),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => context.read<AddressActionBloc>().add(AddressActionHouseChanged(house: value)),
                      textInputAction: TextInputAction.next,
                    ),
                    kAppSpacerVertical(height: 20),
                    TextFormField(
                      focusNode: _localityFocusNode,
                      controller: localityController,
                      decoration: kAppInputDecoration(context, lblText: translate.adderss_area_locality, errText: state.locality.displayError != null ? translate.form_required : null),
                      style: kAppLblSmallFontMedium(context),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => context.read<AddressActionBloc>().add(AddressActionLocalityChanged(locality: value)),
                      textInputAction: TextInputAction.next,
                    ),
                    kAppSpacerVertical(height: 20),
                    TextFormField(
                      controller: landmarkController,
                      decoration: kAppInputDecoration(context, lblText: translate.address_landmark),
                      style: kAppLblSmallFontMedium(context),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => context.read<AddressActionBloc>().add(AddressActionLandmarkChanged(landmark: value)),
                      textInputAction: TextInputAction.done,
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
                            onPressed: () => context.read<AddressActionBloc>().add(AddressActionSubmitted()),
                            style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                            child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.save_address_btn),
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
