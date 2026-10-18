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
import 'package:user/app/core/models/food_campaign_detail_model.dart';
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/food_variations_response_data_modal_model.dart';
import 'package:user/app/core/models/repeat_quantity_modal_response_model.dart';
import 'package:user/app/presentation/pages/home/campaign/food_campaign/bloc/food_campaign_bloc.dart';
import 'package:user/app/presentation/pages/modals/food_info_modal/food_view.dart';
import 'package:user/app/presentation/pages/modals/food_variations_modal/@core/food_variations_modal_view.dart';
import 'package:user/app/presentation/pages/modals/food_variations_modal/repeat/food_variation_modal_repeat_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FoodCampaignScreen extends StatelessWidget {
  final String id;
  const FoodCampaignScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return FoodCampaignView(id: id);
  }
}

class FoodCampaignView extends StatefulWidget {
  final String id;
  const FoodCampaignView({super.key, required this.id});

  @override
  State<FoodCampaignView> createState() => _FoodCampaignViewState();
}

class _FoodCampaignViewState extends State<FoodCampaignView> {
  @override
  void initState() {
    super.initState();
    context.read<FoodCampaignBloc>().add(FoodCampaignInitialEvent(id: widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodCampaignBloc, FoodCampaignState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError || state.status.isCartError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return state.status.isLoading
            ? const FoodCampaignLoadingView()
            : state.status.isFailure
            ? const FoodCampaignErrorView()
            : FoodCampaignResponseView(data: state.campaign, appLocale: state.appLocale);
      },
    );
  }
}

