import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_state.dart';

class AttendanceNotifier extends Notifier<AttendanceState> {
  @override
  AttendanceState build() {
    return const AttendanceState(
      isPunchedIn: false,
      lastPunchTime: null,
    );
  }

  void togglePunch() {
    state = state.copyWith(
      isPunchedIn: !state.isPunchedIn,
      lastPunchTime: DateTime.now(),
    );
  }
}

final attendanceProvider = NotifierProvider<AttendanceNotifier, AttendanceState>(() {
  return AttendanceNotifier();
});
