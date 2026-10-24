import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String id;
  final String name;
  final String description;
  final List<String> muscleGroups;
  final String equipment;
  final String instructions;
  final String? mediaProvider; // 'youtube', 'vimeo', 'external', ou null
  final String? mediaUrl;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Exercise({
    required this.id,
    required this.name,
    this.description = '',
    this.muscleGroups = const [],
    this.equipment = '',
    this.instructions = '',
    this.mediaProvider,
    this.mediaUrl,
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exercise.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Exercise(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      muscleGroups: List<String>.from(data['muscleGroups'] ?? []),
      equipment: data['equipment'] as String? ?? '',
      instructions: data['instructions'] as String? ?? '',
      mediaProvider: data['mediaProvider'] as String?,
      mediaUrl: data['mediaUrl'] as String?,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toCreateMap() => {
    'name': name,
    'description': description,
    'muscleGroups': muscleGroups,
    'equipment': equipment,
    'instructions': instructions,
    'mediaProvider': mediaProvider,
    'mediaUrl': mediaUrl,
    'active': active,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
