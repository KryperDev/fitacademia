import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/workout_plan.dart';
import 'workout_repository.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

final allPlansProvider = StreamProvider.family<List<WorkoutPlan>, String>((ref, gymId) {
  return ref.watch(workoutRepositoryProvider).streamAllPlans(gymId);
});

final studentPlansProvider = StreamProvider.family<List<WorkoutPlan>, ({String gymId, String studentUid})>((ref, args) {
  return ref.watch(workoutRepositoryProvider).streamStudentPlans(args.gymId, args.studentUid);
});
