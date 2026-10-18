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

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/food_variations_response_data_modal_model.dart';
import 'package:user/app/core/models/repeat_quantity_modal_response_model.dart';
import 'package:user/app/core/models/restaurant_info_response_model.dart';
import 'package:user/app/core/models/restaurants_localities_modal_response_model.dart';
import 'package:user/app/presentation/pages/cart/@core/bloc/cart_bloc.dart';
import 'package:user/app/presentation/pages/cart/checkout/bloc/checkout_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/food_search/bloc/food_search_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/restaurant_detail_info/bloc/restaurant_detail_info_bloc.dart';
import 'package:user/app/presentation/pages/modals/cart_summary_modal/bloc/cart_summary_modal_bloc.dart';
import 'package:user/app/presentation/pages/modals/coupon_info_modal/coupon_info_modal_view.dart';
import 'package:user/app/presentation/pages/modals/food_info_modal/food_view.dart';
import 'package:user/app/presentation/pages/home/restaurant/@core/bloc/restaurant_bloc.dart';
import 'package:user/app/presentation/pages/modals/food_variations_modal/@core/food_variations_modal_view.dart';
import 'package:user/app/presentation/pages/modals/food_variations_modal/repeat/food_variation_modal_repeat_view.dart';
import 'package:user/app/presentation/pages/modals/report_issue_restaurant_modal/report_issue_restaurant_modal_view.dart';
import 'package:user/app/presentation/pages/modals/restaurant_info_modal/restaurant_info_modal_view.dart';
import 'package:user/app/presentation/pages/modals/restaurant_menu_modal/restaurant_menu_modal_view.dart';
import 'package:user/app/presentation/pages/modals/restaurants_by_localities_modal/restaurants_by_localities_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/confirm_dialog.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/loader_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class RestaurantScreen extends StatelessWidget {
  final String id;
  final String slug;
  final String name;
  const RestaurantScreen({super.key, required this.id, required this.slug, required this.name});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FoodSearchBloc, FoodSearchState>(
          listener: (context, state) {
            if (state.status.isInitialCartUpdate || state.status.isInitialCartError || state.status.isSearchCartUpdate || state.status.isSearchCartError || state.status.isCartError) {
              context.read<RestaurantBloc>().add(RestaurantRefreshCartEvent());
            } else if (state.status.isInitialFoodFav) {
              context.read<RestaurantBloc>().add(RestaurantRefreshFoodFavEvent(inFavList: state.initialFavIds));
            } else if (state.status.isSearchFoodFav) {
              context.read<RestaurantBloc>().add(RestaurantRefreshFoodFavEvent(inFavList: state.resultFavIds));
            }
          },
        ),
        BlocListener<CheckoutBloc, CheckoutState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError || state.status.isOrderPlaced || state.status.isMakePayment) {
              context.read<RestaurantBloc>().add(RestaurantRefreshCartEvent());
            }
          },
        ),
        BlocListener<CartBloc, CartState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<RestaurantBloc>().add(RestaurantRefreshCartEvent());
            }
          },
        ),
        BlocListener<CartSummaryModalBloc, CartSummaryModalState>(
          listener: (context, state) {
            if (state.status.isUpdateCart) {
              context.read<RestaurantBloc>().add(RestaurantRefreshCartEvent());
            }
          },
        ),
        BlocListener<RestaurantDetailInfoBloc, RestaurantDetailInfoState>(
          listener: (context, state) {
            if (state.status.isFavAdd || state.status.isFavRemove) {
              context.read<RestaurantBloc>().add(RestaurantRefreshFavEvent());
            }
          },
        ),
      ],
      child: RestaurantView(id: id, slug: slug, name: name),
    );
  }
}

class RestaurantView extends StatefulWidget {
  final String id;
  final String slug;
  final String name;
  const RestaurantView({super.key, required this.id, required this.slug, required this.name});

  @override
  State<RestaurantView> createState() => _RestaurantViewState();
}

class _RestaurantViewState extends State<RestaurantView> {
  final ScrollController _scrollControllerMain = ScrollController();
  final ScrollController _scrollControllerCategories = ScrollController();
  final Map<String, GlobalKey> _globalBottomCategoriesKey = {};

  bool _isDialogShown = false;
  late RestaurantBloc _restaurantBloc;
  @override
  void initState() {
    super.initState();
    _restaurantBloc = BlocProvider.of<RestaurantBloc>(context);
    context.read<RestaurantBloc>().add(RestaurantInitialEvent(id: widget.id, slug: widget.slug, name: widget.name));
    _scrollControllerMain.addListener(() {
      context.read<RestaurantBloc>().state.globalMainCategoriesKey.entries.forEach((element) {
        double scrollPositionOfWidget = _getWidgetPosition(element.key);
        if (checkInRange(scrollPositionOfWidget, 60, 70)) {
          final String inTopView = element.key.replaceAll('main_', '');
          context.read<RestaurantBloc>().add(RestaurantScrollToCategory(categoryId: inTopView));
          scrollBottomCategory('bottom_$inTopView', inTopView);
        }
      });
    });
  }

