import 'package:flutter/material.dart';

import 'animal_list_screen.dart';

class CatsScreen extends StatelessWidget {
  const CatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimalListScreen(
      title: 'Cats',
      subtitle: 'Tap to view profile',
      species: 'cat',
      accentColor: Color(0xFFC2185B),
      accentSoft: Color(0xFFF3D6E0),
      emptyText: 'No cats match that name.',
    );
  }
}
