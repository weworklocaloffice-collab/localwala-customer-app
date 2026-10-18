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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/presentation/pages/modals/single_food_from_banner_modal/bloc/single_food_from_banner_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class SingleFoodFromBannerModalScreen extends StatelessWidget {
  final String id;
  final String name;
  const SingleFoodFromBannerModalScreen({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    return SingleFoodFromBannerModalView(id: id, name: name);
  }
}

class SingleFoodFromBannerModalView extends StatefulWidget {
  final String id;
  final String name;
  const SingleFoodFromBannerModalView({super.key, required this.id, required this.name});

  @override
  State<SingleFoodFromBannerModalView> createState() => _SingleFoodFromBannerModalViewState();
}

class _SingleFoodFromBannerModalViewState extends State<SingleFoodFromBannerModalView> {
  @override
  void initState() {
    super.initState();
    context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalInitialEvent(id: widget.id, name: widget.name));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<SingleFoodFromBannerModalBloc, SingleFoodFromBannerModalState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isSaveClose) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.name),
            scrolledUnderElevation: 0,
            actions: state.status.isLoading || state.status.isFailure
                ? []
                : [
                    IconButton(
                      onPressed: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalFavouriteEvent()),
                      icon: FaIcon(
                        state.detail.info!.isFavourite! ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                        size: Theme.of(context).textTheme.titleSmall?.fontSize,
                        color: state.detail.info!.isFavourite! ? Theme.of(context).primaryColor : Theme.of(context).canvasColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodShareEvent()),
                      icon: FaIcon(FontAwesomeIcons.shareFromSquare, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                    ),
                  ],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const SingleFoodFromBannerModalLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const SingleFoodFromBannerModalErrorView(),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                            child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 120.0, imageUrl: state.detail.info!.image!),
                          ),
                        ),
                        kAppSpacerVertical(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            state.detail.info!.foodType! != 'none' ? Row(children: [kAppFoodType(state.detail.info!.foodType!), kAppSpacerHorizontal(width: 5)]) : const SizedBox(),
                            Text(state.detail.info!.restaurants!.name!, style: kAppLblTinyFontRegular(context)),
                          ],
                        ),
                        kAppSpacerVertical(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(state.detail.info!.name!, style: kAppLblMediumFontBold(context)),
                                  kAppSpacerVertical(height: 5),
                                  InkWell(
                                    onTap: () => Navigator.of(context).pushNamed(AppRouter.productReviewRoute, arguments: [state.detail.info!.id!, state.detail.info!.name!, state.detail.info!.rating!.toString()]),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(0),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: ThemeProvider.ratingStarIconColorLight, width: 0.5),
                                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                                          ),
                                          child: kAppFoodRatingStar(state.detail.info!.rating!, iconSize: 12),
                                        ),
                                        kAppSpacerHorizontal(width: 5),
                                        Text("${state.detail.info!.totalRating!} ${translate.ratings}", style: kAppLblTinyFontRegular(context)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        kAppSpacerVertical(height: 5),
                        state.detail.info!.discount! <= 0
                            ? Text(kAppPriceFormat(state.detail.info!.price!), style: kAppLblTinyMediumFontSemi(context))
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(kAppPriceFormat(state.detail.info!.price!), style: kAppLblTinyStrokeFontRegular(context)),
                                  kAppSpacerHorizontal(width: 5),
                                  Text(kAppPriceFormat(state.detail.info!.offerPrice!), style: kAppLblTinyMediumFontSemi(context)),
                                ],
                              ),
                        state.detail.info!.discount! > 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  kAppSpacerVertical(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(color: ThemeProvider.darkBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(AssetsUrl.imageURL.offerTag, height: 10, width: 10),
                                        kAppSpacerHorizontal(width: 5),
                                        Text(
                                          state.detail.info!.discountType == '%'
                                              ? '${translate.flat} ${state.detail.info!.discount!}% ${translate.off}'
                                              : '${translate.flat} ${kAppPriceFormat(state.detail.info!.discount!)} ${translate.off}',
                                          style: kAppLblTinyBoldOffer(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        kAppSpacerVertical(height: 5),
                        Text(state.detail.info!.shortDescription!, style: kAppLblTinyFontRegular(context)),
                        kAppSpacerVertical(height: 5),
                        state.isFromCart == false
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  state.detail.info!.variations!.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: List.generate(
                                            state.detail.info!.variations!.length,
                                            (vIndex) => Container(
                                              width: MediaQuery.of(context).size.width,
                                              margin: const EdgeInsets.symmetric(vertical: 5),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0),
                                                border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Text(kAppTrimWord(state.detail.info!.variations![vIndex].title!, 20), style: kAppLblMediumFontBold(context)),
                                                            kAppSpacerVertical(height: 5),
                                                            state.detail.info!.variations![vIndex].type == 'single'
                                                                ? Text(translate.select_any_one_option, style: kAppLblTinyFontRegular(context))
                                                                : Text(
                                                                    '${translate.select_min} ${state.detail.info!.variations![vIndex].min} ${translate.and_upto} ${state.detail.info!.variations![vIndex].max}',
                                                                    style: kAppLblTinyFontRegular(context),
                                                                  ),
                                                          ],
                                                        ),
                                                        state.detail.info!.variations![vIndex].isRequired!
                                                            ? Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                                                ),
                                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                child: Text(translate.required_food_variation, style: kAppLblTinyFontRegular(context)),
                                                              )
                                                            : const SizedBox(),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(thickness: 0.5, color: ThemeProvider.lightDisabledColor, height: 5),
                                                  Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: List.generate(
                                                        state.detail.info!.variations![vIndex].options!.length,
                                                        (oIndex) => InkWell(
                                                          onTap: () => context.read<SingleFoodFromBannerModalBloc>().add(
                                                            SingleFoodFromBannerModalVariationOptionEvent(vIndex: vIndex, oIndex: oIndex, type: state.detail.info!.variations![vIndex].type!),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Text(state.detail.info!.variations![vIndex].options![oIndex].name!, style: kAppLblTinyFontBold(context)),
                                                                    state.detail.info!.variations![vIndex].options![oIndex].limitCrossed!
                                                                        ? Row(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            children: [
                                                                              kAppSpacerHorizontal(width: 5),
                                                                              Text(
                                                                                "(${translate.only} ${state.detail.info!.variations![vIndex].options![oIndex].stock!} ${translate.item_available})",
                                                                                style: kAppLblTinyFontRegularChip(context, color: 'primary'),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        : const SizedBox(),
                                                                    !state.detail.info!.variations![vIndex].options![oIndex].inStock!
                                                                        ? Row(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            children: [
                                                                              kAppSpacerHorizontal(width: 5),
                                                                              Text("(${translate.out_of_stock})", style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                                                            ],
                                                                          )
                                                                        : const SizedBox(),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                  children: [
                                                                    !state.detail.info!.variations![vIndex].options![oIndex].haveDiscount!
                                                                        ? Text("+ ${kAppPriceFormat(state.detail.info!.variations![vIndex].options![oIndex].price!)}", style: kAppLblTinyFontBold(context))
                                                                        : Row(
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                                            children: [
                                                                              Text(kAppPriceFormat(state.detail.info!.variations![vIndex].options![oIndex].price!), style: kAppLblTinyStrokeRegular(context)),
                                                                              kAppSpacerHorizontal(width: 5),
                                                                              Text('+ ${kAppPriceFormat(state.detail.info!.variations![vIndex].options![oIndex].discountPrice!)}', style: kAppLblTinyFontBold(context)),
                                                                            ],
                                                                          ),
                                                                    kAppSpacerHorizontal(width: 5),
                                                                    state.detail.info!.variations![vIndex].type == 'single'
                                                                        ? Icon(
                                                                            state.detail.info!.variations![vIndex].options![oIndex].checked! ? Icons.radio_button_checked_rounded : Icons.radio_button_off,
                                                                            size: 16,
                                                                            color: Theme.of(context).primaryColor,
                                                                          )
                                                                        : Icon(
                                                                            state.detail.info!.variations![vIndex].options![oIndex].checked!
                                                                                ? Icons.check_box_rounded
                                                                                : state.detail.info!.variations![vIndex].options![oIndex].enable!
                                                                                ? Icons.check_box_outline_blank_rounded
                                                                                : Icons.indeterminate_check_box_outlined,
                                                                            size: 16,
                                                                            color: Theme.of(context).primaryColor,
                                                                          ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                  state.detail.info!.addons!.isNotEmpty
                                      ? Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: const EdgeInsets.symmetric(vertical: 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Text(translate.food_addon, style: kAppLblMediumFontBold(context)),
                                                        kAppSpacerVertical(height: 5),
                                                        Text(translate.select_addon_title, style: kAppLblTinyFontRegular(context)),
                                                      ],
                                                    ),
                                                    const SizedBox(),
                                                  ],
                                                ),
                                              ),
                                              Divider(thickness: 0.5, color: ThemeProvider.lightDisabledColor, height: 5),
                                              Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: List.generate(
                                                    state.detail.info!.addons!.length,
                                                    (aIndex) => InkWell(
                                                      onTap: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalAddonsEvent(index: aIndex)),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Text(state.detail.info!.addons![aIndex].name!, style: kAppLblTinyFontBold(context)),
                                                                state.detail.info!.addons![aIndex].limitCrossed!
                                                                    ? Row(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          kAppSpacerHorizontal(width: 5),
                                                                          Text(
                                                                            "(${translate.only} ${state.detail.info!.addons![aIndex].stockNumber!} ${translate.item_available})",
                                                                            style: kAppLblTinyFontRegularChip(context, color: 'primary'),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : const SizedBox(),
                                                                !state.detail.info!.addons![aIndex].inStock!
                                                                    ? Row(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          kAppSpacerHorizontal(width: 5),
                                                                          Text("(${translate.out_of_stock})", style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                                                        ],
                                                                      )
                                                                    : const SizedBox(),
                                                              ],
                                                            ),
                                                            Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                !state.detail.info!.addons![aIndex].haveDiscount!
                                                                    ? Text("+ ${kAppPriceFormat(state.detail.info!.addons![aIndex].price!)}", style: kAppLblTinyFontBold(context))
                                                                    : Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                        children: [
                                                                          Text(kAppPriceFormat(state.detail.info!.addons![aIndex].price!), style: kAppLblTinyStrokeRegular(context)),
                                                                          kAppSpacerHorizontal(width: 5),
                                                                          Text("+ ${kAppPriceFormat(state.detail.info!.addons![aIndex].discountPrice!)}", style: kAppLblTinyFontBold(context)),
                                                                        ],
                                                                      ),
                                                                kAppSpacerHorizontal(width: 5),
                                                                Icon(state.detail.info!.addons![aIndex].checked! ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, size: 16, color: Theme.of(context).primaryColor),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              )
                            : Column(
                                children: List.generate(state.list.length, (index) => state.list[index].quantity! >= 1 ? FoodItemBlock(model: state.list[index], index: index) : const SizedBox()),
                              ),
                        kAppSpacerVertical(height: 30),
                        TextField(
                          maxLines: 3,
                          maxLength: 100,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          decoration: kAppInputDecoration(context, lblText: translate.cooking_instruction, errText: null),
                          style: kAppLblSmallFontMedium(context),
                          onChanged: (value) => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodInstructionChangeEvent(instruction: value)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: state.status.isLoading || state.status.isFailure
              ? SafeArea(child: const SizedBox())
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
                    child: state.newItem == true
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("${translate.total_amount} :", style: kAppLblMediumFontBold(context)),
                                    state.detail.info!.discount! > 0
                                        ? Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(kAppPriceFormat(state.originalPrice), style: kAppLblTinyStrokeRegular(context)),
                                              kAppSpacerHorizontal(width: 5),
                                              Text("+ ${kAppPriceFormat(state.discountPrice)}", style: kAppLblTinyFontBold(context)),
                                            ],
                                          )
                                        : Text("+ ${kAppPriceFormat(state.originalPrice)}", style: kAppLblTinyFontBold(context)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      width: double.infinity,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          InkWell(
                                            onTap: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalQuantityEvent(action: 'decrease')),
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 15, left: 5),
                                              child: Icon(Icons.remove, size: 18, color: Theme.of(context).primaryColor),
                                            ),
                                          ),
                                          Text("${state.detail.info!.quantity}", style: kAppLblSmallFontBold(context, color: 'primary')),
                                          InkWell(
                                            onTap: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalQuantityEvent(action: 'increase')),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 15, right: 5),
                                              child: Icon(Icons.add, size: 18, color: Theme.of(context).primaryColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                                  Expanded(
                                    flex: 3,
                                    child: InkWell(
                                      onTap: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalNewItemSaveEvent()),
                                      child: Container(
                                        width: double.infinity,
                                        height: 40.0,
                                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [Text(translate.add_to_cart_btn, style: kAppLblSmallFontBoldCart(context))],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : state.isFromCart == true
                        ? Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextButton.icon(
                                  onPressed: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalNewItemEvent()),
                                  icon: Icon(Icons.add, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: Theme.of(context).primaryColor),
                                  label: Text(translate.add_new_customisation, style: kAppLblSmallFontMedium(context, color: 'primary')),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    width: double.infinity,
                                    height: 40.0,
                                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Text(translate.update_cart, style: kAppLblSmallFontBoldCart(context))],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("${translate.total_amount} :", style: kAppLblMediumFontBold(context)),
                                    state.detail.info!.discount! > 0
                                        ? Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(kAppPriceFormat(state.originalPrice), style: kAppLblTinyStrokeRegular(context)),
                                              kAppSpacerHorizontal(width: 5),
                                              Text("+ ${kAppPriceFormat(state.discountPrice)}", style: kAppLblTinyFontBold(context)),
                                            ],
                                          )
                                        : Text("+ ${kAppPriceFormat(state.originalPrice)}", style: kAppLblTinyFontBold(context)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      width: double.infinity,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          InkWell(
                                            onTap: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalQuantityEvent(action: 'decrease')),
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 15, left: 5),
                                              child: Icon(Icons.remove, size: 18, color: Theme.of(context).primaryColor),
                                            ),
                                          ),
                                          Text("${state.detail.info!.quantity}", style: kAppLblSmallFontBold(context, color: 'primary')),
                                          InkWell(
                                            onTap: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalQuantityEvent(action: 'increase')),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 15, right: 5),
                                              child: Icon(Icons.add, size: 18, color: Theme.of(context).primaryColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                                  Expanded(
                                    flex: 3,
                                    child: InkWell(
                                      onTap: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalSaveEvent()),
                                      child: Container(
                                        width: double.infinity,
                                        height: 40.0,
                                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [Text(translate.add_to_cart_btn, style: kAppLblSmallFontBoldCart(context))],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

class FoodItemBlock extends StatelessWidget {
  final FoodInCartModel model;
  final int index;
  const FoodItemBlock({super.key, required this.model, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
      ),
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
                Text(kAppTrimWord(model.name!, 50), style: kAppLblMediumFontBold(context)),
                kAppSpacerVertical(height: 5),
                Text(kAppPriceFormat(model.totalPrice!), style: kAppLblTinyMediumFontSemi(context)),
                kAppSpacerVertical(height: 5),
                Container(
                  padding: const EdgeInsets.only(right: 5),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.8, minWidth: MediaQuery.of(context).size.width / 2.5),
                  child: Text(model.optionName!, maxLines: 4, style: kAppLblTinyFontRegular(context)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        onTap: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalRepeatDecreaseEvent(index: index, uuid: model.uuid!)),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15, left: 5),
                          child: Icon(Icons.remove, size: 18, color: Theme.of(context).primaryColor),
                        ),
                      ),
                      Text("${model.quantity}", style: kAppLblSmallFontBold(context, color: 'primary')),
                      InkWell(
                        onTap: () => context.read<SingleFoodFromBannerModalBloc>().add(SingleFoodFromBannerModalRepeatIncreaseEvent(index: index, uuid: model.uuid!)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 5),
                          child: Icon(Icons.add, size: 18, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                kAppSpacerVertical(height: 5),
                Text(kAppPriceFormat(model.totalPrice!), style: kAppLblTinyMediumFontSemi(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SingleFoodFromBannerModalLoadingView extends StatelessWidget {
  const SingleFoodFromBannerModalLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
      child: Column(
        children: [
          SkeletonLine(
            style: SkeletonLineStyle(height: 120, width: double.infinity, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(height: 20),
          SkeletonLine(
            style: SkeletonLineStyle(height: 16, width: double.infinity, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLine(style: SkeletonLineStyle(height: 16, width: 64, borderRadius: BorderRadius.circular(8))),
              SkeletonLine(style: SkeletonLineStyle(height: 16, width: 64, borderRadius: BorderRadius.circular(8))),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: List.generate(
              10,
              (index) => Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: SkeletonLine(
                  style: SkeletonLineStyle(height: 120, width: double.infinity, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SingleFoodFromBannerModalErrorView extends StatelessWidget {
  const SingleFoodFromBannerModalErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
      child: Center(
        child: Column(
          children: [
            kAppSpacerVertical(height: 20),
            Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
            kAppSpacerVertical(height: 20),
            Text(translate.system_error_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
            kAppSpacerVertical(height: 30),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: kAppTextButtonColoredStyle(context, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor),
              child: Text(translate.undestand_and_go_back),
            ),
          ],
        ),
      ),
    );
  }
}
// Done //
