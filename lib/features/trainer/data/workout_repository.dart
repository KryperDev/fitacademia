import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/workout_plan.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore;

  WorkoutRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<WorkoutPlan>> streamStudentPlans(String gymId, String studentUid) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('workoutPlans')
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(WorkoutPlan.fromDoc).toList());
  }

  Stream<List<WorkoutPlan>> streamAllPlans(String gymId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('workoutPlans')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(WorkoutPlan.fromDoc).toList());
  }

  Future<WorkoutPlan> savePlan({
    required String gymId,
    required WorkoutPlan plan,
  }) async {
    try {
      final ref = _firestore.collection('gyms').doc(gymId).collection('workoutPlans').doc();
      final newPlan = WorkoutPlan(
        id: ref.id,
        name: plan.name,
        studentUid: plan.studentUid,
        createdBy: plan.createdBy,
        version: plan.version,
        status: plan.status,
        exercises: plan.exercises,
        createdAt: plan.createdAt,
        updatedAt: DateTime.now(),
        publishedAt: plan.publishedAt,
      );
      await ref.set(newPlan.toCreateMap());
      return newPlan;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionException('Sem permissão para salvar a ficha.');
      }
      throw UnknownException('Erro ao salvar ficha: ${e.message}');
    }
  }

  Future<void> updatePlan({
    required String gymId,
    required String planId,
    required WorkoutPlan plan,
  }) async {
    try {
      await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('workoutPlans')
          .doc(planId)
          .update({
        'name': plan.name,
        'studentUid': plan.studentUid,
        'version': plan.version,
        'status': plan.status,
        'exercises': plan.exercises.map((e) => e.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
        'publishedAt': plan.publishedAt != null ? Timestamp.fromDate(plan.publishedAt!) : null,
      });
    } on FirebaseException catch (e) {
      throw UnknownException('Erro ao atualizar ficha: ${e.message}');
    }
  }
}
