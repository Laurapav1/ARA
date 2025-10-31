// File: lib/screens/animals/dogs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/offline_banner.dart';
import '../../services/mock_database.dart';
import '../../models/animal.dart';
import '../../models/handling_flag.dart';
import '../../widgets/handling_flag_chips.dart';
import 'animal_detail.dart';

class DogsScreen extends StatefulWidget {
  const DogsScreen({super.key});

  @override
  State<DogsScreen> createState() => _DogsScreenState();
}

class _DogsScreenState extends State<DogsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _requiresCaution(Animal a) => a.isDangerous || a.flags.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final animals = context.watch<MockDatabase>().animals;
    final dogs = animals.where((a) => a.species == 'dog').toList();
    final friendly = dogs.where((d) => !_requiresCaution(d)).toList();
    final careful = dogs.where((d) => _requiresCaution(d)).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF42A5F5).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
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
                      'Friendly & Social',
                      friendly,
                      Icons.favorite,
                      const Color(0xFF66BB6A),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      'Handle with Care',
                      careful,
                      Icons.warning_amber_rounded,
                      const Color(0xFFFFA726),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Dogs',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF265073),
                  ),
                ),
                Text(
                  'Tap to view profile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Animal> list,
    IconData icon,
    Color color,
  ) {
    if (list.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
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
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...list.asMap().entries.map((entry) {
            final index = entry.key;
            final dog = entry.value;
            final delay = index * 0.1;

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(delay, delay + 0.5, curve: Curves.easeOut),
                ),
              ),
              child: _DogCard(
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
              ),
            );
          }),
        ],
      ),
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.accentColor.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Hero(
                tag: 'dog_${widget.dog.id}',
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.pets,
                    color: widget.accentColor,
                    size: 36,
                  ),
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
                        color: Color(0xFF265073),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dog.personality,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    if (widget.dog.flags.isNotEmpty) ...[
                      const SizedBox(height: 8),
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
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
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
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: size,
            color: Colors.amber.shade700,
          ),
          const SizedBox(width: 4),
          for (final f in list.take(2))
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(f.icon, size: size, color: f.color),
            ),
          if (list.length > 2)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '+${list.length - 2}',
                style: TextStyle(
                  fontSize: size - 4,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
