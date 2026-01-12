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
  final List<ZoneTask> subtasks;

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
    this.subtasks = const [],
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
    List<ZoneTask>? subtasks,
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
      subtasks: subtasks ?? this.subtasks,
    );
  }

  /// Helper to make a fresh, mutable copy.
  Zone copy() => copyWith();
}

class ZoneTask {
  final String? id;
  final String name;
  final double progress;
  final int volunteers;
  final List<String> assignedVolunteerIds;
  final List<String> assignedVolunteerNames;

  const ZoneTask({
    this.id,
    required this.name,
    required this.progress,
    required this.volunteers,
    this.assignedVolunteerIds = const [],
    this.assignedVolunteerNames = const [],
  });

  ZoneTask copyWith({
    String? id,
    String? name,
    double? progress,
    int? volunteers,
    List<String>? assignedVolunteerIds,
    List<String>? assignedVolunteerNames,
  }) {
    return ZoneTask(
      id: id ?? this.id,
      name: name ?? this.name,
      progress: progress ?? this.progress,
      volunteers: volunteers ?? this.volunteers,
      assignedVolunteerIds:
          assignedVolunteerIds ?? this.assignedVolunteerIds,
      assignedVolunteerNames:
          assignedVolunteerNames ?? this.assignedVolunteerNames,
    );
  }
}
