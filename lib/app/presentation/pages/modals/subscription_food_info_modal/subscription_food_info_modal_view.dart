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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/food_variation_modal_response_model.dart';
import 'package:user/app/core/models/single_food_info_model.dart';
import 'package:user/app/presentation/pages/modals/subscription_food_info_modal/bloc/subscription_food_info_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class SubscriptionFoodInfoModalScreen extends StatelessWidget {
  final String id;
  final String data;
  final int totalOrders;
  final bool canAddAddons;
  final bool canAddVariations;
  final String inCart;
  const SubscriptionFoodInfoModalScreen({super.key, required this.id, required this.data, required this.totalOrders, required this.canAddAddons, required this.canAddVariations, required this.inCart});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionFoodInfoModalBloc()..add(SubscriptionFoodInfoInitialEvent(id: id, data: data, canAddAddons: canAddAddons, canAddVariations: canAddVariations, totalOrders: totalOrders, inCart: inCart)),
      child: const SubscriptionFoodInfoModalView(),
    );
  }
}

class SubscriptionFoodInfoModalView extends StatelessWidget {
  const SubscriptionFoodInfoModalView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionFoodInfoModalBloc, SubscriptionFoodInfoModalState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isSaveClose) {
          Navigator.of(context, rootNavigator: true).pop({"action": true, "isFavourite": state.info.isFavourite, "quantity": state.info.quantity, "cartItem": state.cartItem.toJson()});
        }
      },
      builder: (context, state) {
        return state.status.isLoading
            ? const SubscriptionFoodInfoModalLoadingView()
            : state.status.isFailure
            ? const SubscriptionFoodInfoModalErrorView()
            : SubscriptionFoodInfoModalResponseView(
                model: state.info,
                savedInCart: state.cartItem,
                originalPrice: state.originalPrice,
                discountPrice: state.discountPrice,
                canAddAddons: state.canAddAddons,
                canAddVariations: state.canAddVariations,
              );
      },
    );
  }
}

