class Animal {
  final String id;
  final String name;
  final String personality;
  final bool isDangerous;
  final String description;
  final String history;

  Animal({
    required this.id,
    required this.name,
    required this.personality,
    required this.isDangerous,
    this.description = '',
    this.history = '',
  });

  Animal copyWith({
    String? personality,
    bool? isDangerous,
    String? description,
    String? history,
  }) {
    return Animal(
      id: id,
      name: name,
      personality: personality ?? this.personality,
      isDangerous: isDangerous ?? this.isDangerous,
      description: description ?? this.description,
      history: history ?? this.history,
    );
  }
}
