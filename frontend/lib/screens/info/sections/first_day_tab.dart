part of '../information.dart';

class _FirstDayTab extends StatelessWidget {
  final _EditableInfoSectionsController? editorController;

  const _FirstDayTab({this.editorController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        _EditableInfoSections(
          controller: editorController,
          storageKey: 'info_first_day',
          initialSections: [
            _EditableInfoSectionModel(
              id: 'induction_overview',
              title: 'Induction',
              style: InfoSectionListStyle.bullet,
              items: _firstDayInductionOverview,
            ),
            _EditableInfoSectionModel(
              id: 'how_shifts_work',
              title: 'How Shifts Work',
              style: InfoSectionListStyle.bullet,
              items: _firstDayHowShiftsWork,
            ),
            _EditableInfoSectionModel(
              id: 'living_at_ara',
              title: 'Living at ARA',
              style: InfoSectionListStyle.bullet,
              items: _firstDayLivingAtAra,
            ),
          ],
        ),
      ],
    );
  }
}
