import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/attendance_record.dart';
import '../../../data/repositories/attendance_repository.dart';

final attendanceMonitorProvider =
    StreamProvider<List<AttendanceRecord>>((ref) {
  return ref.watch(attendanceRepositoryProvider).watchRecent(limit: 50);
});
