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

import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Heart / bookmark toggle for a single property.
///
/// Self-contained: loads its own saved-state on mount, optimistic
/// update on tap, and rolls back on error. Use in the property detail
/// AppBar (or as an icon button overlay on the gallery).
class SavePropertyButton extends StatefulWidget {
  final String propertyId;
  final Color? activeColor;
  final Color? inactiveColor;

  const SavePropertyButton({
    super.key,
    required this.propertyId,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<SavePropertyButton> createState() => _SavePropertyButtonState();
}

class _SavePropertyButtonState extends State<SavePropertyButton> {
  final _repo = RealEstateRepository();

  bool? _isSaved; // null = loading, true = saved, false = not saved
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final saved = await _repo.isPropertySaved(widget.propertyId);
      if (!mounted) return;
      setState(() => _isSaved = saved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaved = false);
    }
  }

  Future<void> _toggle() async {
    if (_busy || _isSaved == null) return;
    final previous = _isSaved!;
    setState(() {
      _isSaved = !previous;
      _busy = true;
    });
    try {
      if (previous) {
        await _repo.removeSavedProperty(widget.propertyId);
      } else {
        await _repo.saveProperty(widget.propertyId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaved = previous); // rollback
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    if (_isSaved == null) {
      return IconButton(
        icon: const Icon(Icons.favorite_border),
        onPressed: null,
        tooltip: translate.re_save_tooltip,
      );
    }
    final isSaved = _isSaved!;
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isSaved ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isSaved),
          color: isSaved
              ? (widget.activeColor ?? Colors.redAccent)
              : widget.inactiveColor,
        ),
      ),
      onPressed: _busy ? null : _toggle,
      tooltip: isSaved ? translate.re_saved_tooltip : translate.re_save_tooltip,
    );
  }
}
