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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/food_search_result_response_model.dart';
import 'package:user/app/core/models/food_variations_response_data_modal_model.dart';
import 'package:user/app/core/models/repeat_quantity_modal_response_model.dart';
import 'package:user/app/presentation/pages/home/restaurant/food_search/bloc/food_search_bloc.dart';
import 'package:user/app/presentation/pages/modals/food_info_modal/food_view.dart';
import 'package:user/app/presentation/pages/modals/food_variations_modal/@core/food_variations_modal_view.dart';
import 'package:user/app/presentation/pages/modals/food_variations_modal/repeat/food_variation_modal_repeat_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FoodSearchScreen extends StatelessWidget {
  final String id;
  final String name;
  const FoodSearchScreen({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    return FoodSearchView(id: id, name: name);
  }
}

class FoodSearchView extends StatefulWidget {
  final String id;
  final String name;
  const FoodSearchView({super.key, required this.id, required this.name});

  @override
  State<FoodSearchView> createState() => _FoodSearchViewState();
}

class _FoodSearchViewState extends State<FoodSearchView> {
  @override
  void initState() {
    super.initState();
    context.read<FoodSearchBloc>().add(FoodSearchInitialEvent(id: widget.id, name: widget.name));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<FoodSearchBloc, FoodSearchState>(
      listener: (context, state) {
        if (state.status.isInitialCartError || state.status.isSearchCartError || state.status.isCartError || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: CupertinoSearchTextField(
              placeholder: "${translate.search_food_query} ${state.name}",
              style: kAppLblMediumFontRegular(context),
              placeholderStyle: kAppLblMediumFontRegular(context),
              onChanged: (value) {
                context.read<FoodSearchBloc>().add(FoodSearchFindResultEvent(searchQuery: value));
              },
              // onSubmitted: (value) {
              //   context.read<FoodSearchBloc>().add(FoodSearchFindResultEvent(searchQuery: value));
              // },
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_outlined, color: Theme.of(context).iconTheme.color),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isInitial || state.status.isInitialCartError || state.status.isInitialCartUpdate || state.status.isInitialFoodFav) ...[
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 100),
                    scrollDirection: Axis.vertical,
                    key: UniqueKey(),
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
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
                                child: FoodScreen(id: state.initialData.foods![index].id!, from: 'search', data: jsonEncode(state.initialData.foods![index]), extraInfo: ''),
                              );
                            },
                          ).then((value) {
                            if (!context.mounted) return;
                            if (value != null) {
                              FoodInfoModalResponseModel foodInfoModalResponse = FoodInfoModalResponseModel.fromJson(value, state.appLocale);
                              context.read<FoodSearchBloc>().add(FoodSearchModalResponseEvent(id: state.initialData.foods![index].id!, collection: 'initial', response: foodInfoModalResponse));
                            }
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                                  child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 100.0, imageUrl: state.initialData.foods![index].image!),
                                ),
                                Positioned(
                                  left: 0,
                                  bottom: 0,
                                  width: MediaQuery.of(context).size.width,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: const BoxDecoration(color: ThemeProvider.darkBackgroundColor),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        state.initialData.foods![index].foodType! != 'none' ? kAppFoodType(state.initialData.foods![index].foodType!, height: 10, width: 10) : const SizedBox(),
                                        state.initialData.foods![index].foodType! != 'none' ? kAppSpacerHorizontal(width: 5) : const SizedBox(),
                                        Text(
                                          kAppTrimWord(state.initialData.foods![index].name!, 20),
                                          style: const TextStyle(fontFamily: 'regular', color: ThemeProvider.whiteColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: state.initialData.foods!.length,
                  ),
                ] else if (state.status.isFailure) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(translate.oops_title, style: kAppLblLargeFontBold(context)),
                      kAppSpacerVertical(height: 5),
                      Text(translate.empty_data_three, style: kAppLblSmallFontMedium(context)),
                    ],
                  ),
                ] else if (state.status.isEmpty) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(translate.oops_title, style: kAppLblLargeFontBold(context)),
                      kAppSpacerVertical(height: 5),
                      Text(translate.explain_query, style: kAppLblSmallFontMedium(context)),
                    ],
                  ),
                ] else if (state.status.isSuccess || state.status.isSearchCartError || state.status.isSearchCartUpdate || state.status.isSearchFoodFav) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(state.response.foods!.length, (index) => FoodBlockView(model: state.response.foods![index], appLocale: state.appLocale)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class FoodBlockView extends StatelessWidget {
  final FoodSearchResultModel model;
  final String appLocale;
  const FoodBlockView({super.key, required this.model, required this.appLocale});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: GestureDetector(
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
                      child: FoodScreen(id: model.id!, from: 'search', data: jsonEncode(model), extraInfo: ''),
                    );
                  },
                ).then((value) {
                  if (!context.mounted) return;
                  if (value != null) {
                    FoodInfoModalResponseModel foodInfoModalResponse = FoodInfoModalResponseModel.fromJson(value, appLocale);
                    context.read<FoodSearchBloc>().add(FoodSearchModalResponseEvent(id: model.id!, collection: 'result', response: foodInfoModalResponse));
                  }
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppFoodType(model.foodType!),
                  kAppSpacerVertical(height: 5),
                  Text(kAppTrimWord(model.name!, 50), style: kAppLblMediumFontBold(context)),
                  model.rating! > 0
                      ? Column(
                          children: [
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
                          ],
                        )
                      : const SizedBox(),
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
                  kAppSpacerVertical(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text(kAppTrimWord(model.shortDescription!, 150), style: kAppLblTinyFontRegular(context)),
                  ),
                  kAppSpacerVertical(height: 5),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
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
                          child: FoodScreen(id: model.id!, from: 'search', data: jsonEncode(model), extraInfo: ''),
                        );
                      },
                    ).then((value) {
                      if (!context.mounted) return;
                      if (value != null) {
                        FoodInfoModalResponseModel foodInfoModalResponse = FoodInfoModalResponseModel.fromJson(value, appLocale);
                        context.read<FoodSearchBloc>().add(FoodSearchModalResponseEvent(id: model.id!, collection: 'result', response: foodInfoModalResponse));
                      }
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CacheNetworkImageWidget(width: double.infinity, height: 80.0, imageUrl: model.image!),
                  ),
                ),
                Positioned(
                  bottom: -25,
                  child: Column(
                    children: [
                      model.quantity! <= 0
                          ? InkWell(
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
                                        context.read<FoodSearchBloc>().add(FoodSearchVariationModalResponseEvent(id: model.id!, data: foodVariationModalResponse));
                                      }
                                    }
                                  });
                                } else {
                                  context.read<FoodSearchBloc>().add(FoodSearchAddCartEvent(id: model.id!));
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                child: Text(translate.add_cart, style: kAppLblSmallFontBold(context, color: 'primary')),
                              ),
                            )
                          : Container(
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
                                              context.read<FoodSearchBloc>().add(FoodSearchRepeatFoodOrderResponseEvent(id: model.id!, data: repeatQuantityModalResponse));
                                            }
                                          }
                                        });
                                      } else {
                                        context.read<FoodSearchBloc>().add(FoodSearchFoodQuantityDecreaseEvent(id: model.id!));
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 15, left: 5),
                                      child: Icon(Icons.remove, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  Text("${model.quantity!}", style: kAppLblSmallFontBold(context, color: 'primary')),
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
                                              context.read<FoodSearchBloc>().add(FoodSearchRepeatFoodOrderResponseEvent(id: model.id!, data: repeatQuantityModalResponse));
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
                                                    context.read<FoodSearchBloc>().add(FoodSearchFoodVariationModalRepeatResponseEvent(id: model.id!, data: foodVariationModalResponse));
                                                  }
                                                }
                                              });
                                            }
                                          }
                                        });
                                      } else {
                                        context.read<FoodSearchBloc>().add(FoodSearchFoodQuantityIncreaseEvent(id: model.id!));
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15, right: 5),
                                      child: Icon(Icons.add, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(height: 5),
                      model.addons!.isNotEmpty || model.variations!.isNotEmpty ? Text(translate.customizable, style: kAppLblTinyFontRegular(context)) : Text("", style: kAppLblTinyFontRegular(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

