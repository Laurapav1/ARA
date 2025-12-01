// File: lib/screens/animals/dogs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/offline_banner.dart';
import '../../services/mock_database.dart';
import '../../models/animal.dart';
import '../../models/handling_flag.dart';
import '../../widgets/handling_flag_chips.dart';
import '../../theme/ara_theme.dart';
import 'animal_detail.dart';

class DogsScreen extends StatelessWidget {
  const DogsScreen({super.key});

  static const Color _friendlyColor = Color(0xFF43A047); // medium green
  static const Color _carefulColor = Color(0xFFFB8C00); // strong amber

  bool _requiresCaution(Animal a) => a.isDangerous || a.flags.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final animals = context.watch<MockDatabase>().animals;
    final dogs = animals.where((a) => a.species == 'dog').toList();
    final friendly = dogs.where((d) => !_requiresCaution(d)).toList();
    final careful = dogs.where((d) => _requiresCaution(d)).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection(
                    context,
                    title: 'Friendly & Social',
                    list: friendly,
                    icon: Icons.favorite,
                    color: _friendlyColor,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Handle with Care',
                    list: careful,
                    icon: Icons.warning_amber_rounded,
                    color: _carefulColor,
                  ),
                ],
              ),
            ),
          ],
        ),
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
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF42A5F5).withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFF42A5F5).withOpacity(.30)),
            ),
            child: const Icon(Icons.pets, color: Color(0xFF1976D2), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Dogs',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ARAColors.ink,
                  ),
                ),
                Text(
                  'Tap to view profile',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Animal> list,
    required IconData icon,
    required Color color,
  }) {
    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section pill (static)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color.withOpacity(0.95),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Cards (static)
        ...list.map((dog) => _DogCard(
              dog: dog,
              accentColor: color,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnimalDetailScreen(animal: dog),
                ),
              ),
              onFlagsPressed: dog.flags.isEmpty
                  ? null
                  : () => _showFlagsQuick(context, dog),
            )),
      ],
    );
  }

  void _showFlagsQuick(BuildContext context, Animal dog) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Handling • ${dog.name}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ARAColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              HandlingFlagChips(flags: dog.flags),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnimalDetailScreen(animal: dog),
                        ),
                      );
                    },
                    child: const Text('View Profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DogCard extends StatefulWidget {
  final Animal dog;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback? onFlagsPressed;

  const _DogCard({
    required this.dog,
    required this.accentColor,
    required this.onTap,
    this.onFlagsPressed,
  });

  @override
  State<_DogCard> createState() => _DogCardState();
}

class _DogCardState extends State<_DogCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.accentColor.withOpacity(0.30);
    final shadowColor = widget.accentColor.withOpacity(0.10);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Keep Hero? It’s static unless you also use a Hero on detail.
              Hero(
                tag: 'dog_${widget.dog.id}',
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.pets, color: widget.accentColor, size: 36),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dog.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ARAColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dog.personality,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    if (widget.dog.flags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: widget.onFlagsPressed,
                        child: HandlingFlagIcons(
                          flags: widget.dog.flags,
                          size: 18,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.grey.shade400, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class HandlingFlagIcons extends StatelessWidget {
  final Set<HandlingFlag> flags;
  final double size;

  const HandlingFlagIcons({
    super.key,
    required this.flags,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final list = flags.toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE69C)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 16, color: Color(0xFFB26A00)),
          const SizedBox(width: 4),
          for (final f in list.take(2))
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(f.icon, size: size, color: f.color),
            ),
          if (list.length > 2) const SizedBox(width: 4),
          if (list.length > 2) const _CountPill(countColor: Color(0xFFB26A00)),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final Color countColor;
  const _CountPill({required this.countColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      '+',
      style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: countColor),
    );
  }
}
