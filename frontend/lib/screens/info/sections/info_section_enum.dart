part of '../information.dart';

enum _InfoSection {
  overview(
    'Shelter Map',
    Icons.map_outlined,
    ARAColors.infoSectionOverviewBg,
    ARAColors.infoSectionOverviewIcon,
  ),
  cleaning(
    'Cleaning',
    Icons.cleaning_services_outlined,
    ARAColors.infoSectionCleaningBg,
    ARAColors.infoSectionCleaningIcon,
  ),
  safety(
    'Safety Rules',
    Icons.shield_outlined,
    ARAColors.infoSectionSafetyBg,
    ARAColors.infoSectionSafetyIcon,
  ),
  checklist(
    'Checklist',
    Icons.checklist_outlined,
    ARAColors.infoSectionChecklistBg,
    ARAColors.infoSectionChecklistIcon,
  );

  const _InfoSection(
    this.label,
    this.icon,
    this.iconTint,
    this.iconColor,
  );

  final String label;
  final IconData icon;
  final Color iconTint;
  final Color iconColor;
}
