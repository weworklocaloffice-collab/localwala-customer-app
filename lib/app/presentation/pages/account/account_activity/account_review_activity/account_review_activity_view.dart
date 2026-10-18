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
import 'package:user/app/core/models/my_review_list_activity_model.dart';
import 'package:user/app/presentation/pages/account/account_activity/account_review_activity/bloc/account_review_activity_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AccountReviewActivityScreen extends StatelessWidget {
  const AccountReviewActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => AccountReviewActivityBloc()..add(AccountReviewActivityInitialEvent()), child: const AccountReviewActivityView());
  }
}

class AccountReviewActivityView extends StatefulWidget {
  const AccountReviewActivityView({super.key});

  @override
  State<AccountReviewActivityView> createState() => _AccountReviewActivityViewState();
}

class _AccountReviewActivityViewState extends State<AccountReviewActivityView> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    super.build(context);
    return BlocConsumer<AccountReviewActivityBloc, AccountReviewActivityState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.status.isLoading) ...[
                const AccountReviewActivityLoadingView(),
              ] else if (state.status.isEmpty) ...[
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(AppRouter.searchRestaurantActivitySectionRoute),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_square, color: Theme.of(context).primaryColor, size: 15),
                            kAppSpacerHorizontal(width: 10),
                            Text(translate.leave_review, style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: 15),
                      ],
                    ),
                  ),
                ),
                const AccountReviewActivityEmptyView(),
              ] else if (state.status.isFailure) ...[
                const AccountReviewActivityErrorView(),
              ] else ...[
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(AppRouter.searchRestaurantActivitySectionRoute),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_square, color: Theme.of(context).primaryColor, size: 15),
                            kAppSpacerHorizontal(width: 10),
                            Text(translate.leave_review, style: kAppLblMediumFontSemiBold(context, color: 'regular')),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: 15),
                      ],
                    ),
                  ),
                ),
                state.model.restaurantReviews!.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => context.read<AccountReviewActivityBloc>().add(AccountReviewActivityRestaurantReviewToggleViewEvent()),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("${translate.restaurant_reviews} (${state.model.restaurantReviews!.length})", style: kAppLblSemiBoldFontLarge(context)),
                                    Icon(state.isRestaurantReviewOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 18, color: Theme.of(context).canvasColor),
                                  ],
                                ),
                              ),
                            ),
                            state.isRestaurantReviewOpen
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(state.model.restaurantReviews!.length, (restaurantIndex) => AccountReviewActivityRestaurantWidgetView(model: state.model.restaurantReviews![restaurantIndex])),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      )
                    : const SizedBox(),
                state.model.foodReviews!.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => context.read<AccountReviewActivityBloc>().add(AccountReviewActivityFoodReviewToggleViewEvent()),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("${translate.food_reviews} (${state.model.foodReviews!.length})", style: kAppLblSemiBoldFontLarge(context)),
                                    Icon(state.isFoodReviewOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 18, color: Theme.of(context).canvasColor),
                                  ],
                                ),
                              ),
                            ),
                            state.isFoodReviewOpen
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(state.model.foodReviews!.length, (restaurantIndex) => AccountReviewActivityFoodWidgetView(model: state.model.foodReviews![restaurantIndex])),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      )
                    : const SizedBox(),
                state.model.driverReviews!.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => context.read<AccountReviewActivityBloc>().add(AccountReviewActivityDriverReviewToggleViewEvent()),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("${translate.deliveryman_reviews} (${state.model.driverReviews!.length})", style: kAppLblSemiBoldFontLarge(context)),
                                    Icon(state.isDriverReviewOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 18, color: Theme.of(context).canvasColor),
                                  ],
                                ),
                              ),
                            ),
                            state.isDriverReviewOpen
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(state.model.driverReviews!.length, (restaurantIndex) => AccountReviewActivityDriverWidgetView(model: state.model.driverReviews![restaurantIndex])),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      )
                    : const SizedBox(),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AccountReviewActivityLoadingView extends StatelessWidget {
  const AccountReviewActivityLoadingView({super.key});

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

class AccountReviewActivityEmptyView extends StatelessWidget {
  const AccountReviewActivityEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.no_reviews, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class AccountReviewActivityErrorView extends StatelessWidget {
  const AccountReviewActivityErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.no_review_found, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class AccountReviewActivityRestaurantWidgetView extends StatelessWidget {
  final RestaurantReviewConfigModel model;
  const AccountReviewActivityRestaurantWidgetView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1.5, color: ThemeProvider.lightDisabledColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircleAvatar(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CacheNetworkImageWidget(width: 50.0, height: 50.0, imageUrl: model.restaurants!.cover!),
                        ),
                      ),
                    ),
                    kAppSpacerHorizontal(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.restaurants!.name!, style: kAppLblMediumFontBold(context)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.1,
                          child: Text(model.restaurants!.address!, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                        ),
                        Text(model.createdAt!, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: ThemeProvider.ratingBgColorLight, borderRadius: BorderRadius.circular(5.0)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('${model.ratingCount}', style: const TextStyle(color: ThemeProvider.ratingTextColorLight)),
                          kAppSpacerHorizontal(width: 2),
                          Icon(Icons.star, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: ThemeProvider.ratingTextColorLight),
                        ],
                      ),
                    ),
                    model.orders!.isNotEmpty ? Icon(Icons.check_circle, size: 14, color: Theme.of(context).canvasColor) : const SizedBox(),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: model.shortReview!.isNotEmpty ? 5 : 0),
            padding: EdgeInsets.symmetric(vertical: model.shortReview!.isNotEmpty ? 5 : 0),
            child: Text(model.shortReview!, style: kAppLblTinyFontBold(context)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: model.hashtags!
                .map(
                  (hastags) => Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(hastags.name!, maxLines: 2, style: kAppLblTinyFontBold(context)),
                  ),
                )
                .toList(),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: model.images!.isNotEmpty ? 5 : 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (model.images!.length == 1) ...[
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150.0, imageUrl: model.images![0]),
                  ),
                ] else if (model.images!.length == 2) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.4, height: 150.0, imageUrl: model.images![0]),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.4, height: 150.0, imageUrl: model.images![1]),
                      ),
                    ],
                  ),
                ] else if (model.images!.length == 3) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.2, height: 150.0, imageUrl: model.images![0]),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.6, height: 70.0, imageUrl: model.images![1]),
                          ),
                          kAppSpacerVertical(height: 10),
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.6, height: 70.0, imageUrl: model.images![2]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountReviewActivityFoodWidgetView extends StatelessWidget {
  final FoodReviewConfigModel model;
  const AccountReviewActivityFoodWidgetView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1.5, color: ThemeProvider.lightDisabledColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: CircleAvatar(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CacheNetworkImageWidget(width: 30.0, height: 30.0, imageUrl: model.foods!.image!),
                        ),
                      ),
                    ),
                    kAppSpacerHorizontal(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.foods!.name!, style: kAppLblMediumFontBold(context)),
                        Text(model.createdAt!, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: ThemeProvider.ratingBgColorLight, borderRadius: BorderRadius.circular(5.0)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('${model.ratingCount}', style: const TextStyle(color: ThemeProvider.ratingTextColorLight)),
                          kAppSpacerHorizontal(width: 2),
                          Icon(Icons.star, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: ThemeProvider.ratingTextColorLight),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, size: 14, color: Theme.of(context).canvasColor),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: model.shortReview!.isNotEmpty ? 5 : 0),
            padding: EdgeInsets.symmetric(vertical: model.shortReview!.isNotEmpty ? 5 : 0),
            child: Text(model.shortReview!, style: kAppLblTinyFontBold(context)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: model.hashtags!
                .map(
                  (hastags) => Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(hastags.name!, maxLines: 2, style: kAppLblTinyFontBold(context)),
                  ),
                )
                .toList(),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: model.images!.isNotEmpty ? 5 : 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (model.images!.length == 1) ...[
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150.0, imageUrl: model.images![0]),
                  ),
                ] else if (model.images!.length == 2) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.4, height: 150.0, imageUrl: model.images![0]),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.4, height: 150.0, imageUrl: model.images![1]),
                      ),
                    ],
                  ),
                ] else if (model.images!.length == 3) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.2, height: 150.0, imageUrl: model.images![0]),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.6, height: 70.0, imageUrl: model.images![1]),
                          ),
                          kAppSpacerVertical(height: 10),
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.6, height: 70.0, imageUrl: model.images![2]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountReviewActivityDriverWidgetView extends StatelessWidget {
  final DriverReviewConfigModel model;
  const AccountReviewActivityDriverWidgetView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1.5, color: ThemeProvider.lightDisabledColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: CircleAvatar(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CacheNetworkImageWidget(width: 30.0, height: 30.0, imageUrl: model.driverInfo!.image!),
                        ),
                      ),
                    ),
                    kAppSpacerHorizontal(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${model.driverInfo!.firstName!} ${model.driverInfo!.lastName!}", style: kAppLblMediumFontBold(context)),
                        Text(model.createdAt!, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: ThemeProvider.ratingBgColorLight, borderRadius: BorderRadius.circular(5.0)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('${model.ratingCount}', style: const TextStyle(color: ThemeProvider.ratingTextColorLight)),
                          kAppSpacerHorizontal(width: 2),
                          Icon(Icons.star, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: ThemeProvider.ratingTextColorLight),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, size: 14, color: Theme.of(context).canvasColor),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: model.shortReview!.isNotEmpty ? 5 : 0),
            padding: EdgeInsets.symmetric(vertical: model.shortReview!.isNotEmpty ? 5 : 0),
            child: Text(model.shortReview!, style: kAppLblTinyFontBold(context)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: model.hashtags!
                .map(
                  (hastags) => Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(hastags.name!, maxLines: 2, style: kAppLblTinyFontBold(context)),
                  ),
                )
                .toList(),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: model.images!.isNotEmpty ? 5 : 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (model.images!.length == 1) ...[
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150.0, imageUrl: model.images![0]),
                  ),
                ] else if (model.images!.length == 2) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.4, height: 150.0, imageUrl: model.images![0]),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.4, height: 150.0, imageUrl: model.images![1]),
                      ),
                    ],
                  ),
                ] else if (model.images!.length == 3) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.2, height: 150.0, imageUrl: model.images![0]),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.6, height: 70.0, imageUrl: model.images![1]),
                          ),
                          kAppSpacerVertical(height: 10),
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.6, height: 70.0, imageUrl: model.images![2]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Done //
