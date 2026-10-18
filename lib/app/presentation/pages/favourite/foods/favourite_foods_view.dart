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
import 'package:user/app/core/models/favourite_foods_model.dart';
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/food_variations_response_data_modal_model.dart';
import 'package:user/app/core/models/repeat_quantity_modal_response_model.dart';
import 'package:user/app/presentation/pages/cart/@core/bloc/cart_bloc.dart';
import 'package:user/app/presentation/pages/cart/checkout/bloc/checkout_bloc.dart';
import 'package:user/app/presentation/pages/favourite/foods/bloc/favourite_foods_bloc.dart';
import 'package:user/app/presentation/pages/home/@core/bloc/home_bloc.dart';
import 'package:user/app/presentation/pages/home/campaign/food_campaign/bloc/food_campaign_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/@core/bloc/restaurant_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/food_search/bloc/food_search_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/categories/filter_foods/bloc/filter_foods_by_category_bloc.dart';
import 'package:user/app/presentation/pages/modals/cart_summary_modal/bloc/cart_summary_modal_bloc.dart';
import 'package:user/app/presentation/pages/modals/food_info_modal/food_view.dart';
import 'package:user/app/presentation/pages/modals/food_variations_modal/@core/food_variations_modal_view.dart';
import 'package:user/app/presentation/pages/modals/food_variations_modal/repeat/food_variation_modal_repeat_view.dart';
import 'package:user/app/presentation/pages/modals/single_food_from_banner_modal/bloc/single_food_from_banner_modal_bloc.dart';
import 'package:user/app/presentation/pages/tabs/bloc/bottom_tab_navigation_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/loader_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FavouriteFoodListScreen extends StatelessWidget {
  const FavouriteFoodListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRefreshCartEvent());
            } else if (state.status.isFoodFav) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsSilenceEvent());
            }
          },
        ),
        BlocListener<SingleFoodFromBannerModalBloc, SingleFoodFromBannerModalState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isSaveClose || state.status.isCartError) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRefreshCartEvent());
            } else if (state.status.isFavAdd || state.status.isFavRemove) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsSilenceEvent());
            }
          },
        ),
        BlocListener<RestaurantBloc, RestaurantState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRefreshCartEvent());
            } else if (state.status.isFavFoodUpdate) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsSilenceEvent());
            }
          },
        ),
        BlocListener<BottomTabNavigationBloc, BottomTabNavigationState>(
          listener: (context, state) {
            if (state.status.isUpdateCart || state.status.isUpdateCartError) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRefreshCartEvent());
            }
          },
        ),
        BlocListener<CartSummaryModalBloc, CartSummaryModalState>(
          listener: (context, state) {
            if (state.status.isUpdateCart) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRefreshCartEvent());
            }
          },
        ),
        BlocListener<FoodCampaignBloc, FoodCampaignState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRefreshCartEvent());
            } else if (state.status.isFavUpdate) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsSilenceEvent());
            }
          },
        ),
        BlocListener<FilterFoodsByCategoryBloc, FilterFoodsByCategoryState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRefreshCartEvent());
            } else if (state.status.isFavUpdate) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsSilenceEvent());
            }
          },
        ),
        BlocListener<FoodSearchBloc, FoodSearchState>(
          listener: (context, state) {
            if (state.status.isInitialCartUpdate || state.status.isInitialCartError || state.status.isSearchCartUpdate || state.status.isSearchCartError || state.status.isCartError) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRefreshCartEvent());
            } else if (state.status.isInitialFoodFav || state.status.isSearchFoodFav) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsSilenceEvent());
            }
          },
        ),
        BlocListener<CartBloc, CartState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRefreshCartEvent());
            }
          },
        ),
        BlocListener<CheckoutBloc, CheckoutState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError || state.status.isOrderPlaced || state.status.isMakePayment) {
              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRefreshCartEvent());
            }
          },
        ),
      ],
      child: const FavouriteFoodListView(),
    );
  }
}

class FavouriteFoodListView extends StatefulWidget {
  const FavouriteFoodListView({super.key});

  @override
  State<FavouriteFoodListView> createState() => _FavouriteFoodListViewState();
}

