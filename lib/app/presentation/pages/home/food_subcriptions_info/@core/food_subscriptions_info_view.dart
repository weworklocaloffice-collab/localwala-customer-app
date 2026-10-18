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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/subscription_tiffin_package_info_response_model.dart';
import 'package:user/app/presentation/pages/home/food_subcriptions_info/@core/bloc/food_subscriptions_info_bloc.dart';
import 'package:user/app/presentation/pages/modals/subscription_food_info_modal/subscription_food_info_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FoodSubscriptionsInfoScreen extends StatelessWidget {
  final String id;
  final String name;
  const FoodSubscriptionsInfoScreen({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FoodSubscriptionsInfoBloc()..add(FoodSubscriptionsInfoInitialEvent(id: id, name: name)),
      child: const FoodSubscriptionsInfoView(),
    );
  }
}

class FoodSubscriptionsInfoView extends StatelessWidget {
  const FoodSubscriptionsInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodSubscriptionsInfoBloc, FoodSubscriptionsInfoState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return state.status.isLoading
            ? const FoodSubscriptionsInfoLoadingView()
            : state.status.isFailure
            ? const FoodSubscriptionsInfoErrorView()
            : FoodSubscriptionsInfoResponseView(isAuthorized: state.isAuthorized, info: state.info);
      },
    );
  }
}

