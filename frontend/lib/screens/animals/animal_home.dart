// File: lib/screens/animals/animal_home.dart
import 'package:flutter/material.dart';
import '../../widgets/offline_banner.dart';
import 'dogs_screen.dart';
import 'cats_screen.dart';

class AnimalHomeScreen extends StatefulWidget {
  const AnimalHomeScreen({super.key});

  @override
  State<AnimalHomeScreen> createState() => _AnimalHomeScreenState();
}

class _AnimalHomeScreenState extends State<AnimalHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2D9596).withOpacity(0.05),
              const Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _animation,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D9596),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meet Our Animals',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF265073),
                                ),
                              ),
                              Text(
                                'Find your furry friend',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Spacer(),
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: const Interval(0.2, 0.8,
                                curve: Curves.elasticOut),
                          ),
                        ),
                        child: _AnimalCategoryCard(
                          title: 'Dogs',
                          description: 'Meet our canine companions',
                          count: '12 dogs',
                          icon: Icons.pets,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF42A5F5),
                              Color(0xFF1976D2),
                            ],
                          ),
                          image: '🐕',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DogsScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: const Interval(0.4, 1.0,
                                curve: Curves.elasticOut),
                          ),
                        ),
                        child: _AnimalCategoryCard(
                          title: 'Cats',
                          description: 'Explore our feline friends',
                          count: '8 cats',
                          icon: Icons.pets,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFEC407A),
                              Color(0xFFC2185B),
                            ],
                          ),
                          image: '🐈',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CatsScreen(),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalCategoryCard extends StatefulWidget {
  final String title;
  final String description;
  final String count;
  final IconData icon;
  final Gradient gradient;
  final String image;
  final VoidCallback onTap;

  const _AnimalCategoryCard({
    required this.title,
    required this.description,
    required this.count,
    required this.icon,
    required this.gradient,
    required this.image,
    required this.onTap,
  });

  @override
  State<_AnimalCategoryCard> createState() => _AnimalCategoryCardState();
}

class _AnimalCategoryCardState extends State<_AnimalCategoryCard> {
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
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -30,
                top: -30,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    widget.icon,
                    size: 180,
                    color: Colors.white,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.count,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      widget.image,
                      style: const TextStyle(fontSize: 80),
                    ),
                  ],
                ),
              ),
              // Arrow indicator
              Positioned(
                right: 20,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
