abstract class AppConfig {
  static const String appName = 'Attendance Tracker';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Location-aware attendance for office geofences. '
      'Employees punch in and out inside registered locations; '
      'super admins manage offices and monitor attendance.';

  /// Web client ID from Firebase Console → Authentication → Google → Web SDK config.
  /// Required on Android when `google-services.json` has empty `oauth_client`.
  /// Leave empty to rely on `google-services.json` after SHA-1 is configured.
  static const String googleWebClientId =
      '213373185921-js2r8ttiqebgs3of8c932qha20v0miga.apps.googleusercontent.com';
}
