class UserSession {
  const UserSession({
    required this.id,
    required this.userId,
    this.punchInAt,
    this.punchOutAt,
    this.durationSeconds,
    required this.isActive,
    this.locationId,
    this.locationName,
  });

  final String id;
  final String userId;
  final DateTime? punchInAt;
  final DateTime? punchOutAt;
  final int? durationSeconds;
  final bool isActive;
  final String? locationId;
  final String? locationName;

  /// Open punch (not yet punched out) — shown in history from live attendance.
  factory UserSession.activePunch({
    required String userId,
    required DateTime punchInAt,
    String? locationId,
    String? locationName,
  }) {
    return UserSession(
      id: '_active',
      userId: userId,
      punchInAt: punchInAt,
      isActive: true,
      locationId: locationId,
      locationName: locationName,
    );
  }

  factory UserSession.fromMap(String id, Map<String, dynamic> map) {
    DateTime? readTime(String key) {
      return (map[key] as dynamic)?.toDate() as DateTime?;
    }

    return UserSession(
      id: id,
      userId: map['userId'] as String? ?? '',
      punchInAt: readTime('punchInAt') ?? readTime('loginAt'),
      punchOutAt: readTime('punchOutAt') ?? readTime('logoutAt'),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt(),
      isActive: map['isActive'] as bool? ?? false,
      locationId: map['locationId'] as String?,
      locationName: map['locationName'] as String?,
    );
  }

  Duration? get duration {
    if (durationSeconds != null) {
      return Duration(seconds: durationSeconds!);
    }
    if (punchInAt != null && punchOutAt != null) {
      return punchOutAt!.difference(punchInAt!);
    }
    return null;
  }
}
