import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/offline_banner.dart';
import '../../services/mock_database.dart';
import '../../models/animal.dart';
import '../../models/handling_flag.dart';
import '../../widgets/handling_flag_chips.dart';
import '../../theme/ara_theme.dart';

class AnimalDetailScreen extends StatelessWidget {
  final Animal animal;
  const AnimalDetailScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final isStaff = db.isStaff;

    final a = db.animals.firstWhere(
      (x) => x.id == animal.id,
      orElse: () => animal,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(a.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const OfflineBanner(),
          const SizedBox(height: 16),
          _buildHero(a),
          const SizedBox(height: 16),
          _buildInfoRow(a),
          const SizedBox(height: 16),
          _buildNotesSection(a),
          const SizedBox(height: 24),
          if (a.trainingVideos.isNotEmpty) ...[
            ElevatedButton(
              onPressed: () {
                // TODO: launch a.trainingVideos.first via url_launcher
              },
              child: const Text('Training'),
            ),
            const SizedBox(height: 16),
          ],
          if (isStaff) ...[
            ElevatedButton(
              onPressed: () => _editFlags(context, a),
              child: const Text('Edit handling flags'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHero(Animal a) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: ARAColors.surfaceWarm,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ARAColors.surfaceWarmTint),
        gradient: ARAColors.softBackgroundGradient,
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.pets, size: 80, color: ARAColors.brandDark),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                a.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(Animal a) {
    final needsCaution = a.isDangerous || a.flags.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                label: 'Species',
                value: _titleCase(a.species),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                label: 'Personality',
                value: a.personality.isNotEmpty ? a.personality : 'Unknown',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                label: 'Handling',
                value: needsCaution ? 'Use caution' : 'No special notes',
                isWarning: needsCaution,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                label: 'Flags',
                value: a.flags.isNotEmpty
                    ? '${a.flags.length} active'
                    : 'None',
                isWarning: a.flags.isNotEmpty,
              ),
            ),
          ],
        ),
        if (a.flags.isNotEmpty) ...[
          const SizedBox(height: 16),
          HandlingFlagChips(flags: a.flags),
        ],
      ],
    );
  }

  Widget _buildNotesSection(Animal a) {
    return Column(
      children: [
        _NoteCard(
          title: 'Care Notes',
          body: a.description.isNotEmpty
              ? a.description
              : 'No care notes yet.',
        ),
        const SizedBox(height: 12),
        _NoteCard(
          title: 'History',
          body: a.history.isNotEmpty ? a.history : 'No history yet.',
        ),
        const SizedBox(height: 12),
        _NoteCard(
          title: 'Kennel Card Summary',
          body: _buildKennelSummary(a),
        ),
      ],
    );
  }

  String _buildKennelSummary(Animal a) {
    final parts = <String>[];
    if (a.personality.isNotEmpty) {
      parts.add(a.personality);
    }
    if (a.isDangerous) {
      parts.add('Extra caution');
    }
    if (a.flags.isNotEmpty) {
      final labels = a.flags.map((f) => f.label).join(', ');
      parts.add('Handling: $labels');
    }
    if (parts.isEmpty) {
      return 'No kennel notes yet.';
    }
    return parts.join(' | ');
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  void _editFlags(BuildContext context, Animal currentAnimal) async {
    final db = context.read<MockDatabase>();
    final working = Set<HandlingFlag>.from(currentAnimal.flags);

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Handling flags',
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StatefulBuilder(
                    builder: (ctx, setState) => ListView(
                      children: HandlingFlag.values.map((f) {
                        return CheckboxListTile(
                          value: working.contains(f),
                          onChanged: (v) => setState(() {
                            v == true ? working.add(f) : working.remove(f);
                          }),
                          secondary: Icon(f.icon, color: f.color),
                          title: Text(f.label),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: FilledButton(
                    onPressed: () {
                      db.updateAnimal(currentAnimal.copyWith(flags: working));
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;

  const _InfoTile({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning ? ARAColors.cautionSurface : ARAColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning ? ARAColors.cautionBorder : ARAColors.surfaceWarmTint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ARAColors.subInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isWarning ? ARAColors.cautionText : ARAColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String title;
  final String body;

  const _NoteCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ARAColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ARAColors.surfaceWarmTint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ARAColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: ARAColors.subInk)),
        ],
      ),
    );
  }
}
