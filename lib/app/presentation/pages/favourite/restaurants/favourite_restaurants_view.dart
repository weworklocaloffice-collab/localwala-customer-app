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
import 'package:user/app/presentation/pages/dining/@core/bloc/dining_bloc.dart';
import 'package:user/app/presentation/pages/dining/dining_campaigns/bloc/dining_campaign_bloc.dart';
import 'package:user/app/presentation/pages/dining/filter_dining_with_category/bloc/filter_dining_with_category_bloc.dart';
import 'package:user/app/presentation/pages/favourite/restaurants/bloc/favourite_restaurants_bloc.dart';
import 'package:user/app/core/models/favourite_restaurants_model.dart';
import 'package:user/app/presentation/pages/home/@core/bloc/home_bloc.dart';
import 'package:user/app/presentation/pages/home/campaign/restaurant_campaign/bloc/restaurant_campaign_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/@core/bloc/restaurant_bloc.dart';
import 'package:user/app/presentation/pages/home/restaurant/restaurant_detail_info/bloc/restaurant_detail_info_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/brands/bloc/restaurants_by_brands_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/categories/filter_restaurants/bloc/filter_restaurants_by_categories_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/cuisine/bloc/restaurants_by_cuisine_bloc.dart';
import 'package:user/app/presentation/pages/modals/restaurants_by_localities_modal/bloc/restaurants_by_localities_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/loader_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FavouriteRestaurantScreen extends StatelessWidget {
  const FavouriteRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status.isRestaurantFav) {
              context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsSilenceEvent());
            }
          },
        ),
        BlocListener<DiningBloc, DiningState>(
          listener: (context, state) {
            if (state.status.isRestaurantFav) {
              context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsSilenceEvent());
            }
          },
        ),
        BlocListener<RestaurantCampaignBloc, RestaurantCampaignState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsSilenceEvent());
            }
          },
        ),
        BlocListener<DiningCampaignBloc, DiningCampaignState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsSilenceEvent());
            }
          },
        ),
        BlocListener<FilterDiningWithCategoryBloc, FilterDiningWithCategoryState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsSilenceEvent());
            }
          },
        ),
        BlocListener<FilterRestaurantsByCategoriesBloc, FilterRestaurantsByCategoriesState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsSilenceEvent());
            }
          },
        ),
        BlocListener<RestaurantBloc, RestaurantState>(
          listener: (context, state) {
            if (state.status.isFavAdd || state.status.isFavRemove) {
              context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsSilenceEvent());
            }
          },
        ),
        BlocListener<RestaurantDetailInfoBloc, RestaurantDetailInfoState>(
          listener: (context, state) {
            if (state.status.isFavAdd || state.status.isFavRemove) {
              context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsSilenceEvent());
            }
          },
        ),
        BlocListener<RestaurantsByCuisineBloc, RestaurantsByCuisineState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsSilenceEvent());
            }
          },
        ),
        BlocListener<RestaurantsByBrandsBloc, RestaurantsByBrandsState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsSilenceEvent());
            }
          },
        ),
        BlocListener<RestaurantsByLocalitiesBloc, RestaurantsByLocalitiesState>(
          listener: (context, state) {
            if (state.status.isFavUpdate) {
              context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsSilenceEvent());
            }
          },
        ),
      ],
      child: const FavouriteRestaurantsView(),
    );
  }
}

class FavouriteRestaurantsView extends StatefulWidget {
  const FavouriteRestaurantsView({super.key});

  @override
  State<FavouriteRestaurantsView> createState() => _FavouriteRestaurantsViewState();
}

class _FavouriteRestaurantsViewState extends State<FavouriteRestaurantsView> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollRestaurants = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsInitialEvent());
    _scrollRestaurants.addListener(() {
      if (_scrollRestaurants.position.pixels == _scrollRestaurants.position.maxScrollExtent) {
        context.read<FavouriteRestaurantsBloc>().add(FavouriteRestaurantsLoadMoreEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<FavouriteRestaurantsBloc, FavouriteRestaurantsState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isRemoveFavStart) {
          LoaderService.showLoader(context, msg: translate.please_wait);
        } else if (state.status.isRemoveFavDone) {
          LoaderService.hideLoder(context);
          showSuccessDialog(context, translate.removed_from_list);
        } else if (state.status.isRemoveFavFailed) {
          LoaderService.hideLoder(context);
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollRestaurants,
          child: Padding(
            padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const FavouriteRestaurantsLoadingView(),
                ] else if (state.status.isUnAuthorized) ...[
                  const UnauthorizedWidget(),
                ] else if (state.status.isFailure) ...[
                  const FavouriteRestaurantsErroView(),
                ] else if (state.status.isEmpty) ...[
                  const FavouriteRestaurantsEmptyView(),
                ] else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: state.restaurants.restaurants!
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
                              child: VerticalRestaurantBlock(model: e, findMode: state.restaurants.findMode!),
                            ),
                          ),
                        )
                        .toList(),
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

class FavouriteRestaurantsLoadingView extends StatelessWidget {
  const FavouriteRestaurantsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        10,
        (index) => Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: SkeletonLine(
            style: SkeletonLineStyle(height: 120, width: double.infinity, borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}

class FavouriteRestaurantsErroView extends StatelessWidget {
  const FavouriteRestaurantsErroView({super.key});

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
            child: Text(translate.okay_i_understand),
          ),
        ],
      ),
    );
  }
}

class FavouriteRestaurantsEmptyView extends StatelessWidget {
  const FavouriteRestaurantsEmptyView({super.key});

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

class VerticalRestaurantBlock extends StatelessWidget {
  final RestaurantsModel model;
  final String findMode;
  const VerticalRestaurantBlock({super.key, required this.model, required this.findMode});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantRoute, arguments: [model.id, model.slug, model.name]),
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
              Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: () => context.read<FavouriteRestaurantsBloc>()..add(FavouriteDeleteRestaurantEvent(restaurantId: model.id!)),
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                    child: Icon(Icons.favorite_rounded, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                  ),
                ),
              ),
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
                    Text(kAppTrimWord(model.cuisineName!, 35), style: kAppLblTinyFontRegular(context)),
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
// Done //
