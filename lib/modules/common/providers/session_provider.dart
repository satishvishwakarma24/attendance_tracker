import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/data/models/attendance_record.dart';
import '/data/models/user_session.dart';
import '/data/repositories/attendance_repository.dart';
import '/data/repositories/auth_repository.dart';
import '/data/repositories/session_repository.dart';
import '/modules/auth/providers/auth_providers.dart';

final userSessionsProvider =
    StreamProvider.autoDispose<List<UserSession>>((ref) async* {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    yield const [];
    return;
  }

  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);

  await for (final completed in sessionRepo.watchUserSessions(user.uid)) {
    AttendanceRecord? latest;
    try {
      latest = await attendanceRepo.getLatestForUser(user.uid);
    } catch (_) {
      latest = null;
    }

    final items = List<UserSession>.from(completed);
    if (latest != null &&
        latest.isPunchIn &&
        latest.timestamp != null &&
        !_hasActivePunch(items, latest.timestamp!)) {
      items.insert(
        0,
        UserSession.activePunch(
          userId: user.uid,
          punchInAt: latest.timestamp!,
          locationId: latest.locationId,
          locationName: latest.locationName,
        ),
      );
    }
    yield items;
  }
});

bool _hasActivePunch(List<UserSession> sessions, DateTime punchInAt) {
  return sessions.any(
    (s) =>
        s.isActive ||
        (s.punchInAt != null &&
            s.punchInAt!.difference(punchInAt).inSeconds.abs() < 2),
  );
}

Future<void> signOut(WidgetRef ref) async {
  await ref.read(authRepositoryProvider).signOut();
}
