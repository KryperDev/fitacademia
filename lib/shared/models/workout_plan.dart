import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutExercise {
  final String exerciseId;
  final String name;
  final int sets;
  final int repsMin;
  final int repsMax;
  final int restSeconds;
  final String notes;

  const WorkoutExercise({
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.repsMin,
    required this.repsMax,
    required this.restSeconds,
    this.notes = '',
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exerciseId: map['exerciseId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      sets: map['sets'] as int? ?? 3,
      repsMin: map['repsMin'] as int? ?? 8,
      repsMax: map['repsMax'] as int? ?? 12,
      restSeconds: map['restSeconds'] as int? ?? 60,
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'exerciseId': exerciseId,
        'name': name,
        'sets': sets,
        'repsMin': repsMin,
        'repsMax': repsMax,
        'restSeconds': restSeconds,
        'notes': notes,
      };

  WorkoutExercise copyWith({
    String? name,
    int? sets,
    int? repsMin,
    int? repsMax,
    int? restSeconds,
    String? notes,
  }) =>
      WorkoutExercise(
        exerciseId: exerciseId,
        name: name ?? this.name,
        sets: sets ?? this.sets,
        repsMin: repsMin ?? this.repsMin,
        repsMax: repsMax ?? this.repsMax,
        restSeconds: restSeconds ?? this.restSeconds,
        notes: notes ?? this.notes,
      );
}

class WorkoutPlan {
  final String id;
  final String name;
  final String studentUid;
  final String createdBy;
  final int version;
  final String status;
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.studentUid,
    required this.createdBy,
    this.version = 1,
    this.status = 'draft',
    this.exercises = const [],
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  factory WorkoutPlan.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final exList = (data['exercises'] as List?)
            ?.map((e) => WorkoutExercise.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    return WorkoutPlan(
      id: doc.id,
      name: data['name'] as String? ?? '',
      studentUid: data['studentUid'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      version: data['version'] as int? ?? 1,
      status: data['status'] as String? ?? 'draft',
      exercises: exList,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'name': name,
        'studentUid': studentUid,
        'createdBy': createdBy,
        'version': version,
        'status': status,
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      };
}
