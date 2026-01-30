import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/offline_banner.dart';
import '../../services/mock_database.dart';
import '../../models/animal.dart';
import '../../models/handling_flag.dart';
import '../../widgets/handling_flag_chips.dart';
import '../../theme/ara_theme.dart';
import 'animal_editor.dart';
import 'animal_status_dialog.dart';

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
          const SizedBox(height: 12),
          _buildMoreInfo(context, a),
          const SizedBox(height: 24),
          if (a.trainingVideos.isNotEmpty) ...[
            FilledButton(
              onPressed: () {
              },
              child: const Text('Training'),
            ),
            const SizedBox(height: 16),
          ],
          if (isStaff) ...[
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnimalEditorScreen(animal: a),
                ),
              ),
              child: const Text('Edit details'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => showAnimalStatusDialog(context, a),
              style: OutlinedButton.styleFrom(
                foregroundColor: ARAColors.danger,
                side: const BorderSide(color: Color(0xFFE47070)),
              ),
              child: const Text('Change status'),
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
      ),
      child: Stack(
        children: [
          if (a.photoBytes != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  a.photoBytes!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            const Positioned.fill(
              child: DecoratedBox(
                decoration:
                    BoxDecoration(gradient: ARAColors.softBackgroundGradient),
                child: Center(
                  child: Icon(Icons.pets, size: 80, color: ARAColors.brandDark),
                ),
              ),
            ),
          if (a.flags.isNotEmpty)
            Positioned(
              right: 12,
              bottom: 12,
              child: _FlagOverlay(flags: a.flags),
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
    final location = _buildLocationLabel(a);

    return Column(
      children: [
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
                label: 'Kennel / Zone',
                value: location,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildNotesSection(Animal a) {
    return Column(
      children: [
        _NoteCard(
          title: 'Handling Notes',
          body: _buildHandlingNotes(a),
        ),
      ],
    );
  }

  Widget _buildMoreInfo(BuildContext context, Animal a) {
    return Container(
      decoration: BoxDecoration(
        color: ARAColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ARAColors.surfaceWarmTint),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: const Text(
            'More information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ARAColors.ink,
            ),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down),
          children: [
            _InfoRow(
              icon: Icons.pets,
              label: 'Age',
              value: _formatAge(a.age),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: ARAColors.surfaceWarmTint),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.bubble_chart_outlined,
              label: 'Breed',
              value: _orNotSet(a.breed),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: ARAColors.surfaceWarmTint),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.wc,
              label: 'Gender',
              value: _orNotSet(a.gender),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: ARAColors.surfaceWarmTint),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.place_outlined,
              label: 'History',
              value: a.history.isNotEmpty ? a.history : 'No history yet.',
            ),
          ],
        ),
      ),
    );
  }

  String _orNotSet(String value) {
    if (value.trim().isEmpty) return 'Not set';
    return value.trim();
  }

  String _formatAge(String value) {
    if (value.trim().isEmpty) return 'Not set';
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) return value.trim();
    final now = DateTime.now();
    int years = now.year - parsed.year;
    if (now.month < parsed.month ||
        (now.month == parsed.month && now.day < parsed.day)) {
      years -= 1;
    }
    if (years < 1) return 'Under 1 year';
    return years == 1 ? '1 year' : '$years years';
  }

  String _buildHandlingNotes(Animal a) {
    if (a.description.trim().isNotEmpty) {
      return a.description.trim();
    }
    if (a.isDangerous || a.flags.isNotEmpty) {
      return 'Check the handling flags for this animal.';
    }
    return 'No handling notes yet.';
  }

  String _buildLocationLabel(Animal a) {
    final parts = <String>[];
    if (a.kennel.trim().isNotEmpty) {
      parts.add(_formatLocationPart(a.kennel.trim(), 'Kennel'));
    }
    if (a.zone.trim().isNotEmpty) {
      parts.add(_formatLocationPart(a.zone.trim(), 'Zone'));
    }
    if (parts.isEmpty) return 'Not set';
    return parts.join(' • ');
  }

  String _formatLocationPart(String value, String prefix) {
    final lowered = value.toLowerCase();
    if (lowered.startsWith(prefix.toLowerCase()) ||
        lowered.contains('cattery')) {
      return value;
    }
    return '$prefix $value';
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
          color:
              isWarning ? ARAColors.cautionBorder : ARAColors.surfaceWarmTint,
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ARAColors.subInk),
        const SizedBox(width: 10),
        Expanded(
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
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ARAColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlagOverlay extends StatelessWidget {
  final Set<HandlingFlag> flags;

  const _FlagOverlay({required this.flags});

  @override
  Widget build(BuildContext context) {
    return HandlingFlagChips(flags: flags);
  }
}
