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

import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/dining_on_map_modal_response_model.dart';
import 'package:user/app/core/models/dining_response_model.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/pages/dining/@core/bloc/dining_bloc.dart';
import 'package:user/app/presentation/pages/dining/dining_campaigns/bloc/dining_campaign_bloc.dart';
import 'package:user/app/presentation/pages/dining/dining_on_maps/dining_on_maps_view.dart';
import 'package:user/app/presentation/pages/dining/filter_dining_with_category/bloc/filter_dining_with_category_bloc.dart';
import 'package:user/app/presentation/pages/favourite/restaurants/bloc/favourite_restaurants_bloc.dart';
import 'package:user/app/presentation/pages/home/@core/bloc/home_bloc.dart';
import 'package:user/app/presentation/pages/home/campaign/restaurant_campaign/bloc/restaurant_campaign_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/@core/bloc/restaurant_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/restaurant_detail_info/bloc/restaurant_detail_info_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/brands/bloc/restaurants_by_brands_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/categories/filter_restaurants/bloc/filter_restaurants_by_categories_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/cuisine/bloc/restaurants_by_cuisine_bloc.dart';
import 'package:user/app/presentation/pages/modals/hide_restaurant_reason_modal/hide_restaurant_reason_modal_view.dart';
import 'package:user/app/presentation/pages/modals/language_translation_modal/language_translation_modal_view.dart';
import 'package:user/app/presentation/pages/modals/restaurants_by_localities_modal/bloc/restaurants_by_localities_bloc.dart';
import 'package:user/app/presentation/styles/app_localization/app_localization_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DiningScreen extends StatelessWidget {
  const DiningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RestaurantBloc, RestaurantState>(
          listener: (context, state) {
            if (state.status.isFavAdd || state.status.isFavRemove) {
              context.read<DiningBloc>().add(DiningRefreshFavouriteEvent(inFavList: state.status.isFavAdd ? [state.info.details!.id!] : []));
            }
          },
        ),
        BlocListener<RestaurantDetailInfoBloc, RestaurantDetailInfoState>(
          listener: (context, state) {
            if (state.status.isFavAdd || state.status.isFavRemove) {
              context.read<DiningBloc>().add(DiningRefreshFavouriteEvent(inFavList: state.status.isFavAdd ? [state.model.details!.id!] : []));
            }
          },
        ),
        BlocListener<FavouriteRestaurantsBloc, FavouriteRestaurantsState>(
          listener: (context, state) {
            if (state.status.isRemoveFavDone) {
              context.read<DiningBloc>().add(DiningRefreshFavouriteEvent(inFavList: state.restaurants.restaurantIds!));
            }
          },
        ),
        BlocListener<RestaurantCampaignBloc, RestaurantCampaignState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<DiningBloc>().add(DiningRefreshFavouriteEvent(inFavList: state.favIds));
            }
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status.isRestaurantFav) {
              context.read<DiningBloc>().add(DiningRefreshFavouriteEvent(inFavList: state.favRestIds));
            } else if (state.status.isHidden) {
              context.read<DiningBloc>().add(DiningSilentHideEvent(id: state.hideUnhideId));
            } else if (state.status.isUnhidden) {
              context.read<DiningBloc>().add(DiningSilentUnHideEvent(id: state.hideUnhideId));
            }
          },
        ),
        BlocListener<DiningCampaignBloc, DiningCampaignState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<DiningBloc>().add(DiningRefreshFavouriteEvent(inFavList: state.favIds));
            } else if (state.status.isHidden) {
              context.read<DiningBloc>().add(DiningSilentHideEvent(id: state.hideUnhideId));
            } else if (state.status.isUnhidden) {
              context.read<DiningBloc>().add(DiningSilentUnHideEvent(id: state.hideUnhideId));
            }
          },
        ),
        BlocListener<FilterDiningWithCategoryBloc, FilterDiningWithCategoryState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<DiningBloc>().add(DiningRefreshFavouriteEvent(inFavList: state.favIds));
            } else if (state.status.isHidden) {
              context.read<DiningBloc>().add(DiningSilentHideEvent(id: state.hideUnhideId));
            } else if (state.status.isUnhidden) {
              context.read<DiningBloc>().add(DiningSilentUnHideEvent(id: state.hideUnhideId));
            }
          },
        ),
        BlocListener<FilterRestaurantsByCategoriesBloc, FilterRestaurantsByCategoriesState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<DiningBloc>().add(DiningRefreshFavouriteEvent(inFavList: state.favIds));
            }
          },
        ),
        BlocListener<RestaurantsByCuisineBloc, RestaurantsByCuisineState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<DiningBloc>().add(DiningRefreshFavouriteEvent(inFavList: state.favIds));
            }
          },
        ),
        BlocListener<RestaurantsByBrandsBloc, RestaurantsByBrandsState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<DiningBloc>().add(DiningRefreshFavouriteEvent(inFavList: state.favIds));
            }
          },
        ),
        BlocListener<RestaurantsByLocalitiesBloc, RestaurantsByLocalitiesState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<DiningBloc>().add(DiningRefreshFavouriteEvent(inFavList: state.favIds));
            }
          },
        ),
      ],
      child: const DiningView(),
    );
  }
}

