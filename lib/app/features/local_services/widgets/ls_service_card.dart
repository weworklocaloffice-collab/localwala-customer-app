import 'package:flutter/material.dart';

import 'package:user/app/features/local_services/models/models.dart';

/// Rich service card used on the Local Services home list.
class LsServiceCard extends StatelessWidget {
  const LsServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.mediaUrl = '',
  });

  final LsService service;
  final VoidCallback onTap;
  final String mediaUrl;

  String _resolveImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (mediaUrl.isEmpty) return path;
    final String base = mediaUrl.endsWith('/') ? mediaUrl : '$mediaUrl/';
    final String key = path.startsWith('/') ? path.substring(1) : path;
    return '$base$key';
  }

  @override
  Widget build(BuildContext context) {
    final String priceText = service.needsQuote
        ? 'Quote needed'
        : (service.minPrice > 0 || service.maxPrice > 0
            ? '${service.minPrice} - ${service.maxPrice}'
            : 'Price on request');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: service.image.isNotEmpty
                    ? Image.network(
                        _resolveImageUrl(service.image),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.handyman_outlined, size: 32, color: Colors.grey),
                      )
                    : const Icon(Icons.handyman_outlined, size: 32, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(service.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    if (service.description.isNotEmpty)
                      Text(
                        service.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        if (service.avgRating > 0) ...<Widget>[
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(service.avgRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                        ],
                        Text(priceText,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Text('${service.baseDurationMinutes} min',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: <Widget>[
                        if (service.needsQuote)
                          _badge('Quote', Colors.orange)
                        else
                          _badge(service.bookingMode, Colors.blue),
                        if (service.bookingMode == 'INSTANT')
                          _badge('Instant', Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}