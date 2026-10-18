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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/account/address_book/address_action/address_action_view.dart';
import 'package:user/app/presentation/pages/account/address_book/new_address_map/bloc/new_address_map_bloc.dart';
import 'package:user/app/presentation/pages/modals/permission_denied/location_permission_denied_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class NewAddressMapScreen extends StatelessWidget {
  final bool isNew;
  final bool fromDelivery;
  final String id;
  final double latitude;
  final double longitude;
  final int title;
  final String receiverName;
  final String countryCode;
  final String receiverContact;
  final String flatHouse;
  final String locality;
  final String landmark;
  const NewAddressMapScreen({
    super.key,
    required this.isNew,
    required this.fromDelivery,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.receiverName,
    required this.countryCode,
    required this.receiverContact,
    required this.flatHouse,
    required this.locality,
    required this.landmark,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewAddressMapBloc()
        ..add(
          NewAddressMapInitialEvent(
            isNew: isNew,
            fromDelivery: fromDelivery,
            id: id,
            latitude: latitude,
            longitude: longitude,
            title: title,
            receiverName: receiverName,
            countryCode: countryCode,
            receiverContact: receiverContact,
            flatHouse: flatHouse,
            locality: locality,
            landmark: landmark,
          ),
        ),
      child: const NewAddressMapView(),
    );
  }
}

class NewAddressMapView extends StatefulWidget {
  const NewAddressMapView({super.key});

  @override
  State<NewAddressMapView> createState() => _NewAddressMapViewState();
}

class _NewAddressMapViewState extends State<NewAddressMapView> {
  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();

  Future<void> changeCameraPosition(double latitude, double longitude) async {
    if (!mounted) return;
    CameraPosition nepPos = CameraPosition(target: LatLng(latitude, longitude), zoom: 16);
    final GoogleMapController controller = await _googleMapController.future;
    if (!mounted) return;
    await controller.animateCamera(CameraUpdate.newCameraPosition(nepPos));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<NewAddressMapBloc, NewAddressMapState>(
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
              context.read<NewAddressMapBloc>().add(NewAddressMapOpenSettingEvent());
            }
          });
        } else if (state.status.isSuccess) {
          changeCameraPosition(state.latitude, state.longitude);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(onPressed: () => Navigator.of(context).pop(false), icon: const Icon(Icons.keyboard_arrow_down_outlined)),
            title: Text(translate.confirm_delivery_address),
          ),
          body: SingleChildScrollView(
            child: state.status.isLoading
                ? kAppCenterCircularProgress(context)
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height - 300,
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
                                _googleMapController.complete(controller);
                              },
                              mapType: MapType.normal,
                              scrollGesturesEnabled: true,
                              zoomControlsEnabled: true,
                              zoomGesturesEnabled: true,
                              initialCameraPosition: CameraPosition(zoom: 16, tilt: 0, bearing: 30, target: LatLng(state.latitude, state.longitude)),
                              onCameraMove: (position) {
                                if (state.latitude != position.target.latitude && state.longitude != position.target.longitude) {
                                  context.read<NewAddressMapBloc>().add(NewAddressMapPositionChangedEvent(latitude: position.target.latitude, longitude: position.target.longitude));
                                }
                              },
                              onCameraIdle: () {
                                context.read<NewAddressMapBloc>().add(NewAddressMapPositionEndedEvent());
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
                                      context.read<NewAddressMapBloc>().add(NewAddressMapLocateMeEvent());
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
                            Text(translate.select_delivery_location.toUpperCase(), style: kAppLblMediumFontMedium(context)),
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
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    isDismissible: false,
                                    enableDrag: false,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    builder: (BuildContext context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.7,
                                        child: AddressActionScreen(
                                          isNew: state.isNew,
                                          id: state.id,
                                          latitude: state.latitude,
                                          longitude: state.longitude,
                                          title: state.titleAddress,
                                          receiverName: state.receiverName,
                                          countryCode: state.countryCode,
                                          receiverContact: state.receiverNumber,
                                          flatHouse: state.houseName,
                                          locality: state.description,
                                          landmark: state.landmark,
                                        ),
                                      );
                                    },
                                  ).then((value) {
                                    if (!context.mounted) return;
                                    if (value == 'true' || value == true) {
                                      Navigator.of(context).pop(true);
                                    }
                                  });
                                },
                                style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                                child: state.status.isDragged ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.complete_address),
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