class _FavouriteFoodListViewState extends State<FavouriteFoodListView> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollFood = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<FavouriteFoodsBloc>().add(FavouriteFoodsInitialEvent());
    _scrollFood.addListener(() {
      if (_scrollFood.position.pixels == _scrollFood.position.maxScrollExtent) {
        context.read<FavouriteFoodsBloc>().add(FavouriteFoodsLoadMoreEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    super.build(context);
    return BlocConsumer<FavouriteFoodsBloc, FavouriteFoodsState>(
      listener: (context, state) {
        if (state.status.isRemoveFavStart) {
          LoaderService.showLoader(context, msg: translate.please_wait);
        } else if (state.status.isRemoveFavDone) {
          LoaderService.hideLoder(context);
          showSuccessDialog(context, translate.removed_from_list);
        } else if (state.status.isRemoveFailed) {
          LoaderService.hideLoder(context);
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isFailure || state.status.isCustomError || state.status.isCartError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollFood,
          child: Padding(
            padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const FavouriteFoodsLoadingView(),
                ] else if (state.status.isUnAuthorized) ...[
                  const UnauthorizedWidget(),
                ] else if (state.status.isFailure) ...[
                  const FavouriteFoodsErroView(),
                ] else if (state.status.isEmpty) ...[
                  const FavouriteFoodsEmptyView(),
                ] else
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
                          child: HorizontalFoodBlock(model: state.foods.foods![index], appLocale: state.appLocale),
                        ),
                      );
                    },
                    itemCount: state.foods.foods!.length,
                  ),
                kAppSpacerVertical(height: 20),
                state.loadMore ? kAppCenterCircularProgress(context) : const SizedBox(),
                kAppSpacerVertical(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class FavouriteFoodsLoadingView extends StatelessWidget {
  const FavouriteFoodsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}

class FavouriteFoodsErroView extends StatelessWidget {
  const FavouriteFoodsErroView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.system_error_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          kAppSpacerVertical(height: 30),
          TextButton(
            onPressed: () => {},
            style: kAppTextButtonColoredStyle(context, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor),
            child: Text(translate.understand_btn),
          ),
        ],
      ),
    );
  }
}

class FavouriteFoodsEmptyView extends StatelessWidget {
  const FavouriteFoodsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.empty_data, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          kAppSpacerVertical(height: 30),
          TextButton(
            onPressed: () => {},
            style: kAppTextButtonColoredStyle(context, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor),
            child: Text(translate.understand_btn),
          ),
        ],
      ),
    );
  }
}

class HorizontalFoodBlock extends StatelessWidget {
  final FavouriteFoodModel model;
  final String appLocale;
  const HorizontalFoodBlock({super.key, required this.model, required this.appLocale});

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
                        child: FoodScreen(id: model.id!, from: 'favourite', data: jsonEncode(model), extraInfo: ''),
                      );
                    },
                  ).then((value) {
                    if (!context.mounted) return;
                    if (value != null) {
                      FoodInfoModalResponseModel foodInfoModalResponse = FoodInfoModalResponseModel.fromJson(value, appLocale);
                      context.read<FavouriteFoodsBloc>().add(FavouriteFoodModalResponseEvent(id: model.id!, response: foodInfoModalResponse));
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
                                  context.read<FavouriteFoodsBloc>().add(FavouriteFoodsVariationModalResponseEvent(id: model.id!, data: foodVariationModalResponse));
                                }
                              }
                            });
                          } else {
                            context.read<FavouriteFoodsBloc>().add(FavouriteFoodsAddCartEvent(id: model.id!));
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
                                        context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRepeatFoodOrderResponseEvent(id: model.id!, data: repeatQuantityModalResponse));
                                      }
                                    }
                                  });
                                } else {
                                  context.read<FavouriteFoodsBloc>().add(FavouriteFoodsFoodQuantityDecreaseEvent(id: model.id!));
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
                                        context.read<FavouriteFoodsBloc>().add(FavouriteFoodsRepeatFoodOrderResponseEvent(id: model.id!, data: repeatQuantityModalResponse));
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
                                              context.read<FavouriteFoodsBloc>().add(FavouriteFoodsFoodVariationModalRepeatResponseEvent(id: model.id!, data: foodVariationModalResponse));
                                            }
                                          }
                                        });
                                      }
                                    }
                                  });
                                } else {
                                  context.read<FavouriteFoodsBloc>().add(FavouriteFoodsFoodQuantityIncreaseEvent(id: model.id!));
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
                  onTap: () => context.read<FavouriteFoodsBloc>()..add(FavouriteFoodsDeleteFoodEvent(foodId: model.id!)),
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                    child: Icon(Icons.favorite_rounded, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
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
                    child: FoodScreen(id: model.id!, from: 'favourite', data: jsonEncode(model), extraInfo: ''),
                  );
                },
              ).then((value) {
                if (!context.mounted) return;
                if (value != null) {
                  FoodInfoModalResponseModel foodInfoModalResponse = FoodInfoModalResponseModel.fromJson(value, appLocale);
                  context.read<FavouriteFoodsBloc>().add(FavouriteFoodModalResponseEvent(id: model.id!, response: foodInfoModalResponse));
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

