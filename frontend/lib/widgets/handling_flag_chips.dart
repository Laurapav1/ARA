import 'package:flutter/material.dart';
import '../models/handling_flag.dart';

class HandlingFlagChips extends StatelessWidget {
  final Set<HandlingFlag> flags;
  const HandlingFlagChips({super.key, required this.flags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: -8,
      children: flags.map((f) {
        return Chip(
          visualDensity: VisualDensity.compact,
          label: Text(f.label),
          avatar: Icon(f.icon, size: 16, color: f.color),
          side: BorderSide(color: f.color.withValues(alpha: 0.5)),
          labelStyle: const TextStyle(fontSize: 12),
          backgroundColor: f.color.withValues(alpha: 0.08),
        );
      }).toList(),
    );
  }
}
