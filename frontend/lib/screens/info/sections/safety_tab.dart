part of '../information.dart';

class _SafetyTab extends StatelessWidget {
  const _SafetyTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: const [
        ExpandableSectionGroup(
          initiallyExpandedId: '',
          sections: [
            ExpandableSectionItem(
              id: 'rules',
              title: 'Rules',
              child: _BulletList(items: _safetyRules),
            ),
            ExpandableSectionItem(
              id: 'incidents',
              title: 'Incident steps',
              child: _NumberedList(items: _incidentSteps),
            ),
          ],
        ),
      ],
    );
  }
}
