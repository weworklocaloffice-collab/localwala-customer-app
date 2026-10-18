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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/complaints_issue_with_list_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/order_details_complaints_model.dart';
import 'package:user/app/presentation/pages/modals/complaints_modal/bloc/complaints_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ComplaintModalScreen extends StatelessWidget {
  final String orderId;
  const ComplaintModalScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ComplaintsModalBloc()..add(ComplaintsModalInitialEvent(orderId: orderId)),
      child: const ComplaintModalView(),
    );
  }
}

class ComplaintModalView extends StatefulWidget {
  const ComplaintModalView({super.key});

  @override
  State<ComplaintModalView> createState() => _ComplaintModalViewState();
}

class _ComplaintModalViewState extends State<ComplaintModalView> {
  XFile? newImage;
  final ImagePicker picker = ImagePicker();

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    setState(() {
      newImage = img;
    });
  }

  Future cleanImage() async {
    setState(() {
      newImage = null;
    });
  }

  final _titleFocusNode = FocusNode();
  final _briefFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleFocusNode.addListener(() {
      if (!_titleFocusNode.hasFocus) {
        context.read<ComplaintsModalBloc>().add(ComplaintModalTitleUnfocusedEvent());
      }
    });

    _briefFocusNode.addListener(() {
      if (!_briefFocusNode.hasFocus) {
        context.read<ComplaintsModalBloc>().add(ComplaintModalBriefUnfocusedEvent());
      }
    });
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _briefFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = context.select((ComplaintsModalBloc bloc) => bloc.state.isValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<ComplaintsModalBloc, ComplaintsModalState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isUploadFailed) {
          cleanImage();
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isUploadSuccess) {
          showSuccessDialog(context, translate.image_uploaded);
          cleanImage();
        } else if (state.status.isMediaDeleteFailed) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isMediaDeleteSuccess) {
          showSuccessDialog(context, translate.image_deleted);
        } else if (state.status.isSubmitFailed) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isSubmitSuccess) {
          showSuccessDialog(context, translate.complaint_saved).then((value) {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop();
          });
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isInProgress || state.status.isUploadStarted || state.status.isMediaDeleteStarted ? true : false,
          child: Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: FaIcon(FontAwesomeIcons.chevronDown, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
              ),
              title: Text(translate.complaints),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const ComplaintLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const ComplaintErroView(),
                  ] else if (state.status.isSuccess ||
                      state.status.isInProgress ||
                      state.status.isUploadStarted ||
                      state.status.isUploadSuccess ||
                      state.status.isUploadFailed ||
                      state.status.isMediaDeleteStarted ||
                      state.status.isMediaDeleteFailed ||
                      state.status.isMediaDeleteSuccess ||
                      state.status.isSubmitFailed ||
                      state.status.isSubmitSuccess) ...[
                    state.complaintsWith.isNotEmpty ? Text(translate.complaint_to, style: kAppLblTinyFontRegular(context)) : const SizedBox(),
                    state.complaintsWith.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 10, top: 5),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                            ),
                            child: DropdownButton<ComplaintIssueWithListModel>(
                              underline: const SizedBox(),
                              isExpanded: true,
                              value: state.complaintTo,
                              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                              style: kAppLblMediumFontRegular(context),
                              items: state.complaintsWith.map((ComplaintIssueWithListModel item) {
                                return DropdownMenuItem<ComplaintIssueWithListModel>(value: item, child: Text(kAppDDTranslate(context, item.label.toString())));
                              }).toList(),
                              onChanged: (newValue) {
                                context.read<ComplaintsModalBloc>().add(ComplaintModalIssueWithEvent(issueWith: newValue!));
                              },
                            ),
                          )
                        : const SizedBox(),
                    state.reasonList.isNotEmpty ? Text(translate.select_reason, style: kAppLblTinyFontRegular(context)) : const SizedBox(),
                    state.reasonList.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 10, top: 5),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                            ),
                            child: DropdownButton<ComplaintReasonListModel>(
                              underline: const SizedBox(),
                              isExpanded: true,
                              value: state.reason,
                              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                              style: kAppLblMediumFontRegular(context),
                              items: state.reasonList.map((ComplaintReasonListModel item) {
                                return DropdownMenuItem<ComplaintReasonListModel>(value: item, child: Text(item.name.toString()));
                              }).toList(),
                              onChanged: (newValue) {
                                context.read<ComplaintsModalBloc>().add(ComplaintModalReasonSelectEvent(reason: newValue!));
                              },
                            ),
                          )
                        : const SizedBox(),
                    state.complaintTo.value == 'product' ? Text(translate.select_product, style: kAppLblTinyFontRegular(context)) : const SizedBox(),
                    state.complaintTo.value == 'product' && state.details.details!.cartItem!.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 10, top: 5),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                            ),
                            child: DropdownButton<FoodInCartModel>(
                              underline: const SizedBox(),
                              isExpanded: true,
                              value: state.food,
                              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                              style: kAppLblMediumFontRegular(context),
                              items: state.details.details!.cartItem!.map((FoodInCartModel item) {
                                return DropdownMenuItem<FoodInCartModel>(value: item, child: Text(item.name.toString()));
                              }).toList(),
                              onChanged: (newValue) {
                                context.read<ComplaintsModalBloc>().add(ComplaintModalFoodSelectEvent(food: newValue!));
                              },
                            ),
                          )
                        : const SizedBox(),
                    Text(translate.complaint_title, style: kAppLblTinyFontRegular(context)),
                    kAppSpacerVertical(height: 5),
                    TextFormField(
                      initialValue: state.complaintTitle.value,
                      focusNode: _titleFocusNode,
                      decoration: kAppInputDecoration(context, lblText: '', errText: state.complaintTitle.displayError != null ? translate.form_required : null),
                      style: kAppLblSmallFontMedium(context),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => context.read<ComplaintsModalBloc>().add(ComplaintModalTitleChangedEvent(title: value)),
                      textInputAction: TextInputAction.next,
                    ),
                    kAppSpacerVertical(height: 5),
                    Text(translate.complaint_brief, style: kAppLblTinyFontRegular(context)),
                    kAppSpacerVertical(height: 5),
                    TextFormField(
                      initialValue: state.complaintBrief.value,
                      focusNode: _briefFocusNode,
                      decoration: kAppInputDecoration(context, lblText: '', errText: state.complaintBrief.displayError != null ? translate.form_required : null),
                      maxLines: 4,
                      style: kAppLblSmallFontMedium(context),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => context.read<ComplaintsModalBloc>().add(ComplaintModalBriefChangedEvent(brief: value)),
                      textInputAction: TextInputAction.done,
                    ),
                    kAppSpacerVertical(height: 10),
                    Text(translate.upload_max_three_images, style: kAppLblTinyFontRegular(context)),
                    kAppSpacerVertical(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        state.imageProof.isNotEmpty && state.imageProof[0].isNotEmpty
                            ? Container(
                                height: 100,
                                width: 100,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                                ),
                                child: Stack(
                                  children: [
                                    CacheNetworkImageWidget(width: 80, height: 80, imageUrl: state.imageProof[0]),
                                    state.status.isMediaDeleteStarted && state.mediaDeleteIndex == 0
                                        ? Align(
                                            alignment: Alignment.center,
                                            child: kAppCircularProgress(context, color: 'primary', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0),
                                          )
                                        : Align(
                                            alignment: Alignment.topRight,
                                            child: InkWell(
                                              onTap: () => context.read<ComplaintsModalBloc>().add(ComplaintModalRemoveUploadImageEvent(index: 0)),
                                              child: const Icon(Icons.delete_forever_outlined, color: ThemeProvider.errorColor, size: 18),
                                            ),
                                          ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        state.imageProof.isNotEmpty && state.imageProof.length >= 2 && state.imageProof[1].isNotEmpty
                            ? Container(
                                height: 100,
                                width: 100,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                                ),
                                child: Stack(
                                  children: [
                                    CacheNetworkImageWidget(width: 80, height: 80, imageUrl: state.imageProof[1]),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () => context.read<ComplaintsModalBloc>().add(ComplaintModalRemoveUploadImageEvent(index: 1)),
                                        child: const Icon(Icons.delete_forever_outlined, color: ThemeProvider.errorColor, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        state.imageProof.isNotEmpty && state.imageProof.length >= 3 && state.imageProof[2].isNotEmpty
                            ? Container(
                                height: 100,
                                width: 100,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                                ),
                                child: Stack(
                                  children: [
                                    CacheNetworkImageWidget(width: 80, height: 80, imageUrl: state.imageProof[2]),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () => context.read<ComplaintsModalBloc>().add(ComplaintModalRemoveUploadImageEvent(index: 2)),
                                        child: const Icon(Icons.delete_forever_outlined, color: ThemeProvider.errorColor, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        state.imageProof.isEmpty || state.imageProof.length != 3
                            ? Container(
                                height: 100,
                                width: 100,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                                ),
                                child: InkWell(
                                  onTap: newImage != null
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
                                  child: newImage != null
                                      ? Stack(
                                          children: [
                                            Image.file(File(newImage!.path), width: 80, height: 80, fit: BoxFit.cover),
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
                                                : Align(
                                                    alignment: Alignment.center,
                                                    child: InkWell(
                                                      onTap: () => context.read<ComplaintsModalBloc>().add(ComplaintModalUploadImageEvent(newImage: newImage!)),
                                                      child: Text(translate.upload, style: kAppLblTinyBoldOffer(context)),
                                                    ),
                                                  ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: InkWell(
                                                onTap: () => cleanImage(),
                                                child: const Icon(Icons.delete_forever_outlined, color: ThemeProvider.errorColor, size: 18),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.image, color: Theme.of(context).canvasColor, size: 18),
                                            kAppSpacerVertical(height: 10),
                                            Text(translate.upload_proof, textAlign: TextAlign.center, style: kAppLblTinyFontRegular(context)),
                                          ],
                                        ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ],
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
                            onPressed: () => isValid ? context.read<ComplaintsModalBloc>().add(ComplaintModalSubmittedEvent()) : null,
                            style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50),
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

class ComplaintLoadingView extends StatelessWidget {
  const ComplaintLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(style: SkeletonLineStyle(height: 8, width: 64, borderRadius: BorderRadius.circular(8))),
                const SizedBox(width: 5),
                SkeletonLine(style: SkeletonLineStyle(height: 8, width: 64, borderRadius: BorderRadius.circular(8))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
        const SizedBox(height: 20),
        SkeletonLine(
          style: SkeletonLineStyle(height: 50, width: double.infinity, borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(10, (index) {
              return SkeletonAvatar(
                style: SkeletonAvatarStyle(width: 80, height: 30, padding: const EdgeInsets.symmetric(horizontal: 5), borderRadius: BorderRadius.circular(8)),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: List.generate(5, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          SkeletonLine(
                            style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(height: 5),
                          SkeletonLine(
                            style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(height: 5),
                          SkeletonLine(
                            style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SkeletonLine(style: SkeletonLineStyle(height: 25, width: 25, borderRadius: BorderRadius.circular(8))),
                              const SizedBox(width: 10),
                              SkeletonLine(style: SkeletonLineStyle(height: 25, width: 25, borderRadius: BorderRadius.circular(8))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SkeletonAvatar(style: SkeletonAvatarStyle(width: 80, height: 80, borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class ComplaintErroView extends StatelessWidget {
  const ComplaintErroView({super.key});

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

