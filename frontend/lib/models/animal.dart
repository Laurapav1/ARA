class Animal {
  final String id;
  final String name;
  final String personality;
  final bool isDangerous;
  Animal({
    required this.id,
    required this.name,
    required this.personality,
    required this.isDangerous,
  });
  Animal copyWith({String? personality, bool? isDangerous}) {
    return Animal(
      id: id,
      name: name,
      personality: personality ?? this.personality,
      isDangerous: isDangerous ?? this.isDangerous,
    );
  }
}
