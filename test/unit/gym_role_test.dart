import 'package:fitacademia/shared/models/gym_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GymRole', () {
    test('fromString mapeia corretamente', () {
      expect(GymRole.fromString('student'), GymRole.student);
      expect(GymRole.fromString('trainer'), GymRole.trainer);
      expect(GymRole.fromString('admin'), GymRole.admin);
      expect(GymRole.fromString(null), isNull);
      expect(GymRole.fromString('invalido'), isNull);
    });

    test('firestoreValue retorna o valor correto', () {
      expect(GymRole.student.firestoreValue, 'student');
      expect(GymRole.trainer.firestoreValue, 'trainer');
      expect(GymRole.admin.firestoreValue, 'admin');
    });

    test('labelPt retorna rótulo em português', () {
      expect(GymRole.student.labelPt, 'Aluno');
      expect(GymRole.trainer.labelPt, 'Professor');
      expect(GymRole.admin.labelPt, 'Administrador');
    });
  });
}
