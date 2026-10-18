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
import 'package:user/app/core/models/dining_by_category_response_model.dart';
import 'package:user/app/presentation/pages/dining/filter_dining_with_category/bloc/filter_dining_with_category_bloc.dart';
import 'package:user/app/presentation/pages/modals/hide_restaurant_reason_modal/hide_restaurant_reason_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FilterDiningWithCategoryScreen extends StatelessWidget {
  final String name;
  final String slug;
  final String city;
  const FilterDiningWithCategoryScreen({super.key, required this.name, required this.slug, required this.city});

  @override
  Widget build(BuildContext context) {
    return FilterDiningWithCategoryView(name: name, slug: slug, city: city);
  }
}

class FilterDiningWithCategoryView extends StatefulWidget {
  final String name;
  final String slug;
  final String city;
  const FilterDiningWithCategoryView({super.key, required this.name, required this.slug, required this.city});

  @override
  State<FilterDiningWithCategoryView> createState() => _FilterDiningWithCategoryViewState();
}

class _FilterDiningWithCategoryViewState extends State<FilterDiningWithCategoryView> {
  final ScrollController _scrollDiningRestaurant = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<FilterDiningWithCategoryBloc>().add(FilterDiningWithCategoryInitialEvent(name: widget.name, slug: widget.slug, city: widget.city));
    _scrollDiningRestaurant.addListener(() {
      if (_scrollDiningRestaurant.position.pixels == _scrollDiningRestaurant.position.maxScrollExtent) {
        context.read<FilterDiningWithCategoryBloc>().add(FilterDiningWithCategoryLoadMoreEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FilterDiningWithCategoryBloc, FilterDiningWithCategoryState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(state.name), scrolledUnderElevation: 0),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            controller: _scrollDiningRestaurant,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const FilterDiningWithCategoryLoadingView(),
                ] else if (state.status.isEmpty || state.status.isFailure) ...[
                  FilterDiningWithCategoryEmptyView(name: state.name),
                ] else ...[
                  kAppSpacerVertical(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: state.model.restaurants!
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
                              child: e.isHidden!
                                  ? FilterDiningWithCategoryVerticalHideBlock(id: e.id!, name: e.name!)
                                  : FilterDiningWithCategoryVerticalBlock(model: e, findMode: state.model.findMode!, isAuthorized: state.isAuthorized),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  kAppSpacerVertical(height: 20),
                  state.loadMore ? kAppCenterCircularProgress(context) : const SizedBox(),
                  kAppSpacerVertical(height: 20),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class FilterDiningWithCategoryLoadingView extends StatelessWidget {
  const FilterDiningWithCategoryLoadingView({super.key});

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

class FilterDiningWithCategoryEmptyView extends StatelessWidget {
  final String name;
  const FilterDiningWithCategoryEmptyView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text("${translate.dining_booking_category_error_one} $name. ${translate.dining_booking_category_error_two}", textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class FilterDiningWithCategoryVerticalBlock extends StatelessWidget {
  final DiningByCategoryRestaurantConfigModel model;
  final String findMode;
  final bool isAuthorized;
  const FilterDiningWithCategoryVerticalBlock({super.key, required this.model, required this.findMode, required this.isAuthorized});

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
                            onTap: () => context.read<FilterDiningWithCategoryBloc>().add(FilterDiningWithCategoryHideEvent(id: model.id!)),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                              child: Icon(Icons.visibility_off_outlined, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                            ),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          GestureDetector(
                            onTap: () => context.read<FilterDiningWithCategoryBloc>().add(FilterDiningWithCategoryFavouriteEvent(id: model.id!, isFavourite: model.isFavourite!)),
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

class FilterDiningWithCategoryVerticalHideBlock extends StatelessWidget {
  final String id;
  final String name;
  const FilterDiningWithCategoryVerticalHideBlock({super.key, required this.id, required this.name});

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
                onTap: () => context.read<FilterDiningWithCategoryBloc>().add(FilterDiningWithCategoryRemoveRestaurantEvent(id: id)),
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
                  onTap: () => context.read<FilterDiningWithCategoryBloc>().add(FilterDiningWithCategoryUndoHideActionEvent(id: id)),
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
// Done //
