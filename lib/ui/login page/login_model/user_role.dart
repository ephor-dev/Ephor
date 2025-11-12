/// Enum representing user roles in the system
/// These values must match the role values in the Supabase employees table
enum UserRole {
  supervisor('Supervisor'),
  humanResources('Human Resources');

  const UserRole(this.value);
  final String value;

  /// Create UserRole from string value
  static UserRole? fromString(String? value) {
    if (value == null) return null;
    try {
      return UserRole.values.firstWhere(
        (role) => role.value.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get display name for the role
  String get displayName {
    switch (this) {
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.humanResources:
        return 'Human Resources';
    }
  }
}

