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
              child: InfoSectionList(items: _safetyRules),
            ),
            ExpandableSectionItem(
              id: 'dog_handling_rules',
              title: 'Dog Handling Rules',
              child: InfoSectionList(items: _safetyDogHandlingRules),
            ),
            ExpandableSectionItem(
              id: 'conduct',
              title: 'Conduct',
              child: InfoSectionList(items: _safetyConduct),
            ),
            ExpandableSectionItem(
              id: 'incidents',
              title: 'Incident steps',
              child: InfoSectionList(
                items: _incidentSteps,
                style: InfoSectionListStyle.numbered,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
