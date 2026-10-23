import 'package:fitacademia/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'FitAcademiaApp monta sem erros de bootstrap',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: FitAcademiaApp()),
      );

      // Avança frames sem pumpAndSettle (a splash e o loading de auth
      // contêm animações contínuas).
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(tester.takeException(), isNull);
    },
  );
}
