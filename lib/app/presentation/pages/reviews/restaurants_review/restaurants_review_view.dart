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
import 'package:user/app/presentation/pages/reviews/restaurants_review/bloc/restaurants_review_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class RestaurantsReviewScreen extends StatelessWidget {
  final String id;
  final String name;
  final String ratings;
  const RestaurantsReviewScreen({super.key, required this.id, required this.name, required this.ratings});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RestaurantsReviewBloc()..add(RestaurantsReviewInitialEvent(id: id, name: name, ratings: ratings)),
      child: const RestaurantsReviewView(),
    );
  }
}

class RestaurantsReviewView extends StatefulWidget {
  const RestaurantsReviewView({super.key});

  @override
  State<RestaurantsReviewView> createState() => _RestaurantsReviewViewState();
}

class _RestaurantsReviewViewState extends State<RestaurantsReviewView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        context.read<RestaurantsReviewBloc>().add(RestaurantsReviewLoadMoreEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<RestaurantsReviewBloc, RestaurantsReviewState>(
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
            controller: _scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const RestaurantsReviewLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const RestaurantReviewErrorView(),
                ] else if (state.status.isEmpty) ...[
                  const RestaurantReviewEmptyView(),
                ] else ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: ThemeProvider.ratingBgColorLight, borderRadius: BorderRadius.circular(5.0)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(state.ratings, style: const TextStyle(color: ThemeProvider.ratingTextColorLight)),
                                  kAppSpacerHorizontal(width: 2),
                                  Icon(Icons.star, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: ThemeProvider.ratingTextColorLight),
                                ],
                              ),
                            ),
                            Text("${translate.total} ${state.detail.totalResults!} ${translate.ratings}", style: kAppLblMediumFontBold(context)),
                          ],
                        ),
                      ),
                      if (state.detail.percentages!.isNotEmpty) ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: state.detail.percentages!
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: LinearProgressIndicator(
                                          value: item.percentage! / 100,
                                          backgroundColor: ThemeProvider.greyColorBorder,
                                          color: Theme.of(context).primaryColor,
                                          minHeight: 10,
                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(color: ThemeProvider.ratingBgColorLight, borderRadius: BorderRadius.circular(5.0)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text('${item.star}', style: const TextStyle(color: ThemeProvider.ratingTextColorLight)),
                                                  kAppSpacerHorizontal(width: 2),
                                                  Icon(Icons.star, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: ThemeProvider.ratingTextColorLight),
                                                ],
                                              ),
                                            ),
                                            kAppSpacerHorizontal(width: 5),
                                            Text("${item.count}/${state.detail.totalResultString!}", style: kAppLblTinyFontRegular(context)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      kAppSpacerVertical(height: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: state.detail.reviews!
                            .map(
                              (item) => Container(
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
                                                    child: CacheNetworkImageWidget(width: 30.0, height: 30.0, imageUrl: item.userInfo!.image!),
                                                  ),
                                                ),
                                              ),
                                              kAppSpacerHorizontal(width: 10),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("${item.userInfo!.firstName!} ${item.userInfo!.lastName!}", style: kAppLblMediumFontBold(context)),
                                                  Text(item.createdAt!, style: kAppLblTinyFontRegular(context)),
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
                                                    Text('${item.ratingCount}', style: const TextStyle(color: ThemeProvider.ratingTextColorLight)),
                                                    kAppSpacerHorizontal(width: 2),
                                                    Icon(Icons.star, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: ThemeProvider.ratingTextColorLight),
                                                  ],
                                                ),
                                              ),
                                              item.orders!.isNotEmpty ? Icon(Icons.check_circle, size: 14, color: Theme.of(context).canvasColor) : const SizedBox(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: item.shortReview!.isNotEmpty ? 5 : 0),
                                      padding: EdgeInsets.symmetric(vertical: item.shortReview!.isNotEmpty ? 5 : 0),
                                      child: Text(item.shortReview!, style: kAppLblTinyFontBold(context)),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: item.hashtags!
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
                                      margin: EdgeInsets.symmetric(vertical: item.images!.isNotEmpty ? 5 : 0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (item.images!.length == 1) ...[
                                            ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                              child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150.0, imageUrl: item.images![0]),
                                            ),
                                          ] else if (item.images!.length == 2) ...[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                  child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.4, height: 150.0, imageUrl: item.images![0]),
                                                ),
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                  child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.4, height: 150.0, imageUrl: item.images![1]),
                                                ),
                                              ],
                                            ),
                                          ] else if (item.images!.length == 3) ...[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                  child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.2, height: 150.0, imageUrl: item.images![0]),
                                                ),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                      child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.6, height: 70.0, imageUrl: item.images![1]),
                                                    ),
                                                    kAppSpacerVertical(height: 10),
                                                    ClipRRect(
                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                      child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.6, height: 70.0, imageUrl: item.images![2]),
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
                              ),
                            )
                            .toList(),
                      ),
                      kAppSpacerVertical(height: 20),
                      state.loadMore ? kAppCenterCircularProgress(context) : const SizedBox(),
                      kAppSpacerVertical(height: 20),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class RestaurantsReviewLoadingView extends StatelessWidget {
  const RestaurantsReviewLoadingView({super.key});

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

class RestaurantReviewEmptyView extends StatelessWidget {
  const RestaurantReviewEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.cartEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.no_review_found_title, textAlign: TextAlign.center, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.no_review_found_sub_title, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class RestaurantReviewErrorView extends StatelessWidget {
  const RestaurantReviewErrorView({super.key});

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
