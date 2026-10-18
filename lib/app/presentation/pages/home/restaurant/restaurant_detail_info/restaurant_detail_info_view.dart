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
import 'package:url_launcher/url_launcher.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/restaurant_detail_information_response_model.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/pages/home/restaurant/restaurant_detail_info/bloc/restaurant_detail_info_bloc.dart';
import 'package:user/app/presentation/pages/modals/coupon_info_modal/coupon_info_modal_view.dart';
import 'package:user/app/presentation/pages/modals/dining_coupon_info_modal/dining_coupon_info_modal_view.dart';
import 'package:user/app/presentation/pages/modals/direct_restaurant_review_ratings_modal/direct_restaurant_review_ratings_modal_view.dart';
import 'package:user/app/presentation/pages/modals/image_gallery_modal/image_gallery_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class RestaurantDetailInfoScreen extends StatelessWidget {
  final String id;
  final String name;
  final String slug;
  final String campaignId;
  const RestaurantDetailInfoScreen({super.key, required this.id, required this.name, required this.slug, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    return RestaurantDetailInfoView(id: id, name: name, slug: slug, campaignId: campaignId);
  }
}

class RestaurantDetailInfoView extends StatefulWidget {
  final String id;
  final String name;
  final String slug;
  final String campaignId;
  const RestaurantDetailInfoView({super.key, required this.id, required this.name, required this.slug, required this.campaignId});

  @override
  State<RestaurantDetailInfoView> createState() => _RestaurantDetailInfoViewState();
}

