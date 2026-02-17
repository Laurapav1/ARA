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
        const ExpandableSectionGroup(
          initiallyExpandedId: 'first_day',
          sections: [
            ExpandableSectionItem(
              id: 'first_day',
              title: 'If this is your first day, start here',
              child: _PlainBulletList(items: _overviewStructureBullets),
            ),
            ExpandableSectionItem(
              id: 'who_is_who',
              title: 'Who\'s who',
              child: _PlainBulletList(items: _overviewWhoIsWhoBullets),
            ),
            ExpandableSectionItem(
              id: 'morning_flow',
              title: 'Morning shift flow',
              child: _NumberedList(items: _overviewMorningFlow),
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
      case 'Zone B':
        return 'Zone B focuses on dog care tasks and cleaning cycles based on board priorities.';
      case 'Zone C':
        return 'Zone C runs similar dog routines with task handover notes at shift end.';
      case 'Catteries':
        return 'Catteries are cat-only spaces with litter, food, water and calm handling routines.';
      case 'Park North':
      case 'Park South':
        return 'Parks are for outdoor dog time and supervision between indoor care blocks.';
      case 'Volunteer accommodation':
        return 'Volunteer accommodation is your base for breaks and cleaning duties assigned in shift tasks.';
      default:
        return 'Select a zone to see a quick description.';
    }
  }
}
