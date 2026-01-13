import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/offline_banner.dart';
import '../../services/mock_database.dart';
import '../../models/animal.dart';
import '../../models/handling_flag.dart';
import '../../theme/ara_theme.dart';
import 'animal_detail.dart';

class CatsScreen extends StatefulWidget {
  const CatsScreen({super.key});

  @override
  State<CatsScreen> createState() => _CatsScreenState();
}

class _CatsScreenState extends State<CatsScreen> {
  static const Color _accentColor = Color(0xFFC2185B);
  static const Color _accentSoft = Color(0xFFF3D6E0);

  String _query = '';

  bool _needsCaution(Animal a) => a.isDangerous || a.flags.isNotEmpty;

  List<Animal> _filterByName(List<Animal> list) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list.where((a) => a.name.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final animals = context.watch<MockDatabase>().animals;
    final cats = animals.where((a) => a.species == 'cat').toList();
    final filtered = _filterByName(cats);
    final friendly = filtered.where((a) => !_needsCaution(a)).toList();
    final careful = filtered.where(_needsCaution).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _buildSearchField(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (filtered.isEmpty) _buildEmptyState(),
                  ...friendly.map((cat) => _AnimalListCard(
                        animal: cat,
                        accentColor: _accentColor,
                        accentSoft: _accentSoft,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnimalDetailScreen(animal: cat),
                          ),
                        ),
                      )),
                  if (careful.isNotEmpty) ...[
                    if (friendly.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      const _SectionDivider(),
                      const SizedBox(height: 6),
                    ],
                    const _GroupLabel(text: 'Care required'),
                    ...careful.map((cat) => _AnimalListCard(
                          animal: cat,
                          accentColor: _accentColor,
                          accentSoft: _accentSoft,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnimalDetailScreen(animal: cat),
                            ),
                          ),
                        )),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: 'Search by name',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: ARAColors.cardBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ARAColors.surfaceWarmTint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ARAColors.brand, width: 2),
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
      child: const Row(
        children: [
          Icon(Icons.search_off, color: ARAColors.subInk),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No cats match that name.',
              style: TextStyle(color: ARAColors.subInk),
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
                  'Cats',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to view profile',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: ARAColors.surfaceWarmTint,
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;

  const _GroupLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: ARAColors.subInk,
        ),
      ),
    );
  }
}

class _AnimalListCard extends StatelessWidget {
  final Animal animal;
  final Color accentColor;
  final Color accentSoft;
  final VoidCallback onTap;

  const _AnimalListCard({
    required this.animal,
    required this.accentColor,
    required this.accentSoft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double tagRowHeight = 26;
    const double cardMinHeight = 80;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: ARAColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ARAColors.surfaceWarmTint),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: cardMinHeight),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: accentSoft.withValues(alpha: 0.6),
                child: Icon(Icons.pets, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      animal.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ARAColors.ink,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: tagRowHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: animal.flags.isEmpty
                            ? const SizedBox()
                            : _FlagRow(flags: animal.flags),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: ARAColors.subInk),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlagRow extends StatelessWidget {
  final Set<HandlingFlag> flags;

  const _FlagRow({required this.flags});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: flags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final flag = flags.elementAt(index);
          return _FlagPill(flag: flag);
        },
      ),
    );
  }
}

class _FlagPill extends StatelessWidget {
  final HandlingFlag flag;

  const _FlagPill({required this.flag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: flag.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: flag.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(flag.icon, size: 14, color: flag.color),
          const SizedBox(width: 4),
          Text(
            flag.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ARAColors.inkStrong,
            ),
          ),
        ],
      ),
    );
  }
}
