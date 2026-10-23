import 'package:firebase_auth/firebase_auth.dart';

sealed class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});
  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

final class AuthException extends AppException {
  const AuthException(super.message, {super.code});
  factory AuthException.fromFirebase(FirebaseAuthException e) {
    final message = switch (e.code) {
      'user-not-found' => 'Nenhuma conta encontrada com este e-mail.',
      'wrong-password' => 'Senha incorreta.',
      'invalid-credential' => 'E-mail ou senha inválidos.',
      'email-already-in-use' => 'Este e-mail já está em uso.',
      'weak-password' => 'A senha é muito fraca. Use pelo menos 8 caracteres.',
      'invalid-email' => 'E-mail inválido.',
      'user-disabled' => 'Esta conta foi desativada.',
      'too-many-requests' => 'Muitas tentativas. Aguarde alguns minutos.',
      'network-request-failed' => 'Falha de conexão. Verifique sua internet.',
      'requires-recent-login' => 'Faça login novamente para concluir esta operação.',
      _ => 'Erro de autenticação. Tente novamente.',
    };
    return AuthException(message, code: e.code);
  }
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

final class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

final class UnknownException extends AppException {
  const UnknownException(super.message, {super.code});
}
