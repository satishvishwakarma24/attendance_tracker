import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/office_location_model.dart';
import '../../../data/repositories/location_repository.dart';

final locationsStreamProvider =
    StreamProvider<List<OfficeLocationModel>>((ref) {
  return ref.watch(locationRepositoryProvider).watchActiveLocations();
});
