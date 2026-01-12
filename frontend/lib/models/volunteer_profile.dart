class VolunteerStay {
  final DateTime start;
  final DateTime end;

  const VolunteerStay({
    required this.start,
    required this.end,
  });
}

class VolunteerProfile {
  final String id;
  final String fullName;
  final String email;
  final DateTime? currentStayStart;
  final DateTime? currentStayEnd;
  final List<VolunteerStay> pastStays;

  const VolunteerProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.currentStayStart,
    required this.currentStayEnd,
    required this.pastStays,
  });

  VolunteerProfile copyWith({
    String? fullName,
    String? email,
    DateTime? currentStayStart,
    DateTime? currentStayEnd,
    List<VolunteerStay>? pastStays,
  }) {
    return VolunteerProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      currentStayStart: currentStayStart ?? this.currentStayStart,
      currentStayEnd: currentStayEnd ?? this.currentStayEnd,
      pastStays: pastStays ?? this.pastStays,
    );
  }
}
