import 'package:flutter/material.dart';
import '../theme/ara_theme.dart';

class FormFieldCard extends StatelessWidget {
  const FormFieldCard({
    super.key,
    required this.focusNode,
    required this.child,
  });

  final FocusNode focusNode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final borderColor = focusNode.hasFocus
            ? ARAColors.brand
            : Theme.of(context).dividerColor;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Theme(
            data: Theme.of(context).copyWith(
              hoverColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
