import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/services/firebase_providers.dart';
import '../../core/utils/logger.dart';
import '../models/user_session.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(firestore: ref.watch(firestoreProvider));
});

class SessionRepository {
  SessionRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('sessions');

  Stream<List<UserSession>> watchUserSessions(String userId, {int limit = 30}) {
    return _sessions
        .where('userId', isEqualTo: userId)
        .orderBy('punchInAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserSession.fromMap(d.id, d.data()))
            .toList());
  }

  /// Records a completed work session when the user punches out.
  Future<void> recordPunchOutSession({
    required String userId,
    required String locationId,
    required String locationName,
    required DateTime punchInAt,
    String? punchInAttendanceId,
  }) async {
    if (punchInAttendanceId != null) {
      final existing = await _sessions
          .where('userId', isEqualTo: userId)
          .where('punchInAttendanceId', isEqualTo: punchInAttendanceId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        Logger.warning(
          'Punch session already recorded for attendance $punchInAttendanceId',
        );
        return;
      }
    }

    final punchOutAt = DateTime.now();
    var durationSeconds = punchOutAt.difference(punchInAt).inSeconds;
    if (durationSeconds < 0) durationSeconds = 0;

    await _sessions.add({
      'userId': userId,
      'locationId': locationId,
      'locationName': locationName,
      'punchInAt': Timestamp.fromDate(punchInAt),
      'punchOutAt': FieldValue.serverTimestamp(),
      'durationSeconds': durationSeconds,
      'isActive': false,
      if (punchInAttendanceId != null)
        'punchInAttendanceId': punchInAttendanceId,
    });

    Logger.info(
      'Punch session recorded for $userId ($durationSeconds s at $locationName)',
    );
  }
}
