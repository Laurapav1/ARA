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
                    items[index],
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

  Widget _marker(int index) {
    if (style == InfoSectionListStyle.numbered) {
      return Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ARAColors.brand.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ARAColors.inkStrong,
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
