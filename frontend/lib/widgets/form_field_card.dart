import 'package:flutter/material.dart';
class FormFieldCard extends StatelessWidget {
  const FormFieldCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: child,
    );
  }
}
