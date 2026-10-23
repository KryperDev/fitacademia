import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/gym.dart';
import '../../../shared/models/gym_invite.dart';
import '../../../shared/models/member.dart';
import '../../../shared/models/user_profile.dart';
import 'gym_repository.dart';

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  return GymRepository();
});

// ==========================================
// 1. MEMBROS
// ==========================================
final membersStreamProvider = StreamProvider.family<List<Member>, String>((ref, gymId) {
  return ref.watch(gymRepositoryProvider).streamMembers(gymId);
});

// ==========================================
// 2. CRIAÇÃO DE ACADEMIA
// ==========================================
class CreateGymController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Gym?> createGym({
    required UserProfile owner,
    required String name,
    required String city,
    required String uf,
  }) async {
    state = const AsyncLoading<void>();
    try {
      final gym = await ref.read(gymRepositoryProvider).createGymWithAdmin(
        owner: owner,
        name: name,
        city: city,
        state: uf,
      );
      state = const AsyncData<void>(null);
      return gym;
    } on AppException catch (e, st) {
      state = AsyncError<void>(e.message, st);
      rethrow;
    } catch (e, st) {
      state = AsyncError<void>('Erro inesperado: $e', st);
      rethrow;
    }
  }
}

final createGymControllerProvider = AsyncNotifierProvider<CreateGymController, void>(CreateGymController.new);

// ==========================================
// 3. CONVITES
// ==========================================
class InviteController extends AsyncNotifier<GymInvite?> {
  @override
  Future<GymInvite?> build() async => null;

  Future<GymInvite?> createInvite({
    required String gymId,
    required String email,
    required String role,
  }) async {
    state = const AsyncLoading();
    try {
      final invite = await ref.read(gymRepositoryProvider).createInvite(
        gymId: gymId,
        email: email,
        role: role,
      );
      state = AsyncData(invite);
      return invite;
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
      rethrow;
    }
  }

  Future<void> acceptInvite({
    required String code,
    required UserProfile user,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(gymRepositoryProvider).acceptInvite(code: code, user: user);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
      rethrow;
    }
  }
}

final inviteControllerProvider = AsyncNotifierProvider<InviteController, GymInvite?>(InviteController.new);
