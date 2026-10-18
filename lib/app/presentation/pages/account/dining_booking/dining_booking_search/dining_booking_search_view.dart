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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/dining_booking_list_response_model.dart';
import 'package:user/app/presentation/pages/account/dining_booking/dining_booking_search/bloc/dining_booking_search_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DiningBookingSearchScreen extends StatelessWidget {
  const DiningBookingSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => DiningBookingSearchBloc()..add(DiningBookingSearchInitialEvent()), child: const DiningBookingSearchView());
  }
}

class DiningBookingSearchView extends StatelessWidget {
  const DiningBookingSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<DiningBookingSearchBloc, DiningBookingSearchState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isLoading ? true : false,
          child: Scaffold(
            appBar: AppBar(
              title: Text(translate.search_dining_booking),
              scrolledUnderElevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(55),
                child: Container(
                  padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: CupertinoSearchTextField(
                          placeholder: translate.search_with_email_or_phone,
                          style: kAppLblMediumFontRegular(context),
                          placeholderStyle: kAppLblMediumFontRegular(context),
                          onChanged: (value) {
                            context.read<DiningBookingSearchBloc>().add(DiningBookingSearchInputChangeEvent(query: value));
                          },
                        ),
                      ),
                      kAppSpacerHorizontal(width: 5),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            context.read<DiningBookingSearchBloc>().add(DiningBookingSearchSubmitEvent());
                            FocusScope.of(context).requestFocus(FocusNode());
                            SystemChannels.textInput.invokeMethod('TextInput.hide');
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(color: ThemeProvider.darkBackgroundColor, borderRadius: BorderRadius.circular(5)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text(translate.search, style: TextStyle(color: ThemeProvider.whiteColor))],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isInitial) ...[
                    const DiningBookingSearchInitialView(),
                  ] else if (state.status.isLoading) ...[
                    const DiningBookingSearchLoadingView(),
                  ] else if (state.status.isEmpty) ...[
                    const DiningBookingSearchEmptyView(),
                  ] else if (state.status.isFailure) ...[
                    const DiningBookingSearchErrorView(),
                  ] else if (state.status.isSuccess) ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(state.model.bookings!.length, (bookingIndex) => DiningBookingInformationTileView(model: state.model.bookings![bookingIndex])),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DiningBookingInformationTileView extends StatelessWidget {
  final DiningBookingDetailConfigModel model;
  const DiningBookingInformationTileView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRouter.diningBookingInformationRoute, arguments: [model.id!]),
      child: Container(
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
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.only(bottom: 10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
              ),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantDetailInfoRoute, arguments: [model.restaurant!.id!, model.restaurant!.name!, model.restaurant!.slug!, '']),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      child: CacheNetworkImageWidget(width: 25.0, height: 25.0, imageUrl: model.restaurant!.cover!),
                    ),
                    kAppSpacerHorizontal(width: 5),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.4,
                          child: Text(model.restaurant!.name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblMediumFontBold(context)),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.4,
                          child: Text(model.restaurant!.address!, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.only(bottom: 10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
              ),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRouter.diningBookingInformationRoute, arguments: [model.id!]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("${translate.name} :", style: kAppLblTinyFontBold(context)),
                        kAppSpacerHorizontal(width: 10),
                        Text(model.userName!, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                    kAppSpacerVertical(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("${translate.email} :", style: kAppLblTinyFontBold(context)),
                        kAppSpacerHorizontal(width: 10),
                        Text(model.userEmail!, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                    kAppSpacerVertical(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("${translate.phone} :", style: kAppLblTinyFontBold(context)),
                        kAppSpacerHorizontal(width: 10),
                        Text("+${model.userCountryCode} ${model.userContact}", style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.only(bottom: 10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
              ),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRouter.diningBookingInformationRoute, arguments: [model.id!]),
                child: Text("${model.bookingDate} ${translate.at} ${model.bookingSlot}", style: kAppLblTinyFontBold(context)),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.only(bottom: 2),
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRouter.diningBookingInformationRoute, arguments: [model.id!]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (model.status! == 'created') ...[
                      Text(translate.booking_created, style: kAppLblSmallFontBold(context, color: 'primary')),
                    ] else if (model.status! == 'accepted') ...[
                      Text(translate.booking_accepted, style: kAppLblSmallFontBold(context, color: 'primary')),
                    ] else if (model.status! == 'completed') ...[
                      Text(translate.booking_completed, style: kAppLblSmallFontBold(context, color: 'primary')),
                    ] else if (model.status! == 'cancelled') ...[
                      Text(translate.booking_cancelled, style: kAppLblSmallFontBold(context, color: 'primary')),
                    ] else if (model.status! == 'rejected') ...[
                      Text(translate.booking_rejected, style: kAppLblSmallFontBold(context, color: 'primary')),
                    ] else if (model.status! == 'refunded') ...[
                      Text(translate.booking_refunded, style: kAppLblSmallFontBold(context, color: 'primary')),
                    ] else if (model.status! == 'partially_refunded') ...[
                      Text(translate.booking_refunded, style: kAppLblSmallFontBold(context, color: 'primary')),
                    ] else if (model.status! == 'pending_payments') ...[
                      Text(translate.payment_pending, style: kAppLblSmallFontBold(context, color: 'primary')),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiningBookingSearchInitialView extends StatelessWidget {
  const DiningBookingSearchInitialView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(translate.find_dining_booking, style: kAppLblLargeFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.find_dining_booking_sub_title, textAlign: TextAlign.center, style: kAppLblSmallFontMedium(context)),
        ],
      ),
    );
  }
}

class DiningBookingSearchLoadingView extends StatelessWidget {
  const DiningBookingSearchLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        10,
        (index) => Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonListTile(
                hasSubtitle: true,
                padding: const EdgeInsets.all(0),
                leadingStyle: const SkeletonAvatarStyle(width: 25, height: 25),
                titleStyle: SkeletonLineStyle(height: 10, randomLength: false, borderRadius: BorderRadius.circular(16)),
                subtitleStyle: SkeletonLineStyle(height: 10, randomLength: true, borderRadius: BorderRadius.circular(16)),
              ),
              kAppSpacerVertical(height: 20),
              SkeletonParagraph(
                style: SkeletonParagraphStyle(
                  spacing: 6,
                  padding: const EdgeInsets.all(0),
                  lineStyle: SkeletonLineStyle(height: 10, randomLength: false, borderRadius: BorderRadius.circular(16)),
                ),
              ),
              kAppSpacerVertical(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SkeletonLine(
                    style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 3.5, borderRadius: BorderRadius.circular(8)),
                  ),
                  SkeletonLine(
                    style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 3.5, borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiningBookingSearchEmptyView extends StatelessWidget {
  const DiningBookingSearchEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.cartEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.no_dining_booking, textAlign: TextAlign.center, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.no_dining_booking_sub_title, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class DiningBookingSearchErrorView extends StatelessWidget {
  const DiningBookingSearchErrorView({super.key});

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
