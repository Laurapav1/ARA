part of '../information.dart';

class _SafetyTab extends StatelessWidget {
  const _SafetyTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        _EditableInfoSections(
          storageKey: 'info_safety',
          initialSections: [
            _EditableInfoSectionModel(
              id: 'rules',
              title: 'Rules',
              style: InfoSectionListStyle.bullet,
              items: _safetyRules,
            ),
            _EditableInfoSectionModel(
              id: 'dog_handling_rules',
              title: 'Dog Handling Rules',
              style: InfoSectionListStyle.bullet,
              items: _safetyDogHandlingRules,
            ),
            _EditableInfoSectionModel(
              id: 'conduct',
              title: 'Conduct',
              style: InfoSectionListStyle.bullet,
              items: _safetyConduct,
            ),
            _EditableInfoSectionModel(
              id: 'incidents',
              title: 'Incident steps',
              style: InfoSectionListStyle.numbered,
              items: _incidentSteps,
            ),
          ],
        ),
      ],
    );
  }
}
