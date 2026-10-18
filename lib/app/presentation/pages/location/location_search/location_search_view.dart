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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/app/core/models/address_list_response_model.dart';
import 'package:user/app/core/models/google_places_result_model.dart';
import 'package:user/app/core/models/local_search_history_model.dart';
import 'package:user/app/presentation/pages/location/location_search/bloc/location_search_bloc.dart';
import 'package:user/app/presentation/pages/modals/permission_denied/location_permission_denied_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class LocationSearchScreen extends StatelessWidget {
  const LocationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => LocationSearchBloc()..add(LocationSearchInitialEvent()), child: const LocationSearchView());
  }
}

class LocationSearchView extends StatelessWidget {
  const LocationSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<LocationSearchBloc, LocationSearchState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isSelected) {
          Navigator.of(context).pushNamed(AppRouter.locationMapsRoute, arguments: [state.latitude, state.longitude, state.placeId, state.title, state.description]);
        } else if (state.status.isHistorySelected) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [0]);
        } else if (state.status.isSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.bottomTabRoute, (Route<dynamic> route) => false, arguments: [0]);
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
              context.read<LocationSearchBloc>().add(LocationSearchOpenSettingEvent());
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: Text(translate.enter_location_your_area),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Padding(
                padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CupertinoSearchTextField(
                      placeholder: translate.location_search_query,
                      style: kAppLblMediumFontRegular(context),
                      placeholderStyle: kAppLblMediumFontRegular(context),
                      onChanged: (String value) {
                        context.read<LocationSearchBloc>().add(LocationSearchInputEvent(searchText: value));
                      },
                      // onSubmitted: (String value) {
                      //   context.read<LocationSearchBloc>().add(LocationSearchInputEvent(searchText: value));
                      // },
                    ),
                    kAppSpacerVertical(height: 10),
                    InkWell(
                      onTap: () => context.read<LocationSearchBloc>().add(LocationSearchLiveLocationEvent()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.my_location_outlined, color: Theme.of(context).primaryColor, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                            kAppSpacerHorizontal(width: 10),
                            Text(translate.use_current_location, style: kAppLblMediumFontSemiBold(context, color: 'primary')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  state.status.isLoading ? Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: kAppCenterCircularProgress(context)) : const SizedBox(),
                  state.predictions.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            kAppLine(context),
                            kAppSpacerVertical(height: 10),
                            Text(translate.search_results, style: kAppLblSmallFontRegular(context)),
                            kAppSpacerVertical(height: 10),
                            Column(children: List.generate(state.predictions.length, (index) => GooglePlacesResultTile(predictions: state.predictions[index]))),
                          ],
                        )
                      : const SizedBox(),
                  kAppSpacerVertical(height: 10),
                  state.addresses.list!.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            kAppLine(context),
                            kAppSpacerVertical(height: 10),
                            Text(translate.saved_address, style: kAppLblSmallFontRegular(context)),
                            kAppSpacerVertical(height: 10),
                            Column(children: List.generate(state.addresses.list!.length, (index) => SavedAddressTile(result: state.addresses.list![index]))),
                          ],
                        )
                      : const SizedBox(),
                  kAppSpacerVertical(height: 10),
                  state.localHistory.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            kAppLine(context),
                            kAppSpacerVertical(height: 10),
                            Text(translate.recent_search, style: kAppLblSmallFontRegular(context)),
                            kAppSpacerVertical(height: 10),
                            Column(children: List.generate(state.localHistory.length, (index) => RecentHistoryTile(result: state.localHistory[index]))),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class GooglePlacesResultTile extends StatelessWidget {
  final Predictions predictions;
  const GooglePlacesResultTile({super.key, required this.predictions});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<LocationSearchBloc>().add(LocationSearchSelectEvent(predictions: predictions)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.my_location_outlined, color: Theme.of(context).canvasColor, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                kAppSpacerHorizontal(width: 5),
                Text(predictions.structuredFormatting!.mainText!, style: kAppLblMediumFontBold(context)),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Text(predictions.description!, style: kAppLblSmallFontRegular(context)),
          ],
        ),
      ),
    );
  }
}

class RecentHistoryTile extends StatelessWidget {
  final LocalSearchHistoryModel result;
  const RecentHistoryTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<LocationSearchBloc>().add(LocationSearchLocalSelectEvent(localResult: result)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.my_location_outlined, color: Theme.of(context).canvasColor, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                kAppSpacerHorizontal(width: 5),
                Text(result.mainText!, style: kAppLblMediumFontBold(context)),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Text(result.description!, style: kAppLblSmallFontRegular(context)),
          ],
        ),
      ),
    );
  }
}

class SavedAddressTile extends StatelessWidget {
  final AddressDataModel result;
  const SavedAddressTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<LocationSearchBloc>().add(LocationSearchSavedAddressEvent(result: result)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.my_location_outlined, color: Theme.of(context).canvasColor, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                kAppSpacerHorizontal(width: 5),
                Text(kAppAddressTitle(context, result.title!), style: kAppLblMediumFontBold(context)),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Text("${result.flatHouse!}, ${result.locality!}, ${result.landmark!}", style: kAppLblSmallFontRegular(context)),
          ],
        ),
      ),
    );
  }
}
// Done //
