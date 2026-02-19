import 'package:flutter/material.dart';

class HeroCircle extends StatelessWidget {
  final Widget child;
  final double size;
  final Color backgroundColor;

  const HeroCircle({
    super.key,
    required this.child,
    this.size = 158,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
