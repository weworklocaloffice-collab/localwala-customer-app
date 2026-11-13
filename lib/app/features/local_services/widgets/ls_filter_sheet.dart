import 'package:flutter/material.dart';

import 'package:user/gen/l10n/app_localizations.dart';

/// Compact filter bottom sheet for the Local Services home.
/// Stateless: all filter values and mutations are delegated via callbacks.
class LsFilterSheet extends StatelessWidget {
  const LsFilterSheet({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.minDuration,
    required this.maxDuration,
    required this.ratingFilter,
    required this.instantOnly,
    required this.selectedPricingMode,
    required this.onMinPriceChanged,
    required this.onMaxPriceChanged,
    required this.onMinDurationChanged,
    required this.onMaxDurationChanged,
    required this.onRatingChanged,
    required this.onInstantChanged,
    required this.onPricingModeChanged,
    required this.onClear,
    required this.onApply,
  });

  final double? minPrice;
  final double? maxPrice;
  final int? minDuration;
  final int? maxDuration;
  final double? ratingFilter;
  final bool instantOnly;
  final String? selectedPricingMode;

  final ValueChanged<double?> onMinPriceChanged;
  final ValueChanged<double?> onMaxPriceChanged;
  final ValueChanged<int?> onMinDurationChanged;
  final ValueChanged<int?> onMaxDurationChanged;
  final ValueChanged<double?> onRatingChanged;
  final ValueChanged<bool> onInstantChanged;
  final ValueChanged<String?> onPricingModeChanged;
  final VoidCallback onClear;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? t = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(t?.ls_filters ?? 'Filters',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: onClear, child: Text(t?.ls_clear ?? 'Clear')),
              ],
            ),
            const SizedBox(height: 12),
            _field(t?.ls_min_price ?? 'Min price', minPrice?.toString() ?? '',
                (v) => onMinPriceChanged(double.tryParse(v))),
            _field(t?.ls_max_price ?? 'Max price', maxPrice?.toString() ?? '',
                (v) => onMaxPriceChanged(double.tryParse(v))),
            _field(t?.ls_min_duration ?? 'Min duration (min)', minDuration?.toString() ?? '',
                (v) => onMinDurationChanged(int.tryParse(v))),
            _field(t?.ls_max_duration ?? 'Max duration (min)', maxDuration?.toString() ?? '',
                (v) => onMaxDurationChanged(int.tryParse(v))),
            const SizedBox(height: 8),
            Text(t?.ls_rating ?? 'Rating', style: const TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 8,
              children: <double>[4.0, 3.0, 2.0].map((double r) {
                return ChoiceChip(
                  label: Text('$r+'),
                  selected: ratingFilter == r,
                  onSelected: (_) =>
                      onRatingChanged(ratingFilter == r ? null : r),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(t?.ls_instant_only ?? 'Instant booking only'),
              value: instantOnly,
              onChanged: onInstantChanged,
            ),
            const SizedBox(height: 8),
            Text(t?.ls_pricing_mode ?? 'Pricing mode',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 8,
              children: <String>['FIXED', 'QUOTE', 'INSPECTION_QUOTE']
                  .map((String m) {
                return ChoiceChip(
                  label: Text(m),
                  selected: selectedPricingMode == m,
                  onSelected: (_) => onPricingModeChanged(
                      selectedPricingMode == m ? null : m),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
                child: ElevatedButton(
                  onPressed: onApply,
                  child: Text(t?.ls_apply ?? 'Apply'),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String initial, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }
}