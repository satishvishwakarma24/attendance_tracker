import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/services/firebase_providers.dart';
import '/core/utils/logger.dart';
import '/data/models/office_location_model.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(firestore: ref.watch(firestoreProvider));
});

class LocationRepository {
  LocationRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _locations =>
      _firestore.collection('locations');

  Stream<List<OfficeLocationModel>> watchActiveLocations() {
    return _locations
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((d) => OfficeLocationModel.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    });
  }

  /// Live id → name map for resolving stored punch/session labels.
  Stream<Map<String, String>> watchLocationNameMap() {
    return _locations.snapshots().map(
          (snapshot) => {
            for (final doc in snapshot.docs)
              doc.id: doc.data()['name'] as String? ?? '',
          },
        );
  }

  Future<OfficeLocationModel?> getLocation(String id) async {
    try {
      final doc = await _locations.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return OfficeLocationModel.fromMap(doc.id, doc.data()!);
    } catch (e, s) {
      Logger.error('Failed to load location $id', e, s);
      rethrow;
    }
  }

  Future<void> addLocation({
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    required String createdBy,
  }) async {
    try {
      await _locations.add({
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radiusMeters': radiusMeters,
        'isActive': true,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Logger.info('Location added: $name');
    } catch (e, s) {
      Logger.error('Failed to add location', e, s);
      rethrow;
    }
  }

  Future<void> updateLocation({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    required bool isActive,
  }) async {
    try {
      await _locations.doc(id).update({
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radiusMeters': radiusMeters,
        'isActive': isActive,
      });
      Logger.info('Location updated: $name ($id)');
    } catch (e, s) {
      Logger.error('Failed to update location', e, s);
      rethrow;
    }
  }

  Future<void> deleteLocation(String id) async {
    try {
      await _locations.doc(id).delete();
      Logger.info('Location deleted: $id');
    } catch (e, s) {
      Logger.error('Failed to delete location', e, s);
      rethrow;
    }
  }
}
