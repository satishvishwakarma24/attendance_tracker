import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  /// Check permission status
  static Future<PermissionStatus> checkPermission(
    Permission permission,
  ) async {
    return await permission.status;
  }

  /// Request a single permission
  static Future<bool> requestPermission(
    Permission permission,
  ) async {
    final status = await permission.request();
    return status.isGranted;
  }

  /// Request multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Check if permission is granted
  static Future<bool> isGranted(Permission permission) async {
    return await permission.isGranted;
  }

  /// Check if permission is denied
  static Future<bool> isDenied(Permission permission) async {
    return await permission.isDenied;
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermanentlyDenied(
    Permission permission,
  ) async {
    return await permission.isPermanentlyDenied;
  }

  /// Open app settings
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  // ----------------------------
  // Common Permission Helpers
  // ----------------------------

  static Future<bool> requestCameraPermission() async {
    return await requestPermission(Permission.camera);
  }

  static Future<bool> requestStoragePermission() async {
    return await requestPermission(Permission.storage);
  }

  static Future<bool> requestPhotosPermission() async {
    return await requestPermission(Permission.photos);
  }

  static Future<bool> requestLocationPermission() async {
    return await requestPermission(Permission.location);
  }

  static Future<bool> requestNotificationPermission() async {
    return await requestPermission(Permission.notification);
  }

  static Future<bool> requestMicrophonePermission() async {
    return await requestPermission(Permission.microphone);
  }

  static Future<bool> requestContactsPermission() async {
    return await requestPermission(Permission.contacts);
  }

  /// Open location settings on the device
  static Future<bool> openLocationSettings() async {
    return await openAppSettings();
  }

  /// Check and request location permission with detailed status
  static Future<Map<String, dynamic>> requestLocationWithStatus() async {
    final status = await Permission.location.request();
    return {
      'granted': status.isGranted,
      'denied': status.isDenied,
      'permanentlyDenied': status.isPermanentlyDenied,
      'status': status,
    };
  }
}

/*
bool granted = await PermissionHandler.requestCameraPermission();

if (granted) {
  print("Camera permission granted");
} else {
  print("Permission denied");
}
 */
