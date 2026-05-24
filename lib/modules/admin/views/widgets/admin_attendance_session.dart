import '/data/models/attendance_record.dart';

/// One employee punch cycle (in + out) for the admin attendance log.
class AdminAttendanceSession {
  const AdminAttendanceSession({
    this.punchIn,
    this.punchOut,
  });

  final AttendanceRecord? punchIn;
  final AttendanceRecord? punchOut;

  String get userId => punchOut?.userId ?? punchIn?.userId ?? '';

  String get userEmail =>
      punchOut?.userEmail ?? punchIn?.userEmail ?? userId;

  String? get locationName =>
      punchOut?.locationName ?? punchIn?.locationName;

  String get locationId => punchOut?.locationId ?? punchIn?.locationId ?? '';

  bool get isActive => punchIn != null && punchOut == null;

  Duration? get duration {
    final inAt = punchIn?.timestamp;
    final outAt = punchOut?.timestamp;
    if (inAt == null || outAt == null) return null;
    return outAt.difference(inAt);
  }
}

/// Pairs raw punch records into in/out sessions (newest first).
List<AdminAttendanceSession> groupAttendanceIntoSessions(
  List<AttendanceRecord> records,
) {
  if (records.isEmpty) return const [];

  final chronological = records.reversed.toList();
  final openIns = <String, AttendanceRecord>{};
  final sessions = <AdminAttendanceSession>[];

  for (final record in chronological) {
    final key = '${record.userId}|${record.locationId}';
    if (record.isPunchIn) {
      openIns[key] = record;
    } else {
      final inRecord = openIns.remove(key);
      sessions.add(AdminAttendanceSession(punchIn: inRecord, punchOut: record));
    }
  }

  for (final inRecord in openIns.values) {
    sessions.add(AdminAttendanceSession(punchIn: inRecord));
  }

  return sessions.reversed.toList();
}
