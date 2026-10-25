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

import 'package:user/gen/l10n/app_localizations.dart';

import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/presentation/pages/real_estate/property_detail.dart';
import 'package:user/app/presentation/pages/real_estate/real_estate_l10n.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/property_card.dart';

/// "Saved" — the customer's favourites list for real estate.
///
/// Reuses the shared backend Favourite with `type: 'property'`. Each
/// card opens the same `PropertyDetailScreen` used elsewhere; long-press
/// to unsave (with confirmation).
class SavedPropertiesScreen extends StatefulWidget {
  const SavedPropertiesScreen({super.key});

  @override
  State<SavedPropertiesScreen> createState() => _SavedPropertiesScreenState();
}

class _SavedPropertiesScreenState extends State<SavedPropertiesScreen> {
  final _repo = RealEstateRepository();

  bool _loading = true;
  List<dynamic> _items = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repo.savedProperties();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your saved properties';
        _loading = false;
      });
    }
  }

  Future<void> _unsave(String propertyId) async {
    try {
      await _repo.removeSavedProperty(propertyId);
      if (!mounted) return;
      setState(() {
        _items = _items.where((p) => p.id != propertyId).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.re_unsave_failed)),
      );
    }
  }

  Future<void> _confirmUnsave(String propertyId, String label) async {
    final translate = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translate.re_remove_from_saved),
        content: Text(translate.re_remove_from_saved_confirm(label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(translate.cancel_title),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(translate.remove),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _unsave(propertyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(translate.re_saved_title)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    translate.re_error_generic,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _items.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(translate.re_no_saved)),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final p = _items[i];
                  return PropertyCard(
                    property: p,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PropertyDetailScreen(propertyId: p.id),
                        ),
                      );
                    },
                    onLongPress: () =>
                        _confirmUnsave(p.id, translate.propertyTitle(p)),
                  );
                },
              ),
      ),
    );
  }
}
