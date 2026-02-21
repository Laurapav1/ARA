import 'package:flutter/material.dart';

import '../theme/ara_theme.dart';
//
class SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Search by name',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
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
}
