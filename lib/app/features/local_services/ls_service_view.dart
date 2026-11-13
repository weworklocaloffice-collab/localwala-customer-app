import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/features/local_services/ls_booking_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';
import 'package:user/app/features/local_services/models/models.dart';
import 'package:user/app/features/local_services/services/local_services_customer_service.dart';

/// Service detail: what it is, how it books, live availability, and the
/// honest price line - "quote needed" for quote modes, never a fake fixed
/// amount. Booking starts here via [LsBookingView].
class LsServiceView extends StatefulWidget {
  const LsServiceView({super.key, required this.service});

  final LsService service;

  @override
  State<LsServiceView> createState() => _LsServiceViewState();
}

class _LsServiceViewState extends State<LsServiceView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _checking = false;
  List<dynamic> _slots = const <dynamic>[];
  String? _slotError;
  bool _favorite = false;
  bool _favBusy = false;
  String _mediaUrl = '';

  @override
  void initState() {
    super.initState();
    _loadFavorite();
    _loadMediaUrl();
  }

  Future<void> _loadMediaUrl() async {
    final String url = await AuthRepository().getMediaUrl();
    if (mounted) setState(() => _mediaUrl = url);
  }

  String _resolveImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (_mediaUrl.isEmpty) return path;
    final String base = _mediaUrl.endsWith('/') ? _mediaUrl : '$_mediaUrl/';
    final String key = path.startsWith('/') ? path.substring(1) : path;
    return '$base$key';
  }

  Future<void> _loadFavorite() async {
    try {
      final dynamic res = await _service.isFavorite(widget.service.id);
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
      if (mounted) {
        setState(() => _favorite = body['favorite'] == true);
      }
    } catch (_) {
      // non-blocking; heart stays unfilled
    }
  }

  Future<void> _toggleFavorite() async {
    if (_favBusy) return;
    setState(() => _favBusy = true);
    try {
      final bool next = !_favorite;
      if (next) {
        await _service.addFavorite(widget.service.id);
      } else {
        await _service.removeFavorite(widget.service.id);
      }
      if (mounted) setState(() => _favorite = next);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_favorite_failed ??
                  'Could not update favourite.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _favBusy = false);
    }
  }

  Future<void> _checkAvailability() async {
    setState(() {
      _checking = true;
      _slotError = null;
    });
    try {
      final DateTime start = DateTime.now().add(const Duration(days: 1));
      final DateTime end = start.add(
        Duration(minutes: widget.service.baseDurationMinutes),
      );
      final dynamic res = await _service.availability(
        serviceId: widget.service.id,
        startAt: start.toIso8601String(),
        endAt: end.toIso8601String(),
      );
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
      setState(() {
        _slots = (body['results'] ?? []) as List<dynamic>;
        _checking = false;
      });
    } catch (e) {
      setState(() {
        _slotError = 'Availability unavailable right now.';
        _checking = false;
      });
    }
  }

  void _openBooking() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LsBookingView(service: widget.service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LsService s = widget.service;
    final int available = _slots
        .where((dynamic e) => (e as Map)['available'] == true)
        .length;
    final AppLocalizations? t = AppLocalizations.of(context);
    final String priceText = s.needsQuote
        ? (t?.ls_quote_needed ?? 'Quote needed')
        : (s.minPrice > 0 || s.maxPrice > 0
            ? '${s.minPrice} - ${s.maxPrice}'
            : (t?.ls_price_on_request ?? 'Price on request'));
    return Scaffold(
      appBar: AppBar(
        title: Text(s.name),
        actions: <Widget>[
          IconButton(
            onPressed: _favBusy ? null : _toggleFavorite,
            tooltip: t?.ls_favorites ?? 'Favorites',
            icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Hero image
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: s.image.isNotEmpty
                ? Image.network(
                    _resolveImageUrl(s.image),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.handyman_outlined,
                          size: 64, color: Colors.grey),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.handyman_outlined,
                        size: 64, color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 16),
          // Title + rating
          Row(
            children: <Widget>[
              Expanded(
                child: Text(s.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              if (s.avgRating > 0) ...<Widget>[
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(s.avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(s.description.isNotEmpty ? s.description : (t?.ls_no_description ?? 'No description available.'),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          const SizedBox(height: 12),
          // Info chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _infoChip(Icons.schedule, '${s.baseDurationMinutes} min'),
              _infoChip(Icons.payments, priceText),
              _infoChip(Icons.book_online, s.bookingMode),
              if (s.depositPercent > 0)
                _infoChip(Icons.account_balance_wallet,
                    t?.ls_deposit_percent(s.depositPercent) ?? 'Deposit ${s.depositPercent}%'),
            ],
          ),
          const SizedBox(height: 16),
          if (s.needsQuote)
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  t?.ls_quote_card ??
                      'Final price comes as a provider quotation after inspection. '
                          'The booking fee (if any) shows separately at checkout.',
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Booking CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openBooking,
              icon: const Icon(Icons.calendar_today),
              label: Text(s.needsQuote
                  ? (t?.ls_request_quote ?? 'Request quote')
                  : (t?.ls_book_now ?? 'Book now')),
            ),
          ),
          const SizedBox(height: 12),
          // Availability
          OutlinedButton.icon(
            onPressed: _checking ? null : _checkAvailability,
            icon: _checking
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.search),
            label: Text(_checking
                ? (t?.ls_checking_availability ?? 'Checking availability...')
                : (t?.ls_check_availability ?? 'Check tomorrow\'s availability'))
          ),
          if (_slotError != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_slotError!, style: const TextStyle(color: Colors.red)),
          ],
          if (_slots.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(t?.ls_providers_free(available) ?? '$available provider(s) free tomorrow',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._slots.whereType<Map>().map((Map raw) {
              final Map<String, dynamic> slot = Map<String, dynamic>.from(raw);
              final dynamic providerRaw = slot['provider'];
              final Map<String, dynamic> provider = providerRaw is Map
                  ? Map<String, dynamic>.from(providerRaw)
                  : <String, dynamic>{};
              final String name = '${provider['businessName'] ?? ''}';
              final String type = '${provider['providerType'] ?? ''}';
              final String image = '${slot['image'] ?? ''}';
              final bool isAvailable = slot['available'] == true;
              final bool sponsored = slot['sponsored'] == true;
              final String status = isAvailable
                  ? (t?.ls_available_tomorrow ?? 'Available tomorrow')
                  : (t?.ls_fully_booked ?? 'Fully booked');
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: image.isEmpty
                      ? const CircleAvatar(
                          child: Icon(Icons.storefront_outlined))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _resolveImageUrl(image),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.storefront_outlined,
                                  size: 20),
                            ),
                          ),
                        ),
                  title: Text(
                      name.isEmpty ? (t?.ls_provider ?? 'Provider') : name),
                  subtitle: Text(type.isEmpty ? status : '$type · $status'),
                  trailing: sponsored
                      ? Chip(
                          label: Text(t?.ls_sponsored_badge ?? 'Sponsored',
                              style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                        )
                      : null,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
    );
  }
}