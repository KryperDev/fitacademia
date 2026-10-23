import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../data/auth_repository.dart';

/// Provider do repositório de autenticação.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider que expõe o stream de estado de autenticação.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

/// Estado do formulário de autenticação (login/cadastro).
class AuthFormState {
  final bool loading;
  final String? error;

  const AuthFormState({this.loading = false, this.error});

  AuthFormState copyWith({bool? loading, String? error, bool clearError = false}) {
    return AuthFormState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Controller de autenticação (Riverpod 3 Notifier).
class AuthController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.signIn(email: email, password: password);
      state = const AuthFormState();
      return true;
    } on AppException catch (e) {
      state = AuthFormState(error: e.message);
      return false;
    } catch (_) {
      state = const AuthFormState(error: 'Erro ao entrar. Tente novamente.');
      return false;
    }
  }

  Future<bool> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.signUp(
        displayName: displayName,
        email: email,
        password: password,
      );
      state = const AuthFormState();
      return true;
    } on AppException catch (e) {
      state = AuthFormState(error: e.message);
      return false;
    } catch (_) {
      state = const AuthFormState(error: 'Erro ao cadastrar. Tente novamente.');
      return false;
    }
  }

  Future<bool> sendPasswordReset({required String email}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.sendPasswordReset(email: email);
      state = const AuthFormState();
      return true;
    } on AppException catch (e) {
      state = AuthFormState(error: e.message);
      return false;
    } catch (_) {
      state = const AuthFormState(
        error: 'Erro ao enviar e-mail de recuperação.',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthFormState>(AuthController.new);
