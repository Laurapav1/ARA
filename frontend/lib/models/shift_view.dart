class AssignedVolunteer {
  final String id;
  final String firstName;
  final String lastName;

  AssignedVolunteer({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory AssignedVolunteer.fromJson(Map<String, dynamic> json) {
    return AssignedVolunteer(
      id: json['id'].toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
    );
  }
}

class ShiftTask {
  final String id;
  final String name;
  final int? maxVolunteers;
  final int requiredVolunteers;
  final int assignedCount;
  final String status;
  final List<AssignedVolunteer> assignedVolunteers;

  ShiftTask({
    required this.id,
    required this.name,
    required this.maxVolunteers,
    required this.requiredVolunteers,
    required this.assignedCount,
    required this.status,
    required this.assignedVolunteers,
  });

  factory ShiftTask.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    final status = rawStatus is int
        ? _statusFromInt(rawStatus)
        : rawStatus?.toString() ?? 'Missing';

    return ShiftTask(
      id: json['taskId'].toString(),
      name: json['name']?.toString() ?? '',
      maxVolunteers: json['maxVolunteers'] as int?,
      requiredVolunteers: json['requiredVolunteers'] as int? ?? 0,
      assignedCount: json['assignedCount'] as int? ?? 0,
      status: status,
      assignedVolunteers: (json['assignedVolunteers'] as List<dynamic>? ?? [])
          .map((v) => AssignedVolunteer.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  static String _statusFromInt(int value) {
    switch (value) {
      case 2:
        return 'Done';
      case 1:
        return 'InProgress';
      default:
        return 'Missing';
    }
  }
}

class ShiftView {
  final String shiftId;
  final String date;
  final String shiftType;
  final String season;
  final String startTime;
  final List<ShiftTask> tasks;

  ShiftView({
    required this.shiftId,
    required this.date,
    required this.shiftType,
    required this.season,
    required this.startTime,
    required this.tasks,
  });

  factory ShiftView.fromJson(Map<String, dynamic> json) {
    return ShiftView(
      shiftId: json['shiftId'].toString(),
      date: json['date']?.toString() ?? '',
      shiftType: json['shiftType']?.toString() ?? '',
      season: json['season']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((t) => ShiftTask.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
