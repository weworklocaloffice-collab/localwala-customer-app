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
import 'package:user/app/core/models/restaurant_campaign_detail_model.dart';
import 'package:user/app/presentation/pages/home/campaign/restaurant_campaign/bloc/restaurant_campaign_bloc.dart';
import 'package:user/app/presentation/pages/modals/hide_restaurant_reason_modal/hide_restaurant_reason_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class RestaurantCampaignScreen extends StatelessWidget {
  final String id;
  const RestaurantCampaignScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return RestaurantCampaignView(id: id);
  }
}

class RestaurantCampaignView extends StatefulWidget {
  final String id;
  const RestaurantCampaignView({super.key, required this.id});

  @override
  State<RestaurantCampaignView> createState() => _RestaurantCampaignViewState();
}

class _RestaurantCampaignViewState extends State<RestaurantCampaignView> {
  @override
  void initState() {
    super.initState();
    context.read<RestaurantCampaignBloc>().add(RestaurantCampaignInitialEvent(id: widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RestaurantCampaignBloc, RestaurantCampaignState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return state.status.isLoading
            ? const RestaurantCampaignLoadingView()
            : state.status.isFailure
            ? const RestaurantCampaignErrorView()
            : RestaurantCampaignResponseView(data: state.campaign, isAuthorized: state.isAuthorized);
      },
    );
  }
}

class RestaurantCampaignLoadingView extends StatelessWidget {
  const RestaurantCampaignLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, scrolledUnderElevation: 0),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
          child: Column(
            children: [
              SkeletonLine(
                style: SkeletonLineStyle(height: 120, width: double.infinity, borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(height: 20),
              SkeletonLine(
                style: SkeletonLineStyle(height: 16, width: double.infinity, borderRadius: BorderRadius.circular(8)),
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
              Column(
                children: List.generate(
                  10,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: SkeletonLine(
                      style: SkeletonLineStyle(height: 120, width: double.infinity, borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RestaurantCampaignErrorView extends StatelessWidget {
  const RestaurantCampaignErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, scrolledUnderElevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
          child: Center(
            child: Column(
              children: [
                kAppSpacerVertical(height: 20),
                Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
                kAppSpacerVertical(height: 20),
                Text(translate.system_error_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
                kAppSpacerVertical(height: 30),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: kAppTextButtonColoredStyle(context, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor),
                  child: Text(translate.undestand_and_go_back),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RestaurantCampaignResponseView extends StatelessWidget {
  final RestaurantCampaignDetailModel data;
  final bool isAuthorized;
  const RestaurantCampaignResponseView({super.key, required this.data, required this.isAuthorized});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    var top = 0.0;
    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            pinned: true,
            snap: false,
            floating: true,
            elevation: 0,
            centerTitle: false,
            expandedHeight: 120.0,
            iconTheme: IconThemeData(color: Theme.of(context).canvasColor),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                child: Icon(Icons.arrow_back, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (ctx, cons) {
                top = cons.biggest.height;
                final collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
                return FlexibleSpaceBar(
                  centerTitle: false,
                  title: top <= collapsedHeight + 5
                      ? AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(microseconds: 200),
                          child: Text(kAppTrimWord(data.detail!.title!, 40), style: Theme.of(context).appBarTheme.titleTextStyle),
                        )
                      : const SizedBox.shrink(),
                  background: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 120.0, imageUrl: data.detail!.image!),
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.detail!.title!, style: kAppLblMediumFontBold(context)),
                      Text(data.detail!.shortDescription!, style: kAppLblTinyFontRegular(context)),
                      kAppSpacerVertical(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(translate.campaign_schedule_date, style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          Expanded(
                            child: Text("${data.detail!.startDate!} - ${data.detail!.endDate}", style: kAppLblTinyFontBold(context), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(translate.campaign_schedule_time, style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          Expanded(
                            child: Text("${data.detail!.startTime!} - ${data.detail!.endTime!}", style: kAppLblTinyFontBold(context), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      kAppSpacerVertical(height: 20),
                      kAppTitleDivider(context, translate.restaurant_campaign_title, 0.0),
                      kAppSpacerVertical(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: data.inCampaign!
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
                                  child: e.isHidden! ? VerticalRestaurantHideBlock(model: e) : VerticalRestaurantBlock(model: e, findMode: data.findMode!, isAuthorized: isAuthorized),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class VerticalRestaurantBlock extends StatelessWidget {
  final InCampaignRestaurantModel model;
  final String findMode;
  final bool isAuthorized;
  const VerticalRestaurantBlock({super.key, required this.model, required this.findMode, required this.isAuthorized});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () {
        context.read<RestaurantCampaignBloc>().add(RestaurantCampaignNavigateEvent());
        Navigator.of(context).pushNamed(AppRouter.restaurantRoute, arguments: [model.id, model.slug, model.name]);
      },
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
                          InkWell(
                            onTap: () => context.read<RestaurantCampaignBloc>().add(RestaurantCampaignHideEvent(id: model.id!)),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                              child: Icon(Icons.visibility_off_outlined, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                            ),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          InkWell(
                            onTap: () => context.read<RestaurantCampaignBloc>().add(RestaurantCampaignFavouriteEvent(id: model.id!, isFavourite: model.isFavourite!)),
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

class VerticalRestaurantHideBlock extends StatelessWidget {
  final InCampaignRestaurantModel model;
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
              Text(translate.hidden_restaurant_title, style: kAppLblTinyFontRegular(context)),
              kAppSpacerVertical(height: 5),
              Text(kAppTrimWord(model.name!, 35), style: kAppLblMediumFontBold(context)),
              kAppSpacerVertical(height: 5),
              Text(translate.hidden_restaurant_sub_title, style: kAppLblTinyFontRegular(context)),
              kAppSpacerVertical(height: 10),
              InkWell(
                onTap: () => context.read<RestaurantCampaignBloc>().add(RestaurantCampaignRemoveRestaurantEvent(id: model.id!)),
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
                child: InkWell(
                  onTap: () => context.read<RestaurantCampaignBloc>().add(RestaurantCampaignUndoHideActionEvent(id: model.id!)),
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
                          child: HideRestaurantReasonModalScreen(restaurantId: model.id!, restaurantName: model.name!),
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
