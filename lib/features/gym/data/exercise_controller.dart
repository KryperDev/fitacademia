import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/exercise.dart';
import 'exercise_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

final exercisesStreamProvider = StreamProvider.family<List<Exercise>, String>((ref, gymId) {
  return ref.watch(exerciseRepositoryProvider).streamExercises(gymId);
});
