import 'package:app_flutter_test/main.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:provider/provider.dart';

class MockCharactersRepository extends Mock implements CharactersRepository {}

const MethodChannel _channel = MethodChannel(
  'plugins.flutter.io/shared_preferences',
);

Future<Map<String, dynamic>> handler(MethodCall methodCall) async {
  return {
    'flutter.characters': [
      '{"id": 1, "name": "Rick Sanchez", "status": "Alive", "species": "Human", "type": "", "gender": "Male", "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg", "location": {"name": "Citadel of Ricks"}, "origin": {"name": "Earth (C-137)"}}',
    ],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, handler);

  test('getCharacters возвращает список персонажей', () async {
    final characters = await CharactersRepositoryImpl().getCharacters();
    expect(characters, isNotEmpty);
    expect(characters.length, 1);
    expect(characters.first.name, 'Rick Sanchez');
  });

  test('CharacterChangeNotifier возвращает список персонажей', () async {
    fakeAsync((_) async {
      final charactersRepository = MockCharactersRepository();

      when(() => charactersRepository.getCharacters()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 10));
        return [
          Character(
            id: 1,
            name: 'Rick Sanchez',
            status: 'Alive',
            species: 'Human',
            type: '',
            gender: 'Male',
            image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
            location: 'Citadel of Ricks',
            origin: 'Earth (C-137)',
          ),
        ];
      });

      final characterChangeNotifier = CharacterChangeNotifier(
        charactersRepository: charactersRepository,
      );
      await characterChangeNotifier.getCharacters();
      expect(characterChangeNotifier.characters, isNotEmpty);
      expect(characterChangeNotifier.characters.length, 1);
      expect(characterChangeNotifier.characters.first.name, 'Rick Sanchez');
    });
  });

  testWidgets('CharacterChangeNotifier возвращает список персонажей', (
    WidgetTester tester,
  ) async {
    final charactersRepository = MockCharactersRepository();
    when(() => charactersRepository.getCharacters()).thenAnswer((_) async {
      return [
        Character(
          id: 1,
          name: 'Rick Sanchez',
          status: 'Alive',
          species: 'Human',
          type: '',
          gender: 'Male',
          image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
          location: 'Citadel of Ricks',
          origin: 'Earth (C-137)',
        ),
        Character(
          id: 2,
          name: 'Morty Smith',
          status: 'Alive',
          species: 'Human',
          type: '',
          gender: 'Male',
          image: 'https://rickandmortyapi.com/api/character/avatar/2.jpeg',
          location: 'Citadel of Ricks',
          origin: 'Earth (C-137)',
        ),
      ];
    });
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CharacterChangeNotifier>(
            create: (context) => CharacterChangeNotifier(
              charactersRepository: charactersRepository,
            ),
          ),
        ],
        child: MaterialApp(home: CharactersListScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Rick Sanchez'), findsOneWidget);
    // expect(find.byType(Image), findsAtLeast(2));
  });

  testWidgets('CharacterChangeNotifier удаляет персонажа', (
    WidgetTester tester,
  ) async {
    final charactersRepository = MockCharactersRepository();
    when(() => charactersRepository.getCharacters()).thenAnswer((_) async {
      return [
        Character(
          id: 1,
          name: 'Rick Sanchez',
          status: 'Alive',
          species: 'Human',
          type: '',
          gender: 'Male',
          image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
          location: 'Citadel of Ricks',
          origin: 'Earth (C-137)',
        ),
        Character(
          id: 2,
          name: 'Morty Smith',
          status: 'Alive',
          species: 'Human',
          type: '',
          gender: 'Male',
          image: 'https://rickandmortyapi.com/api/character/avatar/2.jpeg',
          location: 'Citadel of Ricks',
          origin: 'Earth (C-137)',
        ),
      ];
    });
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CharacterChangeNotifier>(
            create: (context) => CharacterChangeNotifier(
              charactersRepository: charactersRepository,
            ),
          ),
        ],
        child: MaterialApp(home: CharactersListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Morty Smith'), findsOneWidget);
    await tester.tap(find.text('Rick Sanchez'));
    await tester.pumpAndSettle();
    expect(find.text('Rick Sanchez'), findsNothing);
    expect(find.text('Morty Smith'), findsOneWidget);
  });

  testGoldens('CharacterListScreen со списком персонажей', (tester) async {
    await loadAppFonts();
    final charactersRepository = MockCharactersRepository();
    when(() => charactersRepository.getCharacters()).thenAnswer((_) async {
      return [
        Character(
          id: 1,
          name: 'Rick Sanchez',
          status: 'Alive',
          species: 'Human',
          type: '',
          gender: 'Male',
          image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
          location: 'Citadel of Ricks',
          origin: 'Earth (C-137)',
        ),
      ];
    });
    await mockNetworkImages(
      () async => await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CharacterChangeNotifier>(
              create: (context) => CharacterChangeNotifier(
                charactersRepository: charactersRepository,
              ),
            ),
          ],
          child: MaterialApp(home: CharactersListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'character_list_screen');
  });
}
