import 'package:flutter/material.dart';
import '../../theme/ara_theme.dart';

class PageBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PageBackAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: ARAColors.transparent,
    );
  }
}
