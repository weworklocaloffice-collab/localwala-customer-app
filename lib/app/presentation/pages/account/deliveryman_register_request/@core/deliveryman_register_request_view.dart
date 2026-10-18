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

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:user/app/core/models/country_code_modal_response_model.dart';
import 'package:user/app/core/models/deliveryman_register_request_basic_detail_response_model.dart';
import 'package:user/app/core/models/localities_by_city_model.dart';
import 'package:user/app/presentation/pages/account/deliveryman_register_request/@core/bloc/deliveryman_register_request_bloc.dart';
import 'package:user/app/presentation/pages/modals/country_modal/country_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/loader_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DeliverymanRegisterRequestScreen extends StatelessWidget {
  const DeliverymanRegisterRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => DeliverymanRegisterRequestBloc()..add(DeliverymanRegisterRequestInitialEvent()), child: const DeliverymanRegisterRequestView());
  }
}

class DeliverymanRegisterRequestView extends StatefulWidget {
  const DeliverymanRegisterRequestView({super.key});

  @override
  State<DeliverymanRegisterRequestView> createState() => _DeliverymanRegisterRequestViewState();
}

class _DeliverymanRegisterRequestViewState extends State<DeliverymanRegisterRequestView> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController identityController = TextEditingController();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _countryCodeFocusNode = FocusNode();
  final _mobileNuberFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();
  final _dobFocusNode = FocusNode();
  final _identityFocusNode = FocusNode();

  bool _passwordVisible = false;

  XFile? coverImage;
  XFile? identityProofImage;
  XFile? drivingLicense;
  List<FormImageConfigModel> formImages = <FormImageConfigModel>[];

  final ImagePicker picker = ImagePicker();

  Future getCoverImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    if (img != null) {
      setState(() {
        coverImage = img;
      });
    }
  }

  Future getIdentityProofImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    if (img != null) {
      setState(() {
        identityProofImage = img;
      });
    }
  }

  Future getDrivingLicenseImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    if (img != null) {
      setState(() {
        drivingLicense = img;
      });
    }
  }

  Future cleanCoverImage() async {
    setState(() {
      coverImage = null;
    });
  }

  Future cleanIdentityProofImage() async {
    setState(() {
      identityProofImage = null;
    });
  }

  Future cleanDrivingLicenseImage() async {
    setState(() {
      identityProofImage = null;
    });
  }

  Future cleanFormImage(String uuid) async {
    setState(() {
      final int indexOfSameUUID = formImages.indexWhere((x) => x.uuid == uuid);
      if (indexOfSameUUID != -1) {
        formImages.removeAt(indexOfSameUUID);
      }
    });
  }

  bool checkFormImageExist(String uuid) {
    final int indexOfSameUUID = formImages.indexWhere((x) => x.uuid == uuid);
    return indexOfSameUUID != -1 ? true : false;
  }

  Future getFormImage(ImageSource media, String uuid) async {
    var img = await picker.pickImage(source: media);
    if (img != null) {
      setState(() {
        final int indexOfSameUUID = formImages.indexWhere((x) => x.uuid == uuid);
        if (indexOfSameUUID != -1) {
          formImages.removeAt(indexOfSameUUID);
        } else {
          FormImageConfigModel param = FormImageConfigModel(file: img, uuid: uuid);
          formImages.add(param);
        }
      });
    }
  }

  String getFormImagePath(String uuid) {
    final int indexOfSameUUID = formImages.indexWhere((x) => x.uuid == uuid);
    return indexOfSameUUID != -1 ? formImages[indexOfSameUUID].file!.path : '';
  }

  XFile getFormImageCore(String uuid) {
    final int indexOfSameUUID = formImages.indexWhere((x) => x.uuid == uuid);
    return indexOfSameUUID != -1 ? formImages[indexOfSameUUID].file! : formImages[0].file!;
  }

  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestEmailUnfocusedEvent());
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestPasswordUnfocusedEvent());
      }
    });

    _firstNameFocusNode.addListener(() {
      if (!_firstNameFocusNode.hasFocus) {
        context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestFirstNameUnfocusedEvent());
      }
    });

    _lastNameFocusNode.addListener(() {
      if (!_lastNameFocusNode.hasFocus) {
        context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestLastNameUnfocusedEvent());
      }
    });

    _countryCodeFocusNode.addListener(() {
      if (!_countryCodeFocusNode.hasFocus) {
        context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestCountryCodeUnfocusedEvent());
      }
    });

    _mobileNuberFocusNode.addListener(() {
      if (!_mobileNuberFocusNode.hasFocus) {
        context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestMobileNumberUnfocusedEvent());
      }
    });

    _ageFocusNode.addListener(() {
      if (!_ageFocusNode.hasFocus) {
        context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestAgeUnfocusedEvent());
      }
    });

    _dobFocusNode.addListener(() {
      if (!_dobFocusNode.hasFocus) {
        context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestDOBUnfocusedEvent());
      }
    });

    _identityFocusNode.addListener(() {
      if (!_identityFocusNode.hasFocus) {
        context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestIdentityNumberUnfocusedEvent());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    countryCodeController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();

    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _countryCodeFocusNode.dispose();
    _mobileNuberFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    final isValid = context.select((DeliverymanRegisterRequestBloc bloc) => bloc.state.isValid);
    return BlocConsumer<DeliverymanRegisterRequestBloc, DeliverymanRegisterRequestState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isBasicFetched) {
          countryCodeController.text = '${state.flag} (${state.countryCodeField.value})';
        } else if (state.status.isUploadFailed) {
          if (state.uploadingImageTag == 'cover') {
            cleanCoverImage();
          } else if (state.uploadingImageTag == 'identityProof') {
            cleanIdentityProofImage();
          } else if (state.uploadingImageTag == 'license') {
            cleanDrivingLicenseImage();
          } else if (state.formUploadingImageUUID == 'form') {
            cleanFormImage(state.formUploadingImageUUID);
          }
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isUploadSuccess) {
          showSuccessDialog(context, translate.image_uploaded);
          if (state.uploadingImageTag == 'identityProof') {
            cleanIdentityProofImage();
          } else if (state.uploadingImageTag == 'cover') {
            cleanCoverImage();
          } else if (state.uploadingImageTag == 'license') {
            cleanDrivingLicenseImage();
          } else if (state.formUploadingImageUUID == 'form') {
            cleanFormImage(state.formUploadingImageUUID);
          }
        } else if (state.status.isLocalityFetching) {
          LoaderService.showLoader(context, msg: translate.please_wait);
        } else if (state.status.isLocalityFetched) {
          LoaderService.hideLoder(context);
        } else if (state.status.isLocalityFailed) {
          LoaderService.hideLoder(context);
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode).then((value) {});
        } else if (state.status.isSubmitSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.deliverymanRegisterRequestSuccessRoute, (Route<dynamic> route) => false);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.deliveryman_joining_title), scrolledUnderElevation: 0),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        state.coverImageField.value.isNotEmpty
                            ? Container(
                                width: 100,
                                height: 100,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: state.coverImageField.displayError != null ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder, width: state.coverImageField.displayError != null ? 2 : 0),
                                  shape: BoxShape.rectangle,
                                ),
                                child: CacheNetworkImageWidget(width: 100, height: 100, imageUrl: state.coverImageField.value),
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: state.coverImageField.displayError != null ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder, width: state.coverImageField.displayError != null ? 2 : 0),
                                  shape: BoxShape.rectangle,
                                ),
                                child: InkWell(
                                  onTap: coverImage != null
                                      ? null
                                      : () {
                                          showCupertinoModalPopup<void>(
                                            context: context,
                                            builder: (_) => CupertinoActionSheet(
                                              title: Text(translate.choose_from, style: kAppLblMediumFontSemiBold(context)),
                                              actions: <CupertinoActionSheetAction>[
                                                CupertinoActionSheetAction(
                                                  child: Text(translate.gallery, style: kAppLblMediumFontRegular(context)),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    getCoverImage(ImageSource.gallery);
                                                  },
                                                ),
                                                CupertinoActionSheetAction(
                                                  child: Text(translate.camera, style: kAppLblMediumFontRegular(context)),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    getCoverImage(ImageSource.camera);
                                                  },
                                                ),
                                                CupertinoActionSheetAction(
                                                  child: Text(translate.cancel_title, style: kAppLblMediumFontRegularError(context)),
                                                  onPressed: () => Navigator.pop(context),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                  child: coverImage != null
                                      ? Stack(
                                          children: [
                                            Image.file(File(coverImage!.path), width: 100, height: 100, fit: BoxFit.cover),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.5)]),
                                              ),
                                            ),
                                            state.status.isUploadStarted && state.uploadingImageTag == 'cover'
                                                ? Align(
                                                    alignment: Alignment.center,
                                                    child: kAppCircularProgress(context, color: 'primary', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0),
                                                  )
                                                : Align(
                                                    alignment: Alignment.center,
                                                    child: InkWell(
                                                      onTap: () => context.read<DeliverymanRegisterRequestBloc>().add(
                                                        DeliverymanRegisterRequestUploadImageEvent(newImage: coverImage!, formIndex: 0, uploadImageTag: 'cover', formUploadingImageUUID: ''),
                                                      ),
                                                      child: Text(translate.upload, style: kAppLblTinyBoldOffer(context)),
                                                    ),
                                                  ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: InkWell(
                                                onTap: () => cleanCoverImage(),
                                                child: const Icon(Icons.delete_forever_outlined, color: ThemeProvider.errorColor, size: 18),
                                              ),
                                            ),
                                          ],
                                        )
                                      : CacheNetworkImageWidget(width: 100, height: 100, imageUrl: state.coverImageField.value),
                                ),
                              ),
                        kAppSpacerVertical(height: 5),
                        Text("${translate.cover} (1:1)", style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                  ],
                ),
                kAppSpacerVertical(height: 20),
                TextFormField(
                  focusNode: _emailFocusNode,
                  controller: emailController,
                  decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.email_outlined), lblText: translate.email, errText: state.emailField.displayError != null ? translate.form_required : null),
                  style: kAppLblSmallFontMedium(context),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestEmailChangedEvent(email: value)),
                  textInputAction: TextInputAction.next,
                ),
                kAppSpacerVertical(height: 20),
                TextFormField(
                  focusNode: _passwordFocusNode,
                  decoration: kAppInputDecoration(
                    context,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    lblText: translate.password,
                    errText: state.passwordField.displayError != null ? translate.form_required : null,
                    suffixIcon: Icon(_passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    haveSuffixIcon: true,
                    onPressed: () => setState(() {
                      _passwordVisible = !_passwordVisible;
                    }),
                  ),
                  style: kAppLblSmallFontMedium(context),
                  obscureText: !_passwordVisible,
                  keyboardType: TextInputType.text,
                  onChanged: (value) => context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestPasswordChangedEvent(password: value)),
                  textInputAction: TextInputAction.done,
                ),
                kAppSpacerVertical(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        focusNode: _firstNameFocusNode,
                        controller: firstNameController,
                        decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.person_outline), lblText: translate.first_name, errText: state.firstNameField.displayError != null ? translate.form_required : null),
                        style: kAppLblSmallFontMedium(context),
                        keyboardType: TextInputType.text,
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                        onChanged: (value) {
                          if (value.startsWith(' ')) {
                            firstNameController.text = value.trimLeft();
                            firstNameController.selection = TextSelection.collapsed(offset: firstNameController.text.length);
                          }
                          if (RegExp(r'^[0-9]').hasMatch(value)) {
                            firstNameController.text = value.substring(1);
                            firstNameController.selection = TextSelection.collapsed(offset: firstNameController.text.length);
                          }
                          context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestFirstNameChangedEvent(firstName: firstNameController.text));
                        },
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    kAppSpacerHorizontal(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        focusNode: _lastNameFocusNode,
                        controller: lastNameController,
                        decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.person_outline), lblText: translate.last_name, errText: state.lastNameField.displayError != null ? translate.form_required : null),
                        style: kAppLblSmallFontMedium(context),
                        keyboardType: TextInputType.text,
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
                        onChanged: (value) {
                          if (value.startsWith(' ')) {
                            lastNameController.text = value.trimLeft();
                            lastNameController.selection = TextSelection.collapsed(offset: lastNameController.text.length);
                          }
                          if (RegExp(r'^[0-9]').hasMatch(value)) {
                            lastNameController.text = value.substring(1);
                            lastNameController.selection = TextSelection.collapsed(offset: lastNameController.text.length);
                          }
                          context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestLastNameChangedEvent(lastName: lastNameController.text));
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
                        controller: countryCodeController,
                        focusNode: _countryCodeFocusNode,
                        readOnly: true,
                        decoration: kAppInputDecoration(context, lblText: translate.code, errText: state.countryCodeField.displayError != null ? translate.form_required : null),
                        style: kAppLblSmallFontMedium(context),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return CountryCodeModalScreen(code: state.countryCodeField.value);
                                  },
                                  fullscreenDialog: true,
                                ),
                              )
                              .then((value) {
                                if (!context.mounted) return;
                                CountryCodeModalResponseModel countryCodeResponse = CountryCodeModalResponseModel.fromJson(value);
                                if (countryCodeResponse.action!) {
                                  countryCodeController.text = '${countryCodeResponse.flag} (${countryCodeResponse.dialCode})';
                                  context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestCountryCodeChangedEvent(countryCode: countryCodeResponse.dialCode!));
                                }
                              });
                        },
                      ),
                    ),
                    kAppSpacerHorizontal(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        focusNode: _mobileNuberFocusNode,
                        controller: mobileNumberController,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                        decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.person_outline), lblText: translate.mobile, errText: state.mobileNumberField.displayError != null ? translate.form_required : null),
                        style: kAppLblSmallFontMedium(context),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestMobileNumberChangedEvent(mobileNumber: value)),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                kAppSpacerVertical(height: 20),
                TextFormField(
                  focusNode: _ageFocusNode,
                  controller: ageController,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                  decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.timelapse_outlined), lblText: translate.age, errText: state.ageField.displayError != null ? translate.form_required : null),
                  style: kAppLblSmallFontMedium(context),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestAgeChangedEvent(age: value)),
                  textInputAction: TextInputAction.next,
                ),
                kAppSpacerVertical(height: 20),
                TextFormField(
                  focusNode: _dobFocusNode,
                  controller: dobController,
                  decoration: kAppInputDecoration(context, prefixIcon: const Icon(Icons.calendar_month_outlined), lblText: translate.dob, errText: state.dobField.displayError != null ? translate.form_required : null),
                  style: kAppLblLargeFontMedium(context),
                  readOnly: false,
                  keyboardType: TextInputType.number,
                  onTap: () async {
                    await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2100)).then((value) {
                      if (!context.mounted) return;
                      if (value != null) {
                        final String selectedDate = '${value.year}-${value.month}-${value.day}';
                        List<String> parts = selectedDate.split('-');
                        String normalizedDate = "${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}";
                        DateTime parsedDate = DateTime.parse(normalizedDate);
                        String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
                        dobController.text = formattedDate;
                        context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestDOBChangedEvent(dob: formattedDate));
                      }
                    });
                  },
                  textInputAction: TextInputAction.next,
                ),
                kAppSpacerVertical(height: 20),
                Text(translate.joining_type, style: kAppLblTinyFontRegular(context)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                  ),
                  child: DropdownButton<DeliverymanRegisterRequestJobTypeModel>(
                    underline: const SizedBox(),
                    isExpanded: true,
                    value: state.jobType,
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    style: kAppLblMediumFontRegular(context),
                    items: state.jobTypeList.map((DeliverymanRegisterRequestJobTypeModel item) {
                      return DropdownMenuItem<DeliverymanRegisterRequestJobTypeModel>(value: item, child: Text(kAppDDTranslate(context, item.label.toString())));
                    }).toList(),
                    onChanged: (newValue) {
                      context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestJobTypeChangeEvent(jobType: newValue!));
                    },
                  ),
                ),
                kAppSpacerVertical(height: 20),
                Text(translate.identity, style: kAppLblTinyFontRegular(context)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                  ),
                  child: DropdownButton<DeliverymanRegisterRequestIdentityTypeModel>(
                    underline: const SizedBox(),
                    isExpanded: true,
                    value: state.identityType,
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    style: kAppLblMediumFontRegular(context),
                    items: state.identityTypeList.map((DeliverymanRegisterRequestIdentityTypeModel item) {
                      return DropdownMenuItem<DeliverymanRegisterRequestIdentityTypeModel>(value: item, child: Text(kAppDDTranslate(context, item.label.toString())));
                    }).toList(),
                    onChanged: (newValue) {
                      context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestIdentityTypeChangeEvent(identity: newValue!));
                    },
                  ),
                ),
                kAppSpacerVertical(height: 20),
                TextFormField(
                  focusNode: _identityFocusNode,
                  controller: identityController,
                  decoration: kAppInputDecoration(
                    context,
                    prefixIcon: const Icon(Icons.file_present_outlined),
                    lblText: translate.identity_number,
                    errText: state.identityNumberField.displayError != null ? translate.form_required : null,
                  ),
                  style: kAppLblSmallFontMedium(context),
                  keyboardType: TextInputType.text,
                  onChanged: (value) => context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestIdentityNumberChangedEvent(identity: value)),
                  textInputAction: TextInputAction.next,
                ),
                kAppSpacerVertical(height: 20),
                Text("${translate.identity_proof} (1:1)", style: kAppLblTinyFontRegular(context)),
                kAppSpacerVertical(height: 5),
                state.indentityProofField.value.isNotEmpty
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: state.indentityProofField.displayError != null ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder, width: state.indentityProofField.displayError != null ? 2 : 0),
                          shape: BoxShape.rectangle,
                        ),
                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.indentityProofField.value),
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: state.indentityProofField.displayError != null ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder, width: state.indentityProofField.displayError != null ? 2 : 0),
                          shape: BoxShape.rectangle,
                        ),
                        child: InkWell(
                          onTap: identityProofImage != null
                              ? null
                              : () {
                                  showCupertinoModalPopup<void>(
                                    context: context,
                                    builder: (_) => CupertinoActionSheet(
                                      title: Text(translate.choose_from, style: kAppLblMediumFontSemiBold(context)),
                                      actions: <CupertinoActionSheetAction>[
                                        CupertinoActionSheetAction(
                                          child: Text(translate.gallery, style: kAppLblMediumFontRegular(context)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            getIdentityProofImage(ImageSource.gallery);
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          child: Text(translate.camera, style: kAppLblMediumFontRegular(context)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            getIdentityProofImage(ImageSource.camera);
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          child: Text(translate.cancel_title, style: kAppLblMediumFontRegularError(context)),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          child: identityProofImage != null
                              ? Stack(
                                  children: [
                                    Image.file(File(identityProofImage!.path), width: MediaQuery.of(context).size.width, height: 150, fit: BoxFit.cover),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.5)]),
                                      ),
                                    ),
                                    state.status.isUploadStarted && state.uploadingImageTag == 'identityProof'
                                        ? Align(
                                            alignment: Alignment.center,
                                            child: kAppCircularProgress(context, color: 'primary', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0),
                                          )
                                        : Align(
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              onTap: () => context.read<DeliverymanRegisterRequestBloc>().add(
                                                DeliverymanRegisterRequestUploadImageEvent(newImage: identityProofImage!, formIndex: 0, uploadImageTag: 'identityProof', formUploadingImageUUID: ''),
                                              ),
                                              child: Text(translate.upload, style: kAppLblTinyBoldOffer(context)),
                                            ),
                                          ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () => cleanIdentityProofImage(),
                                        child: const Icon(Icons.delete_forever_outlined, color: ThemeProvider.errorColor, size: 24),
                                      ),
                                    ),
                                  ],
                                )
                              : CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.indentityProofField.value),
                        ),
                      ),
                kAppSpacerVertical(height: 20),
                Text(translate.city, style: kAppLblTinyFontRegular(context)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                  ),
                  child: DropdownButton<DeliverymanRegisterRequestCitiesModel>(
                    underline: const SizedBox(),
                    isExpanded: true,
                    value: state.selectedCity,
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    style: kAppLblMediumFontRegular(context),
                    items: state.cityList.map((DeliverymanRegisterRequestCitiesModel item) {
                      return DropdownMenuItem<DeliverymanRegisterRequestCitiesModel>(value: item, child: Text(item.name.toString()));
                    }).toList(),
                    onChanged: (newValue) {
                      context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestCityChangeEvent(city: newValue!));
                    },
                  ),
                ),
                state.localityList.isNotEmpty ? kAppSpacerVertical(height: 20) : const SizedBox(),
                state.localityList.isNotEmpty ? Text(translate.locality, style: kAppLblTinyFontRegular(context)) : const SizedBox(),
                state.localityList.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                        ),
                        child: DropdownButton<LocalitiesFromCityModel>(
                          underline: const SizedBox(),
                          isExpanded: true,
                          value: state.selectedLocality,
                          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                          style: kAppLblMediumFontRegular(context),
                          items: state.localityList.map((LocalitiesFromCityModel item) {
                            return DropdownMenuItem<LocalitiesFromCityModel>(value: item, child: Text(item.name.toString()));
                          }).toList(),
                          onChanged: (newValue) {
                            context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestLocalityChangeEvent(locality: newValue!));
                          },
                        ),
                      )
                    : const SizedBox(),
                kAppSpacerVertical(height: 20),
                Text(translate.vehicle, style: kAppLblTinyFontRegular(context)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                  ),
                  child: DropdownButton<DeliverymanRegisterRequestVehicleModel>(
                    underline: const SizedBox(),
                    isExpanded: true,
                    value: state.selectedVehicle,
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    style: kAppLblMediumFontRegular(context),
                    items: state.vehicleList.map((DeliverymanRegisterRequestVehicleModel item) {
                      return DropdownMenuItem<DeliverymanRegisterRequestVehicleModel>(value: item, child: Text(item.name.toString()));
                    }).toList(),
                    onChanged: (newValue) {
                      context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestVehicleChangeEvent(vehicle: newValue!));
                    },
                  ),
                ),
                kAppSpacerVertical(height: 20),
                Text("${translate.driving_license} (2:1)", style: kAppLblTinyFontRegular(context)),
                kAppSpacerVertical(height: 5),
                state.drivingLicenseField.value.isNotEmpty
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: state.drivingLicenseField.displayError != null ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder, width: state.drivingLicenseField.displayError != null ? 2 : 0),
                          shape: BoxShape.rectangle,
                        ),
                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.drivingLicenseField.value),
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: state.drivingLicenseField.displayError != null ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder, width: state.drivingLicenseField.displayError != null ? 2 : 0),
                          shape: BoxShape.rectangle,
                        ),
                        child: InkWell(
                          onTap: drivingLicense != null
                              ? null
                              : () {
                                  showCupertinoModalPopup<void>(
                                    context: context,
                                    builder: (_) => CupertinoActionSheet(
                                      title: Text(translate.choose_from, style: kAppLblMediumFontSemiBold(context)),
                                      actions: <CupertinoActionSheetAction>[
                                        CupertinoActionSheetAction(
                                          child: Text(translate.gallery, style: kAppLblMediumFontRegular(context)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            getDrivingLicenseImage(ImageSource.gallery);
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          child: Text(translate.camera, style: kAppLblMediumFontRegular(context)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            getDrivingLicenseImage(ImageSource.camera);
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          child: Text(translate.cancel_title, style: kAppLblMediumFontRegularError(context)),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          child: drivingLicense != null
                              ? Stack(
                                  children: [
                                    Image.file(File(drivingLicense!.path), width: MediaQuery.of(context).size.width, height: 150, fit: BoxFit.cover),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.5)]),
                                      ),
                                    ),
                                    state.status.isUploadStarted && state.uploadingImageTag == 'license'
                                        ? Align(
                                            alignment: Alignment.center,
                                            child: kAppCircularProgress(context, color: 'primary', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0),
                                          )
                                        : Align(
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              onTap: () => context.read<DeliverymanRegisterRequestBloc>().add(
                                                DeliverymanRegisterRequestUploadImageEvent(newImage: drivingLicense!, formIndex: 0, uploadImageTag: 'license', formUploadingImageUUID: ''),
                                              ),
                                              child: Text(translate.upload, style: kAppLblTinyBoldOffer(context)),
                                            ),
                                          ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () => cleanCoverImage(),
                                        child: const Icon(Icons.delete_forever_outlined, color: ThemeProvider.errorColor, size: 24),
                                      ),
                                    ),
                                  ],
                                )
                              : CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.drivingLicenseField.value),
                        ),
                      ),
                kAppSpacerVertical(height: 20),
                state.formField.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          state.formField.length,
                          (formIndex) => Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state.formField[formIndex].type! == 'text') ...[
                                FormElementTextWidget(
                                  formIndex: formIndex,
                                  fieldName: state.formField[formIndex].title!,
                                  placeholder: state.formField[formIndex].placeholder!,
                                  isRequired: state.formField[formIndex].isRequired!,
                                  isSubmitted: state.isFormSubmitted,
                                  formValue: state.formField[formIndex].value!,
                                ),
                              ] else if (state.formField[formIndex].type! == 'number') ...[
                                FormElementNumberWidget(
                                  formIndex: formIndex,
                                  fieldName: state.formField[formIndex].title!,
                                  placeholder: state.formField[formIndex].placeholder!,
                                  isRequired: state.formField[formIndex].isRequired!,
                                  isSubmitted: state.isFormSubmitted,
                                  formValue: state.formField[formIndex].value!,
                                ),
                              ] else if (state.formField[formIndex].type! == 'file') ...[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(state.formField[formIndex].title!, style: kAppLblTinyFontRegular(context)),
                                    state.formField[formIndex].value!.isNotEmpty
                                        ? Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: const EdgeInsets.symmetric(vertical: 10),
                                            height: 150,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                color: state.formField[formIndex].isRequired! && state.isFormSubmitted && state.formField[formIndex].value!.isEmpty ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder,
                                                width: state.formField[formIndex].isRequired! && state.isFormSubmitted && state.formField[formIndex].value!.isEmpty ? 2 : 0,
                                              ),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.formField[formIndex].value!),
                                          )
                                        : Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: const EdgeInsets.symmetric(vertical: 10),
                                            height: 150,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                color: state.formField[formIndex].isRequired! && state.isFormSubmitted && state.formField[formIndex].value!.isEmpty ? ThemeProvider.errorColor : ThemeProvider.greyColorBorder,
                                                width: state.formField[formIndex].isRequired! && state.isFormSubmitted && state.formField[formIndex].value!.isEmpty ? 2 : 0,
                                              ),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: InkWell(
                                              onTap: checkFormImageExist(state.formField[formIndex].uuid!) == true
                                                  ? null
                                                  : () {
                                                      showCupertinoModalPopup<void>(
                                                        context: context,
                                                        builder: (_) => CupertinoActionSheet(
                                                          title: Text(translate.choose_from, style: kAppLblMediumFontSemiBold(context)),
                                                          actions: <CupertinoActionSheetAction>[
                                                            CupertinoActionSheetAction(
                                                              child: Text(translate.gallery, style: kAppLblMediumFontRegular(context)),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                getFormImage(ImageSource.gallery, state.formField[formIndex].uuid!);
                                                              },
                                                            ),
                                                            CupertinoActionSheetAction(
                                                              child: Text(translate.camera, style: kAppLblMediumFontRegular(context)),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                getFormImage(ImageSource.camera, state.formField[formIndex].uuid!);
                                                              },
                                                            ),
                                                            CupertinoActionSheetAction(
                                                              child: Text(translate.cancel_title, style: kAppLblMediumFontRegularError(context)),
                                                              onPressed: () => Navigator.pop(context),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                              child: checkFormImageExist(state.formField[formIndex].uuid!) == true
                                                  ? Stack(
                                                      children: [
                                                        Image.file(File(getFormImagePath(state.formField[formIndex].uuid!)), width: MediaQuery.of(context).size.width, height: 150, fit: BoxFit.cover),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.5)]),
                                                          ),
                                                        ),
                                                        state.status.isUploadStarted && state.uploadingImageTag == 'form' && state.formUploadingImageUUID == state.formField[formIndex].uuid!
                                                            ? Align(
                                                                alignment: Alignment.center,
                                                                child: kAppCircularProgress(context, color: 'primary', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0),
                                                              )
                                                            : Align(
                                                                alignment: Alignment.center,
                                                                child: InkWell(
                                                                  onTap: () => context.read<DeliverymanRegisterRequestBloc>().add(
                                                                    DeliverymanRegisterRequestUploadImageEvent(
                                                                      newImage: getFormImageCore(state.formField[formIndex].uuid!),
                                                                      formIndex: formIndex,
                                                                      uploadImageTag: 'form',
                                                                      formUploadingImageUUID: state.formField[formIndex].uuid!,
                                                                    ),
                                                                  ),
                                                                  child: Text(translate.upload, style: kAppLblTinyBoldOffer(context)),
                                                                ),
                                                              ),
                                                        Align(
                                                          alignment: Alignment.topRight,
                                                          child: InkWell(
                                                            onTap: () => cleanFormImage(state.formField[formIndex].uuid!),
                                                            child: const Icon(Icons.delete_forever_outlined, color: ThemeProvider.errorColor, size: 24),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150, imageUrl: state.formField[formIndex].value!),
                                            ),
                                          ),
                                  ],
                                ),
                              ] else if (state.formField[formIndex].type! == 'choose') ...[
                                FormElementCheckboxWidget(
                                  formIndex: formIndex,
                                  fieldName: state.formField[formIndex].title!,
                                  placeholder: state.formField[formIndex].placeholder!,
                                  isRequired: state.formField[formIndex].isRequired!,
                                  isSubmitted: state.isFormSubmitted,
                                  formValue: state.formField[formIndex].value!,
                                  items: state.formField[formIndex].items!,
                                ),
                              ] else if (state.formField[formIndex].type! == 'date') ...[
                                FormElementDateWidget(
                                  formIndex: formIndex,
                                  fieldName: state.formField[formIndex].title!,
                                  placeholder: state.formField[formIndex].placeholder!,
                                  isRequired: state.formField[formIndex].isRequired!,
                                  isSubmitted: state.isFormSubmitted,
                                  formValue: state.formField[formIndex].value!,
                                ),
                              ] else if (state.formField[formIndex].type! == 'email') ...[
                                FormElementEmailWidget(
                                  formIndex: formIndex,
                                  fieldName: state.formField[formIndex].title!,
                                  placeholder: state.formField[formIndex].placeholder!,
                                  isRequired: state.formField[formIndex].isRequired!,
                                  isSubmitted: state.isFormSubmitted,
                                  formValue: state.formField[formIndex].value!,
                                ),
                              ] else if (state.formField[formIndex].type! == 'phone') ...[
                                FormElementPhoneWidget(
                                  formIndex: formIndex,
                                  fieldName: state.formField[formIndex].title!,
                                  placeholder: state.formField[formIndex].placeholder!,
                                  isRequired: state.formField[formIndex].isRequired!,
                                  isSubmitted: state.isFormSubmitted,
                                  formValue: state.formField[formIndex].value!,
                                  extraFormValue: state.formField[formIndex].extraValue!,
                                  flag: state.flag,
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid ? () => context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestSubmitEvent()) : null,
                style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                child: state.status.isSubmit ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.submit),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FormElementTextWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  const FormElementTextWidget({super.key, required this.formIndex, required this.fieldName, required this.placeholder, required this.isRequired, required this.isSubmitted, required this.formValue});

  @override
  State<FormElementTextWidget> createState() => _FormElementTextWidgetState();
}

