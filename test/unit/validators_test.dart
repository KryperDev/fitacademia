import 'package:fitacademia/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('rejeita nulo e vazio', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('   '), isNotNull);
    });

    test('rejeita formato inválido', () {
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('abc@'), isNotNull);
      expect(Validators.email('abc@def'), isNotNull);
    });

    test('aceita e-mail válido', () {
      expect(Validators.email('aluno@fit.com'), isNull);
      expect(Validators.email('professor.x@academia.com.br'), isNull);
    });
  });

  group('Validators.password', () {
    test('exige no mínimo 8 caracteres', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
    });
  });

  group('Validators.displayName', () {
    test('aceita nome com 2 caracteres', () {
      expect(Validators.displayName('Jo'), isNull);
    });
    test('rejeita nome muito curto', () {
      expect(Validators.displayName('J'), isNotNull);
    });
    test('rejeita nome muito longo', () {
      expect(Validators.displayName('a' * 81), isNotNull);
    });
  });
}
