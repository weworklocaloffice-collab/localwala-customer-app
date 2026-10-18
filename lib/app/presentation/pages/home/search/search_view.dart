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
import 'package:user/app/presentation/pages/home/search/bloc/search_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => SearchBloc()..add(SearchInitialEvent()), child: const SearchView());
  }
}

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isNavigate) {
          if (state.navigateTo == 'categories') {
            Navigator.of(context).pushNamed(AppRouter.restaurantsByCategoryRoute, arguments: state.navigationArgs);
          } else if (state.navigateTo == 'cuisines') {
            Navigator.of(context).pushNamed(AppRouter.restaurantsByCuisineRoute, arguments: state.navigationArgs);
          } else if (state.navigateTo == 'brands') {
            Navigator.of(context).pushNamed(AppRouter.restaurantsByBrandsRoute, arguments: state.navigationArgs);
          } else if (state.navigateTo == 'restaurants') {
            Navigator.of(context).pushNamed(AppRouter.restaurantRoute, arguments: state.navigationArgs);
          }
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
                context.read<SearchBloc>().add(SearchFindResultEvent(searchQuery: value));
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
          body: SafeArea(child: SingleChildScrollView(
                 child: Padding(
                   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 8),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                if (state.status.isInitial || state.status.isNavigate) ...[
                  state.localHistory.isNotEmpty ? kAppTitleDivider(context, translate.recent_search_title, ThemeProvider.scaffoldPadding) : const SizedBox(),
                  state.localHistory.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              state.localHistory.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () => context.read<SearchBloc>().add(SearchOnLocalSearchHistoryTapEvent(index: index)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
ClipRRect(
                                             borderRadius: const BorderRadius.all(Radius.circular(100)),
                                             child: CacheNetworkImageWidget(width: 35.0, height: 35.0, imageUrl: state.localHistory[index].image!),
                                           ),
                                           kAppSpacerHorizontal(width: 10),
                                           Column(
                                             mainAxisAlignment: MainAxisAlignment.start,
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             mainAxisSize: MainAxisSize.min,
                                             children: [
                                               Text(state.localHistory[index].title!, style: kAppLblMediumFontSemiBold(context), softWrap: true, overflow: TextOverflow.ellipsis),
                                               Text(state.localHistory[index].subTitle!, style: kAppLblTinyFontRegular(context), softWrap: true, overflow: TextOverflow.ellipsis),
                                             ],
                                           ),
                                         ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => context.read<SearchBloc>().add(SearchOnLocalSearchHistoryDeleteEvent(index: index)),
                                      child: Icon(Icons.close, color: Theme.of(context).canvasColor, size: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  kAppTitleDivider(context, translate.in_mind_title, ThemeProvider.scaffoldPadding),
                  kAppSpacerVertical(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 120),
                      scrollDirection: Axis.vertical,
                      key: UniqueKey(),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.restaurantsByCategoryRoute, arguments: [state.initialData.category![index].name!, state.initialData.category![index].slug!, state.initialData.city!.slug!]);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CacheNetworkImageWidget(width: 35.0, height: 35.0, imageUrl: state.initialData.category![index].image!),
                              kAppSpacerVertical(height: 6),
                              Text(kAppTrimWord(state.initialData.category![index].name!, 8), style: kAppLblMediumFontSemiBold(context)),
                            ],
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
                              (index) => InkWell(
                                onTap: () {
                                  context.read<SearchBloc>().add(SearchSaveHistoryEvent(type: 'categories', index: index));
                                  Navigator.of(context).pushNamed(AppRouter.restaurantsByCategoryRoute, arguments: [state.result.categories![index].name!, state.result.categories![index].slug!, state.initialData.city!.slug!]);
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
                                         mainAxisSize: MainAxisSize.min,
                                         children: [
                                           Text(state.result.categories![index].name!, style: kAppLblMediumFontSemiBold(context), softWrap: true, overflow: TextOverflow.ellipsis),
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
                  state.result.cuisines!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              state.result.cuisines!.length,
                              (index) => InkWell(
                                onTap: () {
                                  context.read<SearchBloc>().add(SearchSaveHistoryEvent(type: 'cuisines', index: index));
                                  Navigator.of(context).pushNamed(AppRouter.restaurantsByCuisineRoute, arguments: [state.result.cuisines![index].name!, state.result.cuisines![index].slug!, state.initialData.city!.slug!]);
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
                                        child: CacheNetworkImageWidget(width: 35.0, height: 35.0, imageUrl: state.result.cuisines![index].image!),
                                      ),
                                      kAppSpacerHorizontal(width: 10),
Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.result.cuisines![index].name!, style: kAppLblMediumFontSemiBold(context), softWrap: true, overflow: TextOverflow.ellipsis),
                            Text(translate.top_restaurants, style: kAppLblTinyFontRegular(context)),
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
                  state.result.brands!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              state.result.brands!.length,
                              (index) => InkWell(
                                onTap: () {
                                  context.read<SearchBloc>().add(SearchSaveHistoryEvent(type: 'brands', index: index));
                                  Navigator.of(context).pushNamed(
                                    AppRouter.restaurantsByBrandsRoute,
                                    arguments: [state.result.brands![index].id!, state.result.brands![index].name!, state.result.brands![index].cover!, state.result.brands![index].slug!, state.initialData.city!.slug!],
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
                                        borderRadius: const BorderRadius.all(Radius.circular(100)),
                                        child: CacheNetworkImageWidget(width: 35.0, height: 35.0, imageUrl: state.result.brands![index].logo!),
                                      ),
                                      kAppSpacerHorizontal(width: 10),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(state.result.brands![index].name!, style: kAppLblMediumFontSemiBold(context), softWrap: true, overflow: TextOverflow.ellipsis),
                                          Text(translate.top_brands, style: kAppLblTinyFontRegular(context)),
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
                              (index) => InkWell(
                                onTap: () {
                                  context.read<SearchBloc>().add(SearchSaveHistoryEvent(type: 'restaurants', index: index));
                                  Navigator.of(context).pushNamed(AppRouter.restaurantRoute, arguments: [state.result.restaurants![index].id!, state.result.restaurants![index].slug!, state.result.restaurants![index].name!]);
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
                                          Text(state.result.restaurants![index].name!, style: kAppLblMediumFontSemiBold(context), softWrap: true, overflow: TextOverflow.ellipsis),
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
         ),
       ),
     );
   }, // close builder
 ); // close BlocConsumer
}
}
// Done //
