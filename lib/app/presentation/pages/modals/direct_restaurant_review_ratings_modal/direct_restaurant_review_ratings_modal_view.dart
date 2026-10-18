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
import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/modals/direct_restaurant_review_ratings_modal/bloc/direct_restaurant_review_ratings_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DirectRestaurantReviewRatingsModalScreen extends StatelessWidget {
  final String restaurant;
  const DirectRestaurantReviewRatingsModalScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DirectRestaurantReviewRatingsModalBloc()..add(DirectRestaurantReviewRatingsModalInitialEvent(restaurant: restaurant)),
      child: const DirectRestaurantReviewRatingsModalView(),
    );
  }
}

class DirectRestaurantReviewRatingsModalView extends StatefulWidget {
  const DirectRestaurantReviewRatingsModalView({super.key});

  @override
  State<DirectRestaurantReviewRatingsModalView> createState() => _DirectRestaurantReviewRatingsModalViewState();
}

class _DirectRestaurantReviewRatingsModalViewState extends State<DirectRestaurantReviewRatingsModalView> {
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<DirectRestaurantReviewRatingsModalBloc, DirectRestaurantReviewRatingsModalState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isSubmitFailed || state.status.isMediaDeleteFailed) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isSubmitSuccess) {
          showSuccessDialog(context, translate.review_saved).then((value) {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop();
          });
        } else if (state.status.isUploadFailed) {
          cleanImage();
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isUploadSuccess) {
          showSuccessDialog(context, translate.image_uploaded);
          cleanImage();
        } else if (state.status.isMediaDeleteSuccess) {
          showSuccessDialog(context, translate.image_deleted);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(translate.review_and_rating),
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(false), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const DirectRestaurantReviewRatingsModalLoadingView(),
                ] else if (state.status.isFailure) ...[
                  Container(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(translate.oops_title, style: kAppLblLargeFontBold(context)),
                        kAppSpacerVertical(height: 5),
                        Text(translate.restaurant_direct_review_error, textAlign: TextAlign.center, style: kAppLblSmallFontMedium(context)),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(kAppTrimWord(state.model.info!.name!, 40), style: kAppLblMediumFontBold(context)),
                                    kAppSpacerVertical(height: 5),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width / 1.8,
                                      child: Text(state.model.info!.address!, maxLines: 2, style: kAppLblTinyFontRegular(context)),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 40.0,
                                  width: 40.0,
                                  child: CircleAvatar(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: state.model.info!.cover!),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Text("${translate.please_rate} ${kAppTrimWord(state.model.info!.name!, 35)} ${translate.end_service}", style: kAppLblMediumFontBold(context)),
                  ),
                  state.model.orderSettings!.ratingStyle! == 'emoji'
                      ? Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: EmojiRatingWidget(iconHeight: 30, iconWidget: 30, rateNumber: state.restauratnRating),
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: StarRatingWidget(iconHeight: 30, iconWidget: 30, rateNumber: state.restauratnRating),
                        ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: state.restaurantMessageList
                          .map(
                            (item) => InkWell(
                              onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalRestaurantMessageSelectEvent(id: item.id!)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(color: state.restaurantMessage.contains(item.id!) ? Theme.of(context).primaryColor : Theme.of(context).canvasColor, width: 1),
                                ),
                                child: Text(item.name!, style: kAppLblTinyFontRegularChip(context, color: state.restaurantMessage.contains(item.id!) ? 'primary' : 'regular')),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Text(translate.write_a_review, style: kAppLblTinyFontRegular(context)),
                  kAppSpacerVertical(height: 5),
                  TextFormField(
                    decoration: kAppInputDecoration(context, lblText: translate.write_experience, errText: null),
                    maxLines: 4,
                    style: kAppLblSmallFontMedium(context),
                    keyboardType: TextInputType.text,
                    onChanged: (value) => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalShortReviewTextChangeEvent(txt: value)),
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
                                            onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalRemoveUploadImageEvent(index: 0)),
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
                                      onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalRemoveUploadImageEvent(index: 1)),
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
                                      onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalRemoveUploadImageEvent(index: 2)),
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
                                                    onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalUploadImageEvent(newImage: newImage!)),
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
                  kAppSpacerVertical(height: 10),
                ],
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: SizedBox(
              height: !state.status.isLoading && !state.status.isFailure ? 50 : 0,
              child: !state.status.isLoading && !state.status.isFailure
                  ? Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state.canSubmit ? () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalSubmitEvent()) : null,
                                style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                                child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.save_reviews),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        );
      },
    );
  }
}

