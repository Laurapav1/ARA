import 'package:flutter/material.dart';

import '../theme/ara_theme.dart';

class ExpandableSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool? isExpanded;
  final ValueChanged<bool>? onChanged;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry contentPadding;
  final TextStyle? titleStyle;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.child,
    this.isExpanded,
    this.onChanged,
    this.initiallyExpanded = false,
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.contentPadding = const EdgeInsets.fromLTRB(14, 0, 14, 14),
    this.titleStyle,
    this.backgroundColor = ARAColors.cardBg,
    this.borderColor = ARAColors.surfaceWarmTint,
    this.borderRadius = 16,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  late bool _internalExpanded;

  @override
  void initState() {
    super.initState();
    _internalExpanded = widget.initiallyExpanded;
  }

  bool get _expanded => widget.isExpanded ?? _internalExpanded;

  void _setExpanded(bool value) {
    if (widget.isExpanded == null) {
      setState(() => _internalExpanded = value);
    }
    widget.onChanged?.call(value);
  }

  void _toggle() => _setExpanded(!_expanded);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Padding(
              padding: widget.headerPadding,
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.chevron_right,
                      color: ARAColors.inkStrong,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: widget.titleStyle ??
                          const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: ARAColors.inkStrong,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: widget.contentPadding,
              child: widget.child,
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}
