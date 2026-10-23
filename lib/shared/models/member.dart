import 'package:cloud_firestore/cloud_firestore.dart';
import 'gym_role.dart';

class Member {
  final String uid;
  final String displayName;
  final GymRole role;
  final String status;
  final String? trainerUid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Member({
    required this.uid,
    required this.displayName,
    required this.role,
    required this.status,
    this.trainerUid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Member.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Member(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      role: GymRole.fromString(data['role'] as String?) ?? GymRole.student,
      status: data['status'] as String? ?? 'active',
      trainerUid: data['trainerUid'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toCreateMap() => {
    'uid': uid,
    'displayName': displayName,
    'role': role.firestoreValue,
    'status': status,
    'trainerUid': trainerUid,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
