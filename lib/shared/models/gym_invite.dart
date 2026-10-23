import 'package:cloud_firestore/cloud_firestore.dart';

class GymInvite {
  final String id;
  final String code;
  final String email;
  final String role;
  final String status; // pending, used, expired
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? usedBy;
  final DateTime? usedAt;

  const GymInvite({
    required this.id,
    required this.code,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.usedBy,
    this.usedAt,
  });

  factory GymInvite.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return GymInvite(
      id: doc.id,
      code: data['code'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'student',
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usedBy: data['usedBy'] as String?,
      usedAt: (data['usedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'code': code,
        'email': email,
        'role': role,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
      };
}
