/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * This source code, including all associated assets, APIs, databases,
 * business logic, designs, and documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution, publication, resale,
 * reverse engineering, or use of this software without prior written
 * authorization is strictly prohibited.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/features/local_services/ls_service_view.dart';
import 'package:user/app/features/local_services/ls_booking_view.dart';
import 'package:user/app/features/local_services/ls_bookings_view.dart';
import 'package:user/app/features/local_services/services/local_services_customer_service.dart';
import 'package:user/app/features/local_services/models/models.dart';

/// Local Services storefront: categories as filter chips (from the API —
/// a new category is a data row, never a new screen) + service list.
///
/// Entry point for the vertical. Reached from home/launcher; inner screens
/// push via [Navigator] like the jhatka feature (no router surgery).
class LsHomeView extends StatefulWidget {
  const LsHomeView({super.key});

  @override
  State<LsHomeView> createState() => _LsHomeViewState();
}

class _LsHomeViewState extends State<LsHomeView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _categories = const <Map<String, dynamic>>[];
  List<LsService> _services = const <LsService>[];
  String? _selectedCategory;
  String? _selectedPricingMode;
  String? _selectedLocation;
  double? _minPrice;
  double? _maxPrice;
  int? _minDuration;
  int? _maxDuration;
  bool? _instantOnly;
  // A RATING, not a flag. Declared `bool?` while feeding a
// `DropdownButtonFormField<double>`, which made `value:` and the `onChanged` assignment
// both ill-typed and would have meant "filtered by false".
double? _ratingFilter;
  String? _speciality;
  List<String>? _amenities;
  String? _resource;
  bool? _sponsoredOnly;

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
      final dynamic catRes = await _service.categories();
      final dynamic svcRes = await _service.services(
        categoryId: _selectedCategory,
      );
      final Map<String, dynamic> catBody =
          Map<String, dynamic>.from(jsonDecode(catRes.body) as Map);
      final Map<String, dynamic> svcBody =
          Map<String, dynamic>.from(jsonDecode(svcRes.body) as Map);
      setState(() {
        _categories = ((catBody['results'] ?? []) as List)
            .whereType<Map<String, dynamic>>()
            .toList();
        _services = ((svcBody['results'] ?? []) as List)
            .whereType<Map<String, dynamic>>()
            .map(LsService.fromJson)
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Could not load services.';
      });
    }
  }

  Future<void> _applyFilters() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dynamic res = await _service.services(
        categoryId: _selectedCategory,
      );
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(res.body) as Map);
      setState(() {
        _services = ((body['results'] ?? []) as List)
            .whereType<Map<String, dynamic>>()
            .map(LsService.fromJson)
            .toList();
        // Client-side filtering for speciality, amenities, resource.
        //
        // The predicate used to test `_services.any(...)` with a closure whose body was a
        // bare expression and no `return`, so it evaluated to null instead of a bool, and
        // it answered for the WHOLE LIST rather than for the element being filtered. A
        // filter whose predicate ignores its parameter is not a filter.
        _services = _services.where((LsService s) {
          if (_speciality != null && _speciality!.isNotEmpty) {
            // Match THIS service. Speciality is a facet option; until facets are read
            // back on the service, a name match is the honest approximation.
            if (!s.name.toLowerCase().contains(_speciality!.toLowerCase())) {
              return false;
            }
          }
          // Amenities (facet MULTI_ENUM) and Resource (facet TEXT/ENUM) have no local
          // equivalent yet, so neither filters. Said plainly rather than as a `return true`
          // that reads like it does.
          return true;
        }).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Filter load failed: $e';
      });
    }
  }

