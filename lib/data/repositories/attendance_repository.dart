import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/services/firebase_providers.dart';
import '../../core/utils/logger.dart';
import '../models/attendance_record.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(firestore: ref.watch(firestoreProvider));
});

class AttendanceRepository {
  AttendanceRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _attendance =>
      _firestore.collection('attendance');

  Stream<List<AttendanceRecord>> watchRecent({int limit = 50}) {
    return _attendance
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AttendanceRecord.fromMap(d.id, d.data()))
            .toList());
  }

  Future<AttendanceRecord?> getLatestForUser(String userId) async {
    final snap = await _attendance
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return AttendanceRecord.fromMap(doc.id, doc.data());
  }

  Future<void> recordPunch({
    required String userId,
    required String userEmail,
    required String locationId,
    required String locationName,
    required bool punchIn,
    required double lat,
    required double lng,
  }) async {
    try {
      await _attendance.add({
        'userId': userId,
        'userEmail': userEmail,
        'locationId': locationId,
        'locationName': locationName,
        'type': punchIn ? 'in' : 'out',
        'timestamp': FieldValue.serverTimestamp(),
        'lat': lat,
        'lng': lng,
      });
      Logger.info('Punch ${punchIn ? 'in' : 'out'} recorded for $userId');
    } catch (e, s) {
      Logger.error('Failed to record punch', e, s);
      rethrow;
    }
  }
}
