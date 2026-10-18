/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 */

import 'package:flutter/material.dart';

import 'package:user/gen/l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/presentation/pages/real_estate/property_detail.dart';

/// Map search — find published properties near the device's current
/// location. The backend's `nearby()` (Flow 14) returns results
/// ordered by distance ascending via Mongo's `$near`.
///
/// The map renders one marker per property. Tapping a marker opens a
/// draggable bottom sheet with a compact property card. Tapping the
/// card navigates to the full property detail screen.
///
/// ## Why no filter UI in v1
///
/// Search radius defaults to 5 km and the 50 km ceiling is enforced
/// server-side (verified by `verify.realestate.search.js`). Adding
/// transaction-type / price filters in the bottom sheet is Phase 5
/// work — the data is already wired through `nearbyProperties()` on
/// the repository, so adding controls is purely UI.
class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final _repo = RealEstateRepository();
  GoogleMapController? _mapController;

  static const _defaultRadiusMeters = 5000;
  static const _fallbackLat = 17.3850; // Hyderabad — used when location is denied
  static const _fallbackLng = 78.4867;

  bool _loadingLocation = true;
  bool _loadingProperties = false;
  LatLng? _userLocation;
  String? _locationError;
  String? _propertyError;
  List<PropertyModel> _properties = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final loc = await _resolveLocation();
    if (!mounted) return;
    setState(() {
      _userLocation = loc;
      _loadingLocation = false;
      if (loc == null) {
        // No permission / no fix — fall back to a city centre so the
        // screen still renders something. The user can pan the map.
        _userLocation = const LatLng(_fallbackLat, _fallbackLng);
      }
    });
    await _loadProperties();
  }

  /// Returns the device's current LatLng, or null on any failure
  /// (permission denied, service off, timeout). The caller falls
  /// back to a city-centre default so the screen is still useful.
  Future<LatLng?> _resolveLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      if (mounted) {
        setState(() => _locationError = 'Location unavailable; showing a city centre');
      }
      return null;
    }
  }

  Future<void> _loadProperties() async {
    final loc = _userLocation;
    if (loc == null) return;
    setState(() {
      _loadingProperties = true;
      _propertyError = null;
    });
    try {
      final list = await _repo.nearbyProperties(
        lng: loc.longitude,
        lat: loc.latitude,
        radiusMeters: _defaultRadiusMeters,
        limit: 50,
      );
      if (!mounted) return;
      setState(() {
        _properties = list;
        _loadingProperties = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _propertyError = 'Could not load nearby properties';
        _loadingProperties = false;
      });
    }
  }

  void _onMarkerTap(PropertyModel p) {
    _showBottomSheet(p);
  }

  void _showBottomSheet(PropertyModel p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return _PropertyBottomSheet(
          property: p,
          onOpen: () {
            Navigator.of(sheetCtx).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PropertyDetailScreen(propertyId: p.id),
              ),
            );
          },
        );
      },
    );
  }

  void _animateTo(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(translate.re_map_title),
        actions: [
          if (_userLocation != null)
            IconButton(
              tooltip: translate.re_map_recenter,
              icon: const Icon(Icons.my_location),
              onPressed: () {
                if (_userLocation != null) _animateTo(_userLocation!);
                _loadProperties();
              },
            ),
        ],
      ),
      body: _loadingLocation
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _buildMap(theme),
                if (_locationError != null) _buildLocationBanner(theme),
                if (_loadingProperties) const _LoadingOverlay(),
                if (_propertyError != null) _buildErrorBanner(theme),
              ],
            ),
    );
  }

  Widget _buildMap(ThemeData theme) {
    final loc = _userLocation;
    if (loc == null) {
      return const Center(child: Text('Location unavailable'));
    }
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: loc, zoom: 13),
      onMapCreated: (c) => _mapController = c,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      markers: _buildMarkers(),
    );
  }

  Set<Marker> _buildMarkers() {
    return {
      for (final p in _properties)
        if (p.latitude != null && p.longitude != null)
          Marker(
            markerId: MarkerId(p.id),
            position: LatLng(p.latitude!, p.longitude!),
            infoWindow: InfoWindow(
              title: p.displayTitle,
              snippet: p.displayPrice,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PropertyDetailScreen(propertyId: p.id),
                ),
              ),
            ),
            onTap: () => _onMarkerTap(p),
          ),
    };
  }

  Widget _buildLocationBanner(ThemeData theme) {
    return Positioned(
      top: 8,
      left: 16,
      right: 16,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            _locationError!,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(ThemeData theme) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Material(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _propertyError!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: _loadProperties,
                child: Text(AppLocalizations.of(context)!.re_retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();
  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 8,
      right: 8,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _PropertyBottomSheet extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onOpen;

  const _PropertyBottomSheet({
    required this.property,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.18,
      maxChildSize: 0.6,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  property.displayTitle,
                  style: theme.textTheme.titleMedium,
                ),
                if (property.addressLine != null ||
                    property.locality != null ||
                    property.city != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      property.addressLine,
                      property.locality,
                      property.city
                    ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  property.displayPrice,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: Text(AppLocalizations.of(context)!.re_map_open_property),
                    onPressed: onOpen,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
