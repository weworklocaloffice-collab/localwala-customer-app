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
import 'package:user/app/core/models/cart_summary_model.dart';
import 'package:user/app/presentation/pages/cart/@core/bloc/cart_bloc.dart';
import 'package:user/app/presentation/pages/cart/checkout/bloc/checkout_bloc.dart';
import 'package:user/app/presentation/pages/favourite/foods/bloc/favourite_foods_bloc.dart';
import 'package:user/app/presentation/pages/home/@core/bloc/home_bloc.dart';
import 'package:user/app/presentation/pages/home/campaign/food_campaign/bloc/food_campaign_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/@core/bloc/restaurant_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/food_search/bloc/food_search_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/categories/filter_foods/bloc/filter_foods_by_category_bloc.dart';
import 'package:user/app/presentation/pages/modals/single_food_from_banner_modal/bloc/single_food_from_banner_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/confirm_dialog.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/loader_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<CartBloc>().add(CartRefreshEvent());
            }
          },
        ),
        BlocListener<RestaurantBloc, RestaurantState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<CartBloc>().add(CartRefreshEvent());
            }
          },
        ),
        BlocListener<FoodCampaignBloc, FoodCampaignState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<CartBloc>().add(CartRefreshEvent());
            }
          },
        ),
        BlocListener<FilterFoodsByCategoryBloc, FilterFoodsByCategoryState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<CartBloc>().add(CartRefreshEvent());
            }
          },
        ),
        BlocListener<SingleFoodFromBannerModalBloc, SingleFoodFromBannerModalState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isSaveClose || state.status.isCartError) {
              context.read<CartBloc>().add(CartRefreshEvent());
            }
          },
        ),
        BlocListener<FavouriteFoodsBloc, FavouriteFoodsState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<CartBloc>().add(CartRefreshEvent());
            }
          },
        ),
        BlocListener<FoodSearchBloc, FoodSearchState>(
          listener: (context, state) {
            if (state.status.isInitialCartUpdate || state.status.isInitialCartError || state.status.isSearchCartUpdate || state.status.isSearchCartError || state.status.isCartError) {
              context.read<CartBloc>().add(CartRefreshEvent());
            }
          },
        ),
        BlocListener<CheckoutBloc, CheckoutState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError || state.status.isOrderPlaced || state.status.isMakePayment) {
              context.read<CartBloc>().add(CartRefreshEvent());
            }
          },
        ),
      ],
      child: const CartView(),
    );
  }
}

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(CartInitialEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCartError || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isAuthorized) {
          Navigator.of(context).pushNamed(AppRouter.checkoutRoute, arguments: [state.checkoutName, state.checkoutRestaurant]);
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
                Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
              } else {
                context.read<CartBloc>().add(CartGuestCheckoutEvent());
              }
            } else {
              if (value == true) {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
              }
            }
          });
        } else if (state.status.isGuestCheckoutStart) {
          LoaderService.showLoader(context, msg: translate.please_wait);
        } else if (state.status.isGuestCheckoutFailed) {
          LoaderService.hideLoder(context);
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode, fromAuth: true);
        } else if (state.status.isGuestCheckoutSuccess) {
          LoaderService.hideLoder(context);
          Navigator.of(context).pushNamed(AppRouter.checkoutRoute, arguments: [state.checkoutName, state.checkoutRestaurant]);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.cart), automaticallyImplyLeading: false, scrolledUnderElevation: 0),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                children: [
                  if (state.status.isLoading) ...[const CartLoadingView()] else if (state.status.isEmpty || state.status.isFailure) ...[const CartEmptyView()] else ...[CartResponseView(summary: state.summary)],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CartLoadingView extends StatelessWidget {
  const CartLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
      child: Column(
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
      ),
    );
  }
}

class CartEmptyView extends StatelessWidget {
  const CartEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.cartEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.empty_cart_title, textAlign: TextAlign.center, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.empty_cart_sub_title, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class CartResponseView extends StatelessWidget {
  final List<CartSummaryModel> summary;
  const CartResponseView({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        summary.length,
        (summaryIndex) => Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  summary[summaryIndex].summary!.length,
                  (foodIndex) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(kAppTrimWord(summary[summaryIndex].summary![foodIndex].name!, 50), style: kAppLblMediumFontBold(context)),
                              kAppSpacerVertical(height: 5),
                              summary[summaryIndex].summary![foodIndex].discount! <= 0
                                  ? Text(kAppPriceFormat(summary[summaryIndex].summary![foodIndex].price!), style: kAppLblTinyMediumFontSemi(context))
                                  : Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(kAppPriceFormat(summary[summaryIndex].summary![foodIndex].price!), style: kAppLblTinyStrokeFontRegular(context)),
                                        kAppSpacerHorizontal(width: 5),
                                        Text(kAppPriceFormat(summary[summaryIndex].summary![foodIndex].offerPrice!), style: kAppLblTinyMediumFontSemi(context)),
                                      ],
                                    ),
                              kAppSpacerVertical(height: 5),
                              summary[summaryIndex].summary![foodIndex].optionName!.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.only(right: 5),
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.8, minWidth: MediaQuery.of(context).size.width / 2.5),
                                      child: Text(summary[summaryIndex].summary![foodIndex].optionName!, maxLines: 4, style: kAppLblTinyFontRegular(context)),
                                    )
                                  : const SizedBox(),
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
                                      onTap: () => context.read<CartBloc>().add(CartQuantityEvent(action: 'decrease', summaryIndex: summaryIndex, foodIndex: foodIndex)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 5),
                                        child: Icon(Icons.remove, size: 18, color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    Text("${summary[summaryIndex].summary![foodIndex].quantity!}", style: kAppLblSmallFontBold(context, color: 'primary')),
                                    InkWell(
                                      onTap: () => context.read<CartBloc>().add(CartQuantityEvent(action: 'increase', summaryIndex: summaryIndex, foodIndex: foodIndex)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 15, right: 5),
                                        child: Icon(Icons.add, size: 18, color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              kAppSpacerVertical(height: 5),
                              Text(kAppPriceFormat(summary[summaryIndex].summary![foodIndex].totalPrice!), style: kAppLblTinyMediumFontSemi(context)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              kAppSpacerVertical(height: 10),
              GestureDetector(
                onTap: () => context.read<CartBloc>().add(CartOnCheckoutEvent(name: summary[summaryIndex].restaurantInfo!.name!, restaurant: summary[summaryIndex].restaurantInfo!.id!)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(translate.place_order, style: kAppLblMediumFontSemiBoldWhite(context)),
                            kAppSpacerVertical(height: 5),
                            Text(kAppTrimWord(summary[summaryIndex].restaurantInfo!.name!, 30), style: kAppLblTinyFontBoldCart(context)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(kAppPriceFormat(summary[summaryIndex].totalRestPrice!), style: kAppLblMediumFontSemiBoldWhite(context)),
                            kAppSpacerVertical(height: 5),
                            Text(translate.total, style: kAppLblTinyFontBoldCart(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              kAppSpacerVertical(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
// Done //
