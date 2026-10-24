import 'package:cloud_firestore/cloud_firestore.dart';

class LoggedSet {
  final int setNumber;
  final double weight;
  final int reps;
  final bool completed;

  const LoggedSet({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.completed = true,
  });

  Map<String, dynamic> toMap() => {
    'setNumber': setNumber,
    'weight': weight,
    'reps': reps,
    'completed': completed,
  };

  factory LoggedSet.fromMap(Map<String, dynamic> map) {
    return LoggedSet(
      setNumber: map['setNumber'] as int? ?? 1,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      reps: map['reps'] as int? ?? 0,
      completed: map['completed'] as bool? ?? true,
    );
  }
}

class ExerciseSession {
  final String exerciseId;
  final String name;
  final int targetSets;
  final int targetRepsMin;
  final int targetRepsMax;
  final int restSeconds;
  final String notes;
  final List<LoggedSet> loggedSets;

  const ExerciseSession({
    required this.exerciseId,
    required this.name,
    required this.targetSets,
    required this.targetRepsMin,
    required this.targetRepsMax,
    required this.restSeconds,
    this.notes = '',
    this.loggedSets = const [],
  });

  Map<String, dynamic> toMap() => {
    'exerciseId': exerciseId,
    'name': name,
    'targetSets': targetSets,
    'targetRepsMin': targetRepsMin,
    'targetRepsMax': targetRepsMax,
    'restSeconds': restSeconds,
    'notes': notes,
    'loggedSets': loggedSets.map((s) => s.toMap()).toList(),
  };

  factory ExerciseSession.fromMap(Map<String, dynamic> map) {
    final setsList = (map['loggedSets'] as List?)
            ?.map((s) => LoggedSet.fromMap(Map<String, dynamic>.from(s)))
            .toList() ??
        [];
    return ExerciseSession(
      exerciseId: map['exerciseId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      targetSets: map['targetSets'] as int? ?? 3,
      targetRepsMin: map['targetRepsMin'] as int? ?? 8,
      targetRepsMax: map['targetRepsMax'] as int? ?? 12,
      restSeconds: map['restSeconds'] as int? ?? 60,
      notes: map['notes'] as String? ?? '',
      loggedSets: setsList,
    );
  }
}

class WorkoutSession {
  final String id;
  final String studentUid;
  final String assignmentId;
  final String planId;
  final int planVersion;
  final String status; // in_progress, completed, abandoned
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;
  final List<ExerciseSession> exercises;

  const WorkoutSession({
    required this.id,
    required this.studentUid,
    required this.assignmentId,
    required this.planId,
    required this.planVersion,
    this.status = 'in_progress',
    required this.startedAt,
    this.completedAt,
    this.durationSeconds,
    this.exercises = const [],
  });

  factory WorkoutSession.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final exList = (data['exercises'] as List?)
            ?.map((e) => ExerciseSession.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    return WorkoutSession(
      id: doc.id,
      studentUid: data['studentUid'] as String? ?? '',
      assignmentId: data['assignmentId'] as String? ?? '',
      planId: data['planId'] as String? ?? '',
      planVersion: data['planVersion'] as int? ?? 1,
      status: data['status'] as String? ?? 'in_progress',
      startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      durationSeconds: data['durationSeconds'] as int?,
      exercises: exList,
    );
  }

  Map<String, dynamic> toCreateMap() => {
    'studentUid': studentUid,
    'assignmentId': assignmentId,
    'planId': planId,
    'planVersion': planVersion,
    'status': status,
    'startedAt': Timestamp.fromDate(startedAt),
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    'durationSeconds': durationSeconds,
    'exercises': exercises.map((e) => e.toMap()).toList(),
  };
}

