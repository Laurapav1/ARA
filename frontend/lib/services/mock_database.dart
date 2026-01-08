// File: lib/services/mock_database.dart
import 'package:flutter/foundation.dart';
import 'package:frontend/models/handling_flag.dart';
import '../models/animal.dart';
import '../models/volunteer_request.dart';

enum VolunteerStatus { anonymous, pending, approved }

class MockDatabase extends ChangeNotifier {
  bool isStaff = false;
  bool isOffline = true;
  int pendingChanges = 0;
  VolunteerStatus volunteerStatus = VolunteerStatus.anonymous;

  final List<VolunteerRequest> _volRequests = [
    VolunteerRequest(
      id: 'v1',
      name: 'Alice',
      startOfStay: DateTime(2025, 7, 10),
      endOfStay: DateTime(2025, 8, 1),
    ),
    VolunteerRequest(
      id: 'v2',
      name: 'Bob',
      startOfStay: DateTime(2025, 7, 15),
      endOfStay: DateTime(2025, 8, 5),
    ),
  ];

  final List<Animal> _animals = [
    Animal(
      id: 'a1',
      name: 'Rex',
      species: 'dog',
      personality: 'Friendly',
      isDangerous: false,
      description: 'Loves belly rubs, high energy.',
      history: 'Found stray near park. Vaccinated 2025-06-10.',
      trainingVideos: ['https://youtube.com/watch?v=abc123'],
      flags: const {}, // none
    ),
    Animal(
      id: 'a2',
      name: 'Luna',
      species: 'dog',
      personality: 'Shy',
      isDangerous: true,
      description: 'Very quiet, scared of loud noises.',
      history: 'Surrendered by owner. Medical check pending.',
      flags: const {HandlingFlag.doubleLeash, HandlingFlag.muzzle},
    ),
    Animal(
      id: 'a3',
      name: 'Whiskers',
      species: 'cat',
      personality: 'Playful',
      isDangerous: false,
      description: 'Chases laser pointers all day.',
      history: 'Rescued from shelter.',
    ),
    Animal(
      id: 'a4',
      name: 'Shadow',
      species: 'cat',
      personality: 'Cautious',
      isDangerous: false,
      description: 'Hides under beds.',
      history: 'Stray.',
    ),
  ];

  List<VolunteerRequest> get pendingRequests => List.unmodifiable(_volRequests);
  List<Animal> get animals => List.unmodifiable(_animals);
  bool get isApprovedVolunteer =>
      volunteerStatus == VolunteerStatus.approved || isStaff;
  bool get isPendingVolunteer => volunteerStatus == VolunteerStatus.pending;

  void acceptRequest(String id) {
    _volRequests.removeWhere((v) => v.id == id);
    pendingChanges++;
    notifyListeners();
  }

  void submitVolunteerRequest({
    required String firstName,
    required String lastName,
    required DateTime startOfStay,
    required DateTime endOfStay,
  }) {
    final request = VolunteerRequest(
      id: 'v${DateTime.now().millisecondsSinceEpoch}',
      name: '$firstName $lastName',
      startOfStay: startOfStay,
      endOfStay: endOfStay,
    );
    _volRequests.add(request);
    volunteerStatus = VolunteerStatus.pending;
    pendingChanges++;
    notifyListeners();
  }

  void setVolunteerStatus(VolunteerStatus status) {
    volunteerStatus = status;
    notifyListeners();
  }

  void updateAnimal(Animal updated) {
    final idx = _animals.indexWhere((a) => a.id == updated.id);
    if (idx != -1) _animals[idx] = updated;
    pendingChanges++;
    notifyListeners();
  }

  Future<void> sync() async {
    await Future.delayed(const Duration(seconds: 1));
    isOffline = false;
    pendingChanges = 0;
    notifyListeners();
  }
}
