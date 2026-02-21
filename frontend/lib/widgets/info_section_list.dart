import 'package:flutter/material.dart';

import '../theme/ara_theme.dart';

enum InfoSectionListStyle {
  bullet,
  numbered,
}

class InfoSectionList extends StatelessWidget {
  final List<String> items;
  final InfoSectionListStyle style;
  final double leadingIndent;

  const InfoSectionList({
    super.key,
    required this.items,
    this.style = InfoSectionListStyle.bullet,
    this.leadingIndent = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leadingIndent),
      child: Column(
        children: List.generate(items.length, (index) {
          final marker = _marker(index);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                marker,
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _capitalizeFirstLetter(items[index]),
                    style: const TextStyle(color: ARAColors.ink),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (RegExp(r'[A-Za-z]').hasMatch(char)) {
        return '${text.substring(0, i)}${char.toUpperCase()}${text.substring(i + 1)}';
      }
    }
    return text;
  }

  Widget _marker(int index) {
    if (style == InfoSectionListStyle.numbered) {
      return Padding(
        padding: const EdgeInsets.only(top: 7),
        child: SizedBox(
          width: 8,
          height: 8,
          child: OverflowBox(
            minWidth: 14,
            maxWidth: 14,
            minHeight: 14,
            maxHeight: 14,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: ARAColors.brand,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.only(top: 7),
      child: SizedBox(
        width: 8,
        height: 8,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ARAColors.brand,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
