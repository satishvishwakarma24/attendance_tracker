import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/office_location_model.dart';
import '../../../data/repositories/location_repository.dart';

final locationsStreamProvider =
    StreamProvider<List<OfficeLocationModel>>((ref) {
  return ref.watch(locationRepositoryProvider).watchActiveLocations();
});

final locationNameMapProvider = StreamProvider<Map<String, String>>((ref) {
  return ref.watch(locationRepositoryProvider).watchLocationNameMap();
});

/// Prefer the current name from [locations], fall back to the stored snapshot.
String resolveLocationDisplayName({
  required String? locationId,
  required String? storedName,
  required Map<String, String> liveNames,
  String fallback = 'Office',
}) {
  if (locationId != null) {
    final live = liveNames[locationId];
    if (live != null && live.isNotEmpty) return live;
  }
  if (storedName != null && storedName.isNotEmpty) return storedName;
  if (locationId != null && locationId.isNotEmpty) return locationId;
  return fallback;
}
