import 'package:flutter/material.dart';

import '../../theme/ara_theme.dart';
import 'animal_list_screen.dart';

class DogsScreen extends StatelessWidget {
  const DogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimalListScreen(
      title: 'Dogs',
      subtitle: 'Tap to view profile',
      species: 'dog',
      accentColor: ARAColors.dogAccent,
      accentSoft: ARAColors.dogAccentLight,
      emptyText: 'No dogs match that name.',
    );
  }
}
