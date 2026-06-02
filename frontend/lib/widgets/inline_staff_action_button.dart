import 'package:flutter/material.dart';

class InlineStaffActionButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;
  final Color iconColor;
  final Color backgroundColor;

  const InlineStaffActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    required this.iconColor,
    this.backgroundColor = const Color(0x2EFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
      ),
      icon: Icon(
        icon,
        color: iconColor,
      ),
    );
  }
}
