import 'package:flutter/material.dart';

import 'package:user/gen/l10n/app_localizations.dart';

/// Horizontal scrollable row of category chips for the Local Services home.
class LsCategoryChipRow extends StatelessWidget {
  const LsCategoryChipRow({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    this.mediaUrl = '',
  });

  final List<Map<String, dynamic>> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final String mediaUrl;

  static String _idOf(Map<String, dynamic> c) =>
      '${c['_id'] ?? c['id'] ?? ''}';

  String _resolveImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (mediaUrl.isEmpty) return path;
    final String base = mediaUrl.endsWith('/') ? mediaUrl : '$mediaUrl/';
    final String key = path.startsWith('/') ? path.substring(1) : path;
    return '$base$key';
  }

  Widget? _avatarFor(Map<String, dynamic> c) {
    final String path = '${c['image'] ?? c['imageUrl'] ?? ''}';
    if (path.isEmpty) return null;
    return ClipOval(
      child: Image.network(
        _resolveImageUrl(path),
        width: 22,
        height: 22,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.category_outlined, size: 16),
      ),
    );
  }

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
              selected: selectedId == null,
              onSelected: (_) => onSelected(null),
            );
          }
          final Map<String, dynamic> c = categories[i - 1];
          final String id = _idOf(c);
          final String name = '${c['name'] ?? c['key'] ?? id}';
          return ChoiceChip(
            avatar: _avatarFor(c),
            label: Text(name),
            selected: selectedId == id,
            onSelected: (_) => onSelected(id),
          );
        },
      ),
    );
  }
}
