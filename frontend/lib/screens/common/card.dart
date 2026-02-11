import 'package:flutter/material.dart';
import '../../theme/ara_theme.dart';

class AraCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;
  final String? image;
  final VoidCallback onTap;

  const AraCard({
    //super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final img = image; // local copy enables sound flow analysis

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        height: 200,
        decoration: BoxDecoration(gradient: gradient),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(icon, size: 180, color: ARAColors.cardBg),
                ),
              ),
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
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: const TextStyle(
                              color: ARAColors.cardBg,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: TextStyle(
                              color: ARAColors.cardBg.withValues(alpha: 0.95),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (img != null && img.isNotEmpty) ...[
                      const SizedBox(width: 20),
                      Text(img, style: const TextStyle(fontSize: 80)),
                    ],
                  ],
                ),
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ARAColors.cardBg.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: ARAColors.cardBg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
