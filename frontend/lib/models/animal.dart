// File: lib/models/animal.dart
import 'dart:typed_data';

import 'handling_flag.dart';

class Animal {
  final String id;
  final String name;
  final String species; // 'dog' or 'cat'
  final String personality;
  final bool isDangerous;
  final bool isInTreatment;
  final Uint8List? photoBytes;
  final String age;
  final String breed;
  final String gender;
  final String description;
  final String history;
  final List<String> trainingVideos;
  final Set<HandlingFlag> flags;
  final String zone;
  final String kennel;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.personality,
    required this.isDangerous,
    this.isInTreatment = false,
    this.photoBytes,
    this.age = '',
    this.breed = '',
    this.gender = '',
    this.description = '',
    this.history = '',
    this.trainingVideos = const [],
    this.flags = const {},
    this.zone = '',
    this.kennel = '',
  });

  Animal copyWith({
    String? personality,
    bool? isDangerous,
    bool? isInTreatment,
    Uint8List? photoBytes,
    String? age,
    String? breed,
    String? gender,
    String? description,
    String? history,
    List<String>? trainingVideos,
    Set<HandlingFlag>? flags,
    String? zone,
    String? kennel,
  }) {
    return Animal(
      id: id,
      name: name,
      species: species,
      personality: personality ?? this.personality,
      isDangerous: isDangerous ?? this.isDangerous,
      isInTreatment: isInTreatment ?? this.isInTreatment,
      photoBytes: photoBytes ?? this.photoBytes,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      description: description ?? this.description,
      history: history ?? this.history,
      trainingVideos: trainingVideos ?? this.trainingVideos,
      flags: flags ?? this.flags,
      zone: zone ?? this.zone,
      kennel: kennel ?? this.kennel,
    );
  }
}