  void onScrollToPosition(String id, String realId) {
    final keyContext = context.read<RestaurantBloc>().state.globalMainCategoriesKey[id]?.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(keyContext, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    }
  }

  bool checkInRange(double position, double min, double max) {
    return ((position - min) * (position - max) <= 0);
  }

  double _getWidgetPosition(String category) {
    final key = context.read<RestaurantBloc>().state.globalMainCategoriesKey[category];
    if (key != null) {
      final keyContext = key.currentContext;
      if (keyContext != null) {
        final box = keyContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        return position.dy;
      }
    }
    return 0.0;
  }

  @override
  void dispose() {
    super.dispose();
    _restaurantBloc.add(RestaurantClearCampaignEvent());
    _scrollControllerMain.dispose();
    _scrollControllerCategories.dispose();
  }

  void scrollBottomCategory(String categoryKey, String realId) {
    final keyContext = _globalBottomCategoriesKey[categoryKey]?.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(keyContext, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<RestaurantBloc, RestaurantState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError || state.status.isCartError && !_isDialogShown) {
          _isDialogShown = true;
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode).then((value) {
            setState(() {
              _isDialogShown = false;
            });
          });
        } else if (state.status.isStartHide) {
          LoaderService.showLoader(context, msg: translate.please_wait);
        } else if (state.status.isHideSuccess) {
          LoaderService.hideLoder(context);
          showSuccessDialog(context, translate.restaurant_hidden_success);
        } else if (state.status.isHideRequestFailed && !_isDialogShown) {
          LoaderService.hideLoder(context);
          _isDialogShown = true;
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode).then((value) {
            setState(() {
              _isDialogShown = false;
            });
          });
        } else if (state.status.isStartUnhide) {
          LoaderService.showLoader(context, msg: translate.please_wait);
        } else if (state.status.isUnhideRequestFailed && !_isDialogShown) {
          LoaderService.hideLoder(context);
          _isDialogShown = true;
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode).then((value) {
            setState(() {
              _isDialogShown = false;
            });
          });
        } else if (state.status.isUnhideSuccess) {
          LoaderService.hideLoder(context);
        } else if (state.status.isAuthorized) {
          Navigator.of(context).pushNamed(AppRouter.checkoutRoute, arguments: [state.info.details!.name!, state.info.details!.id!]);
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
                context.read<RestaurantBloc>().add(RestaurantChangeInitialEvent());
                Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
              } else {
                context.read<RestaurantBloc>().add(RestaurantGuestCheckoutEvent());
              }
            } else {
              if (value == true) {
                context.read<RestaurantBloc>().add(RestaurantChangeInitialEvent());
                Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
              }
            }
          });
        } else if (state.status.isGuestCheckoutStart) {
          LoaderService.showLoader(context, msg: translate.please_wait);
        } else if (state.status.isGuestCheckoutFailed && !_isDialogShown) {
          LoaderService.hideLoder(context);
          context.read<RestaurantBloc>().add(RestaurantChangeInitialEvent());
          _isDialogShown = true;
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode, fromAuth: true).then((value) {
            setState(() {
              _isDialogShown = false;
            });
          });
        } else if (state.status.isGuestCheckoutSuccess) {
          LoaderService.hideLoder(context);
          context.read<RestaurantBloc>().add(RestaurantChangeInitialEvent());
          Navigator.of(context).pushNamed(AppRouter.checkoutRoute, arguments: [state.info.details!.name!, state.info.details!.id!]);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            controller: _scrollControllerMain,
            slivers: [
              state.status.isLoading || state.status.isFailure
                  ? const SliverAppBar(automaticallyImplyLeading: true, expandedHeight: 0)
                  : SliverAppBar(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      expandedHeight: 250.0,
                      pinned: true,
                      floating: false,
                      automaticallyImplyLeading: false,
                      flexibleSpace: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          var top = constraints.biggest.height;
                          return FlexibleSpaceBar(
                            title: top <= 150
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 0, right: 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () => Navigator.of(context).pop(),
                                          icon: FaIcon(FontAwesomeIcons.arrowLeft, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(AppRouter.foodSearchRoute, arguments: [state.info.details!.id!, state.info.details!.name!]);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                            width: MediaQuery.of(context).size.width / 1.6,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Theme.of(context).colorScheme.surface, width: 1),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.search_outlined, color: Theme.of(context).primaryColor),
                                                kAppSpacerHorizontal(width: 5),
                                                Text(translate.home_search_bar, style: kAppLblMediumFontMediumGrey(context)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              isDismissible: false,
                                              enableDrag: false,
                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                              builder: (BuildContext context) {
                                                return FractionallySizedBox(
                                                  heightFactor: 0.6,
                                                  child: RestaurantInfoModalScreen(
                                                    name: state.info.details!.name!,
                                                    isHidden: state.info.details!.isHidden!,
                                                    preBooking: state.info.details!.preBooking!,
                                                    tiffinSubscription: state.info.details!.tiffinSubscription!,
                                                  ),
                                                );
                                              },
                                            ).then((value) {
                                              if (!context.mounted) return;
                                              if (value != null && value.toString().isNotEmpty) {
                                                if (value.toString() == 'dining') {
                                                  Navigator.of(context).pushNamed(AppRouter.restaurantDetailInfoRoute, arguments: [state.info.details!.id!, state.info.details!.name!, state.info.details!.slug!, '']);
                                                } else if (value.toString() == 'hide') {
                                                  if (state.isAuthorized) {
                                                    context.read<RestaurantBloc>().add(RestaurantHideEvent());
                                                  } else {
                                                    showErrorDialog(context, translate.please_authorized, state.extraMessage, state.statusCode);
                                                  }
                                                } else if (value.toString() == 'report') {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    isDismissible: false,
                                                    enableDrag: false,
                                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                                    builder: (BuildContext context) {
                                                      return FractionallySizedBox(heightFactor: 0.6, child: ReportIssueRestaurantModalScreen(id: state.info.details!.id!));
                                                    },
                                                  );
                                                } else if (value.toString() == 'preBooking') {
                                                  Navigator.of(context).pushNamed(AppRouter.restaurantPreBookingTableRoute, arguments: [state.info.details!.id!, state.info.details!.name!, state.info.details!.slug!]);
                                                } else if (value.toString() == 'tiffinSubscriptionPackage') {
                                                  Navigator.of(context).pushNamed(AppRouter.restaruantTiffinSubscriptionPackagesRoute, arguments: [state.info.details!.id!, state.info.details!.name!]);
                                                }
                                              }
                                            });
                                          },
                                          icon: FaIcon(FontAwesomeIcons.ellipsisVertical, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            background: SizedBox(
                              height: 250.0,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(100), bottomRight: Radius.circular(100)),
                                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 250.0, imageUrl: state.info.details!.cover!),
                                      ),
                                      Positioned(
                                        left: 10,
                                        top: 50,
                                        width: MediaQuery.of(context).size.width / 1.06,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () => Navigator.of(context).pop(),
                                              child: Container(
                                                height: 25,
                                                width: 25,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                                                child: Icon(Icons.arrow_back, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).pushNamed(AppRouter.foodSearchRoute, arguments: [state.info.details!.id!, state.info.details!.name!]);
                                                  },
                                                  child: Container(
                                                    height: 25,
                                                    width: 25,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                                                    child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                                                  ),
                                                ),
                                                kAppSpacerHorizontal(width: 10),
                                                InkWell(
                                                  onTap: () => context.read<RestaurantBloc>().add(RestaurantFavouriteEvent()),
                                                  child: Container(
                                                    height: 25,
                                                    width: 25,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                                                    child: FaIcon(
                                                      state.info.details!.isFavourite! ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                                                      size: Theme.of(context).textTheme.labelLarge?.fontSize,
                                                      color: ThemeProvider.primaryColor,
                                                    ),
                                                  ),
                                                ),
                                                kAppSpacerHorizontal(width: 10),
                                                InkWell(
                                                  onTap: () => context.read<RestaurantBloc>().add(RestaurantShareEvent()),
                                                  child: Container(
                                                    height: 25,
                                                    width: 25,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                                                    child: FaIcon(FontAwesomeIcons.arrowUpFromBracket, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                                                  ),
                                                ),
                                                kAppSpacerHorizontal(width: 10),
                                                InkWell(
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
                                                          heightFactor: 0.6,
                                                          child: RestaurantInfoModalScreen(
                                                            name: state.info.details!.name!,
                                                            isHidden: state.info.details!.isHidden!,
                                                            preBooking: state.info.details!.preBooking!,
                                                            tiffinSubscription: state.info.details!.tiffinSubscription!,
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) {
                                                      if (!context.mounted) return;
                                                      if (value != null && value.toString().isNotEmpty) {
                                                        if (value.toString() == 'dining') {
                                                          Navigator.of(context).pushNamed(AppRouter.restaurantDetailInfoRoute, arguments: [state.info.details!.id!, state.info.details!.name!, state.info.details!.slug!, '']);
                                                        } else if (value.toString() == 'hide') {
                                                          if (state.isAuthorized) {
                                                            context.read<RestaurantBloc>().add(RestaurantHideEvent());
                                                          } else {
                                                            showErrorDialog(context, translate.please_authorized, state.extraMessage, state.statusCode);
                                                          }
                                                        } else if (value.toString() == 'report') {
                                                          showModalBottomSheet(
                                                            context: context,
                                                            isScrollControlled: true,
                                                            isDismissible: false,
                                                            enableDrag: false,
                                                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                                            builder: (BuildContext context) {
                                                              return FractionallySizedBox(heightFactor: 0.6, child: ReportIssueRestaurantModalScreen(id: state.info.details!.id!));
                                                            },
                                                          );
                                                        } else if (value.toString() == 'preBooking') {
                                                          Navigator.of(context).pushNamed(AppRouter.restaurantPreBookingTableRoute, arguments: [state.info.details!.id!, state.info.details!.name!, state.info.details!.slug!]);
                                                        } else if (value.toString() == 'tiffinSubscriptionPackage') {
                                                          Navigator.of(context).pushNamed(AppRouter.restaruantTiffinSubscriptionPackagesRoute, arguments: [state.info.details!.id!, state.info.details!.name!]);
                                                        }
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 25,
                                                    width: 25,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                                                    child: FaIcon(FontAwesomeIcons.ellipsisVertical, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                        margin: const EdgeInsets.symmetric(horizontal: 10),
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                                          boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, spreadRadius: 2, blurRadius: 5, offset: const Offset(2, 3))],
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(100)),
                                              child: CacheNetworkImageWidget(width: 60, height: 60, imageUrl: state.info.details!.logo!),
                                            ),

                                            kAppSpacerHorizontal(width: 10),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(kAppTrimWord(state.info.details!.name!, 30), maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblLargeFontBold(context)),
                                                  kAppSpacerVertical(height: 4),
                                                  Wrap(
                                                    spacing: 6,
                                                    runSpacing: 4,
                                                    children: state.info.details!.restauranttypes!.length > 2
                                                        ? [
                                                            ...List.generate(
                                                              2,
                                                              (i) => Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  CacheNetworkImageWidget(width: 10, height: 10, imageUrl: state.info.details!.restauranttypes![i].image!),
                                                                  kAppSpacerHorizontal(width: 4),
                                                                  Text(state.info.details!.restauranttypes![i].name!, style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis),
                                                                ],
                                                              ),
                                                            ),
                                                            Text(translate.and_more, style: kAppLblTinyFontRegular(context)),
                                                          ]
                                                        : state.info.details!.restauranttypes!
                                                              .map(
                                                                (e) => Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    CacheNetworkImageWidget(width: 10, height: 10, imageUrl: e.image!),
                                                                    kAppSpacerHorizontal(width: 4),
                                                                    Text(e.name!, style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis),
                                                                  ],
                                                                ),
                                                              )
                                                              .toList(),
                                                  ),

                                                  kAppSpacerVertical(height: 6),

                                                  Wrap(
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    spacing: 6,
                                                    runSpacing: 4,
                                                    children: [
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Image.asset(AssetsUrl.iconsURL.timeTag, height: 10, width: 10),
                                                          kAppSpacerHorizontal(width: 4),
                                                          Text("${state.info.details!.estimatedDeliveryTime!} ${translate.mins}", style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis),
                                                        ],
                                                      ),

                                                      Text("• ${state.info.details!.distance!} ${state.info.findMode!}", style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis),

                                                      const Text("|"),

                                                      InkWell(
                                                        onTap: () {
                                                          if (state.info.details!.localities!.id!.isNotEmpty) {
                                                            showModalBottomSheet(
                                                              context: context,
                                                              isScrollControlled: true,
                                                              isDismissible: false,
                                                              enableDrag: false,
                                                              showDragHandle: false,
                                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                                              builder: (context) {
                                                                return FractionallySizedBox(
                                                                  heightFactor: 0.7,
                                                                  child: RestaurantsByLocalitiesModalScreen(from: state.info.details!.id!, slug: state.info.details!.localities!.slug!, name: state.info.details!.localities!.name!),
                                                                );
                                                              },
                                                            ).then((value) {
                                                              if (!context.mounted) return;

                                                              if (value != null && value != '') {
                                                                final model = RestaurantsByLocalitiesModalResopnseModel.fromJson(value);

                                                                if (model.id!.isNotEmpty) {
                                                                  context.read<RestaurantBloc>().add(RestaurantInitialEvent(id: model.id!, slug: model.slug!, name: model.name!));
                                                                }
                                                              }
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            border: Border(bottom: BorderSide(width: 1.2, color: ThemeProvider.lightDisabledColor)),
                                                          ),
                                                          child: Text(
                                                            state.info.details!.localities!.name!.isEmpty ? kAppTrimWord(state.info.details!.cities!.name!, 10) : kAppTrimWord(state.info.details!.localities!.name!, 10),
                                                            style: kAppLblTinyFontRegular(context),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  kAppSpacerVertical(height: 6),

                                                  Wrap(
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    spacing: 10,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                        decoration: BoxDecoration(color: ThemeProvider.ratingBgColorLight, borderRadius: BorderRadius.circular(5)),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text(state.info.details!.rating!, style: const TextStyle(color: ThemeProvider.ratingTextColorLight)),
                                                            kAppSpacerHorizontal(width: 2),
                                                            Icon(Icons.star, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: ThemeProvider.ratingTextColorLight),
                                                          ],
                                                        ),
                                                      ),

                                                      InkWell(
                                                        onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantReviewRoute, arguments: [state.info.details!.id!, state.info.details!.name!, state.info.details!.rating!]),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            border: Border(bottom: BorderSide(width: 1.2, color: ThemeProvider.lightDisabledColor)),
                                                          ),
                                                          child: Text("${state.info.details!.totalRating!} ${translate.ratings}", style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              SliverList(
                delegate: SliverChildListDelegate([
                  if (state.status.isLoading) ...[
                    const RestaurantLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    RestaurantErrorView(name: state.name),
                  ] else if (state.status.isEmpty) ...[
                    RestaurantEmptyView(name: state.name),
                  ] else if (state.status.isClosed) ...[
                    RestaurantClosedView(name: state.name),
                  ] else ...[
                    RestaurantResponseView(
                      name: state.name,
                      model: state.info,
                      isRecommendedOpen: state.isRecommendedOpen,
                      globalMainCategoriesKey: state.globalMainCategoriesKey,
                      isHidden: state.info.details!.isHidden!,
                      campaignId: state.campaignId,
                      appLocale: state.appLocale,
                    ),
                  ],
                ]),
              ),
            ],
          ),
          bottomNavigationBar: state.category.isNotEmpty && state.info.haveData! && !state.info.details!.temporaryClosed!
              ? SafeArea(
                  child: SizedBox(
                    height: state.cartTotalItem >= 1 ? 130 : 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 5,
                                child: SingleChildScrollView(
                                  controller: _scrollControllerCategories,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: List.generate(state.category.length, (categoryIndex) {
                                      _globalBottomCategoriesKey['bottom_${state.category[categoryIndex].id.toString()}'] = GlobalKey();
                                      return Container(
                                        key: _globalBottomCategoriesKey['bottom_${state.category[categoryIndex].id.toString()}'],
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        margin: const EdgeInsets.only(left: 5),
                                        decoration: BoxDecoration(
                                          color: state.categoryInView == state.category[categoryIndex].id ? Theme.of(context).colorScheme.shadow : Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            context.read<RestaurantBloc>().add(RestaurantScrollToCategory(categoryId: state.category[categoryIndex].id!));
                                            scrollBottomCategory('bottom_${state.category[categoryIndex].id.toString()}', state.category[categoryIndex].id!.toString());
                                            onScrollToPosition('main_${state.category[categoryIndex].id.toString()}', state.category[categoryIndex].id.toString());
                                          },
                                          child: Text(
                                            state.category[categoryIndex].id! == 'recommended' ? translate.recommended : state.category[categoryIndex].name!,
                                            style: state.categoryInView == state.category[categoryIndex].id ? kAppLblTinyFontBold(context) : kAppLblTinyFontRegular(context),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Align(
                                          alignment: Alignment.bottomRight,
                                          child: FractionallySizedBox(
                                            heightFactor: state.category.isNotEmpty && state.category.length >= 10 ? 0.5 : 0.4,
                                            widthFactor: 0.7,
                                            child: Dialog(
                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                              child: FractionallySizedBox(
                                                child: RestaurantMenuModalScreen(currentInView: state.categoryInView, categories: state.category),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).then((value) {
                                      if (!context.mounted) return;
                                      if (value != null && value.toString() != 'null') {
                                        context.read<RestaurantBloc>().add(RestaurantScrollToCategory(categoryId: value.toString()));
                                        scrollBottomCategory('bottom_$value', value.toString());
                                        onScrollToPosition('main_${value.toString()}', value.toString());
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(color: ThemeProvider.darkBackgroundColor, borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.fastfood_outlined, size: 10, color: ThemeProvider.whiteColor),
                                        kAppSpacerHorizontal(width: 5),
                                        Text(translate.menu, style: TextStyle(color: ThemeProvider.whiteColor, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        state.cartTotalItem >= 1
                            ? GestureDetector(
                                onTap: () => context.read<RestaurantBloc>().add(RestaurantCheckoutEvent()),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("${state.cartTotalItem} ${state.cartTotalItem == 1 ? translate.item : translate.items} ${translate.added}", style: kAppLblTinyFontBoldCart(context)),
                                          kAppSpacerVertical(height: 5),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.75,
                                            child: Text(
                                              kAppCartHelperText(context, state.cartSubTitle, state.cartHelpOne, state.cartHelpTwo, state.cartHelpThree),
                                              style: kAppLblTinyFontBoldCart(context),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(kAppPriceFormat(state.cartTotalAmount), style: kAppLblTinyFontBoldCart(context)),
                                          Text(translate.place_order, style: kAppLblTinyFontBoldCart(context)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                )
              : SafeArea(child: const SizedBox()),
        );
      },
    );
  }
}

class RestaurantLoadingView extends StatelessWidget {
  const RestaurantLoadingView({super.key});

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

class RestaurantErrorView extends StatelessWidget {
  final String name;
  const RestaurantErrorView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
      child: Center(
        child: Column(
          children: [
            kAppSpacerVertical(height: 20),
            Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
            kAppSpacerVertical(height: 20),
            Text("${translate.restaurant_no_food_one} $name. ${translate.restaurant_no_food_two}", textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          ],
        ),
      ),
    );
  }
}

class RestaurantEmptyView extends StatelessWidget {
  final String name;
  const RestaurantEmptyView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
        child: Column(
          children: [
            kAppSpacerVertical(height: 20),
            Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
            kAppSpacerVertical(height: 20),
            Text("${translate.restaurant_no_food_one} $name. ${translate.restaurant_no_food_two}", textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          ],
        ),
      ),
    );
  }
}

class RestaurantClosedView extends StatelessWidget {
  final String name;
  const RestaurantClosedView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
        child: Column(
          children: [
            kAppSpacerVertical(height: 20),
            Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
            kAppSpacerVertical(height: 20),
            Text("$name ${translate.restaurant_closed_notice}", textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          ],
        ),
      ),
    );
  }
}

class RestaurantResponseView extends StatelessWidget {
  final String name;
  final RestaurantInfoResponseModel model;
  final bool isRecommendedOpen;
  final Map<String, GlobalKey> globalMainCategoriesKey;
  final bool isHidden;
  final String campaignId;
  final String appLocale;
  const RestaurantResponseView({
    super.key,
    required this.name,
    required this.model,
    required this.isRecommendedOpen,
    required this.globalMainCategoriesKey,
    required this.isHidden,
    required this.campaignId,
    required this.appLocale,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        isHidden
            ? Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: ThemeProvider.scaffoldPadding),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(translate.you_have_hidden_restaurant, style: kAppLblMediumFontBold(context)),
                    InkWell(
                      onTap: () => context.read<RestaurantBloc>().add(RestaurantHideEvent()),
                      child: Text(translate.unhide, style: kAppLblSmallFontBold(context, color: 'primary')),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
        model.coupons!.isNotEmpty
            ? Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: ThemeProvider.scaffoldPadding),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                ),
                child: CarouselSlider(
                  options: CarouselOptions(autoPlay: true, viewportFraction: 1, aspectRatio: 2.0, enlargeCenterPage: false, height: 50.0, scrollDirection: Axis.horizontal, autoPlayInterval: const Duration(seconds: 2)),
                  items: List.generate(
                    model.coupons!.length,
                    (couponIndex) => InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: false,
                          enableDrag: false,
                          showDragHandle: false,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          builder: (BuildContext context) {
                            return FractionallySizedBox(
                              heightFactor: 0.65,
                              child: CouponInfoModalScreen(
                                name: model.coupons![couponIndex].name!,
                                couponType: model.coupons![couponIndex].couponType!,
                                allRestaurants: model.coupons![couponIndex].allRestaurants!,
                                restaurant: model.coupons![couponIndex].restaurant!,
                                allUsers: model.coupons![couponIndex].allUsers!,
                                user: model.coupons![couponIndex].user!,
                                code: model.coupons![couponIndex].code!,
                                discountType: model.coupons![couponIndex].discountType!,
                                id: model.coupons![couponIndex].id!,
                                limitSameUser: model.coupons![couponIndex].limitSameUser!,
                                loyalityPoints: model.coupons![couponIndex].loyalityPoints!,
                                maxDiscount: model.coupons![couponIndex].maxDiscount!,
                                minCartTotal: model.coupons![couponIndex].minCartTotal!,
                                minDiscount: model.coupons![couponIndex].minDiscount!,
                                promoLbl: kAppOrderCouponTitle(context, model.coupons![couponIndex].promoLbl!, model.coupons![couponIndex].tExtraOne!, model.coupons![couponIndex].tExtraTwo!),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  kAppCouponIcon(model.coupons![couponIndex].couponType!, 30, 30),
                                  kAppSpacerHorizontal(width: 10),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          kAppOrderCouponTitle(context, model.coupons![couponIndex].promoLbl!, model.coupons![couponIndex].tExtraOne!, model.coupons![couponIndex].tExtraTwo!),
                                          maxLines: 1,
                                          style: kAppLblMediumFontBold(context),
                                        ),
                                        Text(
                                          "${translate.use_code} ${model.coupons![couponIndex].code!} ${model.coupons![couponIndex].minCartTotal! > 0 ? '| ${translate.above} ${kAppPriceFormat(model.coupons![couponIndex].minCartTotal!)}' : ''}",
                                          maxLines: 1,
                                          style: kAppLblTinyFontBold(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            kAppSpacerHorizontal(width: 5),
                            Text("${couponIndex + 1}/${model.coupons!.length}", style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
        model.recommended!.isNotEmpty
            ? Container(
                padding: const EdgeInsets.only(left: ThemeProvider.scaffoldPadding, right: ThemeProvider.scaffoldPadding, bottom: 10),
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      key: globalMainCategoriesKey['main_recommended'],
                      onTap: () => context.read<RestaurantBloc>().add(RestaurantToggleRecommendedViewEvent()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("${translate.recommended} (${model.recommended!.length})", style: kAppLblSemiBoldFontLarge(context)),
                            Icon(isRecommendedOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 18, color: Theme.of(context).canvasColor),
                          ],
                        ),
                      ),
                    ),
                    isRecommendedOpen
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              model.recommended!.length,
                              (foodIndex) => FoodBlockView(model: model.recommended![foodIndex], from: 'recommended', categoryIndex: 0, info: model.details!, campaignId: campaignId, appLocale: appLocale),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              )
            : const SizedBox(),
        kAppSpacerVertical(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            model.custom!.length,
            (categoryIndex) => Container(
              padding: const EdgeInsets.only(left: ThemeProvider.scaffoldPadding, right: ThemeProvider.scaffoldPadding, bottom: 10),
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    key: globalMainCategoriesKey['main_${model.custom![categoryIndex].categoryId!.toString()}'],
                    onTap: () => context.read<RestaurantBloc>().add(RestaurantToggleCustomCategoryViewEvent(categoryIndex: categoryIndex)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("${model.custom![categoryIndex].categoryName!} (${model.custom![categoryIndex].foods!.length})", style: kAppLblSemiBoldFontLarge(context)),
                          Icon(model.custom![categoryIndex].isOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 18, color: Theme.of(context).canvasColor),
                        ],
                      ),
                    ),
                  ),
                  model.custom![categoryIndex].isOpen
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            model.custom![categoryIndex].foods!.length,
                            (foodIndex) => FoodBlockView(model: model.custom![categoryIndex].foods![foodIndex], from: 'custom', categoryIndex: categoryIndex, info: model.details!, campaignId: campaignId, appLocale: appLocale),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            model.main!.length,
            (categoryIndex) => Container(
              padding: const EdgeInsets.only(left: ThemeProvider.scaffoldPadding, right: ThemeProvider.scaffoldPadding, bottom: 10),
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    key: globalMainCategoriesKey['main_${model.main![categoryIndex].categoryId!.toString()}'],
                    onTap: () => context.read<RestaurantBloc>().add(RestaurantToggleMainCategoryViewEvent(categoryIndex: categoryIndex)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("${model.main![categoryIndex].categoryName!} (${model.main![categoryIndex].foods!.length})", style: kAppLblSemiBoldFontLarge(context)),
                          Icon(model.main![categoryIndex].isOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 18, color: Theme.of(context).canvasColor),
                        ],
                      ),
                    ),
                  ),
                  model.main![categoryIndex].isOpen
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            model.main![categoryIndex].foods!.length,
                            (foodIndex) => FoodBlockView(model: model.main![categoryIndex].foods![foodIndex], from: 'main', categoryIndex: categoryIndex, info: model.details!, campaignId: campaignId, appLocale: appLocale),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
        kAppSpacerVertical(height: 20),
        Container(
          padding: const EdgeInsets.only(left: ThemeProvider.scaffoldPadding, right: ThemeProvider.scaffoldPadding, bottom: 10),
          margin: const EdgeInsets.only(bottom: 10),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: model.notice!.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.brightness_1, size: 5, color: Theme.of(context).canvasColor),
                    kAppSpacerHorizontal(width: 8),
                    Expanded(child: Text(item.name!, style: kAppLblSmallFontRegular(context))),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        kAppSpacerVertical(height: 20),
        Container(
          padding: const EdgeInsets.only(left: ThemeProvider.scaffoldPadding, right: ThemeProvider.scaffoldPadding, bottom: 10),
          margin: const EdgeInsets.only(bottom: 10),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model.details!.name!, style: kAppLblMediumFontRegular(context)),
              kAppSpacerVertical(height: 5),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: CacheNetworkImageWidget(width: 120.0, height: 80.0, imageUrl: model.details!.license!.image!, fit: BoxFit.contain),
              ),
              kAppSpacerVertical(height: 5),
              Text("${translate.lic_no} ${model.details!.licenseId!} (${model.details!.license!.name!})", style: kAppLblMediumFontRegular(context)),
              kAppSpacerVertical(height: 5),
              InkWell(
                onTap: () async {
                  final Uri launchURLString = Uri.parse(model.details!.license!.website!.toString());
                  !await launchUrl(launchURLString, mode: LaunchMode.inAppBrowserView);
                },
                child: Text(model.details!.license!.website!.toString(), style: kAppLblMediumFontRegular(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FoodBlockView extends StatelessWidget {
  final FoodListModel model;
  final String from;
  final int categoryIndex;
  final RestaurantDetailsModel info;
  final String campaignId;
  final String appLocale;
  const FoodBlockView({super.key, required this.model, required this.from, required this.categoryIndex, required this.info, required this.campaignId, required this.appLocale});

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
                      child: FoodScreen(id: model.id!, from: 'restaurant', data: jsonEncode(model), extraInfo: jsonEncode(info)),
                    );
                  },
                ).then((value) {
                  if (!context.mounted) return;
                  if (value != null) {
                    FoodInfoModalResponseModel foodInfoModalResponse = FoodInfoModalResponseModel.fromJson(value, appLocale);
                    context.read<RestaurantBloc>().add(RestaurantFoodModalResponseEvent(id: model.id!, from: from, categoryIndex: categoryIndex, response: foodInfoModalResponse));
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
                                Text("${model.totalRating} ${translate.ratings}", style: kAppLblTinyFontRegular(context)),
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
                          child: FoodScreen(id: model.id!, from: 'restaurant', data: jsonEncode(model), extraInfo: jsonEncode(info)),
                        );
                      },
                    ).then((value) {
                      if (!context.mounted) return;
                      if (value != null) {
                        FoodInfoModalResponseModel foodInfoModalResponse = FoodInfoModalResponseModel.fromJson(value, appLocale);
                        context.read<RestaurantBloc>().add(RestaurantFoodModalResponseEvent(id: model.id!, from: from, categoryIndex: categoryIndex, response: foodInfoModalResponse));
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
                                        context.read<RestaurantBloc>().add(RestaurantVariationModalResponseEvent(id: model.id!, data: foodVariationModalResponse, from: from, categoryIndex: categoryIndex));
                                      }
                                    }
                                  });
                                } else {
                                  context.read<RestaurantBloc>().add(RestaurantAddCartEvent(id: model.id!, from: from, categoryIndex: categoryIndex));
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
                                              context.read<RestaurantBloc>().add(RestaurantRepeatFoodOrderResponseEvent(id: model.id!, data: repeatQuantityModalResponse, from: from, categoryIndex: categoryIndex));
                                            }
                                          }
                                        });
                                      } else {
                                        context.read<RestaurantBloc>().add(RestaurantFoodQuantityDecreaseEvent(id: model.id!, from: from, categoryIndex: categoryIndex));
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
                                              context.read<RestaurantBloc>().add(RestaurantRepeatFoodOrderResponseEvent(id: model.id!, data: repeatQuantityModalResponse, from: from, categoryIndex: categoryIndex));
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
                                                    context.read<RestaurantBloc>().add(RestaurantFoodVariationModalRepeatResponseEvent(id: model.id!, data: foodVariationModalResponse, from: from, categoryIndex: categoryIndex));
                                                  }
                                                }
                                              });
                                            }
                                          }
                                        });
                                      } else {
                                        context.read<RestaurantBloc>().add(RestaurantFoodQuantityIncreaseEvent(id: model.id!, from: from, categoryIndex: categoryIndex));
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

