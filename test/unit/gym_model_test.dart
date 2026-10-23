import 'package:fitacademia/shared/models/gym.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gym.toCreateMap', () {
    test('inclui ownerUid e campos obrigatórios', () {
      final gym = Gym(
        id: 'abc',
        name: 'Fit Centro',
        status: 'active',
        ownerUid: 'uid1',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
        city: 'São Paulo',
        state: 'SP',
      );
      final map = gym.toCreateMap(ownerUid: 'uid1');
      expect(map['name'], 'Fit Centro');
      expect(map['ownerUid'], 'uid1');
      expect(map['status'], 'active');
      expect(map['city'], 'São Paulo');
      expect(map['state'], 'SP');
      expect(map['subscriptionPlanId'], 'essential');
      expect(map.containsKey('createdAt'), isTrue);
      expect(map.containsKey('updatedAt'), isTrue);
    });

    test('isActive retorna true para active e trial', () {
      final active = Gym(
        id: 'a',
        name: 'A',
        status: 'active',
        ownerUid: 'o',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final trial = Gym(
        id: 'b',
        name: 'B',
        status: 'trial',
        ownerUid: 'o',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(active.isActive, isTrue);
      expect(trial.isActive, isTrue);
    });
  });
}