class _RestaurantDetailInfoViewState extends State<RestaurantDetailInfoView> {
  @override
  void initState() {
    super.initState();
    context.read<RestaurantDetailInfoBloc>().add(RestaurantDetailInfoInitialEvent(id: widget.id, name: widget.name, slug: widget.slug, campaignId: widget.campaignId));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<RestaurantDetailInfoBloc, RestaurantDetailInfoState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isCallRequested ? true : false,
          child: Scaffold(
            body: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
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
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () => context.read<RestaurantDetailInfoBloc>().add(RestaurantDetailInfoFavouriteEvent()),
                                                icon: FaIcon(
                                                  state.model.details!.isFavourite! ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                                                  size: Theme.of(context).textTheme.labelLarge?.fontSize,
                                                  color: ThemeProvider.primaryColor,
                                                ),
                                              ),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () => context.read<RestaurantDetailInfoBloc>().add(RestaurantDetailInfoShareEvent()),
                                                icon: FaIcon(FontAwesomeIcons.arrowUpFromBracket, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                                              ),
                                            ],
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
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        ClipRRect(
                                          child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 250.0, imageUrl: state.model.details!.cover!),
                                        ),
                                        Positioned(
                                          left: 10,
                                          top: 50,
                                          width: MediaQuery.of(context).size.width / 1.06,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              GestureDetector(
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
                                                  GestureDetector(
                                                    onTap: () => context.read<RestaurantDetailInfoBloc>().add(RestaurantDetailInfoFavouriteEvent()),
                                                    child: Container(
                                                      height: 25,
                                                      width: 25,
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                                                      child: FaIcon(
                                                        state.model.details!.isFavourite! ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                                                        size: Theme.of(context).textTheme.labelLarge?.fontSize,
                                                        color: ThemeProvider.primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                  kAppSpacerHorizontal(width: 10),
                                                  GestureDetector(
                                                    onTap: () => context.read<RestaurantDetailInfoBloc>().add(RestaurantDetailInfoShareEvent()),
                                                    child: Container(
                                                      height: 25,
                                                      width: 25,
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                                                      child: FaIcon(FontAwesomeIcons.arrowUpFromBracket, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                                            color: ThemeProvider.gradientBlackColor,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                      child: CacheNetworkImageWidget(width: 60.0, height: 80.0, imageUrl: state.model.details!.logo!),
                                                    ),
                                                    kAppSpacerHorizontal(width: 10),
                                                    Flexible(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            kAppTrimWord(state.model.details!.name!, 30),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize, fontFamily: 'bold', color: ThemeProvider.whiteColor),
                                                          ),
                                                          kAppSpacerVertical(height: 2),
                                                          SizedBox(
                                                            width: MediaQuery.of(context).size.width / 1.7,
                                                            child: Text(
                                                              state.model.details!.address!,
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(fontSize: Theme.of(context).textTheme.labelSmall?.fontSize, fontFamily: 'regular', color: ThemeProvider.whiteColor),
                                                            ),
                                                          ),
                                                          kAppSpacerVertical(height: 2),
                                                          RichText(
                                                            text: TextSpan(
                                                              text:
                                                                  "${state.model.details!.distance!} ${state.model.findMode!} ${translate.away}  • ${state.model.details!.estimatedDeliveryTime!} ${translate.mins}  • ${kAppPriceFormat(state.model.details!.dishPriceForTwo!)} ${translate.for_two_lbl}",
                                                              style: TextStyle(fontSize: Theme.of(context).textTheme.labelSmall?.fontSize, fontFamily: 'regular', color: ThemeProvider.whiteColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: GestureDetector(
                                                  onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantReviewRoute, arguments: [state.model.details!.id!, state.model.details!.name!, state.model.details!.rating!]),
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    // height: 50,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          width: double.infinity,
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          decoration: const BoxDecoration(
                                                            color: ThemeProvider.primaryColor,
                                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                state.model.details!.rating!,
                                                                style: TextStyle(color: ThemeProvider.whiteColor, fontSize: Theme.of(context).textTheme.labelSmall?.fontSize, fontFamily: 'regular'),
                                                              ),
                                                              kAppSpacerHorizontal(width: 5),
                                                              const Icon(Icons.star, color: ThemeProvider.whiteColor, size: 12),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          width: double.infinity,
                                                          // height: 20,
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          decoration: const BoxDecoration(
                                                            color: ThemeProvider.whiteColor,
                                                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                "${state.model.details!.totalRating!} ${translate.reviews}",
                                                                style: TextStyle(color: ThemeProvider.darkBackgroundColor, fontSize: Theme.of(context).textTheme.labelSmall?.fontSize, fontFamily: 'regular'),
                                                              ),
                                                            ],
                                                          ),
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
                      const RestaurantDetailInfoLoadingView(),
                    ] else if (state.status.isFailure) ...[
                      RestaurantDetailInfoErrorView(name: state.name),
                    ] else ...[
                      RestaurantDetailInfoResponseView(model: state.model, dayNames: state.daysName, status: state.status, isAuthorized: state.isAuthorized),
                    ],
                  ]),
                ),
              ],
            ),
            bottomNavigationBar: state.status.isLoading || state.status.isFailure
                ? SafeArea(child: const SizedBox())
                : state.status.isSuccess || state.status.isCustomError || state.status.isFavAdd || state.status.isFavRemove || state.status.isCallRequested
                ? SafeArea(
                    child: SizedBox(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(context).pushNamed(AppRouter.restaurantPreBookingTableRoute, arguments: [state.model.details!.id!, state.model.details!.name!, state.model.details!.slug!]),
                                  style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50),
                                  child: Text(translate.book_table_title),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SafeArea(child: const SizedBox()),
          ),
        );
      },
    );
  }
}

class RestaurantDetailInfoResponseView extends StatefulWidget {
  final RestaurantDetailInformationResponseModel model;
  final List<String> dayNames;
  final RestaurantDetailInfoStatus status;
  final bool isAuthorized;
  const RestaurantDetailInfoResponseView({super.key, required this.model, required this.dayNames, required this.status, required this.isAuthorized});

  @override
  State<RestaurantDetailInfoResponseView> createState() => _RestaurantDetailInfoResponseViewState();
}

