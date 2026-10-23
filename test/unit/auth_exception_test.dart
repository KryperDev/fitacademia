import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitacademia/core/errors/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthException.fromFirebase', () {
    test('mapeia user-not-found', () {
      final e = FirebaseAuthException(code: 'user-not-found');
      final app = AuthException.fromFirebase(e);
      expect(app.message, contains('Nenhuma conta'));
      expect(app.code, 'user-not-found');
    });

    test('mapeia email-already-in-use', () {
      final e = FirebaseAuthException(code: 'email-already-in-use');
      final app = AuthException.fromFirebase(e);
      expect(app.message, contains('já está em uso'));
    });

    test('mapeia weak-password', () {
      final e = FirebaseAuthException(code: 'weak-password');
      final app = AuthException.fromFirebase(e);
      expect(app.message, contains('fraca'));
    });

    test('fallback para código desconhecido', () {
      final e = FirebaseAuthException(code: 'unknown-xyz');
      final app = AuthException.fromFirebase(e);
      expect(app.message, contains('Erro de autenticação'));
    });
  });
}
