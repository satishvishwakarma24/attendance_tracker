import '/config/constant/env_config.dart';

/// Builds Google Static Maps image URLs using [EnvConfig.googleMapsApiKey].
abstract final class StaticMapUrl {
  /// Google Static Maps max dimension is 640 per side (use scale=2 for retina).
  static const int maxSide = 640;

  static bool get hasGoogleKey => EnvConfig.googleMapsApiKey.trim().isNotEmpty;

  static String preview({
    required double lat,
    required double lng,
    int zoom = 13,
    int width = 600,
    int height = 300,
    bool retina = true,
  }) {
    final safeWidth = width.clamp(1, maxSide);
    final safeHeight = height.clamp(1, maxSide);
    final key = EnvConfig.googleMapsApiKey.trim();
    final scale = retina ? '&scale=2' : '';
    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$lat,$lng&zoom=$zoom&size=${safeWidth}x$safeHeight&maptype=roadmap'
        '&markers=color:red%7Clabel:A%7C$lat,$lng'
        '$scale&key=${Uri.encodeQueryComponent(key)}';
  }
}
