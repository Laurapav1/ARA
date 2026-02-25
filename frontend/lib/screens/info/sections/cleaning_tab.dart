part of '../information.dart';

class _CleaningTab extends StatelessWidget {
  const _CleaningTab();

  @override
  Widget build(BuildContext context) {
    final panels = _cleaningPanels();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.28,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: panels.asMap().entries.map((entry) {
                final index = entry.key;
                final panel = entry.value;
                final isTopRow = index < 2;
                return InfoTileCard(
                  title: panel.title,
                  subtitle: 'Open guide',
                  backgroundColor: ARAColors.cardBg,
                  textColor: ARAColors.inkStrong,
                  backgroundEmoji: panel.emoji,
                  backgroundIcon: panel.icon,
                  backgroundIconColor: panel.iconColor,
                  backgroundIconSize: panel.emoji != null
                      ? (isTopRow ? 96 : 92)
                      : (isTopRow ? 104 : 98),
                  backgroundIconOpacity: panel.emoji != null ? 0.08 : 0.12,
                  backgroundIconRight: isTopRow ? -2 : 2,
                  backgroundIconTop: isTopRow ? -4 : 8,
                  backgroundIconAngle: isTopRow ? 0.05 : -0.04,
                  pinTitleToBottom: true,
                  onTap: () => _openCleaningPanel(context, panel),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _openCleaningPanel(BuildContext context, _CleaningPanelData panel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CleaningPanelScreen(panel: panel),
      ),
    );
  }
}

class _CleaningPanelScreen extends StatelessWidget {
  final _CleaningPanelData panel;

  const _CleaningPanelScreen({required this.panel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ARAColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 8),
              child: _BackTitleHeader(
                title: panel.title,
                onBack: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  _CleaningPanelBody(
                    doItems: panel.doItems,
                    doNotItems: panel.doNotItems,
                    doneWhenItems: panel.doneWhenItems,
                    doTitle: panel.doTitle,
                    doNotTitle: panel.doNotTitle,
                    doneWhenTitle: panel.doneWhenTitle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<_CleaningPanelData> _cleaningPanels() {
  final content = _zoneContent();
  return <_CleaningPanelData>[
    _CleaningPanelData(
      id: 'kennels',
      title: 'Cleaning Kennels',
      icon: Icons.pets,
      emoji: '🐶',
      iconBgColor: ARAColors.infoSectionCleaningBg,
      iconColor: ARAColors.infoSectionCleaningIcon,
      doItems: content.kennelCleaning,
      doNotItems: content.kennelDoNotForget,
      doneWhenItems: const [
        'No poo remains on floor/walls.',
        'Fresh water is filled to the top.',
        'Kennel is closed when finished.',
      ],
    ),
    _CleaningPanelData(
      id: 'catteries',
      title: 'Cleaning Catteries',
      icon: Icons.pets_outlined,
      emoji: '🐱',
      iconBgColor: const Color(0xFFEAE4F3),
      iconColor: const Color(0xFF9A7BC2),
      doItems: content.catteryCleaning,
      doNotItems: content.catteryDoNotForget,
      doneWhenItems: const [
        'Litter boxes are clean with fresh sand.',
        'Floors are brushed and mopped.',
        'Fresh water is refilled.',
      ],
    ),
    _CleaningPanelData(
      id: 'bowls_abc',
      title: 'Cleaning Bowls (Zones)',
      icon: Icons.adjust_outlined,
      iconBgColor: ARAColors.infoSectionChecklistBg,
      iconColor: ARAColors.infoSectionChecklistIcon,
      doItems: content.bowlCleaningZones,
      doNotItems: const [
        'Do not leave limestone on bowls.',
        'Do not mix food/water bowl setup between kennels.',
      ],
      doneWhenItems: const [
        'Bowls are scrubbed and rinsed.',
        'Right bowls are back in each kennel.',
        'Water bowls are filled to the top.',
      ],
    ),
    _CleaningPanelData(
      id: 'bowls_cattery',
      title: 'Cleaning Bowls (Catteries)',
      icon: Icons.adjust_outlined,
      iconBgColor: ARAColors.infoSectionChecklistBg,
      iconColor: ARAColors.infoSectionChecklistIcon,
      doItems: content.bowlCleaningCatteries,
      doNotItems: const [
        'Do not skip deep scrubbing.',
      ],
      doneWhenItems: const [
        'Bowls are cleaned and food is returned correctly.',
        'Fresh water is refilled.',
      ],
    ),
    _CleaningPanelData(
      id: 'bowls_parks',
      title: 'Cleaning Bowls (Parks)',
      icon: Icons.wb_sunny_outlined,
      iconBgColor: ARAColors.infoSectionCleaningBg,
      iconColor: ARAColors.infoSectionCleaningIcon,
      doItems: content.bowlCleaningParks,
      doNotItems: const [
        'Do not return the wrong number of bowls/buckets.',
      ],
      doneWhenItems: const [
        'Same bowls/buckets are returned to each park.',
        'All water is filled to the top.',
      ],
    ),
    _CleaningPanelData(
      id: 'accommodation',
      title: 'Cleaning Accommodation',
      icon: Icons.home_outlined,
      iconBgColor: ARAColors.infoSectionCleaningBg,
      iconColor: ARAColors.infoSectionCleaningIcon,
      doItems: content.accommodationCleaning,
      doNotItems: const [
        'Do not postpone this outside shift time.',
        'Do not leave kitchen or bathroom half-cleaned.',
      ],
      doneWhenItems: const [
        'Kitchen, bathroom and floors are fully cleaned.',
        'Area is hygienic and organized before leaving.',
      ],
    ),
    _CleaningPanelData(
      id: 'trash',
      title: 'Trash',
      icon: Icons.delete_outline,
      iconBgColor: ARAColors.infoSectionSafetyBg,
      iconColor: ARAColors.infoSectionSafetyIcon,
      doItems: content.trashTasks,
      doTitle: 'How to do it',
      doNotTitle: 'Do not forget',
      doneWhenTitle: 'Done when',
      doNotItems: const [
        'Do not change the bag if it is almost empty.',
      ],
      doneWhenItems: const [
        'Full bags are removed and new bags are in place.',
        'Trash is left at the correct drop points.',
      ],
    ),
    _CleaningPanelData(
      id: 'extra',
      title: 'Extra Tasks',
      icon: Icons.star_outline,
      iconBgColor: ARAColors.infoSectionCleaningBg,
      iconColor: ARAColors.infoSectionCleaningIcon,
      doItems: content.extraTasks,
      doNotItems: const [
        'Do not prioritize extras over core cleaning and feeding.',
      ],
      doneWhenItems: const [
        'Extra tasks are done safely and communicated to staff.',
      ],
    ),
  ];
}
