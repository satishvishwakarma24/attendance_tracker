class UserSession {
  const UserSession({
    required this.id,
    required this.userId,
    required this.loginAt,
    this.logoutAt,
    this.durationSeconds,
    required this.isActive,
  });

  final String id;
  final String userId;
  final DateTime? loginAt;
  final DateTime? logoutAt;
  final int? durationSeconds;
  final bool isActive;

  factory UserSession.fromMap(String id, Map<String, dynamic> map) {
    return UserSession(
      id: id,
      userId: map['userId'] as String? ?? '',
      loginAt: (map['loginAt'] as dynamic)?.toDate() as DateTime?,
      logoutAt: (map['logoutAt'] as dynamic)?.toDate() as DateTime?,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt(),
      isActive: map['isActive'] as bool? ?? false,
    );
  }

  Duration? get duration {
    if (durationSeconds != null) {
      return Duration(seconds: durationSeconds!);
    }
    if (loginAt != null && logoutAt != null) {
      return logoutAt!.difference(loginAt!);
    }
    return null;
  }
}
