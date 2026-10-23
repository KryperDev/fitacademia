enum GymRole {
  student,
  trainer,
  admin;

  static GymRole? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'student':
        return GymRole.student;
      case 'trainer':
        return GymRole.trainer;
      case 'admin':
        return GymRole.admin;
      default:
        return null;
    }
  }

  String get firestoreValue {
    switch (this) {
      case GymRole.student:
        return 'student';
      case GymRole.trainer:
        return 'trainer';
      case GymRole.admin:
        return 'admin';
    }
  }

  String get labelPt {
    switch (this) {
      case GymRole.student:
        return 'Aluno';
      case GymRole.trainer:
        return 'Professor';
      case GymRole.admin:
        return 'Administrador';
    }
  }
}
