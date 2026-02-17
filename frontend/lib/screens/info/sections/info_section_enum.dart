part of '../information.dart';

enum _InfoSection {
  overview(
    'Shelter Map',
    'Find zones and key areas',
    Icons.map_outlined,
    ARAColors.infoSectionOverviewBg,
    ARAColors.infoSectionOverviewIcon,
  ),
  cleaning(
    'Cleaning',
    'Routines for kennels and catteries',
    Icons.cleaning_services_outlined,
    ARAColors.infoSectionCleaningBg,
    ARAColors.infoSectionCleaningIcon,
  ),
  safety(
    'Safety Rules',
    'Daily safety and incidents',
    Icons.shield_outlined,
    ARAColors.infoSectionSafetyBg,
    ARAColors.infoSectionSafetyIcon,
  ),
  checklist(
    'Checklist',
    'Start and end-of-shift tasks',
    Icons.checklist_outlined,
    ARAColors.infoSectionChecklistBg,
    ARAColors.infoSectionChecklistIcon,
  );

  const _InfoSection(
    this.label,
    this.subtitle,
    this.icon,
    this.iconTint,
    this.iconColor,
  );

  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconTint;
  final Color iconColor;
}
