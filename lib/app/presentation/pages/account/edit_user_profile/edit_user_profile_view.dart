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
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/account/edit_user_profile/bloc/edit_user_profile_bloc.dart';
import 'package:user/app/presentation/pages/modals/user_avatar_list/user_avatar_list_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class EditUserProfileScreen extends StatelessWidget {
  const EditUserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EditUserProfileView();
  }
}

class EditUserProfileView extends StatefulWidget {
  const EditUserProfileView({super.key});

  @override
  State<EditUserProfileView> createState() => _EditUserProfileViewState();
}

class _EditUserProfileViewState extends State<EditUserProfileView> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _countryCodeFocusNode = FocusNode();
  final _mobileNumberFocusNode = FocusNode();

  XFile? newImage;
  final ImagePicker picker = ImagePicker();

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    setState(() {
      newImage = img;
    });
    uploadImageNow(img!);
  }

  void uploadImageNow(XFile img) {
    context.read<EditUserProfileBloc>().add(EditUserProfileUploadImageEvent(newImage: img));
  }

  Future cleanImage() async {
    setState(() {
      newImage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<EditUserProfileBloc>().add(EditUserProfileInitialEvent());
    _firstNameFocusNode.addListener(() {
      if (!_firstNameFocusNode.hasFocus) {
        context.read<EditUserProfileBloc>().add(EditUserProfileFirstNameUnfocusedEvent());
      }
    });

    _lastNameFocusNode.addListener(() {
      if (!_lastNameFocusNode.hasFocus) {
        context.read<EditUserProfileBloc>().add(EditUserProfileLastNameUnfocusedEvent());
      }
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _countryCodeFocusNode.dispose();
    _mobileNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = context.select((EditUserProfileBloc bloc) => bloc.state.isValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<EditUserProfileBloc, EditUserProfileState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          _countryCodeController.text = '${state.flag} (${state.countryCode.value})';
          _firstNameController.text = state.model.info!.firstName!;
          _lastNameController.text = state.model.info!.lastName!;
          _emailController.text = state.model.info!.email!;
          _mobileController.text = state.model.info!.mobile!;
        } else if (state.status.isFailure || state.status.isSubmitFailed || state.status.isUploadFailed) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isSubmitSuccess) {
          showSuccessDialog(context, translate.profile_updated);
        } else if (state.status.isUploadSuccess) {
          showSuccessDialog(context, translate.avatar_uploaded);
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isSubmit || state.status.isUploadStarted ? true : false,
          child: Scaffold(
            appBar: AppBar(title: Text(translate.your_profile), scrolledUnderElevation: 0),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const EditUserProfileLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const EditUserProfileErrorView(),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showCupertinoModalPopup<void>(
                              context: context,
                              builder: (_) => CupertinoActionSheet(
                                title: Text(translate.choose_from, style: kAppLblMediumFontSemiBold(context)),
                                actions: <CupertinoActionSheetAction>[
                                  CupertinoActionSheetAction(
                                    child: Text(translate.avatar_list, style: kAppLblMediumFontRegular(context)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        isDismissible: false,
                                        enableDrag: false,
                                        showDragHandle: false,
                                        useSafeArea: true,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        builder: (BuildContext context) {
                                          return const FractionallySizedBox(child: UserAvatarListModalScreen());
                                        },
                                      ).then((value) {
                                        if (!context.mounted) return;
                                        if (value != null && value.toString().isNotEmpty) {
                                          context.read<EditUserProfileBloc>().add(EditUserProfileAvatarSelectEvent(avatar: value));
                                        }
                                      });
                                    },
                                  ),
                                  CupertinoActionSheetAction(
                                    child: Text(translate.gallery, style: kAppLblMediumFontRegular(context)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      getImage(ImageSource.gallery);
                                    },
                                  ),
                                  CupertinoActionSheetAction(
                                    child: Text(translate.camera, style: kAppLblMediumFontRegular(context)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      getImage(ImageSource.camera);
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
                          child: Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              border: Border.all(color: Theme.of(context).disabledColor, width: 2),
                              shape: BoxShape.rectangle,
                            ),
                            child: newImage != null
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                                    child: Stack(
                                      children: [
                                        Image.file(File(newImage!.path), width: 100, height: 100, fit: BoxFit.cover),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.5)]),
                                          ),
                                        ),
                                        state.status.isUploadStarted
                                            ? Align(
                                                alignment: Alignment.center,
                                                child: kAppCircularProgress(context, color: 'primary', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                                    child: CacheNetworkImageWidget(width: 100, height: 100, imageUrl: state.image),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    kAppSpacerVertical(height: 40),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _firstNameController,
                            focusNode: _firstNameFocusNode,
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
                              context.read<EditUserProfileBloc>().add(EditUserProfileFirstNameChangedEvent(firstName: _firstNameController.text));
                            },
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        kAppSpacerHorizontal(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _lastNameController,
                            focusNode: _lastNameFocusNode,
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
                              context.read<EditUserProfileBloc>().add(EditUserProfileLastNameChangedEvent(lastName: _lastNameController.text));
                            },
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    kAppSpacerVertical(height: 20),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        iconColor: Theme.of(context).canvasColor,
                        prefixIconColor: Theme.of(context).canvasColor,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pushNamed(AppRouter.accountSettingChangeEmailRoute),
                              child: Text(translate.edit, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                            ),
                          ],
                        ),
                        labelText: translate.email,
                        labelStyle: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium?.fontSize, fontFamily: 'medium', color: Theme.of(context).canvasColor),
                        errorStyle: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium?.fontSize, fontFamily: 'medium'),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).canvasColor)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).canvasColor),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      style: kAppLblSmallFontMedium(context),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    kAppSpacerVertical(height: 20),
                    TextFormField(
                      controller: _mobileController,
                      focusNode: _mobileNumberFocusNode,
                      readOnly: true,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.call_outlined),
                        iconColor: Theme.of(context).canvasColor,
                        prefixIconColor: Theme.of(context).canvasColor,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pushNamed(AppRouter.accountSettingChangeMobileRoute),
                              child: Text(translate.edit, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                            ),
                          ],
                        ),
                        labelText: translate.mobile,
                        labelStyle: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium?.fontSize, fontFamily: 'medium', color: Theme.of(context).canvasColor),
                        errorStyle: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium?.fontSize, fontFamily: 'medium'),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).canvasColor)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).canvasColor),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      style: kAppLblSmallFontMedium(context),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    kAppSpacerVertical(height: 20),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, top: 5),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                      ),
                      child: DropdownButton<UserProfileGenderModel>(
                        underline: const SizedBox(),
                        isExpanded: true,
                        value: state.gender,
                        dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                        style: kAppLblMediumFontRegular(context),
                        items: state.genderList.map((UserProfileGenderModel item) {
                          return DropdownMenuItem<UserProfileGenderModel>(value: item, child: Text(kAppDDTranslate(context, item.label.toString())));
                        }).toList(),
                        onChanged: (newValue) {
                          context.read<EditUserProfileBloc>().add(EditUserProfileChangeGenderEvent(gender: newValue!));
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: state.status.isLoading || state.status.isFailure
                ? SafeArea(child: const SizedBox())
                : SafeArea(
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
                                  onPressed: isValid ? () => context.read<EditUserProfileBloc>().add(EditUserProfileSubmitEvent()) : null,
                                  style: kAppElevatedButtonStyle(
                                    context,
                                    disabledColor: Theme.of(context).disabledColor,
                                    bgColor: Theme.of(context).primaryColor,
                                    foreColor: Theme.of(context).scaffoldBackgroundColor,
                                    height: 50.0,
                                  ),
                                  child: state.status.isSubmit ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.update_profile),
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

class EditUserProfileLoadingView extends StatelessWidget {
  const EditUserProfileLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [SkeletonLine(style: SkeletonLineStyle(height: 100.0, width: 100.0, borderRadius: BorderRadius.circular(50.0)))],
        ),
        kAppSpacerVertical(height: 20),
        SkeletonLine(
          style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
        ),
        kAppSpacerVertical(height: 10),
        SkeletonLine(
          style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
        ),
        kAppSpacerVertical(height: 10),
        SkeletonLine(
          style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
        ),
        kAppSpacerVertical(height: 10),
        SkeletonLine(
          style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
        ),
      ],
    );
  }
}

class EditUserProfileErrorView extends StatelessWidget {
  const EditUserProfileErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.empty_data_two, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

