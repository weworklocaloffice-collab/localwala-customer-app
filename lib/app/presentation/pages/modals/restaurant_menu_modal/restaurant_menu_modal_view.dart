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
import 'package:user/app/core/models/restaurant_modal_category_model.dart';
import 'package:user/app/presentation/pages/modals/restaurant_menu_modal/bloc/restaurant_menu_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/theme_bloc/theme_bloc.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class RestaurantMenuModalScreen extends StatelessWidget {
  final String currentInView;
  final List<RestaurantModalCategoryModel> categories;
  const RestaurantMenuModalScreen({super.key, required this.currentInView, required this.categories});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = context.watch<ThemeBloc>().state.isDarkTheme;
    return BlocProvider(
      create: (context) => RestaurantMenuModalBloc()..add(RestuarantMenuInitialEvent(currentInView: currentInView, isDarkTheme: isDarkTheme)),
      child: RestaurantMenuModalView(categories: categories),
    );
  }
}

class RestaurantMenuModalView extends StatelessWidget {
  final List<RestaurantModalCategoryModel> categories;
  const RestaurantMenuModalView({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<RestaurantMenuModalBloc, RestaurantMenuModalState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: state.isDarkTheme ? ThemeProvider.pageBackgroundColor : ThemeProvider.darkPageBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
            child: Column(
              children: List.generate(
                categories.length,
                (categoryIndex) => SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(categories[categoryIndex].id!),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            categories[categoryIndex].id == 'recommended' ? translate.recommended : categories[categoryIndex].name!,
                            style: state.currentInView == categories[categoryIndex].id ? kAppThemeToggleLblBold(context, isDarkTheme: state.isDarkTheme) : kAppThemeToggleLblRegular(context, isDarkTheme: state.isDarkTheme),
                          ),
                          Text(
                            '${categories[categoryIndex].count!}',
                            style: state.currentInView == categories[categoryIndex].id ? kAppThemeToggleLblBold(context, isDarkTheme: state.isDarkTheme) : kAppThemeToggleLblRegular(context, isDarkTheme: state.isDarkTheme),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
// Done //
