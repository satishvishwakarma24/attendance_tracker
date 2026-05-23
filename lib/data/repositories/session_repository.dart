import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _activeSessionKey = 'active_session_id';

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('sessions');

  Stream<List<UserSession>> watchUserSessions(String userId, {int limit = 30}) {
    return _sessions
        .where('userId', isEqualTo: userId)
        .orderBy('loginAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserSession.fromMap(d.id, d.data()))
            .toList());
  }

  Future<String?> getActiveSessionId(String userId) async {
    final snap = await _sessions
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }

  /// Starts a login session or returns the existing active session id.
  Future<String> ensureActiveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedId = prefs.getString(_activeSessionKey);

    if (cachedId != null) {
      final cached = await _sessions.doc(cachedId).get();
      if (cached.exists &&
          cached.data()?['userId'] == userId &&
          cached.data()?['isActive'] == true) {
        return cachedId;
      }
      await prefs.remove(_activeSessionKey);
    }

    final activeSnap = await _sessions
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .get();

    if (activeSnap.docs.isNotEmpty) {
      final keepId = activeSnap.docs.first.id;
      for (final doc in activeSnap.docs.skip(1)) {
        await _closeSessionDoc(doc.reference, doc.data());
      }
      await prefs.setString(_activeSessionKey, keepId);
      return keepId;
    }

    final ref = await _sessions.add({
      'userId': userId,
      'loginAt': FieldValue.serverTimestamp(),
      'logoutAt': null,
      'durationSeconds': null,
      'isActive': true,
    });

    await prefs.setString(_activeSessionKey, ref.id);
    Logger.info('Login session started for $userId');
    return ref.id;
  }

  /// Ends the active session and stores duration. No-op if none is active.
  Future<void> endActiveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    var sessionId = prefs.getString(_activeSessionKey);

    sessionId ??= await getActiveSessionId(userId);
    if (sessionId == null) {
      Logger.warning('No active session to end for $userId');
      return;
    }

    final ref = _sessions.doc(sessionId);
    final snap = await ref.get();
    if (!snap.exists || snap.data() == null) {
      await prefs.remove(_activeSessionKey);
      return;
    }

    final data = snap.data()!;
    if (data['userId'] != userId) {
      Logger.error(
        'Active session user mismatch',
        StateError('session belongs to another user'),
        StackTrace.current,
      );
      await prefs.remove(_activeSessionKey);
      return;
    }

    if (data['isActive'] != true) {
      await prefs.remove(_activeSessionKey);
      return;
    }

    await _closeSessionDoc(ref, data);
    await prefs.remove(_activeSessionKey);
    Logger.info('Login session ended for $userId');
  }

  Future<void> _closeSessionDoc(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) async {
    final loginAt = (data['loginAt'] as Timestamp?)?.toDate();
    final logoutAt = DateTime.now();
    var durationSeconds = 0;
    if (loginAt != null) {
      durationSeconds = logoutAt.difference(loginAt).inSeconds;
      if (durationSeconds < 0) durationSeconds = 0;
    }

    await ref.update({
      'logoutAt': FieldValue.serverTimestamp(),
      'durationSeconds': durationSeconds,
      'isActive': false,
    });
  }
}
