import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String accountStatus;

  const UserProfile({required this.uid, required this.displayName, required this.email, this.photoUrl, required this.createdAt, required this.updatedAt, this.accountStatus = 'active'});

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      accountStatus: data['accountStatus'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toCreateMap() => {
    'displayName': displayName,
    'email': email,
    'photoUrl': photoUrl,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'accountStatus': 'active',
  };
}
