import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CharacterChangeNotifier>(
          create: (context) => CharacterChangeNotifier(
            charactersRepository: CharactersRepositoryImpl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Rick and Morty',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: CharactersListScreen(),
      ),
    );
  }
}

class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({super.key});

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> {
  late CharacterChangeNotifier characterChangeNotifier = context
      .read<CharacterChangeNotifier>();

  @override
  void initState() {
    super.initState();
    characterChangeNotifier.getCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: characterChangeNotifier,
      builder: (context, child) => Scaffold(
        appBar: AppBar(title: const Text('Rick and Morty Characters')),
        body: ListView.builder(
          itemCount: characterChangeNotifier.characters.length,
          itemBuilder: (context, index) {
            return CharacterCard(
              character: characterChangeNotifier.characters[index],
              onTap: () {
                characterChangeNotifier.deleteCharacter(
                  characterChangeNotifier.characters[index].id,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CharacterChangeNotifier extends ChangeNotifier {
  final CharactersRepository charactersRepository;

  CharacterChangeNotifier({required this.charactersRepository});

  List<Character> characters = [];

  Future<void> getCharacters() async {
    final charactersList = await charactersRepository.getCharacters();
    characters = charactersList;
    notifyListeners();
  }

  void deleteCharacter(int id) {
    characters = characters.where((character) => character.id != id).toList();
    notifyListeners();
  }
}

abstract class CharactersRepository {
  Future<List<Character>> getCharacters();
}

class CharactersRepositoryImpl implements CharactersRepository {
  @override
  Future<List<Character>> getCharacters() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final charactersString =
        sharedPreferences.getStringList('characters') ?? [];
    if (charactersString.isNotEmpty) {
      print('charactersString is not empty');
      return charactersString.map((character) {
        final characterMap = jsonDecode(character);
        return Character(
          id: characterMap['id'],
          name: characterMap['name'],
          status: characterMap['status'],
          species: characterMap['species'],
          type: characterMap['type'],
          gender: characterMap['gender'],
          image: characterMap['image'],
          location: characterMap['location']['name'],
          origin: characterMap['origin']['name'],
        );
      }).toList();
    }
    print('charactersString is empty');
    final dio = Dio();
    final response = await dio.get('https://rickandmortyapi.com/api/character');
    final characters = response.data['results'];
    final charactersList = (characters as List)
        .map(
          (character) => Character(
            id: character['id'],
            name: character['name'],
            status: character['status'],
            species: character['species'],
            type: character['type'],
            gender: character['gender'],
            image: character['image'],
            location: character['location']['name'],
            origin: character['origin']['name'],
          ),
        )
        .toList();
    await sharedPreferences.setStringList(
      'characters',
      charactersList
          .map(
            (character) => jsonEncode({
              'id': character.id,
              'name': character.name,
              'status': character.status,
              'species': character.species,
              'type': character.type,
              'gender': character.gender,
              'image': character.image,
              'location': {'name': character.location},
              'origin': {'name': character.origin},
            }),
          )
          .toList(),
    );
    return charactersList;
  }
}

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Icon(Icons.person),
                // child: Image.network(
                //   character.image,
                //   width: 80,
                //   height: 80,
                //   fit: BoxFit.cover,
                //   errorBuilder: (context, error, stackTrace) =>
                //       const Icon(Icons.error),
                // ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${character.species} - ${character.status}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class Character extends Equatable {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final String location;
  final String origin;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.location,
    required this.origin,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    species,
    type,
    gender,
    image,
    location,
    origin,
  ];
}
