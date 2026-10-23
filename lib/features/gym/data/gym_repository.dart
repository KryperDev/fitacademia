import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_exception.dart';
import '../../../shared/models/gym.dart';
import '../../../shared/models/gym_role.dart';
import '../../../shared/models/member.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/gym_invite.dart';

class MyGymMembershipData {
  final String gymId;
  final String role;
  final String gymName;

  const MyGymMembershipData({required this.gymId, required this.role, required this.gymName});
}

class GymRepository {
  final FirebaseFirestore _firestore;

  GymRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // --- CRIAÇÃO DE ACADEMIA ---
  Future<Gym> createGymWithAdmin({
    required UserProfile owner,
    required String name,
    required String city,
    required String state,
  }) async {
    final gymRef = _firestore.collection('gyms').doc(owner.uid);
    final memberRef = gymRef.collection('members').doc(owner.uid);
    final userMembershipRef = _firestore.collection('user_memberships').doc(owner.uid);

    final gym = Gym(
      id: gymRef.id,
      name: name.trim(),
      status: 'active',
      ownerUid: owner.uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      city: city.trim(),
      state: state.trim(),
    );

    final member = Member(
      uid: owner.uid,
      displayName: owner.displayName,
      role: GymRole.admin,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _firestore.runTransaction((transaction) async {
        transaction.set(gymRef, gym.toCreateMap(ownerUid: owner.uid));
        transaction.set(memberRef, member.toCreateMap());
        transaction.set(userMembershipRef, {
          'gymId': gymRef.id,
          'role': 'admin',
          'gymName': gym.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return gym;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionException('Sem permissão para criar academia.');
      }
      throw UnknownException('Erro ao criar academia: ${e.message}');
    }
  }

  // --- BUSCA DE VÍNCULO ---
  Future<MyGymMembershipData?> getMembershipDirect(String uid) async {
    try {
      final doc = await _firestore.collection('user_memberships').doc(uid).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return MyGymMembershipData(
        gymId: data['gymId'] as String,
        role: data['role'] as String,
        gymName: data['gymName'] as String? ?? 'Minha Academia',
      );
    } catch (e) {
      return null;
    }
  }

  // --- MEMBROS (TELA DO ADMIN) ---
  Stream<List<Member>> streamMembers(String gymId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('members')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Member.fromDoc(doc)).toList());
  }

  // --- CONVITES ---
  Future<GymInvite> createInvite({
    required String gymId,
    required String email,
    required String role,
  }) async {
    final code = _generateCode();
    final expiresAt = DateTime.now().add(const Duration(days: 7));
    
    final inviteRef = _firestore.collection('gyms').doc(gymId).collection('invites').doc();
    
    final invite = GymInvite(
      id: inviteRef.id,
      code: code,
      email: email.trim().toLowerCase(),
      role: role,
      status: 'pending',
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
    );

    await inviteRef.set(invite.toCreateMap());
    return invite;
  }

  Future<void> acceptInvite({
    required String code,
    required UserProfile user,
  }) async {
    final snapshot = await _firestore
        .collectionGroup('invites')
        .where('code', isEqualTo: code.toUpperCase())
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw const ValidationException('Convite inválido ou já utilizado.');
    }

    final inviteDoc = snapshot.docs.first;
    final invite = GymInvite.fromDoc(inviteDoc);
    final gymId = inviteDoc.reference.parent.parent!.id;

    if (invite.expiresAt.isBefore(DateTime.now())) {
      throw const ValidationException('Este convite expirou.');
    }

    final gymDoc = await _firestore.collection('gyms').doc(gymId).get();
    final gymName = gymDoc.data()?['name'] as String? ?? 'Academia';

    final memberRef = _firestore.collection('gyms').doc(gymId).collection('members').doc(user.uid);
    final userMembershipRef = _firestore.collection('user_memberships').doc(user.uid);
    
    final member = Member(
      uid: user.uid,
      displayName: user.displayName,
      role: GymRole.fromString(invite.role) ?? GymRole.student,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.runTransaction((transaction) async {
      transaction.update(inviteDoc.reference, {
        'status': 'used',
        'usedBy': user.uid,
        'usedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(memberRef, member.toCreateMap());
      transaction.set(userMembershipRef, {
        'gymId': gymId,
        'role': invite.role,
        'gymName': gymName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}