import 'dart:convert';
import 'dart:io';
import 'package:geocoding/geocoding.dart' show GeocodingPlatform;
import 'osm_tile_url.dart';

/// A place returned from address search (Nominatim).
class AddressSuggestion {
  const AddressSuggestion({
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  final String label;
  final double latitude;
  final double longitude;
}

/// Forward/reverse geocoding for the location picker (Nominatim + platform).
abstract final class AddressGeocoding {
  static const _suggestionLimit = 5;
  static const _minQueryLength = 2;

  /// Autocomplete-style suggestions while the user types.
  static Future<List<AddressSuggestion>> searchSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < _minQueryLength) return [];

    final results = await _nominatimSearch(trimmed, limit: _suggestionLimit);
    return results
        .map(
          (item) => AddressSuggestion(
            label: item.displayName,
            latitude: item.latitude,
            longitude: item.longitude,
          ),
        )
        .toList();
  }

  static Future<(double latitude, double longitude)?> coordinatesForAddress(
    String address,
  ) async {
    final query = address.trim();
    if (query.isEmpty) return null;

    final nominatim = await _nominatimSearch(query, limit: 1);
    if (nominatim.isNotEmpty) {
      final first = nominatim.first;
      return (first.latitude, first.longitude);
    }

    final platform = GeocodingPlatform.instance;
    if (platform == null) return null;

    try {
      final locations = await platform.locationFromAddress(query);
      if (locations.isEmpty) return null;
      final loc = locations.first;
      return (loc.latitude, loc.longitude);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> placeNameForCoordinates(
    double latitude,
    double longitude,
  ) async {
    final platform = GeocodingPlatform.instance;
    if (platform != null) {
      try {
        final places =
            await platform.placemarkFromCoordinates(latitude, longitude);
        if (places.isNotEmpty) {
          final place = places.first;
          final name = place.name?.trim();
          final locality = place.locality?.trim();
          if (name != null && name.isNotEmpty) return name;
          if (locality != null && locality.isNotEmpty) return locality;
        }
      } catch (_) {
        // Best-effort.
      }
    }
    return null;
  }

  static Future<List<_NominatimHit>> _nominatimSearch(
    String query, {
    required int limit,
  }) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': query,
        'format': 'json',
        'limit': '$limit',
        'addressdetails': '0',
      },
    );

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', OsmTileUrl.userAgent);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return [];

      final body = await response.transform(utf8.decoder).join();
      final results = jsonDecode(body) as List<dynamic>;

      return results
          .map((raw) {
            final item = raw as Map<String, dynamic>;
            final lat = double.tryParse(item['lat']?.toString() ?? '');
            final lng = double.tryParse(item['lon']?.toString() ?? '');
            final name = item['display_name']?.toString().trim() ?? '';
            if (lat == null || lng == null || name.isEmpty) return null;
            return _NominatimHit(
              displayName: name,
              latitude: lat,
              longitude: lng,
            );
          })
          .whereType<_NominatimHit>()
          .toList();
    } catch (_) {
      return [];
    } finally {
      client.close();
    }
  }
}

class _NominatimHit {
  const _NominatimHit({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;
}
