import 'package:flutter/material.dart';

import '../theme/ara_theme.dart';

class StaffActionSheetItem {
  final String label;
  final IconData icon;
  final Color? color;
  final Future<void> Function() onTap;

  const StaffActionSheetItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });
}

Future<void> showStaffActionSheet(
  BuildContext context, {
  required List<StaffActionSheetItem> items,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return ListTile(
            leading: Icon(item.icon, color: item.color),
            title: Text(
              item.label,
              style: TextStyle(color: item.color ?? ARAColors.inkStrong),
            ),
            onTap: () async {
              Navigator.pop(sheetContext);
              await item.onTap();
            },
          );
        }).toList(),
      ),
    ),
  );
}
