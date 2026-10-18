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
import 'package:user/app/presentation/pages/favourite/@core/bloc/favourite_bloc.dart';
import 'package:user/app/presentation/pages/favourite/foods/favourite_foods_view.dart';
import 'package:user/app/presentation/pages/favourite/orders/favourite_orders_view.dart';
import 'package:user/app/presentation/pages/favourite/restaurants/favourite_restaurants_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => FavouriteBloc()..add(FavouriteInitialEvent()), child: const FavouriteView());
  }
}

class FavouriteView extends StatefulWidget {
  const FavouriteView({super.key});

  @override
  State<FavouriteView> createState() => _FavouriteViewState();
}

class _FavouriteViewState extends State<FavouriteView> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    super.build(context);
    return BlocConsumer<FavouriteBloc, FavouriteState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: Text(translate.favourite),
            automaticallyImplyLeading: false,
            bottom: TabBar(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).hintColor,
              indicatorColor: Theme.of(context).primaryColor,
              labelStyle: kAppStyleTabTitleStyle(context),
              unselectedLabelStyle: kAppStyleTabTitleStyle(context),
              labelPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              tabs: [Text(translate.favourite_restaurants), Text(translate.favourite_dishes), Text(translate.favourite_orders)],
            ),
          ),
          body: TabBarView(controller: tabController, physics: const NeverScrollableScrollPhysics(), children: const [FavouriteRestaurantScreen(), FavouriteFoodListScreen(), FavouriteOrderScreen()]),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
// Done //
