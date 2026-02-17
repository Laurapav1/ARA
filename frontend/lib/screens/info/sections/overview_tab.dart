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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: ARAColors.countdownSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ARAColors.infoBorder),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.flag_circle_outlined,
                size: 18,
                color: ARAColors.countdownText,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'New volunteer? Start here.',
                  style: TextStyle(
                    color: ARAColors.countdownText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Shelter map',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tap a zone to see a short description.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _ShelterMapPanel(
                selectedArea: _selectedArea,
                onAreaSelected: (area) => setState(() => _selectedArea = area),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: content.zones.map((zone) {
                    final selected = zone == _selectedArea;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _selectedArea = zone),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selected
                              ? ARAColors.brand.withValues(alpha: 0.20)
                              : ARAColors.cardBg,
                          side: BorderSide(
                            color: selected
                                ? ARAColors.brandDark
                                : ARAColors.surfaceWarmTint,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          minimumSize: const Size(0, 38),
                        ),
                        child: Text(
                          zone,
                          style: TextStyle(
                            color:
                                selected ? ARAColors.inkStrong : ARAColors.subInk,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ARAColors.surfaceWarmSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ARAColors.surfaceWarmTint),
                ),
                child: Text(
                  _areaSummary(_selectedArea),
                  style: const TextStyle(color: ARAColors.ink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _SectionCard(
          title: 'If this is your first day, start here',
          child: _PlainBulletList(items: _overviewStructureBullets),
        ),
        const SizedBox(height: 12),
        const _SectionCard(
          title: 'Who\'s who',
          child: _PlainBulletList(items: _overviewWhoIsWhoBullets),
        ),
        const SizedBox(height: 12),
        const _SectionCard(
          title: 'Morning shift flow',
          child: _NumberedList(items: _overviewMorningFlow),
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
