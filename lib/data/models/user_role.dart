enum UserRole {
  employee('employee'),
  superAdmin('super_admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String? raw) {
    if (raw == superAdmin.value) return superAdmin;
    return employee;
  }

  bool get isSuperAdmin => this == superAdmin;
}