class DiningView extends StatefulWidget {
  const DiningView({super.key});

  @override
  State<DiningView> createState() => _DiningViewState();
}

class _DiningViewState extends State<DiningView> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollDiningRestaurant = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<DiningBloc>().add(DiningInitialEvent());
    _scrollDiningRestaurant.addListener(() {
      if (_scrollDiningRestaurant.position.pixels == _scrollDiningRestaurant.position.maxScrollExtent) {
        context.read<DiningBloc>().add(DiningLoadMoreEvent());
      }
    });
  }

  bool isNumbericAddressTitle(String value) {
    if (value.isEmpty) return false;
    return num.tryParse(value) != null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    super.build(context);
    return BlocConsumer<DiningBloc, DiningState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: InkWell(
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.locationSearchRoute, (Route<dynamic> route) => false),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.locationArrow, size: 12, color: Theme.of(context).primaryColor),
                      kAppSpacerHorizontal(width: 5),
                      Text(isNumbericAddressTitle(state.addressTitle) ? kAppAddressTitle(context, int.parse(state.addressTitle)) : state.addressTitle, style: kAppLblMediumFontBold(context)),
                      kAppSpacerHorizontal(width: 5),
                      const FaIcon(FontAwesomeIcons.chevronDown, size: 12),
                    ],
                  ),
                  Text(kAppTrimWord(state.addressSubTitle, 40), style: kAppLblMediumFontBold(context)),
                ],
              ),
            ),
            actions: [
              AppSupportedLanguagesModel.languages.isNotEmpty && AppSupportedLanguagesModel.languages.length > 1
                  ? IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: false,
                          enableDrag: false,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          builder: (BuildContext context) {
                            return FractionallySizedBox(heightFactor: 0.7, child: LanguageTranslationModalScreen(selected: state.locale));
                          },
                        ).then((value) {
                          if (!context.mounted) return;
                          if (value != null) {
                            if (value.toString() != state.locale) {
                              context.read<AppLocalizationBloc>().add(ChangeAppLocalizationEvent(defaultLanguage: value));
                              Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [1]);
                            }
                          }
                        });
                      },
                      icon: FaIcon(FontAwesomeIcons.language, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).iconTheme.color),
                    )
                  : const SizedBox(),
            ],
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(55),
              child: Padding(
                padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed(AppRouter.diningSearchRoutes),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
              ),
            ),
          ),
          body: RefreshIndicator(
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            color: Theme.of(context).canvasColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            onRefresh: () async {
              context.read<DiningBloc>().add(DiningPullRefreshEvent());
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _scrollDiningRestaurant,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const DiningLoadingView(),
                  ] else if (state.status.isEmpty) ...[
                    const DiningEmptyView(),
                  ] else if (state.status.isCustomError || state.status.isSuccess || state.status.isRestaurantFav || state.status.isHidden || state.status.isUnhidden) ...[
                    DiningResponseView(model: state.model, isLoadMore: state.loadMore, isAuthorized: state.isAuthorized),
                  ] else ...[
                    const DiningEmptyView(),
                  ],
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
          floatingActionButton: state.status.isCustomError || state.status.isSuccess || state.status.isRestaurantFav
              ? SizedBox(
                  height: 30,
                  child: FloatingActionButton.extended(
                    heroTag: 'diningOnMaps',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: false,
                        enableDrag: false,
                        showDragHandle: false,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        builder: (BuildContext context) {
                          return const FractionallySizedBox(child: DiningOnMapScreen());
                        },
                      ).then((value) {
                        if (!context.mounted) return;
                        if (value != null && value.toString().isNotEmpty) {
                          DiningOnMapModalResponseModel onMapModalResponseModel = DiningOnMapModalResponseModel.fromJson(value);
                          if (onMapModalResponseModel.id!.isNotEmpty && onMapModalResponseModel.name!.isNotEmpty) {
                            Navigator.of(context).pushNamed(AppRouter.restaurantDetailInfoRoute, arguments: [onMapModalResponseModel.id!, onMapModalResponseModel.name!, onMapModalResponseModel.slug!, '']);
                          }
                        }
                      });
                    },
                    label: Text(translate.maps, style: kAppLblMediumFontSemiBoldWhite(context)),
                    icon: const FaIcon(FontAwesomeIcons.compass, size: 12),
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DiningResponseView extends StatefulWidget {
  final DiningResponseModel model;
  final bool isLoadMore;
  final bool isAuthorized;
  const DiningResponseView({super.key, required this.model, required this.isLoadMore, required this.isAuthorized});

  @override
  State<DiningResponseView> createState() => _DiningResponseViewState();
}

class _DiningResponseViewState extends State<DiningResponseView> {
  final ScrollController _scrollPopularDining = ScrollController();
  final ScrollController _scrollNewDining = ScrollController();

  double _scrollPopularDiningPercentage = 0;
  double _scrollNewDiningPercentage = 0;

  @override
  void initState() {
    super.initState();
    _scrollPopularDining.addListener(() {
      double scrollPercentage = (_scrollPopularDining.position.pixels / _scrollPopularDining.position.maxScrollExtent) * 100;
      if (scrollPercentage > 90) {
        setState(() {
          _scrollPopularDiningPercentage = 80;
        });
      } else {
        setState(() {
          _scrollPopularDiningPercentage = scrollPercentage;
        });
      }
    });

    _scrollNewDining.addListener(() {
      double scrollPercentage = (_scrollNewDining.position.pixels / _scrollNewDining.position.maxScrollExtent) * 100;
      if (scrollPercentage > 90) {
        setState(() {
          _scrollNewDiningPercentage = 80;
        });
      } else {
        setState(() {
          _scrollNewDiningPercentage = scrollPercentage;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kAppSpacerVertical(height: 10),
        widget.model.diningCampaign!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                    child: DiningCampaignBannerListWidget(campaignList: widget.model.diningCampaign!),
                  ),
                  kAppSpacerVertical(height: 20),
                ],
              )
            : const SizedBox(),
        widget.model.categories!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppTitleDivider(context, translate.looking_for_title, ThemeProvider.scaffoldPadding),
                  kAppSpacerVertical(height: 20),
                  widget.model.categories!.length > 12
                      ? SizedBox(
                          width: double.infinity,
                          height: 160,
                          child: ScrollConfiguration(
                            behavior: DiningCategoriesScrollBehavior(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                              child: GridView(
                                scrollDirection: Axis.horizontal,
                                physics: const PageScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 10.0, crossAxisSpacing: 2.0, crossAxisCount: 2, childAspectRatio: 1, mainAxisExtent: MediaQuery.of(context).size.width / 4),
                                children: widget.model.categories!
                                    .map(
                                      (e) => Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        child: DiningCategoriesBlock(name: e.name!, image: e.image!, slug: e.slug!, city: widget.model.city!.slug!),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: widget.model.categories!
                                  .map(
                                    (e) => Container(
                                      margin: const EdgeInsets.only(right: 10, bottom: 10),
                                      child: DiningCategoriesBlock(name: e.name!, image: e.image!, slug: e.slug!, city: widget.model.city!.slug!),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                ],
              )
            : const SizedBox(),
        widget.model.appSettings!.showPopularDiningRestaurant! && widget.model.popularDining!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppTitleDivider(context, translate.popular_dining_title, ThemeProvider.scaffoldPadding),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollPopularDining,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widget.model.popularDining!
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 240,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  child: e.isHidden! ? HorizontalDiningHideBlock(id: e.id!, name: e.name!) : HorizontalDiningBlock(model: e, collection: 'popularDining', isAuthorized: widget.isAuthorized),
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
                          decoration: const BoxDecoration(color: ThemeProvider.greyColorBorder, borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        ),
                        Positioned(
                          left: _scrollPopularDiningPercentage,
                          child: Container(
                            width: 20,
                            height: 4,
                            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        widget.model.appSettings!.showNewDiningRestaurant! && widget.model.newArrivals!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppSpacerVertical(height: 20),
                  kAppTitleDivider(context, '${translate.discover_dining_title} ${Environments.appName}', ThemeProvider.scaffoldPadding),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollNewDining,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widget.model.newArrivals!
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                height: 240,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  child: e.isHidden! ? HorizontalDiningHideBlock(id: e.id!, name: e.name!) : HorizontalDiningBlock(model: e, collection: 'newArrivals', isAuthorized: widget.isAuthorized),
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
                          decoration: const BoxDecoration(color: ThemeProvider.greyColorBorder, borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        ),
                        Positioned(
                          left: _scrollNewDiningPercentage,
                          child: Container(
                            width: 20,
                            height: 4,
                            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        kAppSpacerVertical(height: 20),
        widget.model.dinings!.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kAppTitleDivider(context, translate.dining_restaurant_title, ThemeProvider.scaffoldPadding),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widget.model.dinings!
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  child: e.isHidden! ? VerticalDiningHideBlock(id: e.id!, name: e.name!) : VerticalDiningBlock(model: e, collection: 'dinings', findMode: widget.model.findMode!, isAuthorized: widget.isAuthorized),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  kAppSpacerVertical(height: 20),
                  widget.isLoadMore ? kAppCenterCircularProgress(context) : const SizedBox(),
                  kAppSpacerVertical(height: 20),
                ],
              )
            : const SizedBox(),
      ],
    );
  }
}

class DiningCampaignBannerListWidget extends StatelessWidget {
  final List<DiningCampaignConfigModel> campaignList;
  const DiningCampaignBannerListWidget({super.key, required this.campaignList});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(autoPlay: true, viewportFraction: 1, aspectRatio: 4.0, enlargeCenterPage: false, height: 120.0, scrollDirection: Axis.horizontal),
      items: campaignList
          .map(
            (e) => GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.diningCampaignRoute, arguments: [e.id!]),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 120.0, imageUrl: e.image!),
              ),
            ),
          )
          .toList(),
    );
  }
}

class VerticalDiningBlock extends StatelessWidget {
  final DiningRestaurantsInfoConfigModel model;
  final String collection;
  final String findMode;
  final bool isAuthorized;
  const VerticalDiningBlock({super.key, required this.model, required this.collection, required this.findMode, required this.isAuthorized});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantDetailInfoRoute, arguments: [model.id!, model.name!, model.slug!, '']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150.0, imageUrl: model.cover!),
              ),
              model.promote!
                  ? Positioned(
                      left: 0,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: ThemeProvider.darkBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          translate.promo_lbl,
                          style: TextStyle(fontSize: 10, fontFamily: 'regular', color: ThemeProvider.whiteColor),
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
                          GestureDetector(
                            onTap: () => context.read<DiningBloc>().add(DiningHideEvent(id: model.id!)),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                              child: Icon(Icons.visibility_off_outlined, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                            ),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          GestureDetector(
                            onTap: () => context.read<DiningBloc>().add(DiningFavouriteEvent(id: model.id!, isFavourite: model.isFavourite!)),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                              child: Icon(model.isFavourite! ? Icons.favorite_rounded : Icons.favorite_outline_rounded, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
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
                    Expanded(child: Text(kAppTrimWord(model.name!, 45), style: kAppLblMediumFontBold(context))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: ThemeProvider.ratingBgColorLight, borderRadius: BorderRadius.circular(5.0)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('${model.rating}', style: const TextStyle(color: ThemeProvider.ratingTextColorLight)),
                          kAppSpacerHorizontal(width: 2),
                          Icon(Icons.star, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: ThemeProvider.ratingTextColorLight),
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
                    Expanded(
                      child: Text(kAppTrimWord(model.cuisineName!, 35), style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis),
                    ),
                    Text("${kAppPriceFormat(model.dishPriceForTwo!)} ${translate.for_two_lbl}", style: kAppLblTinyFontRegular(context)),
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
                        Image.asset(AssetsUrl.iconsURL.timeTag, height: 10, width: 10),
                        kAppSpacerHorizontal(width: 5),
                        Text(kAppDeliveryTimeName(context, model.approxDeliveryTime!), style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                    Text("${model.distance!} $findMode", style: kAppLblTinyFontRegular(context)),
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

class VerticalDiningHideBlock extends StatelessWidget {
  final String id;
  final String name;
  const VerticalDiningHideBlock({super.key, required this.id, required this.name});

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
              Text(translate.hidden_restaurant_title, style: kAppLblTinyFontRegular(context)),
              kAppSpacerVertical(height: 5),
              Text(kAppTrimWord(name, 35), style: kAppLblMediumFontBold(context)),
              kAppSpacerVertical(height: 5),
              Text(translate.hidden_restaurant_sub_title, style: kAppLblTinyFontRegular(context)),
              kAppSpacerVertical(height: 10),
              GestureDetector(
                onTap: () => context.read<DiningBloc>().add(DiningRemoveRestaurantFromListEvent(id: id)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                  ),
                  child: Text(translate.remove_now_btn, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => context.read<DiningBloc>().add(DiningUndoHideActionEvent(id: id)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_outlined, size: 10, color: Theme.of(context).canvasColor),
                        kAppSpacerHorizontal(width: 5),
                        Text(translate.undo_btn, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: GestureDetector(
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
                          child: HideRestaurantReasonModalScreen(restaurantId: id, restaurantName: name),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.new_releases_outlined, size: 10, color: Theme.of(context).scaffoldBackgroundColor),
                        kAppSpacerHorizontal(width: 5),
                        Text(translate.why_btn, style: kAppLblTinyRegularWhite(context)),
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

class HorizontalDiningBlock extends StatelessWidget {
  final DiningRestaurantsInfoConfigModel model;
  final String collection;
  final bool isAuthorized;
  const HorizontalDiningBlock({super.key, required this.model, required this.collection, required this.isAuthorized});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantDetailInfoRoute, arguments: [model.id!, model.name!, model.slug!, '']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            children: [
              CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.5, height: 100.0, imageUrl: model.cover!),
              isAuthorized
                  ? Positioned(
                      top: 5,
                      right: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => context.read<DiningBloc>().add(DiningHideEvent(id: model.id!)),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                              child: Icon(Icons.visibility_off_outlined, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                            ),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          GestureDetector(
                            onTap: () => context.read<DiningBloc>().add(DiningFavouriteEvent(id: model.id!, isFavourite: model.isFavourite!)),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                              child: Icon(model.isFavourite! ? Icons.favorite_rounded : Icons.favorite_outline_rounded, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
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
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: ThemeProvider.darkBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          translate.promo_lbl,
                          style: TextStyle(fontSize: 10, fontFamily: 'regular', color: ThemeProvider.whiteColor),
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
                Text(kAppTrimWord(model.name!, 20), style: kAppLblMediumFontBold(context)),
                kAppSpacerVertical(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(AssetsUrl.iconsURL.timeTag, height: 12, width: 12),
                    kAppSpacerHorizontal(width: 5),
                    Text(kAppDeliveryTimeName(context, model.approxDeliveryTime!), style: kAppLblSmallFontRegular(context)),
                  ],
                ),
                kAppSpacerVertical(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(AssetsUrl.iconsURL.priceTag, height: 12, width: 12),
                    kAppSpacerHorizontal(width: 5),
                    Text("${kAppPriceFormat(model.dishPriceForTwo!)} ${translate.for_two_lbl}", style: kAppLblSmallFontRegular(context)),
                  ],
                ),
                kAppSpacerVertical(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(AssetsUrl.iconsURL.starTag, height: 12, width: 12),
                    kAppSpacerHorizontal(width: 5),
                    Text(model.rating!, style: kAppLblSmallFontRegular(context)),
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

class HorizontalDiningHideBlock extends StatelessWidget {
  final String id;
  final String name;
  const HorizontalDiningHideBlock({super.key, required this.id, required this.name});

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
              Text(translate.hidden_restaurant_title, style: kAppLblTinyFontRegular(context)),
              kAppSpacerVertical(height: 5),
              Text(kAppTrimWord(name, 35), style: kAppLblMediumFontBold(context)),
              kAppSpacerVertical(height: 5),
              Text(translate.hidden_restaurant_sub_title, style: kAppLblTinyFontRegular(context)),
              kAppSpacerVertical(height: 10),
              GestureDetector(
                onTap: () => context.read<DiningBloc>().add(DiningRemoveRestaurantFromListEvent(id: id)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                  ),
                  child: Text(translate.remove_now_btn, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => context.read<DiningBloc>().add(DiningUndoHideActionEvent(id: id)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_outlined, size: 10, color: Theme.of(context).canvasColor),
                        kAppSpacerHorizontal(width: 5),
                        Text(translate.undo_btn, style: kAppLblTinyFontRegular(context)),
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
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                          heightFactor: 0.6,
                          child: HideRestaurantReasonModalScreen(restaurantId: id, restaurantName: name),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.new_releases_outlined, size: 10, color: Theme.of(context).scaffoldBackgroundColor),
                        kAppSpacerHorizontal(width: 5),
                        Text(translate.why_btn, style: kAppLblTinyRegularWhite(context)),
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

class DiningCategoriesBlock extends StatelessWidget {
  final String name;
  final String image;
  final String slug;
  final String city;
  const DiningCategoriesBlock({super.key, required this.name, required this.image, required this.slug, required this.city});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRouter.filterDiningWithCategoryRoute, arguments: [name, slug, city]),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 4, height: 80.0, imageUrl: image),
          ),
          Container(
            height: 30,
            width: MediaQuery.of(context).size.width / 4,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
              color: ThemeProvider.gradientBlackColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'regular', color: ThemeProvider.whiteColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DiningCategoriesScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}

class DiningLoadingView extends StatelessWidget {
  const DiningLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
        child: Column(
          children: [
            SkeletonLine(
              style: SkeletonLineStyle(height: 50, width: double.infinity, borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 20),
            SkeletonLine(
              style: SkeletonLineStyle(height: 150, width: double.infinity, borderRadius: BorderRadius.circular(8)),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(10, (index) {
                  return SkeletonAvatar(
                    style: SkeletonAvatarStyle(width: 70, height: 70, padding: const EdgeInsets.symmetric(horizontal: 5), borderRadius: BorderRadius.circular(8)),
                  );
                }),
              ),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(10, (index) {
                  return SkeletonAvatar(
                    style: SkeletonAvatarStyle(width: 280, height: 120, padding: const EdgeInsets.symmetric(horizontal: 5), borderRadius: BorderRadius.circular(8)),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            SkeletonLine(
              style: SkeletonLineStyle(height: 120, width: double.infinity, borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class DiningEmptyView extends StatelessWidget {
  const DiningEmptyView({super.key});

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
            Text(translate.dining_booking_error, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          ],
        ),
      ),
    );
  }
}
// Done //
