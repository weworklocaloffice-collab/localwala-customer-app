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
import 'package:user/app/presentation/pages/account/account_activity/search_restaurant_activity_section/bloc/search_restaurant_activity_section_bloc.dart';
import 'package:user/app/presentation/pages/modals/direct_restaurant_review_ratings_modal/direct_restaurant_review_ratings_modal_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class SearchRestaurantActivitySectionScreen extends StatelessWidget {
  const SearchRestaurantActivitySectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => SearchRestaurantActivitySectionBloc()..add(SearchRestaurantActivitySectionInitialEvent()), child: const SearchRestaurantActivitySectionView());
  }
}

class SearchRestaurantActivitySectionView extends StatelessWidget {
  const SearchRestaurantActivitySectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<SearchRestaurantActivitySectionBloc, SearchRestaurantActivitySectionState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: CupertinoSearchTextField(
              placeholder: translate.search_restaurant,
              style: kAppLblMediumFontRegular(context),
              placeholderStyle: kAppLblMediumFontRegular(context),
              onChanged: (value) {
                context.read<SearchRestaurantActivitySectionBloc>().add(SearchRestaurantActivitySectionFindResultEvent(searchQuery: value));
              },
              // onSubmitted: (value) {
              //   context.read<SearchBloc>().add(SearchFindResultEvent(searchQuery: value));
              // },
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_outlined, color: Theme.of(context).iconTheme.color),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(translate.oops_title, style: kAppLblLargeFontBold(context)),
                        kAppSpacerVertical(height: 5),
                        Text(translate.explain_query, style: kAppLblSmallFontMedium(context)),
                      ],
                    ),
                  ),
                ] else if (state.status.isFailure) ...[
                  Container(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(translate.oops_title, style: kAppLblLargeFontBold(context)),
                        kAppSpacerVertical(height: 5),
                        Text(translate.empty_data_three, style: kAppLblSmallFontMedium(context)),
                      ],
                    ),
                  ),
                ] else if (state.status.isSuccess) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        state.model.restaurants!.length,
                        (index) => InkWell(
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
                                return FractionallySizedBox(child: DirectRestaurantReviewRatingsModalScreen(restaurant: state.model.restaurants![index].id!));
                              },
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                                  child: CacheNetworkImageWidget(width: 35.0, height: 35.0, imageUrl: state.model.restaurants![index].logo!),
                                ),
                                kAppSpacerHorizontal(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(state.model.restaurants![index].name!, style: kAppLblMediumFontSemiBold(context)),
                                    Text(translate.restaurant, style: kAppLblTinyFontRegular(context)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
// Done //
