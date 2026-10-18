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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/location/location_maps/bloc/location_maps_bloc.dart';
import 'package:user/app/presentation/pages/modals/permission_denied/location_permission_denied_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class LocationMapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String placeId;
  final String title;
  final String description;
  const LocationMapScreen({super.key, required this.latitude, required this.longitude, required this.placeId, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationMapsBloc()..add(LocationMapInitialEvent(latitude: latitude, longitude: longitude, placeId: placeId, title: title, description: description)),
      child: LocationMapView(latitude: latitude, longitude: longitude, placeId: placeId, title: title, description: description),
    );
  }
}

class LocationMapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String placeId;
  final String title;
  final String description;
  const LocationMapView({super.key, required this.latitude, required this.longitude, required this.placeId, required this.title, required this.description});

  @override
  State<LocationMapView> createState() => _LocationMapViewState();
}

class _LocationMapViewState extends State<LocationMapView> {
  late GoogleMapController _googleMapController;
  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    void onMapCreated(GoogleMapController controller) {
      _googleMapController = controller;
    }

    return BlocConsumer<LocationMapsBloc, LocationMapsState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isDeniedForever) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              var height = MediaQuery.of(context).size.height;
              var width = MediaQuery.of(context).size.width;
              return AlertDialog(
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                content: SizedBox(height: height - 400, width: width - 80, child: const LocationPermissionDeniedDialonScreen()),
              );
            },
          ).then((value) {
            if (!context.mounted) return;
            if (value == true) {
              context.read<LocationMapsBloc>().add(LocationMapsOpenSettingEvent());
            }
          });
        } else if (state.status.isCurrent) {
          CameraPosition nepPos = CameraPosition(target: LatLng(state.latitude, state.longitude), zoom: 16);
          _googleMapController.animateCamera(CameraUpdate.newCameraPosition(nepPos));
        } else if (state.status.isConfirm) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [0]);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height - 180,
                  child: Stack(
                    children: [
                      GoogleMap(
                        myLocationEnabled: false,
                        compassEnabled: false,
                        tiltGesturesEnabled: false,
                        indoorViewEnabled: false,
                        trafficEnabled: false,
                        buildingsEnabled: false,
                        onMapCreated: onMapCreated,
                        mapType: MapType.normal,
                        scrollGesturesEnabled: true,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        initialCameraPosition: CameraPosition(zoom: 16, tilt: 0, bearing: 30, target: LatLng(widget.latitude, widget.longitude)),
                        onCameraMove: (position) {
                          context.read<LocationMapsBloc>().add(LocationMapPositionChangedEvent(latitude: position.target.latitude, longitude: position.target.longitude));
                        },
                        onCameraIdle: () {
                          context.read<LocationMapsBloc>().add(LocationMapPositionEndedEvent());
                        },
                      ),
                      Center(child: Image.asset(AssetsUrl.imageURL.locationPin, width: 50, height: 50, fit: BoxFit.contain)),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            height: 50,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.my_location_outlined),
                              label: Text(translate.locate_me, style: kAppLblMediumFontSemiBoldWhite(context)),
                              onPressed: () {
                                context.read<LocationMapsBloc>().add(LocationMapsLocateMeEvent());
                              },
                              style: kAppElevatedButtonOutlineStyle(
                                context,
                                disabledColor: Theme.of(context).disabledColor,
                                bgColor: Theme.of(context).primaryColor,
                                foreColor: Theme.of(context).scaffoldBackgroundColor,
                                borderColor: Theme.of(context).primaryColor,
                                height: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 180,
                  padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(translate.select_delivery_location, style: kAppLblMediumFontMedium(context)),
                          SizedBox(
                            height: 25.0,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                              child: Text(translate.change, style: kAppLblSmallFontSemiBold(context)),
                            ),
                          ),
                        ],
                      ),
                      kAppSpacerVertical(height: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_outlined, size: Theme.of(context).textTheme.bodyLarge?.fontSize),
                              kAppSpacerHorizontal(width: 5),
                              Text(state.title, style: kAppLblLargeFontBold(context)),
                            ],
                          ),
                          kAppSpacerVertical(height: 5),
                          Text(state.description, style: kAppLblMediumFontMedium(context)),
                        ],
                      ),
                      kAppSpacerVertical(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.read<LocationMapsBloc>().add(LocationMapsConfirmEvent()),
                          style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                          child: state.status.isDragged ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.confirm_location),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// Done //
