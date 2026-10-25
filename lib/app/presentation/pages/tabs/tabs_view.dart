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
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/cart_summary_modal_response_model.dart';
import 'package:user/app/presentation/pages/account/@core/account_view.dart';
import 'package:user/app/presentation/pages/cart/checkout/bloc/checkout_bloc.dart';
import 'package:user/app/presentation/pages/dining/@core/dining_view.dart';
import 'package:user/app/presentation/pages/favourite/@core/favourite_view.dart';
import 'package:user/app/presentation/pages/favourite/foods/bloc/favourite_foods_bloc.dart';
import 'package:user/app/presentation/pages/history/@core/history_view.dart';
import 'package:user/app/presentation/pages/home/@core/bloc/home_bloc.dart';
import 'package:user/app/presentation/pages/home/@core/home_view.dart';
import 'package:user/app/presentation/pages/home/campaign/food_campaign/bloc/food_campaign_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/@core/bloc/restaurant_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/food_search/bloc/food_search_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/categories/filter_foods/bloc/filter_foods_by_category_bloc.dart';
import 'package:user/app/presentation/pages/modals/cart_summary_modal/bloc/cart_summary_modal_bloc.dart';
import 'package:user/app/presentation/pages/modals/cart_summary_modal/cart_summar_modal_view.dart';
import 'package:user/app/presentation/pages/modals/single_food_from_banner_modal/bloc/single_food_from_banner_modal_bloc.dart';
import 'package:user/app/presentation/pages/reel/@core/reels_view.dart';
import 'package:user/app/presentation/pages/tabs/bloc/bottom_tab_navigation_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/confirm_dialog.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/loader_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AppBottomTabScreen extends StatelessWidget {
  final int tabIndex;
  const AppBottomTabScreen({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<BottomTabNavigationBloc>().add(
                BottomNavigationRefreshCartEvent(),
              );
            }
          },
        ),
        BlocListener<RestaurantBloc, RestaurantState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<BottomTabNavigationBloc>().add(
                BottomNavigationRefreshCartEvent(),
              );
            }
          },
        ),
        BlocListener<CartSummaryModalBloc, CartSummaryModalState>(
          listener: (context, state) {
            if (state.status.isUpdateCart) {
              context.read<BottomTabNavigationBloc>().add(
                BottomNavigationRefreshCartEvent(),
              );
            }
          },
        ),
        BlocListener<FoodCampaignBloc, FoodCampaignState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<BottomTabNavigationBloc>().add(
                BottomNavigationRefreshCartEvent(),
              );
            }
          },
        ),
        BlocListener<FilterFoodsByCategoryBloc, FilterFoodsByCategoryState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<BottomTabNavigationBloc>().add(
                BottomNavigationRefreshCartEvent(),
              );
            }
          },
        ),
        BlocListener<
          SingleFoodFromBannerModalBloc,
          SingleFoodFromBannerModalState
        >(
          listener: (context, state) {
            if (state.status.isCartUpdate ||
                state.status.isSaveClose ||
                state.status.isCartError) {
              context.read<BottomTabNavigationBloc>().add(
                BottomNavigationRefreshCartEvent(),
              );
            }
          },
        ),
        BlocListener<FavouriteFoodsBloc, FavouriteFoodsState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<BottomTabNavigationBloc>().add(
                BottomNavigationRefreshCartEvent(),
              );
            }
          },
        ),
        BlocListener<FoodSearchBloc, FoodSearchState>(
          listener: (context, state) {
            if (state.status.isInitialCartUpdate ||
                state.status.isInitialCartError ||
                state.status.isSearchCartUpdate ||
                state.status.isSearchCartError ||
                state.status.isCartError) {
              context.read<BottomTabNavigationBloc>().add(
                BottomNavigationRefreshCartEvent(),
              );
            }
          },
        ),
        BlocListener<CheckoutBloc, CheckoutState>(
          listener: (context, state) {
            if (state.status.isCartUpdate ||
                state.status.isCartError ||
                state.status.isOrderPlaced ||
                state.status.isMakePayment) {
              context.read<BottomTabNavigationBloc>().add(
                BottomNavigationRefreshCartEvent(),
              );
            }
          },
        ),
      ],
      child: BottomNavigationView(tabIndex: tabIndex),
    );
  }
}

