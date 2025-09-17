// File: lib/models/animal.dart
import 'handling_flag.dart';

class Animal {
  final String id;
  final String name;
  final String species; // 'dog' or 'cat'
  final String personality;
  final bool isDangerous;
  final String description;
  final String history;
  final List<String> trainingVideos;
  final Set<HandlingFlag> flags;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.personality,
    required this.isDangerous,
    this.description = '',
    this.history = '',
    this.trainingVideos = const [],
    this.flags = const {},
  });

  Animal copyWith({
    String? personality,
    bool? isDangerous,
    String? description,
    String? history,
    List<String>? trainingVideos,
    Set<HandlingFlag>? flags,
  }) {
    return Animal(
      id: id,
      name: name,
      species: species,
      personality: personality ?? this.personality,
      isDangerous: isDangerous ?? this.isDangerous,
      description: description ?? this.description,
      history: history ?? this.history,
      trainingVideos: trainingVideos ?? this.trainingVideos,
      flags: flags ?? this.flags,
    );
  }
}