class FoodSubscriptionsInfoResponseView extends StatelessWidget {
  final bool isAuthorized;
  final SubscriptionTiffinPackageInfoModel info;
  const FoodSubscriptionsInfoResponseView({super.key, required this.isAuthorized, required this.info});

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
              onPressed: () => Navigator.of(context).pop(),
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
                final collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
                return FlexibleSpaceBar(
                  centerTitle: false,
                  title: top <= collapsedHeight + 5
                      ? AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(microseconds: 200),
                          child: Text(kAppTrimWord(info.details!.name!, 40), style: Theme.of(context).appBarTheme.titleTextStyle),
                        )
                      : const SizedBox.shrink(),
                  background: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 120.0, imageUrl: info.details!.image!),
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
                      Text("${translate.offer_by} : ${info.details!.restaurants!.name!}", style: kAppLblMediumFontBold(context)),
                      kAppSpacerVertical(height: 5),
                      Text(info.details!.name!, style: kAppLblMediumFontBold(context)),
                      Text(info.details!.shortDescription!, style: kAppLblTinyFontRegular(context)),
                      kAppSpacerVertical(height: 10),
                      info.details!.discount! <= 0
                          ? Text(kAppPriceFormat(info.details!.price!), style: kAppLblTinyMediumFontSemi(context))
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(kAppPriceFormat(info.details!.price!), style: kAppLblTinyStrokeFontRegular(context)),
                                kAppSpacerHorizontal(width: 5),
                                Text(kAppPriceFormat(info.details!.offerPrice!), style: kAppLblTinyMediumFontSemi(context)),
                              ],
                            ),
                      kAppSpacerVertical(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(translate.availability, style: kAppLblTinyFontRegular(context)),
                          kAppSpacerHorizontal(width: 10),
                          Text(kAppTiffinKind(context, info.details!.available!), style: kAppLblTinyFontBold(context)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(translate.validity, style: kAppLblTinyFontRegular(context)),
                          kAppSpacerHorizontal(width: 10),
                          Text("${info.details!.totalOrder!} ${translate.days}", style: kAppLblTinyFontBold(context)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(translate.support, style: kAppLblTinyFontRegular(context)),
                          kAppSpacerHorizontal(width: 10),
                          Text(
                            '${info.details!.orderTo! == 'homedelivery' ? translate.home_delivery : translate.take_away}${info.details!.orderTo! == 'homedelivery' ? ' (${info.details!.deliveryArea} ${info.findMode!.toUpperCase()})' : ''}',
                            style: kAppLblTinyFontBold(context),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(translate.off_day_week, style: kAppLblTinyFontRegular(context)),
                          kAppSpacerHorizontal(width: 10),
                          Text(info.details!.offDayName!, style: kAppLblTinyFontBold(context)),
                        ],
                      ),
                      kAppSpacerVertical(height: 20),
                      kAppTitleDivider(context, translate.time_slot_title, 0.0),
                      kAppSpacerVertical(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: info.details!.timeSlots!
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                                  ),
                                  child: Text("${item.displayStartTime!} - ${item.displayEndTime!}", style: kAppLblTinyFontRegularChip(context)),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      kAppSpacerVertical(height: 20),
                      kAppTitleDivider(context, translate.food_include_title, 0.0),
                      kAppSpacerVertical(height: 20),
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 230),
                        scrollDirection: Axis.vertical,
                        key: UniqueKey(),
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 230,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                              child: FoodSubscriptionsInfoFoodInfoBlock(
                                model: info.foods![index],
                                canAddAddons: info.details!.canSelectAddon!,
                                canAddVariations: info.details!.canSelectVariation!,
                                totalOrders: info.details!.totalOrder!,
                              ),
                            ),
                          );
                        },
                        itemCount: info.foods!.length,
                      ),
                      kAppSpacerVertical(height: 20),
                      kAppTitleDivider(context, translate.terms_and_conditions, 0.0),
                      kAppSpacerVertical(height: 20),
                      Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        margin: const EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: info.details!.notice!.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.brightness_1, size: 5, color: Theme.of(context).canvasColor),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(item.name!, style: kAppLblSmallFontRegular(context))),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
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
                      onPressed: () {
                        if (isAuthorized) {
                          Navigator.of(context).pushNamed(AppRouter.buyFoodSubscriptionPackageRoute, arguments: [info.details!.id!]);
                        } else {
                          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
                        }
                      },
                      style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50),
                      child: Text(isAuthorized ? translate.buy_subscription : translate.sign_in_to_purchase),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FoodSubscriptionsInfoFoodInfoBlock extends StatelessWidget {
  final FoodInSubscriptionPackageInfoModel model;
  final bool canAddAddons;
  final bool canAddVariations;
  final int totalOrders;
  const FoodSubscriptionsInfoFoodInfoBlock({super.key, required this.model, required this.canAddAddons, required this.canAddVariations, required this.totalOrders});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.7,
              child: SubscriptionFoodInfoModalScreen(id: model.id!, data: jsonEncode(model), totalOrders: totalOrders, canAddAddons: canAddAddons, canAddVariations: canAddVariations, inCart: ''),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                  child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 100.0, imageUrl: model.image!),
                ),
                Positioned(left: 5, bottom: 5, child: kAppFoodType(model.foodType!)),
                model.discount! > 0
                    ? Positioned(
                        left: 0,
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: ThemeProvider.darkBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
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
                      )
                    : const SizedBox(),
                canAddAddons || canAddVariations
                    ? Positioned(
                        bottom: 5,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: const BoxDecoration(color: ThemeProvider.darkBackgroundColor),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [Text(translate.customizable, style: kAppLblTinyBoldOffer(context))],
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                kAppSpacerVertical(height: 5),
                Text(kAppTrimWord(model.name!, 20), style: kAppLblMediumFontBold(context)),
                kAppSpacerVertical(height: 5),
                Row(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FoodSubscriptionsInfoLoadingView extends StatelessWidget {
  const FoodSubscriptionsInfoLoadingView({super.key});

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
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 4, crossAxisSpacing: 4, mainAxisExtent: 150),
                  scrollDirection: Axis.vertical,
                  key: UniqueKey(),
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: SkeletonLine(
                        style: SkeletonLineStyle(height: 150, width: double.infinity, borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  itemCount: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodSubscriptionsInfoErrorView extends StatelessWidget {
  const FoodSubscriptionsInfoErrorView({super.key});

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
