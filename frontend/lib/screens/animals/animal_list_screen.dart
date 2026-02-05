import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../services/mock_database.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/animal_grid.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/search_field.dart';
import 'animal_detail.dart';
import 'animal_editor.dart';

class AnimalListScreen extends StatefulWidget {
  final String title;
  final String species;
  final Color accentColor;
  final Color accentSoft;
  final String emptyText;

  const AnimalListScreen({
    super.key,
    required this.title,
    required this.species,
    required this.accentColor,
    required this.accentSoft,
    required this.emptyText,
  });

  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  String _query = '';
  AnimalFilter _activeFilter = AnimalFilter.all;

  bool _needsCaution(Animal a) => a.isDangerous || a.flags.isNotEmpty;
  bool _isInTreatment(Animal a) => a.isInTreatment;

  List<Animal> _filterByName(List<Animal> list) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((a) => a.name.toLowerCase().contains(query)).toList();
  }

  List<Animal> _applyFilters(List<Animal> list) {
    final filtered = _filterByName(list);
    switch (_activeFilter) {
      case AnimalFilter.all:
        return filtered;
      case AnimalFilter.careRequired:
        return filtered.where(_needsCaution).toList();
      case AnimalFilter.inTreatment:
        return filtered.where(_isInTreatment).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final animals = db.animals;
    final speciesAnimals =
        animals.where((a) => a.species == widget.species).toList();
    final filtered = _applyFilters(speciesAnimals);
    final isStaff = db.isStaff;
    final showCautionIcon = _activeFilter == AnimalFilter.all;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: isStaff
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnimalEditorScreen(
                    initialSpecies: widget.species,
                  ),
                ),
              ),
              backgroundColor: ARAColors.brand,
              foregroundColor: ARAColors.ink,
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SearchField(
                onChanged: (value) => setState(() => _query = value),
                hintText: 'Search by name',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: AnimalFilterRow(
                activeFilter: _activeFilter,
                onChanged: (value) => setState(() => _activeFilter = value),
                onMoreFilters: () {},
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  AnimalGrid(
                    animals: filtered,
                    accentColor: widget.accentColor,
                    accentSoft: widget.accentSoft,
                    showCautionIcons: showCautionIcon,
                    needsCaution: _needsCaution,
                    onTap: (animal) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnimalDetailScreen(animal: animal),
                      ),
                    ),
                  ),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildEmptyState(),
                    ),
                  if (isStaff)
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SizedBox(height: 96),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ARAColors.surfaceWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ARAColors.surfaceWarmTint),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_off, color: ARAColors.subInk),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.emptyText,
              style: const TextStyle(color: ARAColors.subInk),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(backgroundColor: ARAColors.cardBg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