class SubscriptionFoodInfoModalResponseView extends StatelessWidget {
  final SingleFoodInfoModel model;
  final FoodVariationModalResponseModel savedInCart;
  final double originalPrice;
  final double discountPrice;
  final bool canAddAddons;
  final bool canAddVariations;
  const SubscriptionFoodInfoModalResponseView({super.key, required this.model, required this.savedInCart, required this.originalPrice, required this.discountPrice, required this.canAddAddons, required this.canAddVariations});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    var top = 0.0;
    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            pinned: true,
            snap: false,
            floating: true,
            elevation: 0,
            centerTitle: false,
            expandedHeight: 120.0,
            iconTheme: IconThemeData(color: Theme.of(context).canvasColor),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop({"action": false, "isFavourite": model.isFavourite, "quantity": model.quantity, "cartItem": savedInCart.toJson()}),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                child: Icon(Icons.arrow_back, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (ctx, cons) {
                top = cons.biggest.height;
                return FlexibleSpaceBar(
                  centerTitle: false,
                  title: top <= 56
                      ? AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(microseconds: 200),
                          child: Text(kAppTrimWord(model.name!, 40), style: Theme.of(context).appBarTheme.titleTextStyle),
                        )
                      : const SizedBox.shrink(),
                  background: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 120.0, imageUrl: model.image!),
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          model.foodType! != 'none' ? Row(children: [kAppFoodType(model.foodType!), kAppSpacerHorizontal(width: 5)]) : const SizedBox(),
                          Text(model.restaurants!.name!, style: kAppLblTinyFontRegular(context)),
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
                                Text(model.name!, style: kAppLblMediumFontBold(context)),
                                kAppSpacerVertical(height: 5),
                                InkWell(
                                  onTap: () => Navigator.of(context).pushNamed(AppRouter.productReviewRoute, arguments: [model.id!, model.name!, model.rating!.toString()]),
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
                                        child: kAppFoodRatingStar(model.rating!, iconSize: 12),
                                      ),
                                      kAppSpacerHorizontal(width: 5),
                                      Text("${model.totalRating!} ${translate.ratings}", style: kAppLblTinyFontRegular(context)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () => context.read<SubscriptionFoodInfoModalBloc>().add(SubscriptionFoodInfoModalShaveEvent()),
                                  icon: FaIcon(FontAwesomeIcons.shareFromSquare, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      kAppSpacerVertical(height: 5),
                      model.discount! <= 0
                          ? Text(kAppPriceFormat(model.price!), style: kAppLblTinyMediumFontSemi(context))
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(kAppPriceFormat(model.price!), style: kAppLblTinyStrokeFontRegular(context)),
                                kAppSpacerHorizontal(width: 5),
                                Text(kAppPriceFormat(model.offerPrice!), style: kAppLblTinyMediumFontSemi(context)),
                              ],
                            ),
                      model.discount! > 0
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                        model.discountType == '%' ? '${translate.flat} ${model.discount}% ${translate.off}' : '${translate.flat} ${kAppPriceFormat(model.discount!)} ${translate.off}',
                                        style: kAppLblTinyBoldOffer(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      kAppSpacerVertical(height: 5),
                      Text(model.shortDescription!, style: kAppLblTinyFontRegular(context)),
                      kAppSpacerVertical(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          model.variations!.isNotEmpty && canAddVariations
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(
                                    model.variations!.length,
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
                                                    Text(kAppTrimWord(model.variations![vIndex].title!, 20), style: kAppLblMediumFontBold(context)),
                                                    kAppSpacerVertical(height: 5),
                                                    model.variations![vIndex].type == 'single'
                                                        ? Text(translate.select_any_one_option, style: kAppLblTinyFontRegular(context))
                                                        : Text("${translate.select_min} ${model.variations![vIndex].min} ${translate.and_upto} ${model.variations![vIndex].max}", style: kAppLblTinyFontRegular(context)),
                                                  ],
                                                ),
                                                model.variations![vIndex].isRequired!
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
                                                model.variations![vIndex].options!.length,
                                                (oIndex) => InkWell(
                                                  onTap: () =>
                                                      context.read<SubscriptionFoodInfoModalBloc>().add(SubscriptionFoodInfoModalVariationOptionEvent(vIndex: vIndex, oIndex: oIndex, type: model.variations![vIndex].type!)),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(model.variations![vIndex].options![oIndex].name!, style: kAppLblTinyFontBold(context)),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            !model.variations![vIndex].options![oIndex].haveDiscount!
                                                                ? Text("+ ${kAppPriceFormat(model.variations![vIndex].options![oIndex].price!)}", style: kAppLblTinyFontBold(context))
                                                                : Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      Text(kAppPriceFormat(model.variations![vIndex].options![oIndex].price!), style: kAppLblTinyStrokeRegular(context)),
                                                                      kAppSpacerHorizontal(width: 5),
                                                                      Text("+ ${kAppPriceFormat(model.variations![vIndex].options![oIndex].discountPrice!)}", style: kAppLblTinyFontBold(context)),
                                                                    ],
                                                                  ),
                                                            kAppSpacerHorizontal(width: 5),
                                                            model.variations![vIndex].type == 'single'
                                                                ? Icon(
                                                                    model.variations![vIndex].options![oIndex].checked! ? Icons.radio_button_checked_rounded : Icons.radio_button_off,
                                                                    size: 16,
                                                                    color: Theme.of(context).primaryColor,
                                                                  )
                                                                : Icon(
                                                                    model.variations![vIndex].options![oIndex].checked!
                                                                        ? Icons.check_box_rounded
                                                                        : model.variations![vIndex].options![oIndex].enable!
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
                          model.addons!.isNotEmpty && canAddAddons
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
                                            model.addons!.length,
                                            (aIndex) => InkWell(
                                              onTap: () => context.read<SubscriptionFoodInfoModalBloc>().add(SubscriptionFoodInfoModalAddonsEvent(index: aIndex)),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(model.addons![aIndex].name!, style: kAppLblTinyFontBold(context)),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        !model.addons![aIndex].haveDiscount!
                                                            ? Text("+ ${kAppPriceFormat(model.addons![aIndex].price!)}", style: kAppLblTinyFontBold(context))
                                                            : Row(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Text(kAppPriceFormat(model.addons![aIndex].price!), style: kAppLblTinyStrokeRegular(context)),
                                                                  kAppSpacerHorizontal(width: 5),
                                                                  Text("+ ${kAppPriceFormat(model.addons![aIndex].discountPrice!)}", style: kAppLblTinyFontBold(context)),
                                                                ],
                                                              ),
                                                        kAppSpacerHorizontal(width: 5),
                                                        Icon(model.addons![aIndex].checked! ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, size: 16, color: Theme.of(context).primaryColor),
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
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
          child: Column(
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
                    discountPrice > 0
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(kAppPriceFormat(originalPrice), style: kAppLblTinyStrokeRegular(context)),
                              kAppSpacerHorizontal(width: 5),
                              Text("+ ${kAppPriceFormat(discountPrice)}", style: kAppLblTinyFontBold(context)),
                            ],
                          )
                        : Text("+ ${kAppPriceFormat(originalPrice)}", style: kAppLblTinyFontBold(context)),
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
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15, left: 5),
                              child: Icon(Icons.remove, size: 18, color: Theme.of(context).primaryColor),
                            ),
                          ),
                          Text("${model.quantity}", style: kAppLblSmallFontBold(context, color: 'primary')),
                          InkWell(
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
                      onTap: () => context.read<SubscriptionFoodInfoModalBloc>().add(SubscriptionFoodInfoModalSaveEvent()),
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
  }
}

class SubscriptionFoodInfoModalLoadingView extends StatelessWidget {
  const SubscriptionFoodInfoModalLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, scrolledUnderElevation: 0),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Padding(
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
        ),
      ),
    );
  }
}

class SubscriptionFoodInfoModalErrorView extends StatelessWidget {
  const SubscriptionFoodInfoModalErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, scrolledUnderElevation: 0),
      body: SingleChildScrollView(
        child: Padding(
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
        ),
      ),
    );
  }
}
// Done //
