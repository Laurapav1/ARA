part of '../information.dart';

class _CleaningTab extends StatefulWidget {
  const _CleaningTab();

  @override
  State<_CleaningTab> createState() => _CleaningTabState();
}

class _CleaningTabState extends State<_CleaningTab> {
  String _expandedId = '';

  @override
  Widget build(BuildContext context) {
    final content = _zoneContent();
    final panels = <_CleaningPanelData>[
      _CleaningPanelData(
        id: 'kennels',
        title: 'Cleaning Kennels',
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
        title: 'Cleaning Bowls A, B, C',
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
        title: 'Cleaning Bowls Catteries',
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
        title: 'Cleaning Bowls Parks',
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
        doItems: content.trashTasks,
        doNotItems: const [
          'Do not leave full bags in working areas.',
          'Do not leave bins without liners.',
        ],
        doneWhenItems: const [
          'Full bags are removed.',
          'Fresh liners are placed.',
        ],
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        const _SectionCard(
          title: 'Cleaning Standard (must be done)',
          child: _CleaningStandardBlock(),
        ),
        const SizedBox(height: 12),
        ...panels.map((panel) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SectionCard(
                title: '',
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: _expandedId == panel.id,
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: ARAColors.successDark,
                    ),
                    title: Text(
                      panel.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ARAColors.inkStrong,
                      ),
                    ),
                    onExpansionChanged: (open) {
                      setState(() {
                        if (open) {
                          _expandedId = panel.id;
                        } else if (_expandedId == panel.id) {
                          _expandedId = '';
                        }
                      });
                    },
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(
                          height: 1,
                          color: ARAColors.surfaceWarmTint,
                        ),
                      ),
                      _CleaningPanelBody(
                        doItems: panel.doItems,
                        doNotItems: panel.doNotItems,
                        doneWhenItems: panel.doneWhenItems,
                      ),
                    ],
                  ),
                ),
              ),
            )),
        const SizedBox(height: 2),
        _SectionCard(
          title: 'General reminders',
          child: _BulletList(items: content.doNotForget),
        ),
      ],
    );
  }
}