class _RestaurantDetailInfoResponseViewState extends State<RestaurantDetailInfoResponseView> {
  Future<void> followLink(String urlString) async {
    final Uri linkUrl = Uri.parse(urlString);
    if (!await launchUrl(linkUrl)) {
      throw Exception('Could not launch $linkUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.model.details!.preBooking!
                    ? Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantPreBookingTableRoute, arguments: [widget.model.details!.id!, widget.model.details!.name!, widget.model.details!.slug!]),
                          child: Container(
                            margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.food_bank_outlined, color: Theme.of(context).primaryColor, size: 15),
                                kAppSpacerHorizontal(width: 10),
                                Flexible(
                                  child: Text(translate.book_table_title, maxLines: 1, style: kAppLblSmallFontMedium(context, color: 'regular')),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.read<RestaurantDetailInfoBloc>().add(RestaurantDetailInfoDirectionEvent()),
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_outlined, color: Theme.of(context).primaryColor, size: 15),
                          kAppSpacerHorizontal(width: 10),
                          Text(translate.direction, style: kAppLblSmallFontMedium(context, color: 'regular')),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.read<RestaurantDetailInfoBloc>().add(RestaurantCallNumberEvent()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          widget.status.isCallRequested
                              ? SizedBox(height: 15.0, width: 15.0, child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 3))
                              : Icon(Icons.call_sharp, color: Theme.of(context).primaryColor, size: 15),
                          kAppSpacerHorizontal(width: 10),
                          Text(translate.call, style: kAppLblSmallFontMedium(context, color: 'regular')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          widget.model.diningCoupons!.isNotEmpty && widget.model.details!.preBooking!
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translate.pre_book_offers, style: kAppLblLargeFontBold(context)),
                    kAppSpacerVertical(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: CarouselSlider(
                        options: CarouselOptions(autoPlay: true, viewportFraction: 1, aspectRatio: 2.0, enlargeCenterPage: false, height: 50.0, scrollDirection: Axis.horizontal, autoPlayInterval: const Duration(seconds: 3)),
                        items: List.generate(
                          widget.model.diningCoupons!.length,
                          (couponIndex) => GestureDetector(
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
                                    child: DiningCouponInfoModalScreen(
                                      name: widget.model.diningCoupons![couponIndex].name!,
                                      allRestaurants: widget.model.diningCoupons![couponIndex].allRestaurants!,
                                      restaurant: widget.model.diningCoupons![couponIndex].restaurant!,
                                      allUsers: widget.model.diningCoupons![couponIndex].allUsers!,
                                      user: widget.model.diningCoupons![couponIndex].user!,
                                      code: widget.model.diningCoupons![couponIndex].code!,
                                      discountType: widget.model.diningCoupons![couponIndex].discountType!,
                                      id: widget.model.diningCoupons![couponIndex].id!,
                                      limitSameUser: widget.model.diningCoupons![couponIndex].limitSameUser!,
                                      maxDiscount: widget.model.diningCoupons![couponIndex].maxDiscount!,
                                      minDiscount: widget.model.diningCoupons![couponIndex].minDiscount!,
                                      preBookingChargeAmount: widget.model.diningCoupons![couponIndex].preBookingChargeAmount!,
                                      preBookingChargeRequired: widget.model.diningCoupons![couponIndex].preBookingChargeRequired!,
                                      availability: widget.model.diningCoupons![couponIndex].availability!,
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
                                        Image.asset(AssetsUrl.imageURL.couponDining, height: 30.0, width: 30.0),
                                        kAppSpacerHorizontal(width: 10),
                                        Flexible(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(kAppTrimWord(widget.model.diningCoupons![couponIndex].name!, 40), maxLines: 1, style: kAppLblMediumFontBold(context)),
                                              Text(
                                                "${translate.use_code} ${widget.model.diningCoupons![couponIndex].code!} | ${widget.model.diningCoupons![couponIndex].preBookingChargeRequired! ? translate.cover_charge : translate.no_cover_charge_required} ${widget.model.diningCoupons![couponIndex].preBookingChargeRequired! ? kAppPriceFormat(widget.model.diningCoupons![couponIndex].preBookingChargeAmount!) : ''}",
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
                                  Text("${couponIndex + 1}/${widget.model.diningCoupons!.length}", style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    kAppSpacerVertical(height: 10),
                  ],
                )
              : const SizedBox(),
          widget.model.orderCoupons!.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translate.walk_in_offers, style: kAppLblLargeFontBold(context)),
                    kAppSpacerVertical(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: CarouselSlider(
                        options: CarouselOptions(autoPlay: true, viewportFraction: 1, aspectRatio: 2.0, enlargeCenterPage: false, height: 50.0, scrollDirection: Axis.horizontal, autoPlayInterval: const Duration(seconds: 2)),
                        items: List.generate(
                          widget.model.orderCoupons!.length,
                          (couponIndex) => GestureDetector(
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
                                      name: widget.model.orderCoupons![couponIndex].name!,
                                      couponType: widget.model.orderCoupons![couponIndex].couponType!,
                                      allRestaurants: widget.model.orderCoupons![couponIndex].allRestaurants!,
                                      restaurant: widget.model.orderCoupons![couponIndex].restaurant!,
                                      allUsers: widget.model.orderCoupons![couponIndex].allUsers!,
                                      user: widget.model.orderCoupons![couponIndex].user!,
                                      code: widget.model.orderCoupons![couponIndex].code!,
                                      discountType: widget.model.orderCoupons![couponIndex].discountType!,
                                      id: widget.model.orderCoupons![couponIndex].id!,
                                      limitSameUser: widget.model.orderCoupons![couponIndex].limitSameUser!,
                                      loyalityPoints: widget.model.orderCoupons![couponIndex].loyalityPoints!,
                                      maxDiscount: widget.model.orderCoupons![couponIndex].maxDiscount!,
                                      minCartTotal: widget.model.orderCoupons![couponIndex].minCartTotal!,
                                      minDiscount: widget.model.orderCoupons![couponIndex].minDiscount!,
                                      promoLbl: widget.model.orderCoupons![couponIndex].promoLbl!,
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
                                        kAppCouponIcon(widget.model.orderCoupons![couponIndex].couponType!, 30, 30),
                                        kAppSpacerHorizontal(width: 10),
                                        Flexible(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(kAppTrimWord(widget.model.orderCoupons![couponIndex].promoLbl!, 40), maxLines: 1, style: kAppLblMediumFontBold(context)),
                                              Text(
                                                "${translate.use_code} ${widget.model.orderCoupons![couponIndex].code!} | ${translate.above} ${kAppPriceFormat(widget.model.orderCoupons![couponIndex].minCartTotal!)}",
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
                                  Text("${couponIndex + 1}/${widget.model.orderCoupons!.length}", style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    kAppSpacerVertical(height: 10),
                  ],
                )
              : const SizedBox(),
          widget.model.menuDetail!.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translate.menu, style: kAppLblLargeFontBold(context)),
                    kAppSpacerVertical(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(
                          widget.model.menuDetail!.length,
                          (menuIndex) => widget.model.menuDetail![menuIndex].photos!.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
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
                                        return FractionallySizedBox(
                                          child: ImageGalleryModalScreen(name: widget.model.menuDetail![menuIndex].name!, photos: widget.model.menuDetail![menuIndex].photos!),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: MediaQuery.of(context).size.width / 3.2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: widget.model.menuDetail![menuIndex].photos!.isNotEmpty
                                              ? CacheNetworkImageWidget(height: 150, width: MediaQuery.of(context).size.width / 3.2, imageUrl: widget.model.menuDetail![menuIndex].photos![0])
                                              : Image.asset(AssetsUrl.imageURL.placeholderImage, fit: BoxFit.cover, height: 150, width: MediaQuery.of(context).size.width / 3.2),
                                        ),
                                        kAppSpacerVertical(height: 5),
                                        Text("${widget.model.menuDetail![menuIndex].name!} (${widget.model.menuDetail![menuIndex].photos!.length} ${translate.pages})", style: kAppLblTinyFontRegular(context)),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ),
                    ),
                    kAppSpacerVertical(height: 10),
                  ],
                )
              : const SizedBox(),
          widget.model.diningPhotos!.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translate.photos, style: kAppLblLargeFontBold(context)),
                    kAppSpacerVertical(height: 10),
                    RestaurantDetailInfoPhotosView(photos: widget.model.diningPhotos!),
                    kAppSpacerVertical(height: 10),
                  ],
                )
              : const SizedBox(),
          widget.model.reviews!.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(translate.reviews, style: kAppLblLargeFontBold(context)),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantReviewRoute, arguments: [widget.model.details!.id!, widget.model.details!.name!, widget.model.details!.rating!]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                            ),
                            child: Text(translate.see_all_reviews, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                          ),
                        ),
                      ],
                    ),
                    kAppSpacerVertical(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: widget.model.reviews!
                            .map(
                              (e) => Container(
                                width: MediaQuery.of(context).size.width / 1.5,
                                height: 170,
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
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
                                                  child: CacheNetworkImageWidget(width: 30.0, height: 30.0, imageUrl: e.userInfo!.image!),
                                                ),
                                              ),
                                            ),
                                            kAppSpacerHorizontal(width: 10),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("${e.userInfo!.firstName!} ${e.userInfo!.lastName!}", style: kAppLblMediumFontBold(context)),
                                                Text(e.createdAt!, style: kAppLblTinyFontRegular(context)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(color: ThemeProvider.ratingBgColorLight, borderRadius: BorderRadius.circular(5.0)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text('${e.ratingCount}', style: const TextStyle(color: ThemeProvider.ratingTextColorLight)),
                                              kAppSpacerHorizontal(width: 2),
                                              Icon(Icons.star, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: ThemeProvider.ratingTextColorLight),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    kAppSpacerVertical(height: 10),
                                    Text(e.shortReview!, maxLines: 3, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontBold(context)),
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: e.images!.isNotEmpty ? 10 : 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (e.images!.length == 1) ...[
                                            ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                              child: CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: e.images![0]),
                                            ),
                                          ] else if (e.images!.length == 2) ...[
                                            ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                              child: CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: e.images![0]),
                                            ),
                                            kAppSpacerHorizontal(width: 10),
                                            ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                              child: CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: e.images![1]),
                                            ),
                                          ] else if (e.images!.length == 3) ...[
                                            ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                              child: CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: e.images![0]),
                                            ),
                                            kAppSpacerHorizontal(width: 10),
                                            ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                              child: CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: e.images![1]),
                                            ),
                                            kAppSpacerHorizontal(width: 10),
                                            ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                              child: CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: e.images![2]),
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
                    ),
                    kAppSpacerVertical(height: 10),
                  ],
                )
              : const SizedBox(),
          widget.isAuthorized
              ? GestureDetector(
                  onTap: () {
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
                        return FractionallySizedBox(child: DirectRestaurantReviewRatingsModalScreen(restaurant: widget.model.details!.id!));
                      },
                    );
                  },
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
                )
              : const SizedBox(),
          Text(translate.about_restaurant, style: kAppLblLargeFontBold(context)),
          kAppSpacerVertical(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.1,
            child: Text(widget.model.details!.shortDescription!, maxLines: 6, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kAppSpacerVertical(height: 10),
              Text(translate.cuisine, style: kAppLblMediumFontBold(context, color: 'regular')),
              kAppSpacerVertical(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.4,
                child: Text(widget.model.details!.cuisineName!, maxLines: 3, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kAppSpacerVertical(height: 10),
              Text(translate.type, style: kAppLblMediumFontBold(context, color: 'regular')),
              kAppSpacerVertical(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.4,
                child: Text(widget.model.details!.restaurantTypeName!, maxLines: 3, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kAppSpacerVertical(height: 10),
              Text(translate.average_cost, style: kAppLblMediumFontBold(context, color: 'regular')),
              kAppSpacerVertical(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.4,
                child: Text(kAppPriceFormat(widget.model.details!.dishPriceForTwo!), maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kAppSpacerVertical(height: 10),
              Text("${translate.joined_on} ${Environments.appName}", style: kAppLblMediumFontBold(context, color: 'regular')),
              kAppSpacerVertical(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.4,
                child: Text("${translate.since} ${widget.model.details!.createdAt!}", maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kAppSpacerVertical(height: 10),
              Text(translate.legal_name, style: kAppLblMediumFontBold(context, color: 'regular')),
              kAppSpacerVertical(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.4,
                child: Text("${widget.model.details!.owerInfo!.firstName!} ${widget.model.details!.owerInfo!.lastName!}", maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kAppSpacerVertical(height: 10),
              Text(widget.model.details!.license!.name!, style: kAppLblMediumFontBold(context, color: 'regular')),
              kAppSpacerVertical(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.4,
                child: Text(widget.model.details!.licenseId!, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
              ),
            ],
          ),
          widget.model.bestFoods!.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kAppSpacerVertical(height: 10),
                    Text(translate.trending_foods, style: kAppLblMediumFontBold(context, color: 'regular')),
                    kAppSpacerVertical(height: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          widget.model.bestFoods!.length,
                          (bestFoodIndex) => Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.star_border, color: Theme.of(context).primaryColor, size: Theme.of(context).textTheme.labelSmall?.fontSize),
                                kAppSpacerHorizontal(width: 5),
                                Text(widget.model.bestFoods![bestFoodIndex].name!, style: kAppLblTinyFontRegular(context)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          widget.model.details!.restaurantfacilities!.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kAppSpacerVertical(height: 10),
                    Text(translate.facilities_features, style: kAppLblMediumFontBold(context, color: 'regular')),
                    kAppSpacerVertical(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 80,
                      child: ScrollConfiguration(
                        behavior: RestaurantDetailInfoScrollBehavior(),
                        child: GridView(
                          scrollDirection: Axis.horizontal,
                          physics: const PageScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 10.0, crossAxisSpacing: 4.0, crossAxisCount: 3, childAspectRatio: 1, mainAxisExtent: MediaQuery.of(context).size.width / 2.3),
                          children: widget.model.details!.restaurantfacilities!
                              .map(
                                (e) => Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline, color: Theme.of(context).primaryColor, size: Theme.of(context).textTheme.labelSmall?.fontSize),
                                      kAppSpacerHorizontal(width: 5),
                                      Text(kAppTrimWord(e.name!, 20), style: kAppLblTinyFontRegular(context)),
                                    ],
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
          widget.model.details!.slots!.isNotEmpty && widget.model.details!.slots!.length == 7
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kAppSpacerVertical(height: 10),
                    Text(translate.opening_closing_time, style: kAppLblMediumFontBold(context, color: 'regular')),
                    kAppSpacerVertical(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        widget.model.details!.slots!.length,
                        (slotIndex) => Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.dayNames[slotIndex], style: kAppLblTinyFontRegular(context)),
                              widget.model.details!.slots![slotIndex].times!.isNotEmpty
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (widget.model.details!.slots![slotIndex].times!.length > 4) ...[
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: List.generate(
                                              !widget.model.details!.slots![slotIndex].isShowMore! ? 3 : widget.model.details!.slots![slotIndex].times!.length,
                                              (timeIndex) => Container(
                                                margin: const EdgeInsets.only(bottom: 2),
                                                child: Text(
                                                  '${widget.model.details!.slots![slotIndex].times![timeIndex].start!}-${widget.model.details!.slots![slotIndex].times![timeIndex].end!}',
                                                  style: kAppLblTinyFontRegular(context),
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => context.read<RestaurantDetailInfoBloc>().add(RestaurantShowMoreSlotEvent(slotIndex: slotIndex)),
                                            child: Text(!widget.model.details!.slots![slotIndex].isShowMore! ? translate.show_more : translate.show_less, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                          ),
                                        ] else ...[
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: List.generate(
                                              widget.model.details!.slots![slotIndex].times!.length,
                                              (timeIndex) => Container(
                                                margin: const EdgeInsets.only(bottom: 2),
                                                child: Text(
                                                  '${widget.model.details!.slots![slotIndex].times![timeIndex].start!}-${widget.model.details!.slots![slotIndex].times![timeIndex].end!}',
                                                  style: kAppLblTinyFontRegular(context),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    )
                                  : Text(translate.off_day, style: kAppLblTinyFontRegular(context)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          kAppSpacerVertical(height: 20),
          widget.model.details!.socialFacebook!.isNotEmpty &&
                  widget.model.details!.socialInstagram!.isNotEmpty &&
                  widget.model.details!.socialX!.isNotEmpty &&
                  widget.model.details!.socialYoutube!.isNotEmpty &&
                  widget.model.details!.socialLinkedIn!.isNotEmpty &&
                  widget.model.details!.socialPinterest!.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translate.follow_on_social_handle, style: kAppLblMediumFontBold(context, color: 'regular')),
                    kAppSpacerVertical(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        widget.model.details!.socialFacebook!.isNotEmpty
                            ? IconButton(onPressed: () => followLink(widget.model.details!.socialFacebook!), icon: Image.asset(AssetsUrl.imageURL.socialFacebook, height: 20, width: 20))
                            : const SizedBox(),
                        widget.model.details!.socialInstagram!.isNotEmpty
                            ? IconButton(onPressed: () => followLink(widget.model.details!.socialInstagram!), icon: Image.asset(AssetsUrl.imageURL.socialInstagram, height: 20, width: 20))
                            : const SizedBox(),
                        widget.model.details!.socialX!.isNotEmpty ? IconButton(onPressed: () => followLink(widget.model.details!.socialX!), icon: Image.asset(AssetsUrl.imageURL.socialX, height: 20, width: 20)) : const SizedBox(),
                        widget.model.details!.socialYoutube!.isNotEmpty
                            ? IconButton(onPressed: () => followLink(widget.model.details!.socialYoutube!), icon: Image.asset(AssetsUrl.imageURL.socialYoutube, height: 20, width: 20))
                            : const SizedBox(),
                        widget.model.details!.socialLinkedIn!.isNotEmpty
                            ? IconButton(onPressed: () => followLink(widget.model.details!.socialLinkedIn!), icon: Image.asset(AssetsUrl.imageURL.socialLinkedIn, height: 20, width: 20))
                            : const SizedBox(),
                        widget.model.details!.socialPinterest!.isNotEmpty
                            ? IconButton(onPressed: () => followLink(widget.model.details!.socialPinterest!), icon: Image.asset(AssetsUrl.imageURL.socialPinterest, height: 20, width: 20))
                            : const SizedBox(),
                      ],
                    ),
                  ],
                )
              : const SizedBox(),
          kAppSpacerVertical(height: 20),
        ],
      ),
    );
  }
}

class RestaurantDetailInfoLoadingView extends StatelessWidget {
  const RestaurantDetailInfoLoadingView({super.key});

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

class RestaurantDetailInfoErrorView extends StatelessWidget {
  final String name;
  const RestaurantDetailInfoErrorView({super.key, required this.name});

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
            Text("${translate.restaurant_detail_error_one} $name. ${translate.restaurant_no_food_two}", textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          ],
        ),
      ),
    );
  }
}

class RestaurantDetailInfoPhotosView extends StatelessWidget {
  final List<String> photos;
  const RestaurantDetailInfoPhotosView({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
            return FractionallySizedBox(
              child: ImageGalleryModalScreen(name: 'Photos', photos: photos),
            );
          },
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photos.length == 1) ...[
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 150.0, imageUrl: photos[0]),
            ),
          ] else if (photos.length == 2) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.3, height: 150.0, imageUrl: photos[0]),
                ),
                kAppSpacerHorizontal(width: 10),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.3, height: 150.0, imageUrl: photos[1]),
                ),
              ],
            ),
          ] else if (photos.length == 3) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.3, height: 150.0, imageUrl: photos[0]),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.3, height: 70.0, imageUrl: photos[1]),
                    ),
                    kAppSpacerVertical(height: 10),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.3, height: 70.0, imageUrl: photos[2]),
                    ),
                  ],
                ),
              ],
            ),
          ] else if (photos.length > 3) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.3, height: 150.0, imageUrl: photos[0]),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.3, height: 70.0, imageUrl: photos[1]),
                    ),
                    kAppSpacerVertical(height: 10),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width / 2.3, height: 70.0, imageUrl: photos[2]),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2.3,
                          height: 70.0,
                          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(5.0)), color: ThemeProvider.gradientBlackColor),
                          child: Center(
                            child: Text(
                              '+${photos.length}',
                              style: const TextStyle(fontFamily: 'regular', color: ThemeProvider.whiteColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class RestaurantDetailInfoScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}

