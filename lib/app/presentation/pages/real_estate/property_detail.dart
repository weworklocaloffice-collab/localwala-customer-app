/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 */

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:user/gen/l10n/app_localizations.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/core/recently_viewed_store.dart';
import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/presentation/pages/real_estate/enquiry_form.dart';
import 'package:user/app/presentation/pages/real_estate/hold_terms.dart';
import 'package:user/app/presentation/pages/real_estate/loan_request_form.dart';
import 'package:user/app/presentation/pages/real_estate/real_estate_l10n.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/property_card.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/save_property_button.dart';
import 'package:user/app/services/shared_pref.dart';

/// Property detail screen — gallery, specs, price, "Submit Enquiry".
/// Public, no auth required to view; auth is only needed to submit the
/// enquiry (handled in the form).
class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final _repo = RealEstateRepository();
  final _recentlyViewed = RecentlyViewedStore(SharedPreferencesManager());

  bool _loading = true;
  PropertyModel? _property;
  List<PropertyModel> _similar = const [];
  PropertyVerificationModel? _verification;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await _repo.propertyById(widget.propertyId);
      List<PropertyModel> sim = const [];
      try {
        sim = await _repo.similarProperties(widget.propertyId);
      } catch (_) {
        // similar is best-effort
      }
      // Verification metadata is best-effort too: a property with no
      // verified documents must still render. The endpoint returns
      // document TYPES only - never a file url (BR-18).
      PropertyVerificationModel? verification;
      try {
        verification = await _repo.propertyVerification(widget.propertyId);
      } catch (_) {
        // verification is best-effort
      }
      if (!mounted) return;
      setState(() {
        _property = p;
        _similar = sim;
        _verification = verification;
        _loading = false;
      });
      // Record this view in local recently-viewed history (no backend hit).
      // Fire-and-forget — a slow disk write does not block the screen.
      unawaited(_recentlyViewed.record(p.id));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load property';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(translate.re_search_title),
        actions: _property == null
            ? null
            : [SavePropertyButton(propertyId: _property!.id)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(translate.re_error_generic),
              ),
            )
          : _buildBody(theme, _property!, translate),
      bottomNavigationBar: _property == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.send),
                        label: Text(translate.re_enquire),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EnquiryFormScreen(
                                propertyId: _property!.id,
                                propertyTitle: translate.propertyTitle(
                                  _property!,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        icon: const Icon(Icons.lock_clock),
                        label: Text(translate.re_hold),
                        onPressed:
                            _property!.availability == 'SOLD' ||
                                _property!.availability == 'RENTED' ||
                                _property!.availability == 'SUSPENDED'
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => HoldTermsScreen(
                                      propertyId: _property!.id,
                                    ),
                                  ),
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    PropertyModel p,
    AppLocalizations translate,
  ) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Gallery
        if (p.media.isNotEmpty)
          SizedBox(
            height: 240,
            child: PageView.builder(
              itemCount: p.media.length,
              itemBuilder: (context, i) => CachedNetworkImage(
                imageUrl: p.media[i],
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: theme.dividerColor),
                errorWidget: (_, __, ___) => Container(
                  color: theme.dividerColor,
                  child: const Icon(Icons.apartment, size: 48),
                ),
              ),
            ),
          )
        else
          Container(
            height: 200,
            color: theme.dividerColor,
            child: const Center(child: Icon(Icons.apartment, size: 48)),
          ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + verified
              Row(
                children: [
                  if (p.verified) ...[
                    Icon(
                      Icons.verified,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      translate.propertyTitle(p),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Price
              Text(
                translate.propertyPrice(p),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Location
              if (p.addressLine != null || p.locality != null || p.city != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        [p.addressLine, p.locality, p.city, p.pincode]
                            .where((e) => e != null && e.toString().isNotEmpty)
                            .join(', '),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // Specs
              if (p.area != null || p.bedrooms != null || p.bathrooms != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (p.area != null)
                      Chip(
                        label: Text(
                          translate.re_area_sqft(p.area!.toStringAsFixed(0)),
                        ),
                      ),
                    if (p.bedrooms != null)
                      Chip(label: Text(translate.re_bhk(p.bedrooms!))),
                    if (p.bathrooms != null)
                      Chip(label: Text(translate.re_bath(p.bathrooms!))),
                    if (p.parking != null)
                      Chip(label: Text(translate.re_parking(p.parking!))),
                  ],
                ),
              const SizedBox(height: 16),

              // Description
              if (p.description != null && p.description!.isNotEmpty) ...[
                Text(
                  translate.re_property_about,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(p.description!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
              ],

              // Verification badge
              if (p.verified)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          translate.re_verified_badge,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Verified documents (BR-18). Types only - the customer
              // learns that a document cleared, never what it is or
              // where the file lives.
              if (_verification != null && _verification!.hasDocuments) ...[
                const SizedBox(height: 16),
                _VerifiedDocumentsCard(verification: _verification!),
              ],

              // Loan entry (Flow 12). Hidden for the same dead states
              // the Hold button refuses — no loan on a sold/rented unit.
              if (p.availability != 'SOLD' &&
                  p.availability != 'RENTED' &&
                  p.availability != 'SUSPENDED') ...[
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Icon(
                        Icons.account_balance_outlined,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(translate.re_loan_request_title),
                    subtitle: Text(translate.re_compare_offers_subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LoanRequestFormScreen(
                            propertyId: p.id,
                            propertyTitle: translate.propertyTitle(p),
                          ),
                        ),
                      );
                      if (result == 'requested' && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(translate.re_loan_submitted)),
                        );
                      }
                    },
                  ),
                ),
              ],

              // Similar properties
              if (_similar.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(translate.re_similar, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _similar.length,
                    itemBuilder: (context, i) {
                      final s = _similar[i];
                      return SizedBox(
                        width: 200,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i == _similar.length - 1 ? 0 : 12,
                          ),
                          child: PropertyCard(
                            property: s,
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PropertyDetailScreen(propertyId: s.id),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The document types that cleared verification for this property.
///
/// BR-18: a customer is entitled to know *that* an ownership document
/// cleared - not to the document. So this card renders category names
/// only; there is no url, no filename and no download.
class _VerifiedDocumentsCard extends StatelessWidget {
  final PropertyVerificationModel verification;

  const _VerifiedDocumentsCard({required this.verification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    final dateText = verification.verifiedAt == null
        ? null
        : MaterialLocalizations.of(
            context,
          ).formatMediumDate(verification.verifiedAt!);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    translate.re_documents_verified_title,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            if (dateText != null) ...[
              const SizedBox(height: 4),
              Text(
                translate.re_documents_verified_on(dateText),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: verification.documentsCleared
                  .map(
                    (category) => Chip(
                      avatar: const Icon(Icons.check_circle, size: 16),
                      label: Text(translate.documentCategory(category)),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}
