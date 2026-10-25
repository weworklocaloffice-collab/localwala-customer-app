import 'package:flutter/material.dart';
import 'package:user/app/presentation/pages/home/@core/business_verticals.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';

class BusinessVerticalStrip extends StatelessWidget {
  const BusinessVerticalStrip({
    super.key,
    required this.verticals,
    required this.onSelected,
    this.height = 64,
  });

  final List<BusinessVertical> verticals;
  final ValueChanged<BusinessVertical> onSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeProvider.scaffoldPadding,
          vertical: 12,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: verticals.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final BusinessVertical vertical = verticals[index];
          return _VerticalChip(
            vertical: vertical,
            onTap: () => onSelected(vertical),
          );
        },
      ),
    );
  }
}

class _VerticalChip extends StatelessWidget {
  const _VerticalChip({required this.vertical, required this.onTap});

  final BusinessVertical vertical;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(20);
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: radius,
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(vertical.icon, size: 18, color: theme.primaryColor),
            const SizedBox(width: 6),
            Text(vertical.label, style: kAppLblMediumFontMedium(context)),
          ],
        ),
      ),
    );
  }
}