class BottomNavigationView extends StatefulWidget {
  final int tabIndex;
  const BottomNavigationView({super.key, required this.tabIndex});

  @override
  State<BottomNavigationView> createState() => _BottomNavigationViewState();
}

class _BottomNavigationViewState extends State<BottomNavigationView>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    context.read<BottomTabNavigationBloc>().add(
      BottomNavigationTabInitialEvent(tabIndex: widget.tabIndex),
    );
    tabController = TabController(
      initialIndex: widget.tabIndex,
      length: 6,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<BottomTabNavigationBloc, BottomTabNavigationState>(
      listener: (context, state) {
        if (tabController.index != state.tabIndex) {
          tabController.animateTo(state.tabIndex);
        }
        if (state.canActivate == false) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.locationSearchRoute,
            (Route<dynamic> route) => false,
          );
        } else if (state.status.isAuthorized) {
          context.read<BottomTabNavigationBloc>().add(
            BottomTabNavigationChangeInitialEvent(),
          );
          Navigator.of(context).pushNamed(
            AppRouter.checkoutRoute,
            arguments: [state.checkoutName, state.checkoutRestaurant],
          );
        } else if (state.status.isUnauthorized) {
          showConfirmDialog(
            context,
            translate.unauthorized,
            translate.unauthorized_checkout_access,
            state.guestCheckout ? translate.sign_in : translate.cancle,
            state.guestCheckout ? translate.guest_checkout : translate.sign_in,
          ).then((value) {
            if (!context.mounted) return;
            if (state.guestCheckout) {
              if (value == false) {
                context.read<BottomTabNavigationBloc>().add(
                  BottomTabNavigationChangeInitialEvent(),
                );
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.loginRoute,
                  (Route<dynamic> route) => false,
                );
              } else {
                context.read<BottomTabNavigationBloc>().add(
                  BottomTabNavigationGuestCheckoutEvent(),
                );
              }
            } else {
              if (value == true) {
                context.read<BottomTabNavigationBloc>().add(
                  BottomTabNavigationChangeInitialEvent(),
                );
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.loginRoute,
                  (Route<dynamic> route) => false,
                );
              }
            }
          });
        } else if (state.status.isGuestCheckoutStart) {
          LoaderService.showLoader(context, msg: translate.please_wait);
        } else if (state.status.isGuestCheckoutFailed) {
          LoaderService.hideLoder(context);
          context.read<BottomTabNavigationBloc>().add(
            BottomTabNavigationChangeInitialEvent(),
          );
          showErrorDialog(
            context,
            state.alertMessage,
            state.extraMessage,
            state.statusCode,
            fromAuth: true,
          );
        } else if (state.status.isGuestCheckoutSuccess) {
          LoaderService.hideLoder(context);
          context.read<BottomTabNavigationBloc>().add(
            BottomTabNavigationChangeInitialEvent(),
          );
          Navigator.of(context).pushNamed(
            AppRouter.checkoutRoute,
            arguments: [state.checkoutName, state.checkoutRestaurant],
          );
        } else if (state.status.isUpdateCartError) {
          showErrorDialog(
            context,
            state.alertMessage,
            state.extraMessage,
            state.statusCode,
          );
        }
      },
      builder: (context, state) {
        return DefaultTabController(
          length: 6,
          initialIndex: state.tabIndex,
          child: Scaffold(
            bottomNavigationBar: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  state.summary.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeProvider.scaffoldPadding,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: [
                              state.summary.length > 1
                                  ? Positioned(
                                      top: -10,
                                      child: GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            isDismissible: false,
                                            enableDrag: false,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(10.0),
                                                  ),
                                            ),
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            builder: (BuildContext context) {
                                              return const FractionallySizedBox(
                                                heightFactor: 0.4,
                                                child: CartSummarModalScreen(),
                                              );
                                            },
                                          ).then((value) {
                                            if (!context.mounted) return;
                                            if (value != null &&
                                                value.toString().isNotEmpty) {
                                              CartSummaryModalResponseModel
                                              cartSummaryModalResponse =
                                                  CartSummaryModalResponseModel.fromJson(
                                                    value,
                                                  );
                                              if (cartSummaryModalResponse
                                                      .type! ==
                                                  'restaurant') {
                                                final int restaurantIndex =
                                                    state.summary.indexWhere(
                                                      (element) =>
                                                          element.restId ==
                                                          cartSummaryModalResponse
                                                              .value,
                                                    );
                                                if (restaurantIndex != -1) {
                                                  Navigator.of(
                                                    context,
                                                  ).pushNamed(
                                                    AppRouter.restaurantRoute,
                                                    arguments: [
                                                      state
                                                          .summary[restaurantIndex]
                                                          .restaurantInfo!
                                                          .id!,
                                                      state
                                                          .summary[restaurantIndex]
                                                          .restaurantInfo!
                                                          .slug!,
                                                      state
                                                          .summary[restaurantIndex]
                                                          .restaurantInfo!
                                                          .name!,
                                                    ],
                                                  );
                                                }
                                              } else if (cartSummaryModalResponse
                                                      .type! ==
                                                  'checkout') {
                                                final int restaurantIndex =
                                                    state.summary.indexWhere(
                                                      (element) =>
                                                          element.restId ==
                                                          cartSummaryModalResponse
                                                              .value,
                                                    );
                                                if (restaurantIndex != -1) {
                                                  context
                                                      .read<
                                                        BottomTabNavigationBloc
                                                      >()
                                                      .add(
                                                        BottomTabNavigationOnCheckoutEvent(
                                                          name: state
                                                              .summary[restaurantIndex]
                                                              .restaurantInfo!
                                                              .name!,
                                                          restaurant: state
                                                              .summary[restaurantIndex]
                                                              .restaurantInfo!
                                                              .id!,
                                                        ),
                                                      );
                                                }
                                              }
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5.0,
                                            ),
                                            border: Border.all(
                                              color: ThemeProvider
                                                  .lightDisabledColor,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                "+ ${state.summary.length - 1} ${translate.more}",
                                                style:
                                                    kAppLblTinyFontRegularChip(
                                                      context,
                                                      color: 'primary',
                                                    ),
                                              ),
                                              kAppSpacerHorizontal(width: 5),
                                              Icon(
                                                Icons.arrow_drop_up_outlined,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                size: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        Navigator.of(context).pushNamed(
                                          AppRouter.restaurantRoute,
                                          arguments: [
                                            state
                                                .summary[0]
                                                .restaurantInfo!
                                                .id!,
                                            state
                                                .summary[0]
                                                .restaurantInfo!
                                                .slug!,
                                            state
                                                .summary[0]
                                                .restaurantInfo!
                                                .name!,
                                          ],
                                        ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                          child: CacheNetworkImageWidget(
                                            width: 40.0,
                                            height: 30.0,
                                            imageUrl: state
                                                .summary[0]
                                                .restaurantInfo!
                                                .logo!,
                                          ),
                                        ),
                                        kAppSpacerHorizontal(width: 10),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              kAppTrimWord(
                                                state
                                                    .summary[0]
                                                    .restaurantInfo!
                                                    .name!,
                                                30,
                                              ),
                                              style: kAppLblTinyFontBold(
                                                context,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  translate.view_menu,
                                                  style:
                                                      kAppLblTinyFontRegularChip(
                                                        context,
                                                        color: 'primary',
                                                      ),
                                                ),
                                                Icon(
                                                  Icons.chevron_right,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                  size: 12,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () => context
                                            .read<BottomTabNavigationBloc>()
                                            .add(
                                              BottomTabNavigationOnCheckoutEvent(
                                                name: state
                                                    .summary[0]
                                                    .restaurantInfo!
                                                    .name!,
                                                restaurant: state
                                                    .summary[0]
                                                    .restaurantInfo!
                                                    .id!,
                                              ),
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                translate.view_cart,
                                                style: kAppLblTinyFontBoldCart(
                                                  context,
                                                ),
                                              ),
                                              Text(
                                                "${state.summary[0].totalItemInCart} ${translate.items}",
                                                style: kAppLblTinyFontBoldCart(
                                                  context,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      kAppSpacerHorizontal(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          showConfirmDialog(
                                            context,
                                            translate.are_you_sure,
                                            '${translate.confirm_remove_restaurant_cart_item_one} ${state.summary[0].restaurantInfo!.name!} ${translate.confirm_remove_restaurant_cart_item_two}',
                                            translate.no,
                                            translate.yes,
                                          ).then((value) {
                                            if (!context.mounted) return;
                                            if (value == true) {
                                              context
                                                  .read<
                                                    BottomTabNavigationBloc
                                                  >()
                                                  .add(
                                                    BottomNavigationRemoveCartItemByRestaurant(
                                                      restaurantId: state
                                                          .summary[0]
                                                          .restId!,
                                                    ),
                                                  );
                                            }
                                          });
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: Theme.of(context).canvasColor,
                                          size: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  TabBar(
                    controller: tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Theme.of(context).hintColor,
                    indicatorColor: Theme.of(context).primaryColor,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 0),
                    labelStyle: kAppLblMediumFontMedium(context),
                    dividerColor: ThemeProvider.transparentColor,
                    onTap: (int index) => context
                        .read<BottomTabNavigationBloc>()
                        .add(BottomNavigationTabChange(tabIndex: index)),
                    tabs: [
                      Tab(
                        icon: Image.asset(
                          AssetsUrl.iconsURL.bottomTabDelivery,
                          height: 20,
                          width: 20,
                          color: state.tabIndex == 0
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).hintColor,
                        ),
                        text: translate.delivery,
                      ),
                      Tab(
                        icon: Image.asset(
                          AssetsUrl.iconsURL.bottomTabDining,
                          height: 20,
                          width: 20,
                          color: state.tabIndex == 1
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).hintColor,
                        ),
                        text: translate.dining,
                      ),
                      Tab(
                        icon: Image.asset(
                          AssetsUrl.iconsURL.bottomTabHistory,
                          height: 20,
                          width: 20,
                          color: state.tabIndex == 2
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).hintColor,
                        ),
                        text: translate.history,
                      ),
                      Tab(
                        icon: Image.asset(
                          state.tabIndex == 3
                              ? AssetsUrl.iconsURL.bottomTabFavouriteActive
                              : AssetsUrl.iconsURL.bottomTabFavourite,
                          height: 20,
                          width: 20,
                          color: state.tabIndex == 3
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).hintColor,
                        ),
                        text: translate.favourite,
                      ),
                      Tab(
                        icon: Image.asset(
                          AssetsUrl.iconsURL.bottomTabAccount,
                          height: 20,
                          width: 20,
                          color: state.tabIndex == 4
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).hintColor,
                        ),
                        text: translate.account,
                      ),
                      // TODO(asset): replace with a designer tab icon to match the other image-asset tabs.
                      Tab(
                        icon: Icon(
                          Icons.play_circle_outline,
                          size: 22,
                          color: state.tabIndex == 5
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).hintColor,
                        ),
                        text: translate.reels,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                const HomeScreen(),
                const DiningScreen(),
                const HistoryScreen(),
                const FavouriteScreen(),
                const AccountScreen(),
                // Reels must be told when its tab is showing. `TabBarView` keeps every
                // child mounted, so the video player survives a tab switch and keeps
                // playing audio over whatever the user moved to.
                BlocSelector<
                  BottomTabNavigationBloc,
                  BottomTabNavigationState,
                  bool
                >(
                  selector: (state) => state.tabIndex == 5,
                  builder: (context, isActive) =>
                      ReelsScreen(isActive: isActive),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Done //
