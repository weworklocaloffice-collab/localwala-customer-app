import 'package:flutter/material.dart';

import 'package:user/gen/l10n/app_localizations.dart';

/// Horizontal scrollable row of category chips for the Local Services home.
class LsCategoryChipRow extends StatelessWidget {
  const LsCategoryChipRow({
    super.key,
    required this.categories,
    required this.selectedKey,
    required this.onSelected,
  });

  final List<Map<String, dynamic>> categories;
  final String? selectedKey;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int i) {
          if (i == 0) {
            final AppLocalizations? t = AppLocalizations.of(context);
            return ChoiceChip(
              label: Text(t?.ls_all ?? 'All'),
              selected: selectedKey == null,
              onSelected: (_) => onSelected(null),
            );
          }
          final Map<String, dynamic> c = categories[i - 1];
          final String key = '${c['key'] ?? ''}';
          final String name = '${c['name'] ?? key}';
          return ChoiceChip(
            label: Text(name),
            selected: selectedKey == key,
            onSelected: (_) => onSelected(key),
          );
        },
      ),
    );
  }
}