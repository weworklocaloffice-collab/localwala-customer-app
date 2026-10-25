/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright Ac 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 */

import 'package:flutter/material.dart';

import 'package:user/app/presentation/pages/real_estate/hold_list.dart';
import 'package:user/app/presentation/pages/real_estate/loan_applications.dart';
import 'package:user/app/presentation/pages/real_estate/map_search.dart';
import 'package:user/app/presentation/pages/real_estate/purchases.dart';
import 'package:user/app/presentation/pages/real_estate/visits_list.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/real_estate_discovery_section.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/real_estate_entry_card.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/real_estate_home_section.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class RealEstateHomeScreen extends StatelessWidget {
  const RealEstateHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(translate.re_search_title),
        actions: [
          IconButton(
            tooltip: translate.re_map_view_tooltip,
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MapSearchScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeProvider.scaffoldPadding,
            ),
            child: const RealEstateEntryCard(),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeProvider.scaffoldPadding,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickAction(
                  icon: Icons.favorite_border,
                  label: translate.re_saved_title,
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRouter.reSavedPropertiesRoute,
                  ),
                ),
                _QuickAction(
                  icon: Icons.assignment_outlined,
                  label: translate.re_my_enquiries,
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRouter.reLeadsRoute,
                  ),
                ),
                _QuickAction(
                  icon: Icons.event_available_outlined,
                  label: translate.re_visit_list_title,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VisitsListScreen(),
                    ),
                  ),
                ),
                _QuickAction(
                  icon: Icons.account_balance_outlined,
                  label: translate.re_loan_list_title,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoanApplicationsScreen(),
                    ),
                  ),
                ),
                _QuickAction(
                  icon: Icons.lock_clock_outlined,
                  label: translate.re_hold_list_title,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MyHoldsScreen(),
                    ),
                  ),
                ),
                _QuickAction(
                  icon: Icons.shopping_bag_outlined,
                  label: translate.re_purchases_title,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PurchasesScreen(),
                    ),
                  ),
                ),
                _QuickAction(
                  icon: Icons.history,
                  label: translate.re_recently_viewed_title,
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRouter.reRecentlyViewedRoute,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const RealEstateHomeSection(),
          const RealEstateDiscoverySection(),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
