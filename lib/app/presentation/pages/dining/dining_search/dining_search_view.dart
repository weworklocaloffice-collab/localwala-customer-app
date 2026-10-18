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
import 'package:user/app/presentation/pages/dining/dining_search/bloc/dining_search_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DiningSearchScreen extends StatelessWidget {
  const DiningSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => DiningSearchBloc()..add(DiningSearchInitialEvent()), child: const DiningSearchView());
  }
}

class DiningSearchView extends StatelessWidget {
  const DiningSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<DiningSearchBloc, DiningSearchState>(
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
              placeholder: translate.search_query,
              style: kAppLblMediumFontRegular(context),
              placeholderStyle: kAppLblMediumFontRegular(context),
              onChanged: (value) {
                context.read<DiningSearchBloc>().add(DiningSearchFindResultEvent(searchQuery: value));
              },
              // onSubmitted: (value) {
              //   context.read<DiningSearchBloc>().add(DiningSearchFindResultEvent(searchQuery: value));
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
                if (state.status.isInitial) ...[
                  kAppTitleDivider(context, translate.in_mind_title, ThemeProvider.scaffoldPadding),
                  kAppSpacerVertical(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 80),
                      scrollDirection: Axis.vertical,
                      key: UniqueKey(),
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.filterDiningWithCategoryRoute, arguments: [state.initialData.category![index].name!, state.initialData.category![index].slug!, state.initialData.city!.slug!]);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.bottomCenter,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                  child: CacheNetworkImageWidget(width: 80.0, height: 80.0, imageUrl: state.initialData.category![index].image!),
                                ),
                                Container(
                                  height: 30,
                                  width: 80.0,
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                                    color: ThemeProvider.gradientBlackColor,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        state.initialData.category![index].name!,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontFamily: 'regular', color: ThemeProvider.whiteColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: state.initialData.category!.length,
                    ),
                  ),
                ] else if (state.status.isEmpty) ...[
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
                  state.result.categories!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              state.result.categories!.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(AppRouter.filterDiningWithCategoryRoute, arguments: [state.result.categories![index].name!, state.result.categories![index].slug!, state.initialData.city!.slug!]);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(100)),
                                        child: CacheNetworkImageWidget(width: 35.0, height: 35.0, imageUrl: state.result.categories![index].image!),
                                      ),
                                      kAppSpacerHorizontal(width: 10),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(state.result.categories![index].name!, style: kAppLblMediumFontSemiBold(context)),
                                          Text(translate.top_restaurant_and_dish, style: kAppLblTinyFontRegular(context)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  state.result.restaurants!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              state.result.restaurants!.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AppRouter.restaurantDetailInfoRoute, arguments: [state.result.restaurants![index].id!, state.result.restaurants![index].name!, state.result.restaurants![index].slug!, '']);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(100)),
                                        child: CacheNetworkImageWidget(width: 35.0, height: 35.0, imageUrl: state.result.restaurants![index].logo!),
                                      ),
                                      kAppSpacerHorizontal(width: 10),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(state.result.restaurants![index].name!, style: kAppLblMediumFontSemiBold(context)),
                                          Text(translate.restaurant, style: kAppLblTinyFontRegular(context)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
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
