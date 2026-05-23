import 'package:geolocator/geolocator.dart';

import '/data/models/office_location_model.dart';

class GeofenceMatch {
  final OfficeLocationModel location;
  final double distanceMeters;

  const GeofenceMatch({
    required this.location,
    required this.distanceMeters,
  });
}

abstract final class GeofenceService {
  static double distanceMeters({
    required double userLat,
    required double userLng,
    required OfficeLocationModel office,
  }) {
    return Geolocator.distanceBetween(
      userLat,
      userLng,
      office.latitude,
      office.longitude,
    );
  }

  /// Returns the nearest active office the user is inside, if any.
  static GeofenceMatch? findInsideOffice({
    required double userLat,
    required double userLng,
    required List<OfficeLocationModel> offices,
  }) {
    GeofenceMatch? nearestInside;

    for (final office in offices) {
      if (!office.isActive) continue;
      final dist = distanceMeters(
        userLat: userLat,
        userLng: userLng,
        office: office,
      );
      if (dist <= office.radiusMeters) {
        if (nearestInside == null || dist < nearestInside.distanceMeters) {
          nearestInside = GeofenceMatch(location: office, distanceMeters: dist);
        }
      }
    }
    return nearestInside;
  }

  /// Nearest office even when outside (for display).
  static GeofenceMatch? findNearest({
    required double userLat,
    required double userLng,
    required List<OfficeLocationModel> offices,
  }) {
    GeofenceMatch? nearest;
    for (final office in offices) {
      if (!office.isActive) continue;
      final dist = distanceMeters(
        userLat: userLat,
        userLng: userLng,
        office: office,
      );
      if (nearest == null || dist < nearest.distanceMeters) {
        nearest = GeofenceMatch(location: office, distanceMeters: dist);
      }
    }
    return nearest;
  }
}
