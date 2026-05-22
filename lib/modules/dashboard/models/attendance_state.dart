class AttendanceState {
  final bool isPunchedIn;
  final DateTime? lastPunchTime;

  const AttendanceState({
    required this.isPunchedIn,
    this.lastPunchTime,
  });

  AttendanceState copyWith({
    bool? isPunchedIn,
    DateTime? lastPunchTime,
  }) {
    return AttendanceState(
      isPunchedIn: isPunchedIn ?? this.isPunchedIn,
      lastPunchTime: lastPunchTime ?? this.lastPunchTime,
    );
  }
}
