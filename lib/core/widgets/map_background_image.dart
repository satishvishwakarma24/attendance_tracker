import 'package:flutter/material.dart';

import '/core/utils/osm_tile_url.dart';
import '/core/utils/static_map_url.dart';

/// Map stack: asset, Google Static Maps (primary), OSM tiles (fallback).
class MapBackgroundImage extends StatelessWidget {
  const MapBackgroundImage({
    super.key,
    this.latitude,
    this.longitude,
    this.zoom = 13,
    this.mapWidth = 600,
    this.mapHeight = 300,
    this.fit = BoxFit.cover,
    this.child,
  });

  final double? latitude;
  final double? longitude;
  final int zoom;
  final int mapWidth;
  final int mapHeight;
  final BoxFit fit;
  final Widget? child;

  static const assetPath = 'assets/images/map_background.jpg';
  static const _tileHeaders = {'User-Agent': OsmTileUrl.userAgent};

  @override
  Widget build(BuildContext context) {
    final lat = latitude;
    final lng = longitude;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          assetPath,
          fit: fit,
          errorBuilder: (_, __, ___) => const _MapPatternFallback(),
        ),
        if (lat != null && lng != null)
          _LiveMapLayer(
            lat: lat,
            lng: lng,
            zoom: zoom,
            mapWidth: mapWidth,
            mapHeight: mapHeight,
            fit: fit,
            tileHeaders: _tileHeaders,
          ),
        if (child != null) child!,
      ],
    );
  }
}

class _LiveMapLayer extends StatefulWidget {
  const _LiveMapLayer({
    required this.lat,
    required this.lng,
    required this.zoom,
    required this.mapWidth,
    required this.mapHeight,
    required this.fit,
    required this.tileHeaders,
  });

  final double lat;
  final double lng;
  final int zoom;
  final int mapWidth;
  final int mapHeight;
  final BoxFit fit;
  final Map<String, String> tileHeaders;

  @override
  State<_LiveMapLayer> createState() => _LiveMapLayerState();
}

class _LiveMapLayerState extends State<_LiveMapLayer> {
  bool _googleLoaded = false;
  bool _useOsmFallback = false;

  @override
  void didUpdateWidget(covariant _LiveMapLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lat != widget.lat ||
        oldWidget.lng != widget.lng ||
        oldWidget.zoom != widget.zoom) {
      _googleLoaded = false;
      _useOsmFallback = false;
    }
  }

  void _onGoogleError() {
    if (!_useOsmFallback && mounted) {
      setState(() => _useOsmFallback = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showGoogle = StaticMapUrl.hasGoogleKey && !_useOsmFallback;
    final googleUrl = showGoogle
        ? StaticMapUrl.preview(
            lat: widget.lat,
            lng: widget.lng,
            zoom: widget.zoom,
            width: widget.mapWidth,
            height: widget.mapHeight,
          )
        : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_useOsmFallback || !StaticMapUrl.hasGoogleKey)
          _OsmTileGrid(
            lat: widget.lat,
            lng: widget.lng,
            zoom: widget.zoom,
            headers: widget.tileHeaders,
          ),
        if (googleUrl != null)
          Image.network(
            googleUrl,
            key: ValueKey(googleUrl),
            fit: widget.fit,
            gaplessPlayback: true,
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                if (!_googleLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _googleLoaded = true);
                  });
                }
                return child;
              }
              return const SizedBox.shrink();
            },
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _onGoogleError();
              });
              return const SizedBox.shrink();
            },
          ),
        if ((_useOsmFallback || !StaticMapUrl.hasGoogleKey) && !_googleLoaded)
          Positioned(
            left: 4,
            bottom: 2,
            child: Text(
              OsmTileUrl.attribution,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                    fontSize: 9,
                  ),
            ),
          ),
      ],
    );
  }
}

class _OsmTileGrid extends StatelessWidget {
  const _OsmTileGrid({
    required this.lat,
    required this.lng,
    required this.zoom,
    required this.headers,
  });

  final double lat;
  final double lng;
  final int zoom;
  final Map<String, String> headers;

  @override
  Widget build(BuildContext context) {
    final centerX = OsmTileUrl.tileX(lng, zoom);
    final centerY = OsmTileUrl.tileY(lat, zoom);
    const radius = 1;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final col = index % 3;
        final row = index ~/ 3;
        final x = centerX + (col - radius);
        final y = centerY + (row - radius);
        return Image.network(
          OsmTileUrl.tile(zoom, x, y),
          headers: headers,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => const _MapPatternFallback(),
        );
      },
    );
  }
}

class _MapPatternFallback extends StatelessWidget {
  const _MapPatternFallback();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _MapGridPainter(
        lineColor: colors.outline.withValues(alpha: 0.35),
        fillColor: colors.surfaceContainer,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  _MapGridPainter({required this.lineColor, required this.fillColor});

  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = fillColor);
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    const step = 28.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) => false;
}
