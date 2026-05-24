abstract class AppConfig {
  static const String appName = 'Attendance Tracker';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Location-aware attendance for office geofences. '
      'Employees punch in and out inside registered locations; '
      'super admins manage offices and monitor attendance.';

  /// Web client ID from Firebase Console → Authentication → Google → Web SDK config.
  static const String googleWebClientId =
      '854033715988-kpnkvevkj6t6on51sjvd6e4jas2vn8r3.apps.googleusercontent.com';
}
