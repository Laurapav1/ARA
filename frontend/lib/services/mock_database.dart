import 'package:flutter/foundation.dart';
import '../models/volunteer_request.dart';
import '../models/animal.dart';

class MockDatabase extends ChangeNotifier {
  bool isStaff = false;
  bool isOffline = true;
  int pendingChanges = 0;

  final List<VolunteerRequest> _volRequests = [
    VolunteerRequest(id: 'v1', name: 'Alice', endOfStay: DateTime(2025, 8, 1)),
    VolunteerRequest(id: 'v2', name: 'Bob', endOfStay: DateTime(2025, 8, 5)),
  ];
  final List<Animal> _animals = [
    Animal(
      id: 'a1',
      name: 'Rex',
      personality: 'Friendly',
      isDangerous: false,
      description: 'Loves belly rubs, high energy.',
      history: 'Found stray near park. Vaccinated 2025-06-10.',
    ),
    Animal(
      id: 'a2',
      name: 'Luna',
      personality: 'Shy',
      isDangerous: true,
      description: 'Very quiet, scared of loud noises.',
      history: 'Surrendered by owner. Medical check pending.',
    ),
  ];

  List<VolunteerRequest> get pendingRequests => List.unmodifiable(_volRequests);
  List<Animal> get animals => List.unmodifiable(_animals);

  void acceptRequest(String id) {
    _volRequests.removeWhere((v) => v.id == id);
    pendingChanges++;
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