class _FormElementTextWidgetState extends State<FormElementTextWidget> {
  late TextEditingController formTextController;

  @override
  void initState() {
    super.initState();
    formTextController = TextEditingController(text: widget.formValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: formTextController,
        decoration: kAppInputDecoration(context, lblText: widget.fieldName, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
        style: kAppLblLargeFontMedium(context),
        keyboardType: TextInputType.text,
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^\w\s]+'))],
        onChanged: (value) {
          if (value.startsWith(' ')) {
            formTextController.text = value.trimLeft();
            formTextController.selection = TextSelection.collapsed(offset: formTextController.text.length);
          }
          if (RegExp(r'^[0-9]').hasMatch(value)) {
            formTextController.text = value.substring(1);
            formTextController.selection = TextSelection.collapsed(offset: formTextController.text.length);
          }
          context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestFormTextInputChangeEvent(formIndex: widget.formIndex, value: formTextController.text));
        },
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class FormElementNumberWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  const FormElementNumberWidget({super.key, required this.formIndex, required this.fieldName, required this.placeholder, required this.isRequired, required this.isSubmitted, required this.formValue});

  @override
  State<FormElementNumberWidget> createState() => _FormElementNumberWidgetState();
}

class _FormElementNumberWidgetState extends State<FormElementNumberWidget> {
  late TextEditingController formNumberController;

