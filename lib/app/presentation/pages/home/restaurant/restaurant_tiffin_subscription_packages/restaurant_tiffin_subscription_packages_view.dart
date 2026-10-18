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
import 'package:user/app/core/models/tiffin_subscription_list_from_restaurant_response_model.dart';
import 'package:user/app/presentation/pages/home/restaurant/restaurant_tiffin_subscription_packages/bloc/restaurant_tiffin_subscription_packages_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class RestaurantTiffinSubscriptionPackageScreen extends StatelessWidget {
  final String restaurant;
  final String restaurantName;
  const RestaurantTiffinSubscriptionPackageScreen({super.key, required this.restaurant, required this.restaurantName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RestaurantTiffinSubscriptionPackagesBloc()..add(RestaurantTiffinSubscriptionPackagesInitialEvent(restaurant: restaurant, restaurantName: restaurantName)),
      child: const RestaurantTiffinSubscriptionPackagesView(),
    );
  }
}

class RestaurantTiffinSubscriptionPackagesView extends StatefulWidget {
  const RestaurantTiffinSubscriptionPackagesView({super.key});

  @override
  State<RestaurantTiffinSubscriptionPackagesView> createState() => _RestaurantTiffinSubscriptionPackagesViewState();
}

class _RestaurantTiffinSubscriptionPackagesViewState extends State<RestaurantTiffinSubscriptionPackagesView> {
  final ScrollController _scrollMoreSubscription = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollMoreSubscription.addListener(() {
      if (_scrollMoreSubscription.position.pixels == _scrollMoreSubscription.position.maxScrollExtent) {
        context.read<RestaurantTiffinSubscriptionPackagesBloc>().add(RestaurantTiffinSubscriptionPackagesLoadMoreEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<RestaurantTiffinSubscriptionPackagesBloc, RestaurantTiffinSubscriptionPackagesState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.tiffin_subscription_packages), scrolledUnderElevation: 0),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: _scrollMoreSubscription,
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const RestaurantTiffinSubscriptionPackagesLoadingView(),
                ] else if (state.status.isEmpty) ...[
                  const RestaurantTiffinSubscriptionPackagesEmptyView(),
                ] else if (state.status.isFailure) ...[
                  const RestaurantTiffinSubscriptionPackagesErrorView(),
                ] else ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(state.list.results!.length, (packageIndex) => RestaurantTiffinSubscriptionPackagesInfoTile(model: state.list.results![packageIndex])),
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

class RestaurantTiffinSubscriptionPackagesInfoTile extends StatelessWidget {
  final TiffinSubscriptionInfoConfigModel model;
  const RestaurantTiffinSubscriptionPackagesInfoTile({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRouter.foodSubscriptionInfoRoute, arguments: [model.id!, model.name!]),
      child: Container(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kAppTrimWord(model.name!, 50), style: kAppLblMediumFontBold(context)),
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
                  Text(
                    "${kSubscriptionPackageDays(model.interval!)} ${translate.days} & ${model.orderTo! == 'homedelivery' ? translate.home_delivery : translate.take_away} ${translate.only}",
                    style: kAppLblTinyFontRegular(context),
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
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CacheNetworkImageWidget(width: double.infinity, height: 100.0, imageUrl: model.image!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantTiffinSubscriptionPackagesLoadingView extends StatelessWidget {
  const RestaurantTiffinSubscriptionPackagesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class RestaurantTiffinSubscriptionPackagesEmptyView extends StatelessWidget {
  const RestaurantTiffinSubscriptionPackagesEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.cartEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.matching_record_not_found, textAlign: TextAlign.center, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.no_data_reason_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class RestaurantTiffinSubscriptionPackagesErrorView extends StatelessWidget {
  const RestaurantTiffinSubscriptionPackagesErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.empty_data_two, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}
// Done //
