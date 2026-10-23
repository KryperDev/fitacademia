abstract final class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String noGym = '/no-gym';
  static const String createGym = '/no-gym/create';
  static const String acceptInvite = '/no-gym/accept-invite';
  static const String studentHome = '/student';
  static const String studentWorkouts = '/student/workouts';
  static const String studentWorkoutDetail = '/student/workouts/:planId';
  static const String studentSession = '/student/session/:assignmentId';
  static const String studentHistory = '/student/history';
  static const String studentProgress = '/student/progress';
  static const String studentNotifications = '/student/notifications';
  static const String studentProfile = '/student/profile';
  static const String trainerHome = '/trainer';
  static const String trainerStudents = '/trainer/students';
  static const String trainerStudentDetail = '/trainer/students/:studentUid';
  static const String trainerPlanEditor = '/trainer/plans/:planId';
  static const String trainerPlanNew = '/trainer/plans/new';
  static const String gymAdminHome = '/gym-admin';
  static const String gymAdminMembers = '/gym-admin/members';
  static const String gymAdminExercises = '/gym-admin/exercises';
  static const String gymAdminReports = '/gym-admin/reports';
  static const String gymAdminSettings = '/gym-admin/settings';
  static const String platformAdminHome = '/platform-admin';
  static const String platformAdminGyms = '/platform-admin/gyms';
  static const String platformAdminPlans = '/platform-admin/plans';

  static String studentWorkoutDetailPath(String planId) => '/student/workouts/$planId';
  static String studentSessionPath(String assignmentId) => '/student/session/$assignmentId';
  static String trainerStudentDetailPath(String studentUid) => '/trainer/students/$studentUid';
  static String trainerPlanEditorPath(String planId) => '/trainer/plans/$planId';
}



