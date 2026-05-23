import 'user_role_enum.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final UserRole role;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
    this.createdAt,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      role: UserRole.fromString(map['role'] as String?),
      createdAt: (map['createdAt'] as dynamic)?.toDate() as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      if (displayName != null) 'displayName': displayName,
      'role': role.value,
      'createdAt': createdAt,
    };
  }
}
