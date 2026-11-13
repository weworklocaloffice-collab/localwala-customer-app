import 'package:flutter/material.dart';
import 'package:user/app/features/dairy/dairy_view_helpers.dart';

class DairyHeaderBanner extends StatelessWidget {
  const DairyHeaderBanner({super.key, required this.campaign});

  final Map<String, dynamic> campaign;

  @override
  Widget build(BuildContext context) {
    if (campaign.isEmpty) return const SizedBox.shrink();
    final Map<String, dynamic> business = asMap(campaign['business']);
    final Map<String, dynamic> product = asMap(campaign['product']);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product['name']?.toString() ?? business['name']?.toString() ?? 'Dairy offer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  campaign['title']?.toString() ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.local_offer_outlined),
        ],
      ),
    );
  }
}