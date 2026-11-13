import 'package:flutter/material.dart';
import 'package:user/app/router/app_route_config.dart';

class DairyCartSummaryBar extends StatelessWidget {
  const DairyCartSummaryBar({
    super.key,
    required this.count,
    required this.totalLabel,
  });

  final int count;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRouter.dairyCartRoute),
          child: Text('Cart ($count) · $totalLabel'),
        ),
      ),
    );
  }
}