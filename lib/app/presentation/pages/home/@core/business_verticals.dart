import 'package:flutter/material.dart';
import 'package:user/gen/l10n/app_localizations.dart';

enum BusinessVerticalId { stores, services, meat, realEstate }

class BusinessVertical {
  const BusinessVertical({
    required this.id,
    required this.label,
    required this.icon,
  });

  final BusinessVerticalId id;
  final String label;
  final IconData icon;
}

List<BusinessVertical> buildBusinessVerticals(AppLocalizations translate) => <BusinessVertical>[
  BusinessVertical(
    id: BusinessVerticalId.stores,
    label: translate.stores_entry_title,
    icon: Icons.storefront_outlined,
  ),
  BusinessVertical(
    id: BusinessVerticalId.services,
    label: translate.vertical_services,
    icon: Icons.handyman_outlined,
  ),
  BusinessVertical(
    id: BusinessVerticalId.meat,
    label: translate.vertical_meat,
    icon: Icons.kebab_dining,
  ),
  BusinessVertical(
    id: BusinessVerticalId.realEstate,
    label: translate.re_search_title,
    icon: Icons.apartment,
  ),
];
