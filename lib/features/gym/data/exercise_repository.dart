import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/exercise.dart';

class ExerciseRepository {
  final FirebaseFirestore _firestore;

  ExerciseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Exercise>> streamExercises(String gymId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('exercises')
        .where('active', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Exercise.fromDoc(doc)).toList());
  }

  Future<void> createExercise({
    required String gymId,
    required Exercise exercise,
  }) async {
    try {
      await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('exercises')
          .add(exercise.toCreateMap());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionException('Sem permissão para criar exercício.');
      }
      throw UnknownException('Erro ao criar exercício: ${e.message}');
    }
  }

  Future<void> updateExercise({
    required String gymId,
    required String exerciseId,
    required Exercise exercise,
  }) async {
    try {
      await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('exercises')
          .doc(exerciseId)
          .update({
        'name': exercise.name,
        'description': exercise.description,
        'muscleGroups': exercise.muscleGroups,
        'equipment': exercise.equipment,
        'instructions': exercise.instructions,
        'mediaProvider': exercise.mediaProvider,
        'mediaUrl': exercise.mediaUrl,
        'active': exercise.active,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionException('Sem permissão para editar exercício.');
      }
      throw UnknownException('Erro ao editar exercício: ${e.message}');
    }
  }

  Future<void> deleteExercise({
    required String gymId,
    required String exerciseId,
  }) async {
    try {
      await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('exercises')
          .doc(exerciseId)
          .delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionException('Sem permissão para excluir exercício.');
      }
      throw UnknownException('Erro ao excluir exercício: ${e.message}');
    }
  }
}
