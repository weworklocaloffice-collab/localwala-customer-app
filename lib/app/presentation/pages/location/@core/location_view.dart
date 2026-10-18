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
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/location/@core/bloc/location_bloc.dart';
import 'package:user/app/presentation/pages/modals/permission_denied/location_permission_denied_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => LocationBloc()..add(LocationInitialEvent()), child: const LocationView());
  }
}

class LocationView extends StatelessWidget {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [0]);
        } else if (state.status.isFailure) {
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
              context.read<LocationBloc>().add(LocationOpenSettingEvent());
            }
          });
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isLoading ? true : false,
          child: Scaffold(
            appBar: AppBar(title: Text(translate.location_title), scrolledUnderElevation: 0),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: Text(translate.need_location_for_restaurants, textAlign: TextAlign.start, style: kAppLblMediumFontRegular(context)),
                  ),
                  kAppSpacerVertical(height: 20),
                  Image.asset(AssetsUrl.imageURL.locationMap, height: MediaQuery.of(context).size.height / 2, width: double.infinity, fit: BoxFit.fitWidth),
                  kAppSpacerVertical(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.read<LocationBloc>().add(LocationFetchEvent()),
                            style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                            child: state.status.isLoading ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.continue_btn),
                          ),
                        ),
                        kAppSpacerVertical(height: 10),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(AppRouter.locationSearchRoute),
                          child: Text(translate.enter_location_manually, style: kAppLblMediumFontSemiBold(context, color: 'primary')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Done //