class EmojiRatingWidget extends StatelessWidget {
  final int rateNumber;
  final double iconHeight;
  final double iconWidget;
  const EmojiRatingWidget({super.key, required this.rateNumber, required this.iconHeight, required this.iconWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalIconPressEvent(rate: 1)),
          child: Image.asset(
            rateNumber != 0 && rateNumber > 1
                ? AssetsUrl.iconsURL.rateEmojiOff
                : rateNumber == 1
                ? AssetsUrl.iconsURL.rate1EmojiOn
                : AssetsUrl.iconsURL.rate1EmojiOff,
            height: iconHeight,
            width: iconWidget,
          ),
        ),
        kAppSpacerHorizontal(width: 5),
        InkWell(
          onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalIconPressEvent(rate: 2)),
          child: Image.asset(
            rateNumber != 0 && rateNumber > 2
                ? AssetsUrl.iconsURL.rateEmojiOff
                : rateNumber == 2
                ? AssetsUrl.iconsURL.rate2EmojiOn
                : AssetsUrl.iconsURL.rate2EmojiOff,
            height: iconHeight,
            width: iconWidget,
          ),
        ),
        kAppSpacerHorizontal(width: 5),
        InkWell(
          onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalIconPressEvent(rate: 3)),
          child: Image.asset(
            rateNumber != 0 && rateNumber > 3
                ? AssetsUrl.iconsURL.rateEmojiOff
                : rateNumber == 3
                ? AssetsUrl.iconsURL.rate3EmojiOn
                : AssetsUrl.iconsURL.rate3EmojiOff,
            height: iconHeight,
            width: iconWidget,
          ),
        ),
        kAppSpacerHorizontal(width: 5),
        InkWell(
          onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalIconPressEvent(rate: 4)),
          child: Image.asset(
            rateNumber != 0 && rateNumber > 4
                ? AssetsUrl.iconsURL.rateEmojiOff
                : rateNumber == 4
                ? AssetsUrl.iconsURL.rate4EmojiOn
                : AssetsUrl.iconsURL.rate4EmojiOff,
            height: iconHeight,
            width: iconWidget,
          ),
        ),
        kAppSpacerHorizontal(width: 5),
        InkWell(
          onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalIconPressEvent(rate: 5)),
          child: Image.asset(
            rateNumber != 0 && rateNumber > 5
                ? AssetsUrl.iconsURL.rateEmojiOff
                : rateNumber == 5
                ? AssetsUrl.iconsURL.rate5EmojiOn
                : AssetsUrl.iconsURL.rate5EmojiOff,
            height: iconHeight,
            width: iconWidget,
          ),
        ),
      ],
    );
  }
}

class StarRatingWidget extends StatelessWidget {
  final int rateNumber;
  final double iconHeight;
  final double iconWidget;
  const StarRatingWidget({super.key, required this.rateNumber, required this.iconHeight, required this.iconWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalIconPressEvent(rate: 1)),
          child: Image.asset(rateNumber >= 1 ? AssetsUrl.iconsURL.starRatingOn : AssetsUrl.iconsURL.starRatingOff, height: iconHeight, width: iconWidget),
        ),
        kAppSpacerHorizontal(width: 5),
        InkWell(
          onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalIconPressEvent(rate: 2)),
          child: Image.asset(rateNumber >= 2 ? AssetsUrl.iconsURL.starRatingOn : AssetsUrl.iconsURL.starRatingOff, height: iconHeight, width: iconWidget),
        ),
        kAppSpacerHorizontal(width: 5),
        InkWell(
          onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalIconPressEvent(rate: 3)),
          child: Image.asset(rateNumber >= 3 ? AssetsUrl.iconsURL.starRatingOn : AssetsUrl.iconsURL.starRatingOff, height: iconHeight, width: iconWidget),
        ),
        kAppSpacerHorizontal(width: 5),
        InkWell(
          onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalIconPressEvent(rate: 4)),
          child: Image.asset(rateNumber >= 4 ? AssetsUrl.iconsURL.starRatingOn : AssetsUrl.iconsURL.starRatingOff, height: iconHeight, width: iconWidget),
        ),
        kAppSpacerHorizontal(width: 5),
        InkWell(
          onTap: () => context.read<DirectRestaurantReviewRatingsModalBloc>().add(DirectRestaurantReviewRatingsModalIconPressEvent(rate: 5)),
          child: Image.asset(rateNumber >= 5 ? AssetsUrl.iconsURL.starRatingOn : AssetsUrl.iconsURL.starRatingOff, height: iconHeight, width: iconWidget),
        ),
      ],
    );
  }
}

class DirectRestaurantReviewRatingsModalLoadingView extends StatelessWidget {
  const DirectRestaurantReviewRatingsModalLoadingView({super.key});

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
// Done //
