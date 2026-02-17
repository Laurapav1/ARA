import 'package:flutter/material.dart';
import '../theme/ara_theme.dart';

class InfoTileCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? leading;
  final IconData? backgroundIcon;
  final Color? backgroundIconColor;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color? textColor;
  final bool showArrow;
  final double backgroundIconOpacity;
  final double backgroundIconSize;
  final double backgroundIconRight;
  final double backgroundIconTop;
  final double backgroundIconAngle;
  final bool pinTitleToBottom;
  final double titleTopGap;

  const InfoTileCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.leading,
    this.backgroundIcon,
    this.backgroundIconColor,
    this.backgroundColor,
    this.backgroundGradient,
    this.textColor,
    this.showArrow = false,
    this.backgroundIconOpacity = 0.18,
    this.backgroundIconSize = 152,
    this.backgroundIconRight = -46,
    this.backgroundIconTop = -42,
    this.backgroundIconAngle = 0.0,
    this.pinTitleToBottom = false,
    this.titleTopGap = 6,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.replaceFirst(' (', '\n(');
    final resolvedTextColor = textColor ??
        (backgroundGradient != null ? ARAColors.cardBg : ARAColors.inkStrong);

    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: backgroundColor ?? ARAColors.cardBg,
          gradient: backgroundGradient,
          borderRadius: BorderRadius.circular(16),
          border: backgroundGradient == null
              ? Border.all(
                  color: const Color(0xFFE6E1D8),
                  width: 1,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: backgroundGradient == null ? 0.07 : 0.12,
              ),
              blurRadius: backgroundGradient == null ? 12 : 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              if (backgroundIcon != null)
                Positioned(
                  right: backgroundIconRight,
                  top: backgroundIconTop,
                  child: Opacity(
                    opacity: backgroundIconOpacity,
                    child: Transform.rotate(
                      angle: backgroundIconAngle,
                      child: Icon(
                        backgroundIcon,
                        size: backgroundIconSize,
                        color: backgroundIconColor ??
                            (backgroundGradient != null
                                ? ARAColors.cardBg
                                : ARAColors.brand),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
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
                      style: TextStyle(
                        color: resolvedTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.1,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: resolvedTextColor.withValues(alpha: 0.94),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showArrow)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: ARAColors.cardBg.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: ARAColors.cardBg,
                      size: 18,
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
