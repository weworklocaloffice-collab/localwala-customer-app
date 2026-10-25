/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 *
 * This source code is proprietary to WeWorkLocal.
 */

import 'package:flutter/material.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Subcategory bottom sheet — shown when the user taps a group header
/// (e.g. "RESIDENTIAL") in the home section's "Browse by category"
/// grid. Lists every subcategory in the group as an action chip.
///
/// Tapping a chip invokes [onSelect] with the chosen category; the
/// caller is expected to close any open screens and navigate to the
/// search screen with the chosen key. Tapping outside the sheet
/// dismisses without calling [onSelect].
class SubcategoryPickerSheet extends StatelessWidget {
  final String groupName;
  final List<GroupedCategory> items;
  final void Function(GroupedCategory picked)? onSelect;

  const SubcategoryPickerSheet({
    super.key,
    required this.groupName,
    required this.items,
    this.onSelect,
  });

  /// Convenience launcher: opens the sheet using the host context's
  /// theme and runs [onSelect] in the caller if the user picks one.
  static Future<void> show(
    BuildContext context, {
    required String groupName,
    required List<GroupedCategory> items,
    void Function(GroupedCategory picked)? onSelect,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SubcategoryPickerSheet(
        groupName: groupName,
        items: items,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle — visual hint that the sheet is dismissible.
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(groupName, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  AppLocalizations.of(context)!.re_no_subcategories,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((c) {
                  return ActionChip(
                    label: Text(c.name),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onSelect?.call(c);
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
