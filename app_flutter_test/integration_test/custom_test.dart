import 'package:app_flutter_test/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'CharacterChangeNotifier удаляет персонажа',
    (tester) async {
      app.main();

      await tester.pumpAndSettle();
      expect(find.text('Rick Sanchez'), findsOneWidget);
      expect(find.text('Morty Smith'), findsOneWidget);
      await tester.tap(find.text('Rick Sanchez'));
      await tester.pumpAndSettle();
      expect(find.text('Rick Sanchez'), findsNothing);
      expect(find.text('Morty Smith'), findsOneWidget);
    },
  );
  testWidgets(
    'CharacterChangeNotifier удаляет персонажа',
    (tester) async {
      // app.main();
      await tester.pumpWidget(const app.MainApp());

      await tester.pumpAndSettle();
      expect(find.text('Rick Sanchez'), findsOneWidget);
      expect(find.text('Morty Smith'), findsOneWidget);
      await tester.tap(find.text('Rick Sanchez'));
      await tester.pumpAndSettle();
      expect(find.text('Rick Sanchez'), findsNothing);
      expect(find.text('Morty Smith'), findsOneWidget);
    },
  );
}
