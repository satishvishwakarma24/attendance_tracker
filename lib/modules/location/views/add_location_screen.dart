import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '/core/theme/app_theme.dart';
import '../../common/widgets/module_responsive.dart';
import '/core/utils/location_permission_helper.dart';
import '/core/utils/logger.dart';
import '/data/repositories/location_repository.dart';
import 'location_picker_screen.dart';
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
  double? _deviceLat;
  double? _deviceLng;

  @override
  void initState() {
    super.initState();
    _latController.addListener(_onCoordinatesChanged);
    _lngController.addListener(_onCoordinatesChanged);
    if (widget.isEditing) {
      _loadExisting();
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

  Future<bool?> _promptLocationAccess(LocationAccess access) {
    final text = context.textStyles;
    final openSettings =
        LocationPermissionHelper.needsSystemSettings(access);

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Location required', style: text.titleLarge),
        content: Text(
          openSettings
              ? LocationPermissionHelper.messageFor(access)
              : 'Allow location while using the app to use your current '
                  'position for this office.',
          style: text.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(openSettings ? 'Open Settings' : 'Allow location'),
          ),
        ],
      ),
    );
  }

  Future<LocationAccess> _ensureLocationForGps() async {
    var access = await LocationPermissionHelper.checkStatus();
    if (access == LocationAccess.granted) {
      return LocationAccess.granted;
    }

    if (LocationPermissionHelper.needsSystemSettings(access)) {
      if (!mounted) return access;
      final accepted = await _promptLocationAccess(access);
      if (accepted == true) {
        await LocationPermissionHelper.openSettingsFor(access);
      }
      return access;
    }

    if (!mounted) return access;
    final accepted = await _promptLocationAccess(access);
    if (accepted != true) {
      return LocationAccess.denied;
    }

    return LocationPermissionHelper.requestWhileInUse();
  }

  Future<void> _useCurrentLocation() async {
    if (_isFetchingGps) return;

    setState(() => _isFetchingGps = true);

    try {
      final access = await _ensureLocationForGps();
      if (access != LocationAccess.granted) {
        if (!mounted) return;
        setState(() => _isFetchingGps = false);
        if (!LocationPermissionHelper.needsSystemSettings(access)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocationPermissionHelper.messageFor(access)),
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
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coordinates set from your current location'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, s) {
      Logger.error('Failed to read GPS for add location', e, s);
      if (!mounted) return;
      setState(() => _isFetchingGps = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not read GPS. Try again or enter coordinates.'),
        ),
      );
    }
  }

  Future<void> _openLocationPicker() async {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLatitude: lat,
          initialLongitude: lng,
        ),
      ),
    );
    if (!mounted || result == null) return;

    _latController.text = result.latitude.toStringAsFixed(6);
    _lngController.text = result.longitude.toStringAsFixed(6);
    _deviceLat = result.latitude;
    _deviceLng = result.longitude;
    if (_nameController.text.trim().isEmpty &&
        result.suggestedName != null &&
        result.suggestedName!.trim().isNotEmpty) {
      _nameController.text = result.suggestedName!.trim();
    }
    setState(() {});
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
                        isFetchingGps: _isFetchingGps,
                        onCurrentLocation: _useCurrentLocation,
                        onSelectOnMap: _openLocationPicker,
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
                        onActiveChanged: (val) =>
                            setState(() => _isActive = val),
                        isSaving: _isSaving,
                        onSave: _saveLocation,
                      ),
                    ],
                  ),
                ),
    );
  }
}
