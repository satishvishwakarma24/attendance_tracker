import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '/core/theme/app_theme.dart';
import '/core/utils/address_geocoding.dart';
import '/core/utils/location_permission_helper.dart';
import '/core/utils/logger.dart';
import '/core/widgets/interactive_picker_map.dart';
import '../../common/widgets/module_responsive.dart';

class LocationPickerResult {
  const LocationPickerResult({
    required this.latitude,
    required this.longitude,
    this.suggestedName,
  });

  final double latitude;
  final double longitude;
  final String? suggestedName;
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.preferCurrentLocation = false,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final bool preferCurrentLocation;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<InteractivePickerMapState> _mapKey =
      GlobalKey<InteractivePickerMapState>();

  static const double _defaultLat = 22.7196;
  static const double _defaultLng = 75.8577;

  Timer? _suggestDebounce;
  bool _isInitializing = true;
  bool _isSearching = false;
  bool _isLoadingSuggestions = false;
  bool _myLocationEnabled = false;
  List<AddressSuggestion> _suggestions = [];
  double _selectedLat = _defaultLat;
  double _selectedLng = _defaultLng;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    _initialize();
  }

  Future<void> _initialize() async {
    final initialLat = widget.initialLatitude;
    final initialLng = widget.initialLongitude;

    if (initialLat != null && initialLng != null) {
      _setSelection(initialLat, initialLng);
      setState(() => _isInitializing = false);
      return;
    }

    if (widget.preferCurrentLocation) {
      await _centerOnDeviceLocation();
    }

    if (mounted) {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _centerOnDeviceLocation() async {
    var access = await LocationPermissionHelper.checkStatus();
    if (access == LocationAccess.denied) {
      access = await LocationPermissionHelper.requestWhileInUse();
    }
    if (access != LocationAccess.granted) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      _setSelection(position.latitude, position.longitude);
      setState(() => _myLocationEnabled = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapKey.currentState?.moveTo(position.latitude, position.longitude);
      });
    } catch (e, s) {
      Logger.error('Failed to center picker on current location', e, s);
    }
  }

  void _setSelection(double lat, double lng) {
    _selectedLat = lat;
    _selectedLng = lng;
  }

  void _onMapCenterChanged(double lat, double lng) {
    setState(() {
      _selectedLat = lat;
      _selectedLng = lng;
      _suggestions = [];
    });
  }

  void _onSearchTextChanged() {
    _suggestDebounce?.cancel();
    final query = _searchController.text.trim();
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _isLoadingSuggestions = false;
      });
      return;
    }

    _suggestDebounce = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _isLoadingSuggestions = true);
    try {
      final results = await AddressGeocoding.searchSuggestions(query);
      if (!mounted || _searchController.text.trim() != query) return;
      setState(() {
        _suggestions = results;
        _isLoadingSuggestions = false;
      });
    } catch (e, s) {
      Logger.error('Address suggestions failed', e, s);
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _isLoadingSuggestions = false;
      });
    }
  }

  void _applySuggestion(AddressSuggestion suggestion) {
    _searchController.text = suggestion.label;
    _setSelection(suggestion.latitude, suggestion.longitude);
    setState(() {
      _suggestions = [];
      _isLoadingSuggestions = false;
    });
    _mapKey.currentState?.moveTo(suggestion.latitude, suggestion.longitude);
    FocusScope.of(context).unfocus();
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _isSearching) return;

    setState(() {
      _isSearching = true;
      _suggestions = [];
    });
    try {
      final coords = await AddressGeocoding.coordinatesForAddress(query);
      if (!mounted) return;
      if (coords == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No location found for that search.')),
        );
        return;
      }
      _setSelection(coords.$1, coords.$2);
      setState(() {});
      _mapKey.currentState?.moveTo(coords.$1, coords.$2);
      FocusScope.of(context).unfocus();
    } catch (e, s) {
      Logger.error('Location search failed', e, s);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search failed. Try another address.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<String?> _resolveSuggestedName() async {
    try {
      return await AddressGeocoding.placeNameForCoordinates(
        _selectedLat,
        _selectedLng,
      );
    } catch (e, s) {
      Logger.error('Reverse geocoding failed in location picker', e, s);
      return null;
    }
  }

  Future<void> _confirmSelection() async {
    final suggestedName = await _resolveSuggestedName();
    if (!mounted) return;
    Navigator.of(context).pop(
      LocationPickerResult(
        latitude: _selectedLat,
        longitude: _selectedLng,
        suggestedName: suggestedName,
      ),
    );
  }

  @override
  void dispose() {
    _suggestDebounce?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: InteractivePickerMap(
                    key: _mapKey,
                    latitude: _selectedLat,
                    longitude: _selectedLng,
                    myLocationEnabled: _myLocationEnabled,
                    onCenterChanged: _onMapCenterChanged,
                  ),
                ),
                const Positioned.fill(child: MapPickerCenterPin()),
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  right: 12.w,
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _searchLocation(),
                          decoration: InputDecoration(
                            hintText: 'Search address or place',
                            filled: true,
                            fillColor: colors.surfaceContainerLowest,
                            suffixIcon: _isSearching || _isLoadingSuggestions
                                ? Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.primary,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    onPressed: _searchLocation,
                                    icon: const Icon(Icons.search),
                                  ),
                          ),
                        ),
                        if (_suggestions.isNotEmpty)
                          Container(
                            margin: EdgeInsets.only(top: 6.h),
                            constraints: BoxConstraints(maxHeight: 220.h),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: colors.outline),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withValues(alpha: 0.12),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _suggestions.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: colors.outlineVariant,
                              ),
                              itemBuilder: (context, index) {
                                final item = _suggestions[index];
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    Icons.place_outlined,
                                    size: 20.sp,
                                    color: colors.primary,
                                  ),
                                  title: Text(
                                    item.label,
                                    style: text.bodySmall?.copyWith(
                                      fontSize: 13.sp,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => _applySuggestion(item),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12.w,
                  right: 12.w,
                  bottom: 12.h,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLowest
                            .withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Selected coordinates',
                            style: text.labelLarge?.copyWith(fontSize: 13.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Lat: ${_selectedLat.toStringAsFixed(6)}  •  Lng: ${_selectedLng.toStringAsFixed(6)}',
                            style: text.bodySmall?.copyWith(fontSize: 12.sp),
                          ),
                          SizedBox(height: 10.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _confirmSelection,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Use this location'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
