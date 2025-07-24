// File: lib/models/zone.dart
class Zone {
  final String name;
  final double progress;
  final int volunteers;
  final List<String> tasks;
  final String tip;

  const Zone({
    required this.name,
    required this.progress,
    required this.volunteers,
    required this.tasks,
    required this.tip,
  });

  /// Create a new Zone from this one, with modified fields.
  Zone copyWith({
    String? name,
    double? progress,
    int? volunteers,
    List<String>? tasks,
    String? tip,
  }) {
    return Zone(
      name: name ?? this.name,
      progress: progress ?? this.progress,
      volunteers: volunteers ?? this.volunteers,
      tasks: tasks ?? this.tasks,
      tip: tip ?? this.tip,
    );
  }

  /// Helper to make a fresh, mutable copy.
  Zone copy() => copyWith();
}
