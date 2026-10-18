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
import 'package:user/app/presentation/pages/home/sort/categories/@core/bloc/restaurants_by_category_bloc.dart';
import 'package:user/app/presentation/pages/home/sort/categories/filter_foods/filter_foods_by_category_view.dart';
import 'package:user/app/presentation/pages/home/sort/categories/filter_restaurants/filter_restaurants_by_category_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class RestaurantsByCategoryScreen extends StatelessWidget {
  final String name;
  final String slug;
  final String city;
  const RestaurantsByCategoryScreen({super.key, required this.name, required this.slug, required this.city});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RestaurantsByCategoryBloc()..add(RestaurantsByCategoryInitialEvent(name: name, slug: slug, city: city)),
      child: RestaurantsByCategoryView(name: name, slug: slug, city: city),
    );
  }
}

class RestaurantsByCategoryView extends StatefulWidget {
  final String name;
  final String slug;
  final String city;
  const RestaurantsByCategoryView({super.key, required this.name, required this.slug, required this.city});

  @override
  State<RestaurantsByCategoryView> createState() => _RestaurantsByCategoryViewState();
}

class _RestaurantsByCategoryViewState extends State<RestaurantsByCategoryView> with TickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<RestaurantsByCategoryBloc, RestaurantsByCategoryState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.name),
            scrolledUnderElevation: 0,
            bottom: TabBar(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).hintColor,
              indicatorColor: Theme.of(context).primaryColor,
              labelStyle: kAppStyleTabTitleStyle(context),
              unselectedLabelStyle: kAppStyleTabTitleStyle(context),
              labelPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              tabs: [Text(translate.restaurants), Text(translate.dishes)],
            ),
          ),
          body: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              FilterRestaurantsByCategoryScreen(name: widget.name, slug: widget.slug, city: widget.city),
              FilterFoodsByCategoryScreen(name: widget.name, slug: widget.slug, city: widget.city),
            ],
          ),
        );
      },
    );
  }
}

