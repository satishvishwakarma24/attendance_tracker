import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '/core/theme/app_theme.dart';
import '/core/utils/location_permission_helper.dart';
import '/modules/common/module_responsive.dart';
import '/core/utils/logger.dart';
import '/data/repositories/location_repository.dart';
import 'widgets/location_details_form.dart';
import 'widgets/location_map_preview.dart';

class AddLocationScreen extends ConsumerStatefulWidget {
  const AddLocationScreen({super.key, this.locationId});

  /// When set, the screen loads and updates an existing location.
  final String? locationId;

  bool get isEditing => locationId != null && locationId!.isNotEmpty;

  @override
  ConsumerState<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends ConsumerState<AddLocationScreen> {
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  double _radius = 100.0;
  bool _isActive = true;
  bool _isSaving = false;
  bool _isLoading = false;
  bool _isFetchingGps = false;
  String? _loadError;
  String _gpsPillLabel = 'Use GPS';
  double? _deviceLat;
  double? _deviceLng;

  @override
  void initState() {
    super.initState();
    _latController.addListener(_onCoordinatesChanged);
    _lngController.addListener(_onCoordinatesChanged);
    if (widget.isEditing) {
      _loadExisting();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _useCurrentLocation(silent: true);
      });
    }
  }

  void _onCoordinatesChanged() {
    if (mounted) setState(() {});
  }

  (double?, double?) get _officeCoordinates {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) return (null, null);
    return (lat, lng);
  }

  Future<void> _useCurrentLocation({bool silent = false}) async {
    if (_isFetchingGps) return;

    setState(() {
      _isFetchingGps = true;
      _gpsPillLabel = 'Locating…';
    });

    try {
      final access = await LocationPermissionHelper.ensureWhileInUse();
      if (access != LocationAccess.granted) {
        if (!mounted) return;
        setState(() {
          _isFetchingGps = false;
          _gpsPillLabel = _labelForAccess(access);
        });
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocationPermissionHelper.messageFor(access)),
              action: access == LocationAccess.permanentlyDenied
                  ? const SnackBarAction(
                      label: 'Settings',
                      onPressed: openAppSettings,
                    )
                  : null,
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      _latController.text = position.latitude.toStringAsFixed(6);
      _lngController.text = position.longitude.toStringAsFixed(6);
      setState(() {
        _deviceLat = position.latitude;
        _deviceLng = position.longitude;
        _isFetchingGps = false;
        _gpsPillLabel = 'GPS Active';
      });

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coordinates set from your current location'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, s) {
      Logger.error('Failed to read GPS for add location', e, s);
      if (!mounted) return;
      setState(() {
        _isFetchingGps = false;
        _gpsPillLabel = 'Retry GPS';
      });
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not read GPS. Try again or enter coordinates.'),
          ),
        );
      }
    }
  }

  String _labelForAccess(LocationAccess access) {
    switch (access) {
      case LocationAccess.granted:
        return 'GPS Active';
      case LocationAccess.serviceDisabled:
        return 'GPS off';
      case LocationAccess.permanentlyDenied:
        return 'No access';
      case LocationAccess.denied:
        return 'Use GPS';
    }
  }

  Future<void> _loadExisting() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final loc = await ref
          .read(locationRepositoryProvider)
          .getLocation(widget.locationId!);
      if (!mounted) return;
      if (loc == null) {
        setState(() {
          _isLoading = false;
          _loadError = 'Location not found.';
        });
        return;
      }
      _nameController.text = loc.name;
      _latController.text = loc.latitude.toString();
      _lngController.text = loc.longitude.toString();
      setState(() {
        _radius = loc.radiusMeters;
        _isActive = loc.isActive;
        _isLoading = false;
      });
    } catch (e, s) {
      Logger.error('Failed to load location for edit', e, s);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Could not load location.';
      });
    }
  }

  Future<void> _saveLocation() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an office name')),
      );
      return;
    }

    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid latitude and longitude'),
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(locationRepositoryProvider);
      if (widget.isEditing) {
        await repo.updateLocation(
          id: widget.locationId!,
          name: name,
          latitude: lat,
          longitude: lng,
          radiusMeters: _radius,
          isActive: _isActive,
        );
      } else {
        await repo.addLocation(
          name: name,
          latitude: lat,
          longitude: lng,
          radiusMeters: _radius,
          createdBy: uid,
        );
      }

      if (!mounted) return;
      final colors = context.colors;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Location "$name" updated'
                : 'Location "$name" successfully added!',
          ),
          backgroundColor: colors.primary,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save location: $e'),
          backgroundColor: context.colors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _latController.removeListener(_onCoordinatesChanged);
    _lngController.removeListener(_onCoordinatesChanged);
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.isEditing ? 'Edit Location' : 'Add Location',
          style: text.titleLarge?.copyWith(fontSize: 18.sp),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      _loadError!,
                      style: text.bodyMedium?.copyWith(fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: ModuleResponsive.screenPadding,
                  child: Column(
                    children: [
                      LocationMapPreview(
                        radius: _radius,
                        officeLat: _officeCoordinates.$1,
                        officeLng: _officeCoordinates.$2,
                        deviceLat: _deviceLat,
                        deviceLng: _deviceLng,
                        gpsPillLabel: _gpsPillLabel,
                        isFetchingGps: _isFetchingGps,
                        onUseGps: () => _useCurrentLocation(),
                      ),
                      SizedBox(height: 24.h),
                      LocationDetailsForm(
                        nameController: _nameController,
                        latController: _latController,
                        lngController: _lngController,
                        radius: _radius,
                        onRadiusChanged: (val) => setState(() => _radius = val),
                        isEditing: widget.isEditing,
                        isActive: _isActive,
                        onActiveChanged: (val) => setState(() => _isActive = val),
                        isFetchingGps: _isFetchingGps,
                        onUseCurrentLocation: () => _useCurrentLocation(),
                        isSaving: _isSaving,
                        onSave: _saveLocation,
                      ),
                    ],
                  ),
                ),
    );
  }
}