  @override
  void initState() {
    super.initState();
    formNumberController = TextEditingController(text: widget.formValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: formNumberController,
        decoration: kAppInputDecoration(context, lblText: widget.fieldName, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
        style: kAppLblLargeFontMedium(context),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
        onChanged: (value) => context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestFormTextInputChangeEvent(formIndex: widget.formIndex, value: formNumberController.text)),
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class FormElementEmailWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  const FormElementEmailWidget({super.key, required this.formIndex, required this.fieldName, required this.placeholder, required this.isRequired, required this.isSubmitted, required this.formValue});

  @override
  State<FormElementEmailWidget> createState() => _FormElementEmailWidgetState();
}

class _FormElementEmailWidgetState extends State<FormElementEmailWidget> {
  late TextEditingController formEmailController;

  @override
  void initState() {
    super.initState();
    formEmailController = TextEditingController(text: widget.formValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: formEmailController,
        decoration: kAppInputDecoration(context, lblText: widget.fieldName, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
        style: kAppLblLargeFontMedium(context),
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) => context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestFormTextInputChangeEvent(formIndex: widget.formIndex, value: formEmailController.text)),
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class FormElementDateWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  const FormElementDateWidget({super.key, required this.formIndex, required this.fieldName, required this.placeholder, required this.isRequired, required this.isSubmitted, required this.formValue});

  @override
  State<FormElementDateWidget> createState() => _FormElementDateWidgetState();
}

class _FormElementDateWidgetState extends State<FormElementDateWidget> {
  late TextEditingController formDateController;

  @override
  void initState() {
    super.initState();
    formDateController = TextEditingController(text: widget.formValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: formDateController,
        decoration: kAppInputDecoration(context, lblText: widget.fieldName, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
        style: kAppLblLargeFontMedium(context),
        readOnly: false,
        keyboardType: TextInputType.number,
        onTap: () async {
          await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2100)).then((value) {
            if (!context.mounted) return;
            if (value != null) {
              final String selectedDate = '${value.year}-${value.month}-${value.day}';
              List<String> parts = selectedDate.split('-');
              String normalizedDate = "${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}";
              DateTime parsedDate = DateTime.parse(normalizedDate);
              String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
              formDateController.text = formattedDate;
              context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestFormTextInputChangeEvent(formIndex: widget.formIndex, value: formattedDate));
            }
          });
        },
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class FormElementCheckboxWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  final List<DeliverymanFormElementItemConfigModel> items;
  const FormElementCheckboxWidget({super.key, required this.formIndex, required this.fieldName, required this.placeholder, required this.isRequired, required this.isSubmitted, required this.formValue, required this.items});

  @override
  State<FormElementCheckboxWidget> createState() => _FormElementCheckboxWidgetState();
}

class _FormElementCheckboxWidgetState extends State<FormElementCheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.fieldName, style: kAppLblTinyFontRegular(context)),
        kAppSpacerVertical(height: 5),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            widget.items.length,
            (checkboxIndex) => GestureDetector(
              onTap: () => context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestFormCheckboxChangeEvent(formIndex: widget.formIndex, checkboxIndex: checkboxIndex)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.items[checkboxIndex].name!, style: kAppLblTinyFontRegular(context)),
                    Icon(widget.items[checkboxIndex].value! == true ? Icons.check_box : Icons.check_box_outline_blank_outlined, size: 12, color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FormElementPhoneWidget extends StatefulWidget {
  final int formIndex;
  final String fieldName;
  final String placeholder;
  final bool isRequired;
  final bool isSubmitted;
  final String formValue;
  final String extraFormValue;
  final String flag;
  const FormElementPhoneWidget({
    super.key,
    required this.formIndex,
    required this.fieldName,
    required this.placeholder,
    required this.isRequired,
    required this.isSubmitted,
    required this.formValue,
    required this.extraFormValue,
    required this.flag,
  });

  @override
  State<FormElementPhoneWidget> createState() => _FormElementPhoneWidgetState();
}

class _FormElementPhoneWidgetState extends State<FormElementPhoneWidget> {
  late TextEditingController formCountryCodeController;
  late TextEditingController formMobileController;

  @override
  void initState() {
    super.initState();
    formCountryCodeController = TextEditingController(text: '${widget.flag} ${widget.extraFormValue}');
    formMobileController = TextEditingController(text: widget.formValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              controller: formCountryCodeController,
              readOnly: true,
              decoration: kAppInputDecoration(context, lblText: translate.country_code, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
              style: kAppLblSmallFontMedium(context),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return CountryCodeModalScreen(code: widget.extraFormValue);
                        },
                        fullscreenDialog: true,
                      ),
                    )
                    .then((value) {
                      if (!context.mounted) return;
                      CountryCodeModalResponseModel countryCodeResponse = CountryCodeModalResponseModel.fromJson(value);
                      if (countryCodeResponse.action!) {
                        formCountryCodeController.text = '${countryCodeResponse.flag} (${countryCodeResponse.dialCode})';
                        context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestFormCountryCodeChangeEvent(formIndex: widget.formIndex, value: countryCodeResponse.dialCode!));
                      }
                    });
              },
            ),
          ),
        ),
        kAppSpacerHorizontal(width: 10),
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              controller: formMobileController,
              decoration: kAppInputDecoration(context, lblText: widget.fieldName, errText: widget.isRequired && widget.isSubmitted && widget.formValue.isEmpty ? translate.form_required : null),
              style: kAppLblLargeFontMedium(context),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              onChanged: (value) => context.read<DeliverymanRegisterRequestBloc>().add(DeliverymanRegisterRequestFormTextInputChangeEvent(formIndex: widget.formIndex, value: formMobileController.text)),
              textInputAction: TextInputAction.next,
            ),
          ),
        ),
      ],
    );
  }
}

class FormImageConfigModel {
  String? uuid;
  XFile? file;

  FormImageConfigModel({this.uuid, this.file});

  FormImageConfigModel.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['file'] = file;
    return data;
  }
}

