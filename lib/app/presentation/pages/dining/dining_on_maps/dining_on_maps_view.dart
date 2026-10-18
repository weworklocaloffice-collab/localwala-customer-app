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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/near_me_dining_restaurant_on_map_response_model.dart';
import 'package:user/app/presentation/pages/dining/dining_on_maps/bloc/dining_on_map_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/google_dark_map_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DiningOnMapScreen extends StatelessWidget {
  const DiningOnMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => DiningOnMapBloc()..add(DiningOnMapInitialEvent()), child: const DiningOnMapsView());
  }
}

class DiningOnMapsView extends StatefulWidget {
  const DiningOnMapsView({super.key});

  @override
  State<DiningOnMapsView> createState() => _DiningOnMapsViewState();
}

class _DiningOnMapsViewState extends State<DiningOnMapsView> with WidgetsBindingObserver {
  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();
  final ScrollController _diningController = ScrollController();
  @override
  void dispose() async {
    super.dispose();
    if (!kIsWeb) {
      final GoogleMapController controller = await _googleMapController.future;
      controller.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<DiningOnMapBloc, DiningOnMapState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: state.status.isInitial
              ? kAppCenterCircularProgress(context, color: 'primary')
              : !kIsWeb
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      GoogleMap(
                        myLocationEnabled: false,
                        compassEnabled: false,
                        tiltGesturesEnabled: false,
                        indoorViewEnabled: false,
                        trafficEnabled: false,
                        buildingsEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          if (!_googleMapController.isCompleted) {
                            _googleMapController.complete(controller);
                          }
                        },
                        mapType: MapType.normal,
                        markers: state.markers,
                        polylines: state.polyline,
                        scrollGesturesEnabled: true,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        style: GoogleDarkMapStyle.mapStyles,
                        initialCameraPosition: CameraPosition(zoom: 12, tilt: 0, bearing: 30, target: LatLng(state.latitude, state.longitude)),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                            child: Icon(Icons.close, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              controller: _diningController,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (state.status.isInitial || state.status.isLocationFetched) ...[
                                    const DiningOnMapLoadingView(),
                                  ] else if (state.status.isEmpty) ...[
                                    const DiningOnMapEmptyView(),
                                  ] else if (state.status.isFailure) ...[
                                    const DiningOnMapErrorView(),
                                  ] else ...[
                                    DiningOnMapRestaurantTileView(model: state.model),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                            child: Icon(Icons.close, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                          ),
                        ),
                      ),
                      Center(child: Text(translate.google_maps_here, style: kAppLblLargeFontBold(context))),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class DiningOnMapRestaurantTileView extends StatelessWidget {
  final NearMeDiningRestaurantsOnMapResponseModel model;
  const DiningOnMapRestaurantTileView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          model.dinings!.length,
          (diningIndex) => Container(
            width: MediaQuery.of(context).size.width / 1.1,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).scaffoldBackgroundColor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CacheNetworkImageWidget(width: double.infinity, height: 100.0, imageUrl: model.dinings![diningIndex].cover!),
                      ),
                      model.dinings![diningIndex].promote!
                          ? Positioned(
                              left: 5,
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
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: Text(kAppTrimWord(model.dinings![diningIndex].name!, 25), style: kAppLblMediumFontBold(context))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: ThemeProvider.ratingBgColorLight, borderRadius: BorderRadius.circular(5.0)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('${model.dinings![diningIndex].rating}', style: const TextStyle(color: ThemeProvider.ratingTextColorLight)),
                                  kAppSpacerHorizontal(width: 2),
                                  Icon(Icons.star, size: Theme.of(context).textTheme.labelSmall?.fontSize, color: ThemeProvider.ratingTextColorLight),
                                ],
                              ),
                            ),
                          ],
                        ),
                        kAppSpacerVertical(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(kAppTrimWord(model.dinings![diningIndex].cuisineName!, 15), style: kAppLblTinyFontRegular(context)),
                            Text("${kAppPriceFormat(model.dinings![diningIndex].dishPriceForTwo!)} ${translate.for_two_lbl}", style: kAppLblTinyFontRegular(context)),
                          ],
                        ),
                        kAppSpacerVertical(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(AssetsUrl.iconsURL.timeTag, height: 10, width: 10),
                                kAppSpacerHorizontal(width: 5),
                                Text(kAppDeliveryTimeName(context, model.dinings![diningIndex].approxDeliveryTime!), style: kAppLblTinyFontRegular(context)),
                              ],
                            ),
                            Text("${model.dinings![diningIndex].distance!} ${model.findMode}", style: kAppLblTinyFontRegular(context)),
                          ],
                        ),
                        kAppSpacerVertical(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 30,
                                child: FloatingActionButton.extended(
                                  heroTag: 'diningRestaurantOnMaps',
                                  onPressed: () => Navigator.of(context).pop({"id": model.dinings![diningIndex].id!, "name": model.dinings![diningIndex].name!, "slug": model.dinings![diningIndex].slug!}),
                                  label: Text(translate.view_dining, style: kAppLblMediumFontSemiBoldWhite(context)),
                                  icon: const Icon(Icons.restaurant, size: 15),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () => context.read<DiningOnMapBloc>().add(DiningOnMapDirectionEvent(diningIndex: diningIndex)),
                                    child: const Icon(Icons.directions_outlined, size: 20, color: ThemeProvider.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        kAppSpacerVertical(height: 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DiningOnMapLoadingView extends StatelessWidget {
  const DiningOnMapLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          5,
          (index) => Container(
            width: MediaQuery.of(context).size.width / 1.1,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: SkeletonLine(style: SkeletonLineStyle(height: 100, width: 100, borderRadius: BorderRadius.circular(8))),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SkeletonLine(
                        style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                      ),
                      kAppSpacerVertical(height: 5),
                      SkeletonLine(
                        style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                      ),
                      kAppSpacerVertical(height: 5),
                      SkeletonLine(
                        style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2.8, borderRadius: BorderRadius.circular(8)),
                      ),
                      kAppSpacerVertical(height: 5),
                      SkeletonLine(
                        style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                      ),
                      kAppSpacerVertical(height: 5),
                      SkeletonLine(
                        style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DiningOnMapEmptyView extends StatelessWidget {
  const DiningOnMapEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      width: MediaQuery.of(context).size.width / 1,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).scaffoldBackgroundColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(translate.oops_title, style: kAppLblLargeFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.no_dining_restaurant_error, textAlign: TextAlign.center, style: kAppLblSmallFontMedium(context)),
        ],
      ),
    );
  }
}

class DiningOnMapErrorView extends StatelessWidget {
  const DiningOnMapErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      width: MediaQuery.of(context).size.width / 1,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).scaffoldBackgroundColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(translate.oops_title, style: kAppLblLargeFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.dining_map_error, textAlign: TextAlign.center, style: kAppLblSmallFontMedium(context)),
        ],
      ),
    );
  }
}

