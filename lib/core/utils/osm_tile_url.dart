import 'dart:math' as math;

/// OpenStreetMap raster tile helpers (free, no API key or billing).
abstract final class OsmTileUrl {
  static const userAgent = 'AttendanceTracker/1.0';
  static const attribution = '© OpenStreetMap';

  static int tileX(double lng, int zoom) {
    final n = math.pow(2, zoom).toDouble();
    return ((lng + 180) / 360 * n).floor();
  }

  static int tileY(double lat, int zoom) {
    final latRad = lat * math.pi / 180;
    final n = math.pow(2, zoom).toDouble();
    return ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
            2 *
            n)
        .floor();
  }

  static String tile(int zoom, int x, int y) =>
      'https://tile.openstreetmap.org/$zoom/$x/$y.png';
}
