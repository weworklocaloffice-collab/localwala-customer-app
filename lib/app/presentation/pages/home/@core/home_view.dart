/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright Â© 2026 WeWorkLocal.
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
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/campaign_list_model.dart';
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/food_variations_response_data_modal_model.dart';
import 'package:user/app/core/models/home_response_model.dart';
import 'package:user/app/core/models/repeat_quantity_modal_response_model.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/pages/cart/@core/bloc/cart_bloc.dart';
import 'package:user/app/presentation/pages/cart/checkout/bloc/checkout_bloc.dart';
import 'package:user/app/presentation/pages/dining/@core/bloc/dining_bloc.dart';
import 'package:user/app/presentation/pages/dining/dining_campaigns/bloc/dining_campaign_bloc.dart';
import 'package:user/app/presentation/pages/dining/filter_dining_with_category/bloc/filter_dining_with_category_bloc.dart';
import 'package:user/app/presentation/pages/favourite/foods/bloc/favourite_foods_bloc.dart';
import 'package:user/app/presentation/pages/favourite/restaurants/bloc/favourite_restaurants_bloc.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/presentation/pages/home/@core/bloc/header_banner_bloc.dart';
import 'package:user/app/presentation/pages/home/@core/bloc/home_bloc.dart';
import 'package:user/app/presentation/pages/home/@core/business_verticals.dart';
import 'package:user/app/presentation/pages/home/@core/home_app_bar.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/business_vertical_strip.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_header_search_bar.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_promo_banner.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_promo_banner_model.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/split_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/presentation/pages/home/campaign/food_campaign/bloc/food_campaign_bloc.dart';
import 'package:user/app/presentation/pages/home/campaign/restaurant_campaign/bloc/restaurant_campaign_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/food_search/bloc/food_search_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/restaurant_detail_info/bloc/restaurant_detail_info_bloc.dart';
import 'package:user/app/presentation/pages/modals/cart_summary_modal/bloc/cart_summary_modal_bloc.dart';
import 'package:user/app/presentation/pages/modals/food_info_modal/food_view.dart';
import 'package:user/app/presentation/pages/home/restaurant/@core/bloc/restaurant_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/brands/bloc/restaurants_by_brands_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/categories/filter_foods/bloc/filter_foods_by_category_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/categories/filter_restaurants/bloc/filter_restaurants_by_categories_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/cuisine/bloc/restaurants_by_cuisine_bloc.dart';
import 'package:user/app/presentation/pages/modals/food_variations_modal/@core/food_variations_modal_view.dart';
import 'package:user/app/presentation/pages/modals/food_variations_modal/repeat/food_variation_modal_repeat_view.dart';
import 'package:user/app/presentation/pages/modals/hide_restaurant_reason_modal/hide_restaurant_reason_modal_view.dart';
import 'package:user/app/presentation/pages/modals/language_translation_modal/language_translation_modal_view.dart';
import 'package:user/app/presentation/pages/modals/restaurants_by_localities_modal/bloc/restaurants_by_localities_bloc.dart';
import 'package:user/app/presentation/pages/modals/single_food_from_banner_modal/bloc/single_food_from_banner_modal_bloc.dart';
import 'package:user/app/presentation/pages/tabs/bloc/bottom_tab_navigation_bloc.dart';
import 'package:user/app/presentation/styles/app_localization/app_localization_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:badges/badges.dart' as badges;
import 'package:user/gen/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FavouriteFoodsBloc, FavouriteFoodsState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<HomeBloc>().add(HomeRefreshCartEvent());
            } else if (state.status.isRemoveFavDone ||
                state.status.isRemoveSilence) {
              context.read<HomeBloc>().add(
                HomeRefreshFoodFavEvent(inFavList: state.foods.foodIds!),
              );
            }
          },
        ),
        BlocListener<RestaurantBloc, RestaurantState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<HomeBloc>().add(HomeRefreshCartEvent());
            } else if (state.status.isFavAdd || state.status.isFavRemove) {
              context.read<HomeBloc>().add(
                HomeRefreshRestaurantFavEvent(
                  inFavList: state.status.isFavAdd
                      ? [state.info.details!.id!]
                      : [],
                ),
              );
            } else if (state.status.isFavFoodUpdate) {
              context.read<HomeBloc>().add(
                HomeRefreshFoodFavEvent(inFavList: state.favIds),
              );
            }
          },
        ),
        BlocListener<BottomTabNavigationBloc, BottomTabNavigationState>(
          listener: (context, state) {
            if (state.status.isUpdateCart || state.status.isUpdateCartError) {
              context.read<HomeBloc>().add(HomeRefreshCartEvent());
            }
          },
        ),
        BlocListener<CartSummaryModalBloc, CartSummaryModalState>(
          listener: (context, state) {
            if (state.status.isUpdateCart) {
              context.read<HomeBloc>().add(HomeRefreshCartEvent());
            }
          },
        ),
        BlocListener<RestaurantDetailInfoBloc, RestaurantDetailInfoState>(
          listener: (context, state) {
            if (state.status.isFavAdd || state.status.isFavRemove) {
              context.read<HomeBloc>().add(
                HomeRefreshRestaurantFavEvent(
                  inFavList: state.status.isFavAdd
                      ? [state.model.details!.id!]
                      : [],
                ),
              );
            }
          },
        ),
        BlocListener<FoodCampaignBloc, FoodCampaignState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<HomeBloc>().add(HomeRefreshCartEvent());
            } else if (state.status.isFavUpdate) {
              context.read<HomeBloc>().add(
                HomeRefreshFoodFavEvent(inFavList: state.favIds),
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
              context.read<HomeBloc>().add(HomeRefreshCartEvent());
            } else if (state.status.isFavAdd) {
              context.read<HomeBloc>().add(
                HomeRefreshFoodFavEvent(inFavList: [state.detail.info!.id!]),
              );
            } else if (state.status.isFavRemove) {
              context.read<HomeBloc>().add(
                HomeRefreshFoodFavEvent(inFavList: []),
              );
            }
          },
        ),
        BlocListener<FilterFoodsByCategoryBloc, FilterFoodsByCategoryState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<HomeBloc>().add(HomeRefreshCartEvent());
            } else if (state.status.isFavUpdate) {
              context.read<HomeBloc>().add(
                HomeRefreshFoodFavEvent(inFavList: state.favIds),
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
              context.read<HomeBloc>().add(HomeRefreshCartEvent());
            } else if (state.status.isInitialFoodFav) {
              context.read<HomeBloc>().add(
                HomeRefreshFoodFavEvent(inFavList: state.initialFavIds),
              );
            } else if (state.status.isSearchFoodFav) {
              context.read<HomeBloc>().add(
                HomeRefreshFoodFavEvent(inFavList: state.resultFavIds),
              );
            }
          },
        ),
        BlocListener<FavouriteRestaurantsBloc, FavouriteRestaurantsState>(
          listener: (context, state) {
            if (state.status.isRemoveFavDone) {
              context.read<HomeBloc>().add(
                HomeRefreshRestaurantFavEvent(
                  inFavList: state.restaurants.restaurantIds!,
                ),
              );
            }
          },
        ),
        BlocListener<RestaurantCampaignBloc, RestaurantCampaignState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<HomeBloc>().add(
                HomeRefreshRestaurantFavEvent(inFavList: state.favIds),
              );
            } else if (state.status.isHidden) {
              context.read<HomeBloc>().add(
                HomeSilentHideEvent(id: state.hideUnhideId),
              );
            } else if (state.status.isUnhidden) {
              context.read<HomeBloc>().add(
                HomeSilentUnHideEvent(id: state.hideUnhideId),
              );
            }
          },
        ),
        BlocListener<DiningCampaignBloc, DiningCampaignState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<HomeBloc>().add(
                HomeRefreshRestaurantFavEvent(inFavList: state.favIds),
              );
            } else if (state.status.isHidden) {
              context.read<HomeBloc>().add(
                HomeSilentHideEvent(id: state.hideUnhideId),
              );
            } else if (state.status.isUnhidden) {
              context.read<HomeBloc>().add(
                HomeSilentUnHideEvent(id: state.hideUnhideId),
              );
            }
          },
        ),
        BlocListener<
          FilterDiningWithCategoryBloc,
          FilterDiningWithCategoryState
        >(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<HomeBloc>().add(
                HomeRefreshRestaurantFavEvent(inFavList: state.favIds),
              );
            } else if (state.status.isHidden) {
              context.read<HomeBloc>().add(
                HomeSilentHideEvent(id: state.hideUnhideId),
              );
            } else if (state.status.isUnhidden) {
              context.read<HomeBloc>().add(
                HomeSilentUnHideEvent(id: state.hideUnhideId),
              );
            }
          },
        ),
        BlocListener<DiningBloc, DiningState>(
          listener: (context, state) {
            if (state.status.isRestaurantFav) {
              context.read<HomeBloc>().add(
                HomeRefreshRestaurantFavEvent(inFavList: state.favIds),
              );
            } else if (state.status.isHidden) {
              context.read<HomeBloc>().add(
                HomeSilentHideEvent(id: state.hideUnhideId),
              );
            } else if (state.status.isUnhidden) {
              context.read<HomeBloc>().add(
                HomeSilentUnHideEvent(id: state.hideUnhideId),
              );
            }
          },
        ),
        BlocListener<
          FilterRestaurantsByCategoriesBloc,
          FilterRestaurantsByCategoriesState
        >(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<HomeBloc>().add(
                HomeRefreshRestaurantFavEvent(inFavList: state.favIds),
              );
            } else if (state.status.isHidden) {
              context.read<HomeBloc>().add(
                HomeSilentHideEvent(id: state.hideUnhideId),
              );
            } else if (state.status.isUnhidden) {
              context.read<HomeBloc>().add(
                HomeSilentUnHideEvent(id: state.hideUnhideId),
              );
            }
          },
        ),
        BlocListener<RestaurantsByCuisineBloc, RestaurantsByCuisineState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<HomeBloc>().add(
                HomeRefreshRestaurantFavEvent(inFavList: state.favIds),
              );
            } else if (state.status.isHidden) {
              context.read<HomeBloc>().add(
                HomeSilentHideEvent(id: state.hideUnhideId),
              );
            } else if (state.status.isUnhidden) {
              context.read<HomeBloc>().add(
                HomeSilentUnHideEvent(id: state.hideUnhideId),
              );
            }
          },
        ),
        BlocListener<RestaurantsByBrandsBloc, RestaurantsByBrandsState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<HomeBloc>().add(
                HomeRefreshRestaurantFavEvent(inFavList: state.favIds),
              );
            } else if (state.status.isHidden) {
              context.read<HomeBloc>().add(
                HomeSilentHideEvent(id: state.hideUnhideId),
              );
            } else if (state.status.isUnhidden) {
              context.read<HomeBloc>().add(
                HomeSilentUnHideEvent(id: state.hideUnhideId),
              );
            }
          },
        ),
        BlocListener<RestaurantsByLocalitiesBloc, RestaurantsByLocalitiesState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<HomeBloc>().add(
                HomeRefreshRestaurantFavEvent(inFavList: state.favIds),
              );
            } else if (state.status.isHidden) {
              context.read<HomeBloc>().add(
                HomeSilentHideEvent(id: state.hideUnhideId),
              );
            } else if (state.status.isUnhidden) {
              context.read<HomeBloc>().add(
                HomeSilentUnHideEvent(id: state.hideUnhideId),
              );
            }
          },
        ),
        BlocListener<CartBloc, CartState>(
          listener: (context, state) {
            if (state.status.isCartUpdate || state.status.isCartError) {
              context.read<HomeBloc>().add(HomeRefreshCartEvent());
            }
          },
        ),
        BlocListener<CheckoutBloc, CheckoutState>(
          listener: (context, state) {
            if (state.status.isCartUpdate ||
                state.status.isCartError ||
                state.status.isOrderPlaced ||
                state.status.isMakePayment) {
              context.read<HomeBloc>().add(HomeRefreshCartEvent());
            }
          },
        ),
      ],
      child: BlocProvider<HeaderBannerBloc>(
        create: (context) =>
            HeaderBannerBloc()..add(HeaderBannerInitialEvent()),
        child: const HomeView(),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final ScrollController _scrollRestaurants = ScrollController();

  /// Single Lottie playhead for a header whose media spans the app bar and the banner.
  AnimationController? _headerMediaController;

  /// Drives the header media's parallax. One notifier for BOTH surfaces, so the app bar
  /// and the banner can never pan by different amounts and tear at the split.
  final ValueNotifier<double> _headerParallax = ValueNotifier<double>(0);

  /// Pan range in pixels, refreshed from the layout as it is built.
  double _headerParallaxRange = 0;

  /// Raw scroll offset, so the app bar can translate away with the page.
  ///
  /// This `Scaffold` never moves the app bar on its own - `performLayout` always positions
  /// the slot at `Offset.zero`, with no scroll term - so there is no `floating: true` that
  /// would do it. Translating it here is also what keeps the shared media intact: the
  /// banner lives in the scrolling body and the app bar is moved by exactly the same
  /// amount, so the two windows stay adjoining at every offset instead of sliding apart.
  final ValueNotifier<double> _headerScrollOffset = ValueNotifier<double>(0);

  /// Pan value that represents "not scrolled".
  ///
  /// Not zero: a shared canvas is painted with bleed above and below the visible region,
  /// so the resting position is the middle of that bleed. Starting at zero would frame the
  /// header as though it were already scrolled, and the artwork would sit too high until
  /// the first scroll.
  double _headerParallaxBase = 0;

  /// How much of the scroll distance the artwork lags behind by. Under 1 keeps it slower
  /// than the surface, which is what reads as depth rather than as a bug.
  static const double _parallaxRate = 0.35;

  /// Pan budget for a banner that does not share its canvas, as a fraction of its height.
  static const double _parallaxFallbackRange = 0.18;

  void _onHeaderScroll() {
    final double raw = _scrollRestaurants.hasClients
        ? _scrollRestaurants.offset
        : 0;
    if (_headerScrollOffset.value != raw) _headerScrollOffset.value = raw;
    if (_headerParallaxRange <= 0) return;
    final double offset = _scrollRestaurants.hasClients
        ? _scrollRestaurants.offset
        : 0;
    // Clamped to the bleed the layout actually rendered, so the artwork never runs out
    // of canvas and leaves a bare edge at the end of the travel.
    _headerParallax.value =
        _headerParallaxBase +
        (offset * _parallaxRate).clamp(
          -_headerParallaxRange,
          _headerParallaxRange,
        );
  }

  /// Guards against re-resolving the header for the same banner payload.
  HeaderBannerModel? _resolvedHeaderBanner;
  bool _didResolveHeaderBanner = false;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeInitialEvent());
    _scrollRestaurants.addListener(_onHeaderScroll);
    _scrollRestaurants.addListener(() {
      if (_scrollRestaurants.position.pixels ==
          _scrollRestaurants.position.maxScrollExtent) {
        context.read<HomeBloc>().add(HomeLoadMoreEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollRestaurants.dispose();
    // Belongs to this screen, not to either media widget, so it is disposed here.
    _headerMediaController?.dispose();
    _headerParallax.dispose();
    _headerScrollOffset.dispose();
    super.dispose();
  }

  /// Feeds freshly received banners into the header resolver.
  ///
  /// Runs on every home response, including pull-to-refresh, so the header
  /// configuration and the home feed always come from the same round trip.
  void _resolveHeaderBanner(BuildContext context, HomeState state) {
    final HeaderBannerModel? banner = state.homeData.headerBanner;
    if (_didResolveHeaderBanner && identical(banner, _resolvedHeaderBanner))
      return;
    _didResolveHeaderBanner = true;
    _resolvedHeaderBanner = banner;
    context.read<HeaderBannerBloc>().add(
      HeaderBannerUpdatedEvent(headerBanner: banner),
    );
  }

  /// Routes a header banner tap.
  ///
  /// The header banner lives in its own backend module, so unlike the in-body
  /// carousel it carries no joined restaurant/food object. The server resolves
  /// `ctaTarget` into `ctaTargetDetail` instead, because `/restaurants_by_category`
  /// and `/restaurant` are argument based routes that need name + slug.
  ///
  /// Anything unrecognised is a no-op rather than a crash - a banner must never be
  /// able to take the customer down.
  Future<void> _onHeaderBannerTap(HomePromoBannerSpec spec) async {
    final String action = spec.ctaAction?.trim().toLowerCase() ?? '';
    final HeaderBannerCtaTarget? target = spec.ctaTargetDetail;

    if (action == 'open_restaurant_list' || action == 'restaurant_list') {
      Navigator.of(context).pushNamed(AppRouter.bottomTabRoute, arguments: [0]);
      return;
    }

    if (action == 'open_search') {
      Navigator.of(context).pushNamed(AppRouter.searchRoute);
      return;
    }

    if (action == 'category' &&
        target != null &&
        target.name != null &&
        target.slug != null) {
      Navigator.of(context).pushNamed(
        AppRouter.restaurantsByCategoryRoute,
        arguments: [target.name, target.slug, _citySlug],
      );
      return;
    }

    if (action == 'restaurant' &&
        target != null &&
        target.id != null &&
        target.slug != null) {
      Navigator.of(context).pushNamed(
        AppRouter.restaurantRoute,
        arguments: [target.id, target.slug, target.name],
      );
      return;
    }

    // The food modal is argument based on [foodId, foodName], unlike the page routes
    // above. Resolved server side, so an operator picking a food in the admin can be
    // sure it is still live and has a readable name by the time anyone taps the banner.
    if (action == 'food' &&
        target != null &&
        target.id != null &&
        target.name != null) {
      Navigator.of(context).pushNamed(
        AppRouter.singleFoodFromBannerRoute,
        arguments: [target.id, target.name],
      );
      return;
    }

    final String? destination = _firstFilled(spec.deepLink, spec.ctaTarget);
    if (destination == null) return;

    final Uri? uri = Uri.tryParse(destination);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  /// City slug required by the category listing route.
  String? get _citySlug => context.read<HomeBloc>().state.homeData.city?.slug;

  Future<void> _openStores() async {
    final LocationRepository location = LocationRepository();
    final bool hasLocation = await location.haveLocation();
    final List<dynamic> arguments = <dynamic>[];
    if (hasLocation) {
      arguments.add(await location.userLatitude());
      arguments.add(await location.userLongitude());
    }
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamed(AppRouter.storesHomeRoute, arguments: arguments);
  }

  void _onVerticalSelected(BusinessVertical vertical) {
    switch (vertical.id) {
      case BusinessVerticalId.stores:
        _openStores();
        break;
      case BusinessVerticalId.services:
        Navigator.of(context).pushNamed(AppRouter.localServicesHomeRoute);
        break;
      case BusinessVerticalId.meat:
        Navigator.of(context).pushNamed(AppRouter.jhatkaHomeRoute);
        break;
      case BusinessVerticalId.realEstate:
        Navigator.of(context).pushNamed(AppRouter.reHomeRoute);
        break;
    }
  }

  /// Refreshes the home feed and keeps the split open until it has landed.
  ///
  /// The split spinner is only honest while there is still work in flight, so
  /// the returned future has to outlive the event dispatch and settle on the
  /// state the refresh produced. `HomePullRefreshEvent` reports `loading` first
  /// and then the terminal status, so that is what this waits on - comparing the
  /// terminal status against the pre refresh one would hang whenever the feed
  /// simply refreshes to the same status it already had. The timeout is the
  /// safety net for a request that never comes back, because the split must
  /// not stay open forever.
  Future<void> _pullRefresh() async {
    final HomeBloc bloc = context.read<HomeBloc>();
    bool loading = bloc.state.status == HomeStatus.loading;
    bloc.add(HomePullRefreshEvent());
    await bloc.stream
        .firstWhere((HomeState state) {
          if (state.status == HomeStatus.loading) {
            loading = true;
            return false;
          }
          return loading;
        })
        .timeout(const Duration(seconds: 30), onTimeout: () => bloc.state);
  }

  /// Returns the first non blank string, ignoring whitespace only values.
  static String? _firstFilled(String? a, String? b) {
    if (a != null && a.trim().isNotEmpty) return a.trim();
    if (b != null && b.trim().isNotEmpty) return b.trim();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.status.isFailure ||
            state.status.isCustomError ||
            state.status.isCartError) {
          showErrorDialog(
            context,
            state.alertMessage,
            state.extraMessage,
            state.statusCode,
          );
        }
        _resolveHeaderBanner(context, state);
      },
      builder: (context, state) {
        return BlocBuilder<HeaderBannerBloc, HeaderBannerState>(
          builder: (context, headerState) {
            // Resolved once so the app bar and the banner window the header gradient against
            // the same surface height. Without this each would guess, and the two
            // slices would meet at the right colour but in the wrong proportion.
            final double bannerHeight = headerState.specs.isEmpty
                ? HomePromoBannerSpec.defaultHeight
                : headerState.specs.first.resolveHeight(
                    MediaQuery.sizeOf(context).width,
                  );
            // Height the app bar actually paints, resolved the same way HomeAppBar does
            // it internally: toolbar row PLUS the search bar beneath it. Both surfaces
            // need the same number to agree on the shared media canvas, and neither can
            // take it from the other without a cycle. Using only the toolbar row shifted
            // every slice up by the search bar's height and the animation visibly
            // restarted at the seam.
            // Only the winning spec drives the header. A carousel rotates through several,
            // but the app bar sits above all of them, so sharing the media has to mean
            // sharing the one currently on screen.
            final HomePromoBannerSpec? headerSpec = headerState.specs.isEmpty
                ? null
                : headerState.specs.first;

            // The shared media canvas is computed ONCE, here, and the SAME object goes to
            // the app bar and the banner.
            //
            // Deriving it per surface made the two windows agree only for as long as two
            // separate expressions kept matching, and nothing enforced that. The moment one
            // drifted - a toolbar height vs a toolbar+search height, a width from a
            // different MediaQuery - each surface cropped the same composition against a
            // different coordinate space and the artwork visibly jumped at the split.
            final double screenWidth = MediaQuery.sizeOf(context).width;
            // The app bar's SLOT is taller than its content.
            //
            // `Scaffold` strips the status-bar padding out of the `MediaQuery` the `AppBar`
            // receives and then adds it back as extra height on top of `preferredSize`, so
            // the box handed to `HomeAppBar` is `preferredSize + topPadding` - 143 on this
            // device, not the 119 its content occupies. Media fills that slot, so the
            // layout has to measure the SLOT.
            //
            // Measuring the content instead (the obvious reading) put the app bar's window
            // 24px too tall: it painted canvas rows 0..143 while the banner painted
            // 119..313, so rows 119..143 were drawn twice - a duplicated strip of artwork
            // sitting above the banner and again at the top of it.
            final double topInset = MediaQuery.paddingOf(context).top;
            // The app bar never resizes now, so this is a plain sum of two constants and
            // there is nothing left that can drift out of step with the slot.
            final double appBarSlotHeight =
                HomeAppBar.resolveRegionHeight(headerState.headerTheme) +
                topInset;

            final HeaderMediaLayout? mediaLayout =
                (headerSpec?.showMediaInAppBar ?? false)
                ? HeaderMediaLayout(
                    appBarHeight: appBarSlotHeight,
                    bannerHeight: headerSpec!.resolveHeight(screenWidth),
                    width: screenWidth,
                    // Zero bleed when parallax is off. The canvas is rendered at
                    // `paintedCanvasHeight`, so any overscan at all would fit the
                    // artwork to a TALLER box and quietly change the crop - meaning the
                    // banner would look different merely because this feature exists.
                    parallaxFactor: (headerSpec!.parallaxEnabled
                        ? headerSpec.parallaxIntensity
                        : 0),
                  )
                : null;
            // Supplied only when the banner actually asks for parallax. The notifier is
            // what makes the standalone banner pre-scale its artwork to create the bleed
            // the pan consumes, so handing it over while parallax is off would zoom every
            // banner by 20% for nothing.
            final bool parallaxOn = headerSpec?.parallaxEnabled ?? false;
            _headerParallaxRange =
                mediaLayout?.overscan ??
                (headerSpec?.resolveHeight(screenWidth) ?? 0) *
                    _parallaxFallbackRange;
            // A shared canvas rests in the middle of its bleed; a standalone banner has no
            // bleed and rests at zero.
            _headerParallaxBase = mediaLayout?.overscan ?? 0;

            // ONE playhead for the whole header. The app bar and the banner each build
            // their own media widget, and with a controller apiece the asset was fetched
            // and decoded twice and each half began playing whenever its own `onLoaded`
            // landed - hundreds of milliseconds apart, permanently. Handing both windows
            // this one controller makes them show the same frame by construction. Created
            // here rather than in the media widget because it has to outlive either half.
            final AnimationController? mediaController = mediaLayout == null
                ? null
                : (_headerMediaController ??= AnimationController(
                    vsync: this,
                    duration: const Duration(seconds: 1),
                  ));
            return Scaffold(
              appBar: HomeAppBar(
                state: state,
                headerTheme: headerState.headerTheme,
                spec: headerSpec,
                bannerHeight: bannerHeight,
                mediaLayout: mediaLayout,
                mediaController: mediaController,
                parallax: _headerParallax,
              ),
              body: SplitRefresh(
                onRefresh: _pullRefresh,
                child: CustomScrollView(
                  controller: _scrollRestaurants,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: HomePromoBannerSlot(
                        specs: headerState.specs,
                        onTap: _onHeaderBannerTap,
                        backgroundTheme: headerState.headerTheme,
                        mediaLayout: mediaLayout,
                        mediaController: mediaController,
                        parallax: parallaxOn ? _headerParallax : null,
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _BusinessVerticalStripDelegate(
                        child: BusinessVerticalStrip(
                          verticals: buildBusinessVerticals(translate),
                          onSelected: _onVerticalSelected,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: HomeHeaderSearchBar()),
                    if (state.status.isLoading)
                      const SliverToBoxAdapter(child: HomeInitialLoading())
                    else if (state.status.isEmpty)
                      const SliverToBoxAdapter(child: HomeEmptyResponse())
                    else if (state.status.isSuccess ||
                        state.status.isCustomError ||
                        state.status.isCartUpdate ||
                        state.status.isCartError ||
                        state.status.isRestaurantFav ||
                        state.status.isFoodFav ||
                        state.status.isHidden ||
                        state.status.isUnhidden)
                      SliverToBoxAdapter(
                        child: HomeResponseView(
                          data: state.homeData,
                          campaignList: state.campaignList,
                          isLoadMore: state.loadMore,
                          isAuthorized: state.isAuthorized,
                          appLocale: state.appLocale,
                        ),
                      )
                    else
                      const SliverToBoxAdapter(child: HomeEmptyResponse()),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _BusinessVerticalStripDelegate extends SliverPersistentHeaderDelegate {
  const _BusinessVerticalStripDelegate({required this.child});

  final Widget child;

  static const double _height = 64;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _BusinessVerticalStripDelegate oldDelegate) =>
      oldDelegate.child != child;
}

class HomeInitialLoading extends StatelessWidget {
  const HomeInitialLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeProvider.scaffoldPadding,
        ),
        child: Column(
          children: [
            SkeletonLine(
              style: SkeletonLineStyle(
                height: 50,
                width: double.infinity,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 20),
            SkeletonLine(
              style: SkeletonLineStyle(
                height: 150,
                width: double.infinity,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 16,
                    width: 64,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 16,
                    width: 64,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(10, (index) {
                  return SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      width: 70,
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 16,
                    width: 64,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 16,
                    width: 64,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(10, (index) {
                  return SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      width: 280,
                      height: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            SkeletonLine(
              style: SkeletonLineStyle(
                height: 120,
                width: double.infinity,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class HomeEmptyResponse extends StatelessWidget {
  const HomeEmptyResponse({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeProvider.scaffoldPadding,
      ),
      child: Center(
        child: Column(
          children: [
            kAppSpacerVertical(height: 20),
            Image.asset(
              AssetsUrl.imageURL.homeEmpty,
              height: 256,
              width: 256,
              fit: BoxFit.fitWidth,
            ),
            kAppSpacerVertical(height: 20),
            Text(
              translate.home_error,
              textAlign: TextAlign.center,
              style: kAppLblMediumFontRegular(context),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeResponseView extends StatefulWidget {
  final HomeResponseModel data;
  final List<CampaignListModel> campaignList;
  final bool isLoadMore;
  final bool isAuthorized;
  final String appLocale;
  const HomeResponseView({
    super.key,
    required this.data,
    required this.campaignList,
    required this.isLoadMore,
    required this.isAuthorized,
    required this.appLocale,
  });

  @override
  State<HomeResponseView> createState() => _HomeResponseViewState();
}

class _HomeResponseViewState extends State<HomeResponseView> {
  final ScrollController _scrollPopularRestaurant = ScrollController();
  final ScrollController _scrollNewRestaurant = ScrollController();
  final ScrollController _scrollMostReviewedFood = ScrollController();
  final ScrollController _scrollPopularFoods = ScrollController();
  final ScrollController _scrollTrendingFoods = ScrollController();
  final ScrollController _scrollSubscriptionPackages = ScrollController();

  double _scrollPopularRestaurantPercentage = 0;
  double _scrollNewRestaurantPercentage = 0;
  double _scrollMostReviewedFoodPercentage = 0;
  double _scrollPopularFoodPercentage = 0;
  double _scrollTrendingFoodPercentage = 0;
  double _scrollSubscriptionPackagesPercentage = 0;

  @override
  void initState() {
    super.initState();
    _scrollPopularRestaurant.addListener(() {
      double scrollPercentage =
          (_scrollPopularRestaurant.position.pixels /
              _scrollPopularRestaurant.position.maxScrollExtent) *
          100;
      if (scrollPercentage > 90) {
        setState(() {
          _scrollPopularRestaurantPercentage = 80;
        });
      } else {
        setState(() {
          _scrollPopularRestaurantPercentage = scrollPercentage;
        });
      }
    });

    _scrollNewRestaurant.addListener(() {
      double scrollPercentage =
          (_scrollNewRestaurant.position.pixels /
              _scrollNewRestaurant.position.maxScrollExtent) *
          100;
      if (scrollPercentage > 90) {
        setState(() {
          _scrollNewRestaurantPercentage = 80;
        });
      } else {
        setState(() {
          _scrollNewRestaurantPercentage = scrollPercentage;
        });
      }
    });

    _scrollMostReviewedFood.addListener(() {
      double scrollPercentage =
          (_scrollMostReviewedFood.position.pixels /
              _scrollMostReviewedFood.position.maxScrollExtent) *
          100;
      if (scrollPercentage > 90) {
        setState(() {
          _scrollMostReviewedFoodPercentage = 80;
        });
      } else {
        setState(() {
          _scrollMostReviewedFoodPercentage = scrollPercentage;
        });
      }
    });

    _scrollPopularFoods.addListener(() {
      double scrollPercentage =
          (_scrollPopularFoods.position.pixels /
              _scrollPopularFoods.position.maxScrollExtent) *
          100;
      if (scrollPercentage > 90) {
        setState(() {
          _scrollPopularFoodPercentage = 80;
        });
      } else {
        setState(() {
          _scrollPopularFoodPercentage = scrollPercentage;
        });
      }
    });

    _scrollTrendingFoods.addListener(() {
      double scrollPercentage =
          (_scrollTrendingFoods.position.pixels /
              _scrollTrendingFoods.position.maxScrollExtent) *
          100;
      if (scrollPercentage > 90) {
        setState(() {
          _scrollTrendingFoodPercentage = 80;
        });
      } else {
        setState(() {
          _scrollTrendingFoodPercentage = scrollPercentage;
        });
      }
    });

    _scrollSubscriptionPackages.addListener(() {
      double scrollPercentage =
          (_scrollSubscriptionPackages.position.pixels /
              _scrollSubscriptionPackages.position.maxScrollExtent) *
          100;
      if (scrollPercentage > 90) {
        setState(() {
          _scrollSubscriptionPackagesPercentage = 80;
        });
      } else {
        setState(() {
          _scrollSubscriptionPackagesPercentage = scrollPercentage;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        kAppSpacerVertical(height: 10),
        widget.campaignList.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeProvider.scaffoldPadding,
                    ),
                    child: CampaignBannerList(
                      campaignList: widget.campaignList,
                    ),
                  ),
                  kAppSpacerVertical(height: 20),
                ],
              )
            : const SizedBox(),
        widget.data.categories!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppTitleDivider(
                    context,
                    translate.in_mind_title,
                    ThemeProvider.scaffoldPadding,
                  ),
                  kAppSpacerVertical(height: 20),
                  widget.data.categories!.length > 15
                      ? SizedBox(
                          width: double.infinity,
                          height: 160,
                          child: ScrollConfiguration(
                            behavior: CategoriesScrollBehavior(),
                            child: GridView(
                              scrollDirection: Axis.horizontal,
                              physics: const PageScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisSpacing: 2.0,
                                    crossAxisSpacing: 2.0,
                                    crossAxisCount: 2,
                                    childAspectRatio: 1,
                                  ),
                              children: widget.data.categories!
                                  .map(
                                    (e) => CategoriesBlock(
                                      name: e.name!,
                                      image: e.image!,
                                      slug: e.slug!,
                                      city: widget.data.city!.slug!,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeProvider.scaffoldPadding,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: widget.data.categories!
                                  .map(
                                    (e) => Container(
                                      margin: const EdgeInsets.only(right: 20),
                                      child: CategoriesBlock(
                                        name: e.name!,
                                        image: e.image!,
                                        slug: e.slug!,
                                        city: widget.data.city!.slug!,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                ],
              )
            : const SizedBox(),
        widget.data.appSettings!.showTodaysTrendingFood! &&
                widget.data.trendingFoods!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppSpacerVertical(height: 20),
                  kAppTitleDivider(
                    context,
                    translate.today_trending_title,
                    ThemeProvider.scaffoldPadding,
                  ),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeProvider.scaffoldPadding,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollTrendingFoods,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widget.data.trendingFoods!
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 240,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                    color: ThemeProvider.lightDisabledColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  child: HorizontalFoodBlock(
                                    model: e,
                                    collection: 'trendingFoods',
                                    isAuthorized: widget.isAuthorized,
                                    appLocale: widget.appLocale,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  kAppSpacerVertical(height: 20),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: ThemeProvider.greyColorBorder,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                        ),
                        Positioned(
                          left: _scrollTrendingFoodPercentage,
                          child: Container(
                            width: 20,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        widget.data.appSettings!.showMostReviewedFood! &&
                widget.data.mostReviewedFoods!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppSpacerVertical(height: 20),
                  kAppTitleDivider(
                    context,
                    translate.customer_loved_items_title,
                    ThemeProvider.scaffoldPadding,
                  ),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeProvider.scaffoldPadding,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollMostReviewedFood,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widget.data.mostReviewedFoods!
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 240,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                    color: ThemeProvider.lightDisabledColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  child: HorizontalFoodBlock(
                                    model: e,
                                    collection: 'mostReviewedFoods',
                                    isAuthorized: widget.isAuthorized,
                                    appLocale: widget.appLocale,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  kAppSpacerVertical(height: 20),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: ThemeProvider.greyColorBorder,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                        ),
                        Positioned(
                          left: _scrollMostReviewedFoodPercentage,
                          child: Container(
                            width: 20,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        widget.data.appSettings!.showPopularFood! &&
                widget.data.popularFoods!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppSpacerVertical(height: 20),
                  kAppTitleDivider(
                    context,
                    translate.most_order_items_title,
                    ThemeProvider.scaffoldPadding,
                  ),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeProvider.scaffoldPadding,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollPopularFoods,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widget.data.popularFoods!
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 240,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                    color: ThemeProvider.lightDisabledColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  child: HorizontalFoodBlock(
                                    model: e,
                                    collection: 'popularFoods',
                                    isAuthorized: widget.isAuthorized,
                                    appLocale: widget.appLocale,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  kAppSpacerVertical(height: 20),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: ThemeProvider.greyColorBorder,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                        ),
                        Positioned(
                          left: _scrollPopularFoodPercentage,
                          child: Container(
                            width: 20,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        kAppSpacerVertical(height: 20),
        widget.data.brands!.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  kAppTitleDivider(
                    context,
                    translate.brand_title,
                    ThemeProvider.scaffoldPadding,
                  ),
                  kAppSpacerVertical(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: widget.data.brands!
                          .map(
                            (e) => TopBrandsBlock(
                              name: e.name!,
                              image: e.logo!,
                              id: e.id!,
                              slug: e.slug!,
                              city: widget.data.city!.name!,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  kAppSpacerVertical(height: 20),
                ],
              )
            : const SizedBox(),
        widget.data.appSettings!.showPopularRestaurant! &&
                widget.data.popularRestaurant!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppTitleDivider(
                    context,
                    translate.popular_restaurant_title,
                    ThemeProvider.scaffoldPadding,
                  ),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeProvider.scaffoldPadding,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollPopularRestaurant,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widget.data.popularRestaurant!
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 240,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                    color: ThemeProvider.lightDisabledColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  child: e.isHidden!
                                      ? HorizontalRestaurantHideBlock(model: e)
                                      : HorizontalRestaurantBlock(
                                          model: e,
                                          collection: 'popularRestaurant',
                                          isAuthorized: widget.isAuthorized,
                                        ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  kAppSpacerVertical(height: 20),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: ThemeProvider.greyColorBorder,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                        ),
                        Positioned(
                          left: _scrollPopularRestaurantPercentage,
                          child: Container(
                            width: 20,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        widget.data.banners!.isNotEmpty
            ? Column(
                children: [
                  kAppSpacerVertical(height: 20),
                  kAppTitleDivider(
                    context,
                    translate.eat_well_title,
                    ThemeProvider.scaffoldPadding,
                  ),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeProvider.scaffoldPadding,
                    ),
                    child: BannersList(bannerList: widget.data.banners!),
                  ),
                ],
              )
            : const SizedBox(),
        widget.data.cuisine!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppSpacerVertical(height: 20),
                  kAppTitleDivider(
                    context,
                    translate.global_flavour_title,
                    ThemeProvider.scaffoldPadding,
                  ),
                  kAppSpacerVertical(height: 20),
                  widget.data.cuisine!.length > 15
                      ? SizedBox(
                          width: double.infinity,
                          height: 160,
                          child: ScrollConfiguration(
                            behavior: CategoriesScrollBehavior(),
                            child: GridView(
                              scrollDirection: Axis.horizontal,
                              physics: const PageScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisSpacing: 2.0,
                                    crossAxisSpacing: 2.0,
                                    crossAxisCount: 2,
                                    childAspectRatio: 1,
                                  ),
                              children: widget.data.cuisine!
                                  .map(
                                    (e) => CuisineBlock(
                                      name: e.name!,
                                      image: e.image!,
                                      slug: e.slug!,
                                      city: widget.data.city!.slug!,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeProvider.scaffoldPadding,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget.data.cuisine!
                                  .map(
                                    (e) => Container(
                                      margin: const EdgeInsets.only(right: 20),
                                      child: CuisineBlock(
                                        name: e.name!,
                                        image: e.image!,
                                        slug: e.slug!,
                                        city: widget.data.city!.slug!,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                ],
              )
            : const SizedBox(),
        widget.data.appSettings!.showNewRestaurant! &&
                widget.data.newArrivals!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppSpacerVertical(height: 20),
                  kAppTitleDivider(
                    context,
                    '${translate.discover_restaurant_title} ${Environments.appName}',
                    ThemeProvider.scaffoldPadding,
                  ),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeProvider.scaffoldPadding,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollNewRestaurant,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widget.data.newArrivals!
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 240,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                    color: ThemeProvider.lightDisabledColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  child: e.isHidden!
                                      ? HorizontalRestaurantHideBlock(model: e)
                                      : HorizontalRestaurantBlock(
                                          model: e,
                                          collection: 'newArrivals',
                                          isAuthorized: widget.isAuthorized,
                                        ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  kAppSpacerVertical(height: 20),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: ThemeProvider.greyColorBorder,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                        ),
                        Positioned(
                          left: _scrollNewRestaurantPercentage,
                          child: Container(
                            width: 20,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        widget.data.appSettings!.showTiffinSubscriptionPackages! &&
                widget.data.tiffinSubscriptionPackages!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppSpacerVertical(height: 20),
                  kAppTitleDivider(
                    context,
                    '${translate.new_tiffin_package_title} ${Environments.appName}',
                    ThemeProvider.scaffoldPadding,
                  ),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeProvider.scaffoldPadding,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollSubscriptionPackages,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widget.data.tiffinSubscriptionPackages!
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 270,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                    color: ThemeProvider.lightDisabledColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  child: HorizontalSubscriptionPackageBlock(
                                    model: e,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  kAppSpacerVertical(height: 20),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: ThemeProvider.greyColorBorder,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                        ),
                        Positioned(
                          left: _scrollSubscriptionPackagesPercentage,
                          child: Container(
                            width: 20,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        kAppSpacerVertical(height: 20),
        widget.data.restaurants!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppTitleDivider(
                    context,
                    translate.restaurant_title,
                    ThemeProvider.scaffoldPadding,
                  ),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeProvider.scaffoldPadding,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widget.data.restaurants!
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                    color: ThemeProvider.lightDisabledColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  child: e.isHidden!
                                      ? VerticalRestaurantHideBlock(model: e)
                                      : VerticalRestaurantBlock(
                                          model: e,
                                          collection: 'restaurants',
                                          findMode: widget.data.findMode!,
                                          isAuthorized: widget.isAuthorized,
                                        ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  kAppSpacerVertical(height: 20),
                  widget.isLoadMore
                      ? kAppCenterCircularProgress(context)
                      : const SizedBox(),
                  kAppSpacerVertical(height: 20),
                ],
              )
            : const SizedBox(),
      ],
    );
  }
}

class CampaignBannerList extends StatelessWidget {
  final List<CampaignListModel> campaignList;
  const CampaignBannerList({super.key, required this.campaignList});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        viewportFraction: 1,
        aspectRatio: 4.0,
        enlargeCenterPage: false,
        height: 120.0,
        scrollDirection: Axis.horizontal,
      ),
      items: campaignList
          .map(
            (e) => InkWell(
              onTap: () => Navigator.of(context).pushNamed(
                e.type == 'food'
                    ? AppRouter.foodCampaignRoute
                    : AppRouter.restaurantCampaignRoute,
                arguments: [e.id],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: CacheNetworkImageWidget(
                  width: MediaQuery.of(context).size.width,
                  height: 120.0,
                  imageUrl: e.image!,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class CategoriesBlock extends StatelessWidget {
  final String name;
  final String image;
  final String slug;
  final String city;
  const CategoriesBlock({
    super.key,
    required this.name,
    required this.image,
    required this.slug,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        AppRouter.restaurantsByCategoryRoute,
        arguments: [name, slug, city],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: image),
          kAppSpacerVertical(height: 10),
          Text(kAppTrimWord(name, 8), style: kAppLblSmallFontRegular(context)),
        ],
      ),
    );
  }
}

class TopBrandsBlock extends StatelessWidget {
  final String name;
  final String image;
  final String id;
  final String slug;
  final String city;
  const TopBrandsBlock({
    super.key,
    required this.name,
    required this.image,
    required this.id,
    required this.slug,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          AppRouter.restaurantsByBrandsRoute,
          arguments: [id, name, image, slug, city],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: CacheNetworkImageWidget(
                width: 80.0,
                height: 80.0,
                imageUrl: image,
              ),
            ),
            kAppSpacerVertical(height: 10),
            Text(
              kAppTrimWord(name, 15),
              style: kAppLblSmallFontRegular(context),
            ),
          ],
        ),
      ),
    );
  }
}

class CuisineBlock extends StatelessWidget {
  final String name;
  final String image;
  final String slug;
  final String city;
  const CuisineBlock({
    super.key,
    required this.name,
    required this.image,
    required this.slug,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        AppRouter.restaurantsByCuisineRoute,
        arguments: [name, slug, city],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: image),
          kAppSpacerVertical(height: 10),
          Text(kAppTrimWord(name, 8), style: kAppLblSmallFontRegular(context)),
        ],
      ),
    );
  }
}

class CategoriesScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class HorizontalRestaurantBlock extends StatelessWidget {
  final RestaurantsModel model;
  final String collection;
  final bool isAuthorized;
  const HorizontalRestaurantBlock({
    super.key,
    required this.model,
    required this.collection,
    required this.isAuthorized,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        AppRouter.restaurantRoute,
        arguments: [model.id, model.slug, model.name],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            children: [
              CacheNetworkImageWidget(
                width: MediaQuery.of(context).size.width / 2.5,
                height: 100.0,
                imageUrl: model.cover!,
              ),
              isAuthorized
                  ? Positioned(
                      top: 5,
                      right: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => context.read<HomeBloc>().add(
                              HomeHideRestaurantEvent(id: model.id!),
                            ),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: ThemeProvider.whiteColor,
                              ),
                              child: Icon(
                                Icons.visibility_off_outlined,
                                size: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.fontSize,
                                color: ThemeProvider.primaryColor,
                              ),
                            ),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          InkWell(
                            onTap: () => context.read<HomeBloc>().add(
                              HomeFavouriteEvent(
                                type: 'restaurant',
                                id: model.id!,
                                collection: collection,
                                isFavourite: model.isFavourite!,
                              ),
                            ),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: ThemeProvider.whiteColor,
                              ),
                              child: Icon(
                                model.isFavourite!
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded,
                                size: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.fontSize,
                                color: ThemeProvider.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              model.promote!
                  ? Positioned(
                      left: 0,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeProvider.darkBackgroundColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          translate.promo_lbl,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'regular',
                            color: ThemeProvider.whiteColor,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  kAppTrimWord(model.name!, 20),
                  style: kAppLblMediumFontBold(context),
                ),
                kAppSpacerVertical(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      AssetsUrl.iconsURL.timeTag,
                      height: 12,
                      width: 12,
                    ),
                    kAppSpacerHorizontal(width: 5),
                    Text(
                      kAppDeliveryTimeName(context, model.approxDeliveryTime!),
                      style: kAppLblSmallFontRegular(context),
                    ),
                  ],
                ),
                kAppSpacerVertical(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      AssetsUrl.iconsURL.priceTag,
                      height: 12,
                      width: 12,
                    ),
                    kAppSpacerHorizontal(width: 5),
                    Text(
                      "${kAppPriceFormat(model.dishPriceForTwo!)} ${translate.for_two_lbl}",
                      style: kAppLblSmallFontRegular(context),
                    ),
                  ],
                ),
                kAppSpacerVertical(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      AssetsUrl.iconsURL.starTag,
                      height: 12,
                      width: 12,
                    ),
                    kAppSpacerHorizontal(width: 5),
                    Text(
                      model.rating!,
                      style: kAppLblSmallFontRegular(context),
                    ),
                  ],
                ),
                kAppSpacerVertical(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HorizontalFoodBlock extends StatelessWidget {
  final FoodsModel model;
  final String collection;
  final bool isAuthorized;
  final String appLocale;
  const HorizontalFoodBlock({
    super.key,
    required this.model,
    required this.collection,
    required this.isAuthorized,
    required this.appLocale,
  });

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
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10.0),
                      ),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    builder: (BuildContext context) {
                      return FractionallySizedBox(
                        heightFactor: 0.7,
                        child: FoodScreen(
                          id: model.id!,
                          from: 'home',
                          data: jsonEncode(model),
                          extraInfo: '',
                        ),
                      );
                    },
                  ).then((value) {
                    if (!context.mounted) return;
                    if (value != null) {
                      FoodInfoModalResponseModel foodInfoModalResponse =
                          FoodInfoModalResponseModel.fromJson(value, appLocale);
                      context.read<HomeBloc>().add(
                        HomeFoodModalResponseEvent(
                          id: model.id!,
                          collection: collection,
                          response: foodInfoModalResponse,
                        ),
                      );
                    }
                  });
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                  child: CacheNetworkImageWidget(
                    width: MediaQuery.of(context).size.width,
                    height: 100.0,
                    imageUrl: model.image!,
                  ),
                ),
              ),
              Positioned(
                left: 5,
                bottom: 5,
                child: kAppFoodType(model.foodType!),
              ),
              model.quantity! <= 0
                  ? Positioned(
                      bottom: 5,
                      right: 5,
                      child: InkWell(
                        onTap: () async {
                          if (model.addons!.isNotEmpty ||
                              model.variations!.isNotEmpty) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              isDismissible: false,
                              enableDrag: false,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10.0),
                                ),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              builder: (BuildContext context) {
                                return FractionallySizedBox(
                                  heightFactor: 0.7,
                                  child: FoodVariationsModalScreen(
                                    id: model.id!,
                                    name: model.name!,
                                    image: model.image!,
                                    options: jsonEncode({
                                      "addons": model.addons!,
                                      "variations": model.variations!,
                                    }),
                                    price: model.price!,
                                    offerPrice: model.offerPrice!,
                                    discount: model.discount!,
                                    discountType: model.discountType!,
                                    purchaseLimit: int.parse(
                                      model.purchaseLimit!.toString(),
                                    ),
                                    stockNumber: int.parse(
                                      model.stockNumber!.toString(),
                                    ),
                                    stockType: model.stockType!,
                                  ),
                                );
                              },
                            ).then((value) {
                              if (!context.mounted) return;
                              if (value != null) {
                                FoodVariationModalResponseDataModel
                                foodVariationModalResponse =
                                    FoodVariationModalResponseDataModel.fromJson(
                                      value,
                                      appLocale,
                                    );
                                if (foodVariationModalResponse.action!) {
                                  context.read<HomeBloc>().add(
                                    HomeFoodVariationModalResponseEvent(
                                      id: model.id!,
                                      collection: collection,
                                      data: foodVariationModalResponse,
                                    ),
                                  );
                                }
                              }
                            });
                          } else {
                            context.read<HomeBloc>().add(
                              HomeAddCartEvent(
                                id: model.id!,
                                collection: collection,
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: ThemeProvider.whiteColor,
                          ),
                          child: Icon(
                            Icons.add,
                            size: Theme.of(
                              context,
                            ).textTheme.labelLarge?.fontSize,
                            color: ThemeProvider.primaryColor,
                          ),
                        ),
                      ),
                    )
                  : Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        height: 25,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: ThemeProvider.whiteColor,
                        ),
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
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10.0),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    builder: (BuildContext context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.4,
                                        child: FoodVariationModalRepeatScreen(
                                          id: model.id!,
                                          action: false,
                                        ),
                                      );
                                    },
                                  ).then((value) {
                                    if (!context.mounted) return;
                                    if (value != null) {
                                      RepeatQuantityModalResponseModel
                                      repeatQuantityModalResponse =
                                          RepeatQuantityModalResponseModel.fromJson(
                                            value,
                                          );
                                      if (repeatQuantityModalResponse.action ==
                                          'update') {
                                        context.read<HomeBloc>().add(
                                          HomeRepeatFoodOrderResponseEvent(
                                            id: model.id!,
                                            collection: collection,
                                            data: repeatQuantityModalResponse,
                                          ),
                                        );
                                      }
                                    }
                                  });
                                } else {
                                  context.read<HomeBloc>().add(
                                    HomeFoodQuantityDecreaseEvent(
                                      id: model.id!,
                                      collection: collection,
                                    ),
                                  );
                                }
                              },
                              child: Icon(
                                Icons.remove_circle_outline,
                                size: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.fontSize,
                                color: ThemeProvider.primaryColor,
                              ),
                            ),
                            Text(
                              '${model.quantity!}',
                              style: TextStyle(
                                color: ThemeProvider.primaryColor,
                                fontSize: Theme.of(
                                  context,
                                ).textTheme.labelMedium?.fontSize,
                                fontFamily: 'semibold',
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (model.addons!.isNotEmpty ||
                                    model.variations!.isNotEmpty) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    isDismissible: false,
                                    enableDrag: false,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10.0),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    builder: (BuildContext context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.4,
                                        child: FoodVariationModalRepeatScreen(
                                          id: model.id!,
                                          action: true,
                                        ),
                                      );
                                    },
                                  ).then((value) {
                                    if (!context.mounted) return;
                                    if (value != null) {
                                      RepeatQuantityModalResponseModel
                                      repeatQuantityModalResponse =
                                          RepeatQuantityModalResponseModel.fromJson(
                                            value,
                                          );
                                      if (repeatQuantityModalResponse.action ==
                                          'update') {
                                        context.read<HomeBloc>().add(
                                          HomeRepeatFoodOrderResponseEvent(
                                            id: model.id!,
                                            collection: collection,
                                            data: repeatQuantityModalResponse,
                                          ),
                                        );
                                      } else if (repeatQuantityModalResponse
                                              .action ==
                                          'new') {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          isDismissible: false,
                                          enableDrag: false,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(10.0),
                                            ),
                                          ),
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          builder: (BuildContext context) {
                                            return FractionallySizedBox(
                                              heightFactor: 0.7,
                                              child: FoodVariationsModalScreen(
                                                id: model.id!,
                                                name: model.name!,
                                                image: model.image!,
                                                options: jsonEncode({
                                                  "addons": model.addons!,
                                                  "variations":
                                                      model.variations!,
                                                }),
                                                price: model.price!,
                                                offerPrice: model.offerPrice!,
                                                discount: model.discount!,
                                                discountType:
                                                    model.discountType!,
                                                purchaseLimit: int.parse(
                                                  model.purchaseLimit!
                                                      .toString(),
                                                ),
                                                stockNumber: int.parse(
                                                  model.stockNumber!.toString(),
                                                ),
                                                stockType: model.stockType!,
                                              ),
                                            );
                                          },
                                        ).then((value) {
                                          if (!context.mounted) return;
                                          if (value != null) {
                                            FoodVariationModalResponseDataModel
                                            foodVariationModalResponse =
                                                FoodVariationModalResponseDataModel.fromJson(
                                                  value,
                                                  appLocale,
                                                );
                                            if (foodVariationModalResponse
                                                .action!) {
                                              context.read<HomeBloc>().add(
                                                HomeFoodVariationModalRepeatResponseEvent(
                                                  id: model.id!,
                                                  collection: collection,
                                                  data:
                                                      foodVariationModalResponse,
                                                ),
                                              );
                                            }
                                          }
                                        });
                                      }
                                    }
                                  });
                                } else {
                                  context.read<HomeBloc>().add(
                                    HomeFoodQuantityIncreaseEvent(
                                      id: model.id!,
                                      collection: collection,
                                    ),
                                  );
                                }
                              },
                              child: Icon(
                                Icons.add_circle_outline,
                                size: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.fontSize,
                                color: ThemeProvider.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              isAuthorized
                  ? Positioned(
                      top: 5,
                      right: 5,
                      child: InkWell(
                        onTap: () => context.read<HomeBloc>().add(
                          HomeFavouriteEvent(
                            type: 'food',
                            id: model.id!,
                            collection: collection,
                            isFavourite: model.isFavourite!,
                          ),
                        ),
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: ThemeProvider.whiteColor,
                          ),
                          child: Icon(
                            model.isFavourite!
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            size: Theme.of(
                              context,
                            ).textTheme.labelLarge?.fontSize,
                            color: ThemeProvider.primaryColor,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              model.discount! > 0
                  ? Positioned(
                      left: 0,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeProvider.darkBackgroundColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              AssetsUrl.imageURL.offerTag,
                              height: 10,
                              width: 10,
                            ),
                            kAppSpacerHorizontal(width: 5),
                            Text(
                              model.discountType == '%'
                                  ? '${translate.flat} ${model.discount}% ${translate.off}'
                                  : '${translate.flat} ${kAppPriceFormat(model.discount!)} ${translate.off}',
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10.0),
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                    heightFactor: 0.7,
                    child: FoodScreen(
                      id: model.id!,
                      from: 'home',
                      data: jsonEncode(model),
                      extraInfo: '',
                    ),
                  );
                },
              ).then((value) {
                if (!context.mounted) return;
                if (value != null) {
                  FoodInfoModalResponseModel foodInfoModalResponse =
                      FoodInfoModalResponseModel.fromJson(value, appLocale);
                  context.read<HomeBloc>().add(
                    HomeFoodModalResponseEvent(
                      id: model.id!,
                      collection: collection,
                      response: foodInfoModalResponse,
                    ),
                  );
                }
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                kAppSpacerVertical(height: 5),
                Text(
                  kAppTrimWord(model.restaurants!.name!, 15),
                  style: kAppLblTinyFontRegular(context),
                ),
                Text(
                  kAppTrimWord(model.name!, 15),
                  style: kAppLblMediumFontBold(context),
                ),
                kAppSpacerVertical(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ThemeProvider.ratingStarIconColorLight,
                          width: 0.5,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(2),
                        ),
                      ),
                      child: kAppFoodRatingStar(model.rating!, iconSize: 12),
                    ),
                    kAppSpacerHorizontal(width: 5),
                    Text(
                      "${model.totalRating!} ${translate.ratings}",
                      style: kAppLblTinyFontRegular(context),
                    ),
                  ],
                ),
                kAppSpacerVertical(height: 5),
                model.discount! <= 0
                    ? Text(
                        kAppPriceFormat(model.price!),
                        style: kAppLblTinyMediumFontSemi(context),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            kAppPriceFormat(model.price!),
                            style: kAppLblTinyStrokeFontRegular(context),
                          ),
                          kAppSpacerHorizontal(width: 5),
                          Text(
                            kAppPriceFormat(model.offerPrice!),
                            style: kAppLblTinyMediumFontSemi(context),
                          ),
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

class VerticalRestaurantBlock extends StatelessWidget {
  final RestaurantsModel model;
  final String collection;
  final String findMode;
  final bool isAuthorized;
  const VerticalRestaurantBlock({
    super.key,
    required this.model,
    required this.collection,
    required this.findMode,
    required this.isAuthorized,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        AppRouter.restaurantRoute,
        arguments: [model.id, model.slug, model.name],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                child: CacheNetworkImageWidget(
                  width: MediaQuery.of(context).size.width,
                  height: 150.0,
                  imageUrl: model.cover!,
                ),
              ),
              model.promote!
                  ? Positioned(
                      left: 0,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeProvider.darkBackgroundColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          translate.promo_lbl,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'regular',
                            color: ThemeProvider.whiteColor,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              isAuthorized
                  ? Positioned(
                      top: 5,
                      right: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => context.read<HomeBloc>().add(
                              HomeHideRestaurantEvent(id: model.id!),
                            ),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: ThemeProvider.whiteColor,
                              ),
                              child: Icon(
                                Icons.visibility_off_outlined,
                                size: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.fontSize,
                                color: ThemeProvider.primaryColor,
                              ),
                            ),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          InkWell(
                            onTap: () => context.read<HomeBloc>().add(
                              HomeFavouriteEvent(
                                type: 'restaurant',
                                id: model.id!,
                                collection: collection,
                                isFavourite: model.isFavourite!,
                              ),
                            ),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: ThemeProvider.whiteColor,
                              ),
                              child: Icon(
                                model.isFavourite!
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded,
                                size: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.fontSize,
                                color: ThemeProvider.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        kAppTrimWord(model.name!, 45),
                        style: kAppLblMediumFontBold(context),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeProvider.ratingBgColorLight,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${model.rating}',
                            style: const TextStyle(
                              color: ThemeProvider.ratingTextColorLight,
                            ),
                          ),
                          kAppSpacerHorizontal(width: 2),
                          Icon(
                            Icons.star,
                            size: Theme.of(
                              context,
                            ).textTheme.labelSmall?.fontSize,
                            color: ThemeProvider.ratingTextColorLight,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                kAppSpacerVertical(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      kAppTrimWord(model.cuisineName!, 35),
                      style: kAppLblTinyFontRegular(context),
                    ),
                    Text(
                      "${kAppPriceFormat(model.dishPriceForTwo!)} ${translate.for_two_lbl}",
                      style: kAppLblTinyFontRegular(context),
                    ),
                  ],
                ),
                kAppSpacerVertical(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          AssetsUrl.iconsURL.timeTag,
                          height: 10,
                          width: 10,
                        ),
                        kAppSpacerHorizontal(width: 5),
                        Text(
                          kAppDeliveryTimeName(
                            context,
                            model.approxDeliveryTime!,
                          ),
                          style: kAppLblTinyFontRegular(context),
                        ),
                      ],
                    ),
                    Text(
                      "${model.distance!} $findMode",
                      style: kAppLblTinyFontRegular(context),
                    ),
                  ],
                ),
                kAppSpacerVertical(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BannersList extends StatelessWidget {
  final List<BannersModel> bannerList;
  const BannersList({super.key, required this.bannerList});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        viewportFraction: 1,
        aspectRatio: 4.0,
        enlargeCenterPage: false,
        height: 120.0,
        scrollDirection: Axis.horizontal,
      ),
      items: bannerList
          .map(
            (model) => InkWell(
              onTap: () async {
                if (model.type == 'restaurant') {
                  Navigator.of(context).pushNamed(
                    AppRouter.restaurantRoute,
                    arguments: [
                      model.restaurants!.id,
                      model.restaurants!.slug,
                      model.restaurants!.name,
                    ],
                  );
                } else if (model.type == 'food') {
                  Navigator.of(context).pushNamed(
                    AppRouter.singleFoodFromBannerRoute,
                    arguments: [model.foods!.id!, model.foods!.name!],
                  );
                } else if (model.type == 'external') {
                  final Uri launchURLString = Uri.parse(model.external!);
                  !await launchUrl(
                    launchURLString,
                    mode: LaunchMode.inAppBrowserView,
                  );
                }
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: CacheNetworkImageWidget(
                  width: MediaQuery.of(context).size.width,
                  height: 120.0,
                  imageUrl: model.image!,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class HorizontalRestaurantHideBlock extends StatelessWidget {
  final RestaurantsModel model;
  const HorizontalRestaurantHideBlock({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translate.hidden_restaurant_title,
                style: kAppLblTinyFontRegular(context),
              ),
              kAppSpacerVertical(height: 5),
              Text(
                kAppTrimWord(model.name!, 35),
                style: kAppLblMediumFontBold(context),
              ),
              kAppSpacerVertical(height: 5),
              Text(
                translate.hidden_restaurant_sub_title,
                style: kAppLblTinyFontRegular(context),
              ),
              kAppSpacerVertical(height: 10),
              InkWell(
                onTap: () => context.read<HomeBloc>().add(
                  HomeRemoveRestaurantFromListEvent(id: model.id!),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    translate.remove_now_btn,
                    style: kAppLblTinyFontRegularChip(
                      context,
                      color: 'primary',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: ThemeProvider.lightDisabledColor,
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () => context.read<HomeBloc>().add(
                    HomeUndoHideActionEvent(id: model.id!),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh_outlined,
                          size: 10,
                          color: Theme.of(context).canvasColor,
                        ),
                        kAppSpacerHorizontal(width: 5),
                        Text(
                          translate.undo_btn,
                          style: kAppLblTinyFontRegular(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: false,
                      enableDrag: false,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10.0),
                        ),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                          heightFactor: 0.6,
                          child: HideRestaurantReasonModalScreen(
                            restaurantId: model.id!,
                            restaurantName: model.name!,
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(15.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.new_releases_outlined,
                          size: 10,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        kAppSpacerHorizontal(width: 5),
                        Text(
                          translate.why_btn,
                          style: kAppLblTinyRegularWhite(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class VerticalRestaurantHideBlock extends StatelessWidget {
  final RestaurantsModel model;
  const VerticalRestaurantHideBlock({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translate.hidden_restaurant_title,
                style: kAppLblTinyFontRegular(context),
              ),
              kAppSpacerVertical(height: 5),
              Text(
                kAppTrimWord(model.name!, 35),
                style: kAppLblMediumFontBold(context),
              ),
              kAppSpacerVertical(height: 5),
              Text(
                translate.hidden_restaurant_sub_title,
                style: kAppLblTinyFontRegular(context),
              ),
              kAppSpacerVertical(height: 10),
              InkWell(
                onTap: () => context.read<HomeBloc>().add(
                  HomeRemoveRestaurantFromListEvent(id: model.id!),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    translate.remove_now_btn,
                    style: kAppLblTinyFontRegularChip(
                      context,
                      color: 'primary',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: ThemeProvider.lightDisabledColor,
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () => context.read<HomeBloc>().add(
                    HomeUndoHideActionEvent(id: model.id!),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh_outlined,
                          size: 10,
                          color: Theme.of(context).canvasColor,
                        ),
                        kAppSpacerHorizontal(width: 5),
                        Text(
                          translate.undo_btn,
                          style: kAppLblTinyFontRegular(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: false,
                      enableDrag: false,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10.0),
                        ),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                          heightFactor: 0.6,
                          child: HideRestaurantReasonModalScreen(
                            restaurantId: model.id!,
                            restaurantName: model.name!,
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(15.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.new_releases_outlined,
                          size: 10,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        kAppSpacerHorizontal(width: 5),
                        Text(
                          translate.why_btn,
                          style: kAppLblTinyRegularWhite(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HorizontalSubscriptionPackageBlock extends StatelessWidget {
  final TiffinSubscriptionPackagesInfoModel model;
  const HorizontalSubscriptionPackageBlock({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
          AppRouter.foodSubscriptionInfoRoute,
          arguments: [model.id!, model.name!],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                  child: CacheNetworkImageWidget(
                    width: MediaQuery.of(context).size.width,
                    height: 100.0,
                    imageUrl: model.image!,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: ThemeProvider.whiteColor,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: Theme.of(context).textTheme.labelLarge?.fontSize,
                      color: ThemeProvider.primaryColor,
                    ),
                  ),
                ),
                model.discount! > 0
                    ? Positioned(
                        left: 0,
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeProvider.darkBackgroundColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                AssetsUrl.imageURL.offerTag,
                                height: 10,
                                width: 10,
                              ),
                              kAppSpacerHorizontal(width: 5),
                              Text(
                                model.discountType == '%'
                                    ? '${translate.flat} ${model.discount}% ${translate.off}'
                                    : '${translate.flat} ${kAppPriceFormat(model.discount!)} ${translate.off}',
                                style: kAppLblTinyBoldOffer(context),
                              ),
                            ],
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
                Text(
                  kAppTrimWord(model.restaurants!.name!, 15),
                  style: kAppLblTinyFontRegular(context),
                ),
                Text(
                  kAppTrimWord(model.name!, 15),
                  style: kAppLblMediumFontBold(context),
                ),
                kAppSpacerVertical(height: 5),
                Text(
                  "${kSubscriptionPackageDays(model.interval!)} ${translate.days} & ${model.orderTo! == 'homedelivery' ? translate.home_delivery : translate.take_away} ${translate.only}",
                  style: kAppLblTinyFontRegular(context),
                ),
                kAppSpacerVertical(height: 5),
                model.discount! <= 0
                    ? Text(
                        kAppPriceFormat(model.price!),
                        style: kAppLblTinyMediumFontSemi(context),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            kAppPriceFormat(model.price!),
                            style: kAppLblTinyStrokeFontRegular(context),
                          ),
                          kAppSpacerHorizontal(width: 5),
                          Text(
                            kAppPriceFormat(model.offerPrice!),
                            style: kAppLblTinyMediumFontSemi(context),
                          ),
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
