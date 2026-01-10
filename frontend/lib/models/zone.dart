// File: lib/models/zone.dart
class Zone {
  final String? taskId;
  final String name;
  final String category;
  final String? startTime;
  final double progress;
  final int volunteers;
  final int? taskCount;
  final List<String> tasks;
  final String tip;
  final List<String> assignedVolunteerIds;
  final List<String> assignedVolunteerNames;

  const Zone({
    this.taskId,
    required this.name,
    this.category = 'General',
    this.startTime,
    required this.progress,
    required this.volunteers,
    this.taskCount,
    required this.tasks,
    required this.tip,
    this.assignedVolunteerIds = const [],
    this.assignedVolunteerNames = const [],
  });

  /// Create a new Zone from this one, with modified fields.
  Zone copyWith({
    String? taskId,
    String? name,
    String? category,
    String? startTime,
    double? progress,
    int? volunteers,
    int? taskCount,
    List<String>? tasks,
    String? tip,
    List<String>? assignedVolunteerIds,
    List<String>? assignedVolunteerNames,
  }) {
    return Zone(
      taskId: taskId ?? this.taskId,
      name: name ?? this.name,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      progress: progress ?? this.progress,
      volunteers: volunteers ?? this.volunteers,
      taskCount: taskCount ?? this.taskCount,
      tasks: tasks ?? this.tasks,
      tip: tip ?? this.tip,
      assignedVolunteerIds:
          assignedVolunteerIds ?? this.assignedVolunteerIds,
      assignedVolunteerNames:
          assignedVolunteerNames ?? this.assignedVolunteerNames,
    );
  }

  /// Helper to make a fresh, mutable copy.
  Zone copy() => copyWith();
}
