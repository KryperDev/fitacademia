import 'package:cloud_firestore/cloud_firestore.dart';

class Gym {
  final String id;
  final String name;
  final String? logoUrl;
  final String status;
  final String ownerUid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> settings;
  final String subscriptionPlanId;
  final String city;
  final String state;

  const Gym({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.status,
    required this.ownerUid,
    required this.createdAt,
    required this.updatedAt,
    this.settings = const {},
    this.subscriptionPlanId = 'essential',
    this.city = '',
    this.state = '',
  });

  factory Gym.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Gym(
      id: doc.id,
      name: data['name'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
      status: data['status'] as String? ?? 'trial',
      ownerUid: data['ownerUid'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      settings: (data['settings'] as Map<String, dynamic>?) ?? {},
      subscriptionPlanId: data['subscriptionPlanId'] as String? ?? 'essential',
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
    );
  }

  Map<String, dynamic> toCreateMap({required String ownerUid}) => {
    'name': name,
    'logoUrl': logoUrl,
    'status': status,
    'ownerUid': ownerUid,
    'city': city,
    'state': state,
    'settings': settings,
    'subscriptionPlanId': subscriptionPlanId,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  bool get isActive => status == 'active' || status == 'trial';
}
