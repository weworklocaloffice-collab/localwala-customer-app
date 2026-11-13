import 'package:flutter/material.dart';
import 'package:user/app/features/dairy/dairy_view_helpers.dart';

class DairyPromoBanner extends StatelessWidget {
  const DairyPromoBanner({super.key, required this.campaigns});

  final List<dynamic> campaigns;

  @override
  Widget build(BuildContext context) {
    if (campaigns.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 120,
      child: PageView.builder(
        itemCount: campaigns.length,
        itemBuilder: (BuildContext context, int index) {
          final Map<String, dynamic> c = asMap(campaigns[index]);
          final Map<String, dynamic> business = asMap(c['business']);
          final Map<String, dynamic> product = asMap(c['product']);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product['name']?.toString() ??
                        business['name']?.toString() ??
                        'Offer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c['title']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}