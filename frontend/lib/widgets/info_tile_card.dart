import 'package:flutter/material.dart';
import '../theme/ara_theme.dart';

class InfoTileCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget? leading;
  final bool pinTitleToBottom;
  final double titleTopGap;

  const InfoTileCard({
    super.key,
    required this.title,
    required this.onTap,
    this.leading,
    this.pinTitleToBottom = false,
    this.titleTopGap = 6,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.replaceFirst(' (', '\n(');

    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: ARAColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE6E1D8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) leading!,
                if (leading != null) SizedBox(height: titleTopGap),
                if (pinTitleToBottom) const Spacer(),
                Text(
                  displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ARAColors.inkStrong,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