class FoodCampaignResponseView extends StatelessWidget {
  final FoodCampaignDetailModel data;
  final String appLocale;
  const FoodCampaignResponseView({super.key, required this.data, required this.appLocale});

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
                          child: Text(kAppTrimWord(data.detail!.title!, 40), style: Theme.of(context).appBarTheme.titleTextStyle),
                        )
                      : const SizedBox.shrink(),
                  background: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 120.0, imageUrl: data.detail!.image!),
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
                      Text(data.detail!.title!, style: kAppLblMediumFontBold(context)),
                      Text(data.detail!.shortDescription!, style: kAppLblTinyFontRegular(context)),
                      kAppSpacerVertical(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(translate.campaign_schedule_date, style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          Expanded(
                            child: Text("${data.detail!.startDate!} - ${data.detail!.endDate}", textAlign: TextAlign.end, style: kAppLblTinyFontBold(context), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(translate.campaign_schedule_time, style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          Expanded(
                            child: Text("${data.detail!.startTime!} - ${data.detail!.endTime!}", style: kAppLblTinyFontBold(context), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      kAppSpacerVertical(height: 20),
                      kAppTitleDivider(context, translate.food_title, 0.0),
                      kAppSpacerVertical(height: 20),
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 240),
                        scrollDirection: Axis.vertical,
                        key: UniqueKey(),
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                              child: HorizontalFoodBlock(campaignId: data.detail!.id!, model: data.inCampaign![index], appLocale: appLocale),
                            ),
                          );
                        },
                        itemCount: data.inCampaign!.length,
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class FoodCampaignLoadingView extends StatelessWidget {
  const FoodCampaignLoadingView({super.key});

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

class FoodCampaignErrorView extends StatelessWidget {
  const FoodCampaignErrorView({super.key});

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

class HorizontalFoodBlock extends StatelessWidget {
  final String campaignId;
  final InCampaignFoodModel model;
  final String appLocale;
  const HorizontalFoodBlock({super.key, required this.campaignId, required this.model, required this.appLocale});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () async {
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
                        child: FoodScreen(id: model.id!, from: 'campaign', data: jsonEncode(model), extraInfo: ''),
                      );
                    },
                  ).then((value) {
                    if (!context.mounted) return;
                    if (value != null) {
                      FoodInfoModalResponseModel foodInfoModalResponse = FoodInfoModalResponseModel.fromJson(value, appLocale);
                      context.read<FoodCampaignBloc>().add(FoodCampaignFoodModalResponseEvent(id: model.id!, response: foodInfoModalResponse));
                    }
                  });
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                  child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 100.0, imageUrl: model.image!),
                ),
              ),
              Positioned(left: 5, bottom: 5, child: kAppFoodType(model.foodType!)),
              model.quantity! <= 0
                  ? Positioned(
                      bottom: 5,
                      right: 5,
                      child: InkWell(
                        onTap: () async {
                          if (model.addons!.isNotEmpty || model.variations!.isNotEmpty) {
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
                                  child: FoodVariationsModalScreen(
                                    id: model.id!,
                                    name: model.name!,
                                    image: model.image!,
                                    options: jsonEncode({"addons": model.addons!, "variations": model.variations!}),
                                    price: model.price!,
                                    offerPrice: model.offerPrice!,
                                    discount: model.discount!,
                                    discountType: model.discountType!,
                                    purchaseLimit: int.parse(model.purchaseLimit!.toString()),
                                    stockNumber: int.parse(model.stockNumber!.toString()),
                                    stockType: model.stockType!,
                                  ),
                                );
                              },
                            ).then((value) {
                              if (!context.mounted) return;
                              if (value != null) {
                                FoodVariationModalResponseDataModel foodVariationModalResponse = FoodVariationModalResponseDataModel.fromJson(value, appLocale);
                                if (foodVariationModalResponse.action!) {
                                  context.read<FoodCampaignBloc>().add(FoodCampaignVariationModalResponseEvent(id: model.id!, data: foodVariationModalResponse));
                                }
                              }
                            });
                          } else {
                            context.read<FoodCampaignBloc>().add(FoodCampaignAddCartEvent(id: model.id!));
                          }
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                          child: Icon(Icons.add, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                        ),
                      ),
                    )
                  : Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        height: 25,
                        width: 80,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: ThemeProvider.whiteColor),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                if (model.cartEntity == 'multiple') {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    isDismissible: false,
                                    enableDrag: false,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    builder: (BuildContext context) {
                                      return FractionallySizedBox(heightFactor: 0.4, child: FoodVariationModalRepeatScreen(id: model.id!, action: false));
                                    },
                                  ).then((value) {
                                    if (!context.mounted) return;
                                    if (value != null) {
                                      RepeatQuantityModalResponseModel repeatQuantityModalResponse = RepeatQuantityModalResponseModel.fromJson(value);
                                      if (repeatQuantityModalResponse.action == 'update') {
                                        context.read<FoodCampaignBloc>().add(FoodCampaignRepeatFoodOrderResponseEvent(id: model.id!, data: repeatQuantityModalResponse));
                                      }
                                    }
                                  });
                                } else {
                                  context.read<FoodCampaignBloc>().add(FoodCampaignFoodQuantityDecreaseEvent(id: model.id!));
                                }
                              },
                              child: Icon(Icons.remove_circle_outline, size: Theme.of(context).textTheme.titleMedium?.fontSize, color: ThemeProvider.primaryColor),
                            ),
                            Text(
                              '${model.quantity!}',
                              style: TextStyle(color: ThemeProvider.primaryColor, fontSize: Theme.of(context).textTheme.labelMedium?.fontSize, fontFamily: 'semibold'),
                            ),
                            InkWell(
                              onTap: () {
                                if (model.addons!.isNotEmpty || model.variations!.isNotEmpty) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    isDismissible: false,
                                    enableDrag: false,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    builder: (BuildContext context) {
                                      return FractionallySizedBox(heightFactor: 0.4, child: FoodVariationModalRepeatScreen(id: model.id!, action: true));
                                    },
                                  ).then((value) {
                                    if (!context.mounted) return;
                                    if (value != null) {
                                      RepeatQuantityModalResponseModel repeatQuantityModalResponse = RepeatQuantityModalResponseModel.fromJson(value);
                                      if (repeatQuantityModalResponse.action == 'update') {
                                        context.read<FoodCampaignBloc>().add(FoodCampaignRepeatFoodOrderResponseEvent(id: model.id!, data: repeatQuantityModalResponse));
                                      } else if (repeatQuantityModalResponse.action == 'new') {
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
                                              child: FoodVariationsModalScreen(
                                                id: model.id!,
                                                name: model.name!,
                                                image: model.image!,
                                                options: jsonEncode({"addons": model.addons!, "variations": model.variations!}),
                                                price: model.price!,
                                                offerPrice: model.offerPrice!,
                                                discount: model.discount!,
                                                discountType: model.discountType!,
                                                purchaseLimit: int.parse(model.purchaseLimit!.toString()),
                                                stockNumber: int.parse(model.stockNumber.toString()),
                                                stockType: model.stockType!,
                                              ),
                                            );
                                          },
                                        ).then((value) {
                                          if (!context.mounted) return;
                                          if (value != null) {
                                            FoodVariationModalResponseDataModel foodVariationModalResponse = FoodVariationModalResponseDataModel.fromJson(value, appLocale);
                                            if (foodVariationModalResponse.action!) {
                                              context.read<FoodCampaignBloc>().add(FoodCampaignFoodVariationModalRepeatResponseEvent(id: model.id!, data: foodVariationModalResponse));
                                            }
                                          }
                                        });
                                      }
                                    }
                                  });
                                } else {
                                  context.read<FoodCampaignBloc>().add(FoodCampaignFoodQuantityIncreaseEvent(id: model.id!));
                                }
                              },
                              child: Icon(Icons.add_circle_outline, size: Theme.of(context).textTheme.titleMedium?.fontSize, color: ThemeProvider.primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
              Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: () => context.read<FoodCampaignBloc>()..add(FoodCampaignFavouriteEvent(id: model.id!, isFavourite: model.isFavourite!)),
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                    child: Icon(model.isFavourite! ? Icons.favorite_rounded : Icons.favorite_outline_rounded, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                  ),
                ),
              ),
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
            ],
          ),
          GestureDetector(
            onTap: () async {
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
                    child: FoodScreen(id: model.id!, from: 'campaign', data: jsonEncode(model), extraInfo: ''),
                  );
                },
              ).then((value) {
                if (!context.mounted) return;
                if (value != null) {
                  FoodInfoModalResponseModel foodInfoModalResponse = FoodInfoModalResponseModel.fromJson(value, appLocale);
                  context.read<FoodCampaignBloc>().add(FoodCampaignFoodModalResponseEvent(id: model.id!, response: foodInfoModalResponse));
                }
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                kAppSpacerVertical(height: 5),
                Text(kAppTrimWord(model.restaurants!.name!, 15), style: kAppLblTinyFontRegular(context)),
                Text(kAppTrimWord(model.name!, 15), style: kAppLblMediumFontBold(context)),
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
          ),
        ],
      ),
    );
  }
}

