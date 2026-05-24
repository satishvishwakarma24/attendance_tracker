import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ll;

import '/core/utils/osm_tile_url.dart';
import '/core/utils/static_map_url.dart';

/// Pan/zoom map for picking a point. Uses Google Maps when a key is set,
/// otherwise OpenStreetMap via [flutter_map] (still smooth; not static images).
class InteractivePickerMap extends StatefulWidget {
  const InteractivePickerMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onCenterChanged,
    this.zoom = 15,
    this.myLocationEnabled = false,
  });

  final double latitude;
  final double longitude;
  final void Function(double lat, double lng) onCenterChanged;
  final double zoom;
  final bool myLocationEnabled;

  @override
  State<InteractivePickerMap> createState() => InteractivePickerMapState();
}

class InteractivePickerMapState extends State<InteractivePickerMap> {
  GoogleMapController? _googleController;
  final MapController _osmController = MapController();
  bool _ignoreNextOsmMove = false;

  Future<void> moveTo(double lat, double lng, {double? zoom}) async {
    final z = zoom ?? widget.zoom;
    if (StaticMapUrl.hasGoogleKey) {
      final controller = _googleController;
      if (controller == null) return;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: z),
        ),
      );
      return;
    }

    _ignoreNextOsmMove = true;
    _osmController.move(ll.LatLng(lat, lng), z);
    widget.onCenterChanged(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    if (StaticMapUrl.hasGoogleKey) {
      return _GooglePickerMap(
        latitude: widget.latitude,
        longitude: widget.longitude,
        zoom: widget.zoom,
        myLocationEnabled: widget.myLocationEnabled,
        onMapCreated: (c) => _googleController = c,
        onCenterChanged: widget.onCenterChanged,
      );
    }

    return _OsmPickerMap(
      controller: _osmController,
      latitude: widget.latitude,
      longitude: widget.longitude,
      zoom: widget.zoom,
      ignoreNextMove: () => _ignoreNextOsmMove,
      clearIgnoreNextMove: () => _ignoreNextOsmMove = false,
      onCenterChanged: widget.onCenterChanged,
    );
  }
}

class _GooglePickerMap extends StatefulWidget {
  const _GooglePickerMap({
    required this.latitude,
    required this.longitude,
    required this.zoom,
    required this.myLocationEnabled,
    required this.onMapCreated,
    required this.onCenterChanged,
  });

  final double latitude;
  final double longitude;
  final double zoom;
  final bool myLocationEnabled;
  final ValueChanged<GoogleMapController> onMapCreated;
  final void Function(double lat, double lng) onCenterChanged;

  @override
  State<_GooglePickerMap> createState() => _GooglePickerMapState();
}

class _GooglePickerMapState extends State<_GooglePickerMap> {
  LatLng? _pendingCenter;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.latitude, widget.longitude),
        zoom: widget.zoom,
      ),
      onMapCreated: widget.onMapCreated,
      onCameraMove: (position) => _pendingCenter = position.target,
      onCameraIdle: () {
        final center = _pendingCenter;
        if (center == null) return;
        widget.onCenterChanged(center.latitude, center.longitude);
      },
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationEnabled,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: true,
      liteModeEnabled: false,
    );
  }
}

class _OsmPickerMap extends StatefulWidget {
  const _OsmPickerMap({
    required this.controller,
    required this.latitude,
    required this.longitude,
    required this.zoom,
    required this.ignoreNextMove,
    required this.clearIgnoreNextMove,
    required this.onCenterChanged,
  });

  final MapController controller;
  final double latitude;
  final double longitude;
  final double zoom;
  final bool Function() ignoreNextMove;
  final VoidCallback clearIgnoreNextMove;
  final void Function(double lat, double lng) onCenterChanged;

  @override
  State<_OsmPickerMap> createState() => _OsmPickerMapState();
}

class _OsmPickerMapState extends State<_OsmPickerMap> {
  @override
  Widget build(BuildContext context) {
    final center = ll.LatLng(widget.latitude, widget.longitude);

    return FlutterMap(
      mapController: widget.controller,
      options: MapOptions(
        initialCenter: center,
        initialZoom: widget.zoom,
        minZoom: 3,
        maxZoom: 19,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onMapEvent: (event) {
          if (widget.ignoreNextMove()) {
            if (event is MapEventMoveEnd) {
              widget.clearIgnoreNextMove();
            }
            return;
          }
          if (event is MapEventMoveEnd) {
            final c = widget.controller.camera.center;
            widget.onCenterChanged(c.latitude, c.longitude);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName:
              'com.satishvishwakarma.attendance_tracker.demo',
        ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution(OsmTileUrl.attribution),
          ],
        ),
      ],
    );
  }
}

/// Fixed center pin so the map moves underneath (standard picker UX).
class MapPickerCenterPin extends StatelessWidget {
  const MapPickerCenterPin({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -18),
          child: Icon(
            Icons.location_on,
            color: colors.error,
            size: 48,
            shadows: [
              Shadow(
                color: colors.shadow.withValues(alpha: 0.35),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
