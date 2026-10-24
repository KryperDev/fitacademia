import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/workout_plan.dart';
import '../../../shared/models/workout_session.dart';
import 'student_repository.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository();
});

final activePlanProvider = FutureProvider.family<WorkoutPlan?, ({String gymId, String studentUid})>((ref, args) {
  return ref.watch(studentRepositoryProvider).getActivePlan(args.gymId, args.studentUid);
});

final sessionHistoryProvider = StreamProvider.family<List<WorkoutSession>, ({String gymId, String studentUid})>((ref, args) {
  return ref.watch(studentRepositoryProvider).streamSessionHistory(args.gymId, args.studentUid);
});
