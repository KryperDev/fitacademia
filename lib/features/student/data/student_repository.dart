import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/workout_plan.dart';
import '../../../shared/models/workout_session.dart';

class StudentRepository {
  final FirebaseFirestore _firestore;

  StudentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Pega a ficha ativa (published) mais recente do aluno
  Future<WorkoutPlan?> getActivePlan(String gymId, String studentUid) async {
    final snapshot = await _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('workoutPlans')
        .where('studentUid', isEqualTo: studentUid)
        .where('status', isEqualTo: 'published')
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return WorkoutPlan.fromDoc(snapshot.docs.first);
  }

  // Salva uma nova sessão de treino
  Future<void> saveSession(String gymId, WorkoutSession session) async {
    final ref = _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('workoutSessions')
        .doc();
    
    final newSession = WorkoutSession(
      id: ref.id,
      studentUid: session.studentUid,
      assignmentId: session.assignmentId,
      planId: session.planId,
      planVersion: session.planVersion,
      status: session.status,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      durationSeconds: session.durationSeconds,
      exercises: session.exercises,
    );

    await ref.set(newSession.toCreateMap());
  }

  // Lista o histórico de sessões concluídas
  Stream<List<WorkoutSession>> streamSessionHistory(String gymId, String studentUid) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('workoutSessions')
        .where('studentUid', isEqualTo: studentUid)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(WorkoutSession.fromDoc).toList());
  }
}
