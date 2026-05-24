import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of checking or requesting location while the app is in use.
enum LocationAccess {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

abstract final class LocationPermissionHelper {
  /// Reads current location service + permission state (no system prompt).
  static Future<LocationAccess> checkStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAccess.serviceDisabled;
    }

    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      return LocationAccess.granted;
    }
    if (status.isPermanentlyDenied) {
      return LocationAccess.permanentlyDenied;
    }
    return LocationAccess.denied;
  }

  /// Requests `locationWhenInUse` after the user has seen an in-app rationale.
  static Future<LocationAccess> requestWhileInUse() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAccess.serviceDisabled;
    }

    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      return LocationAccess.granted;
    }
    if (status.isPermanentlyDenied) {
      return LocationAccess.permanentlyDenied;
    }

    status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      return LocationAccess.granted;
    }
    if (status.isPermanentlyDenied) {
      return LocationAccess.permanentlyDenied;
    }
    return LocationAccess.denied;
  }

  /// Check first; request only if not yet granted.
  static Future<LocationAccess> ensureWhileInUse() async {
    final current = await checkStatus();
    if (current == LocationAccess.granted) {
      return LocationAccess.granted;
    }
    if (current == LocationAccess.permanentlyDenied ||
        current == LocationAccess.serviceDisabled) {
      return current;
    }
    return requestWhileInUse();
  }

  static String messageFor(LocationAccess access) {
    switch (access) {
      case LocationAccess.granted:
        return '';
      case LocationAccess.denied:
        return 'Location access is required while using the app to verify '
            'office geofences and punch in or out.';
      case LocationAccess.permanentlyDenied:
        return 'Location is turned off for Attendance Tracker. Enable '
            '"Allow only while using the app" in Settings.';
      case LocationAccess.serviceDisabled:
        return 'Turn on device location (GPS) to check office zones and punch.';
    }
  }

  /// Opens the system screen appropriate for [access] (GPS vs app permission).
  static Future<void> openSettingsFor(LocationAccess access) async {
    switch (access) {
      case LocationAccess.serviceDisabled:
        await Geolocator.openLocationSettings();
      case LocationAccess.permanentlyDenied:
        await openAppSettings();
      case LocationAccess.granted:
      case LocationAccess.denied:
        break;
    }
  }

  static bool needsSystemSettings(LocationAccess access) =>
      access == LocationAccess.serviceDisabled ||
      access == LocationAccess.permanentlyDenied;
}
