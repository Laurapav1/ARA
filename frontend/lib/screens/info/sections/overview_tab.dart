part of '../information.dart';

class _OverviewTab extends StatefulWidget {
  const _OverviewTab();

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  String _selectedArea = 'Reception';

  @override
  Widget build(BuildContext context) {
    final content = _zoneContent();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        _SectionCard(
          title: 'Shelter map',
          child: _OverviewMapContent(
            zones: content.zones,
            selectedArea: _selectedArea,
            onAreaSelected: (area) => setState(() => _selectedArea = area),
            areaSummary: _areaSummary,
          ),
        ),
        const SizedBox(height: 12),
        _EditableInfoSections(
          storageKey: 'info_overview_zone_basics',
          initialSections: [
            _EditableInfoSectionModel(
              id: 'zone_basics',
              title: 'Zone basics',
              style: InfoSectionListStyle.bullet,
              items: _overviewStructureBullets,
            ),
          ],
        ),
      ],
    );
  }

  String _areaSummary(String area) {
    switch (area) {
      case 'Reception':
        return 'Reception is the check-in point for task board updates, keys and quick staff questions.';
      case 'Zone A':
        return 'Zone A is a dog area with regular feeding, water checks and cleaning rounds.';
      case 'Staff House':
        return 'Staff House is a staff-only operational base area.';
      case 'Paradise park':
        return 'Paradise park is an outdoor park area used for supervised dog time.';
      case '66 starts':
        return '66 starts area details can be added here.';
      case 'Zone B':
        return 'Zone B focuses on dog care tasks and cleaning cycles based on board priorities.';
      case 'Zone C':
        return 'Zone C runs similar dog routines with task handover notes at shift end.';
      case 'Volunteer house':
        return 'Volunteer house is the volunteer accommodation and break area.';
      case 'Adult catteries':
        return 'Adult catteries are cat-only areas for adult cats with calm handling and cleaning routines.';
      case 'Pool side cattries':
        return 'Pool side cattries are cat spaces near the pool-side section with standard cattery care routines.';
      default:
        return 'Select a zone to see a quick description.';
    }
  }
}