// Build a chip for a facet option. Currently uncalled — kept because facets are the
// intended filter UI. `onSelected` takes the new bool because that is what
// `FilterChip.onSelected` (`ValueChanged<bool>?`) hands it; the old `Function()` could
// never be passed there.
Widget _buildFacetChip(String label, bool selected, ValueChanged<bool>? onSelected,
      {bool active = true}) {
    final Color color = selected
        ? Theme.of(context).colorScheme.primary
        : (active
            ? Colors.grey
            : Colors.grey.shade400);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: color,
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Services'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'My bookings',
            onPressed: () => Navigator.of(context)
                .push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LsBookingsView(),
                  ),
                )
                .then((_) => _load()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    children: <Widget>[
                      // Filters panel
                      _buildFiltersPanel(),
                      // Service list
                      Expanded(
                        child: _services.isEmpty
                            ? const Center(
                                child: Text('No services here yet.'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _services.length,
                                itemBuilder:
                                    (BuildContext context, int i) {
                                  final LsService s = _services[i];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: ListTile(
                                      title: Text(s.name),
                                      subtitle: Text(
                                        s.needsQuote
                                            ? 'Quote needed'
                                            : 'Booking: ${s.bookingMode}',
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                      ),
                                      onTap: () =>
                                          Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              LsServiceView(service: s),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Pricing range
            TextField(
              decoration: const InputDecoration(
                labelText: 'Min price ₹',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _minPrice = double.tryParse(value) ?? null;
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Max price ₹',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _maxPrice = double.tryParse(value) ?? null;
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 8),
            // Duration range
            TextField(
              decoration: const InputDecoration(
                labelText: 'Min duration min',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _minDuration = int.tryParse(value) ?? null;
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Max duration min',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _maxDuration = int.tryParse(value) ?? null;
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 8),
            // Instant only toggle
            ListTile(
              title: const Text('Instant only'),
              trailing: Checkbox(
                value: _instantOnly ?? false,
                onChanged: (bool? value) {
                  setState(() => _instantOnly = value);
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(height: 8),
            // Location filter
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              items: <String>['home', 'provider', 'online']
                  .map((String location) => DropdownMenuItem<String>(
                        value: location,
                        child: Text(location[0].toUpperCase() +
                            location.substring(1)),
                      ))
                  .toList(),
              onChanged: (String? value) {
                setState(() => _selectedLocation = value);
                _applyFilters();
              },
            ),
            const SizedBox(height: 8),
            // Rating filter
            Row(
              children: <Widget>[
                const Text('Min rating:'),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<double>(
                    value: _ratingFilter,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: <double>[4.0, 3.5, 3.0, 2.5, 2.0, 1.0]
                        .map((double rating) => DropdownMenuItem<double>(
                              value: rating,
                              child: Text(rating.toStringAsFixed(1)),
                            ))
                        .toList(),
                    onChanged: (double? value) {
                      setState(() => _ratingFilter = value);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Speciality filter (from facet ENUM/MULTI_ENUM)
            TextField(
              decoration: const InputDecoration(
                labelText: 'Speciality',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _speciality = value.isNotEmpty ? value : null);
                _applyFilters();
              },
            ),
            const SizedBox(height: 8),
            // Amenities filter (from facet MULTI_ENUM)
            TextField(
              decoration: const InputDecoration(
                labelText: 'Amenities (comma-separated)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _amenities = value.isNotEmpty ? value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() : null;
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 8),
            // Resource filter (rooms/vehicles/equipment)
            DropdownButtonFormField<String>(
              value: _resource,
              decoration: const InputDecoration(
                labelText: 'Resource',
                border: OutlineInputBorder(),
              ),
              // `map<String>` claimed the closure returns a String while it returns a
// `DropdownMenuItem<String>`. The type argument names the RESULT type, not the input.
items: <String>['', 'room', 'vehicle', 'equipment']
    .map<DropdownMenuItem<String>>((String location) => DropdownMenuItem<String>(
                        value: location,
                        child: Text(location.isEmpty ? 'Any' : location),
                      ))
                  .toList(),
              onChanged: (String? value) {
                setState(() => _resource = value ?? '');
                _applyFilters();
              },
            ),
            const SizedBox(height: 24),
            // Apply button
            ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}