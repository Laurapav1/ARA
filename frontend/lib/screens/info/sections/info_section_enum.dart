part of '../information.dart';

enum _InfoSection {
  shelterMap(
    'Shelter Map',
    'Find zones and key areas',
    Icons.map_outlined,
    ARAColors.infoSectionOverviewBg,
    ARAColors.infoSectionOverviewIcon,
  ),
  cleaning(
    'Cleaning',
    'Kennels, catteries, parks, and housing',
    Icons.cleaning_services_outlined,
    ARAColors.infoSectionCleaningBg,
    ARAColors.infoSectionCleaningIcon,
  ),
  safety(
    'Safety',
    'Safety rules and incident response',
    Icons.shield_outlined,
    ARAColors.infoSectionSafetyBg,
    ARAColors.infoSectionSafetyIcon,
  ),
  beforeYouArrive(
    'Before You Arrive',
    'Travel, packing, and arrival prep',
    Icons.flight_land_outlined,
    ARAColors.infoSectionChecklistBg,
    ARAColors.infoSectionChecklistIcon,
  ),
  firstDay(
    'First Day',
    'Orientation and first-shift essentials',
    Icons.star_outline,
    ARAColors.infoSectionChecklistBg,
    ARAColors.infoSectionChecklistIcon,
  ),
  livingInfo(
    'Living Info',
    'Accommodation and facilities',
    Icons.home_outlined,
    ARAColors.infoSectionOverviewBg,
    ARAColors.infoSectionOverviewIcon,
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
