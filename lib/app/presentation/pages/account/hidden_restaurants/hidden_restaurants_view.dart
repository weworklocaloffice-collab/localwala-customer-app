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
import 'package:user/app/core/models/hidden_restaurants_list_model.dart';
import 'package:user/app/presentation/pages/account/hidden_restaurants/bloc/hidden_restaurants_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class HiddenRestaurantScreen extends StatelessWidget {
  const HiddenRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => HiddenRestaurantsBloc()..add(HiddenRestaurantsInitialEvent()), child: const HiddenRestaurantView());
  }
}

class HiddenRestaurantView extends StatelessWidget {
  const HiddenRestaurantView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<HiddenRestaurantsBloc, HiddenRestaurantsState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.hidden_restaurants), scrolledUnderElevation: 0),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                ] else if (state.status.isEmpty || state.status.isFailure) ...[
                  Container(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(translate.oops_title, style: kAppLblLargeFontBold(context)),
                        kAppSpacerVertical(height: 5),
                        Text(translate.hidden_restaurant_not_found, textAlign: TextAlign.center, style: kAppLblSmallFontMedium(context)),
                      ],
                    ),
                  ),
                ] else if (state.status.isUnAuthorized) ...[
                  const Padding(padding: EdgeInsets.all(ThemeProvider.scaffoldPadding), child: UnauthorizedWidget()),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: state.list.restaurants!
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
                                child: e.isHidden! ? VerticalRestaurantBlock(model: e) : VerticalRestaurantShowBlock(model: e),
                              ),
                            ),
                          )
                          .toList(),
                    ),
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

class VerticalRestaurantBlock extends StatelessWidget {
  final HiddenRestaurantsModel model;
  const VerticalRestaurantBlock({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantRoute, arguments: [model.id, model.slug, model.name]),
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
              Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: () => context.read<HiddenRestaurantsBloc>().add(HiddenRestaurantChangeEvent(id: model.id!)),
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: ThemeProvider.whiteColor),
                    child: Icon(Icons.visibility, size: Theme.of(context).textTheme.labelLarge?.fontSize, color: ThemeProvider.primaryColor),
                  ),
                ),
              ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VerticalRestaurantShowBlock extends StatelessWidget {
  final HiddenRestaurantsModel model;
  const VerticalRestaurantShowBlock({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(translate.unhide_restaurant_title, style: kAppLblTinyFontRegular(context)),
          kAppSpacerVertical(height: 5),
          Text(kAppTrimWord(model.name!, 35), style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.unhide_restaurant_sub_title, style: kAppLblTinyFontRegular(context)),
        ],
      ),
    );
  }
}
// Done //
