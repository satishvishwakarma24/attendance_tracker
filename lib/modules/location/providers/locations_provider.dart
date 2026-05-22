import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/office_location.dart';

class LocationsNotifier extends Notifier<List<OfficeLocation>> {
  @override
  List<OfficeLocation> build() {
    return [
      const OfficeLocation(
        name: 'Downtown HQ',
        coordinates: '40.7128° N, 74.0060° W',
        icon: Icons.business,
      ),
      const OfficeLocation(
        name: 'Westside Branch',
        coordinates: '34.0522° N, 118.2437° W',
        icon: Icons.domain,
      ),
      const OfficeLocation(
        name: 'Innovation Hub',
        coordinates: '37.7749° N, 122.4194° W',
        icon: Icons.lightbulb,
      ),
    ];
  }

  void addLocation(OfficeLocation location) {
    state = [...state, location];
  }
}

final locationsProvider = NotifierProvider<LocationsNotifier, List<OfficeLocation>>(() {
  return LocationsNotifier();
});
