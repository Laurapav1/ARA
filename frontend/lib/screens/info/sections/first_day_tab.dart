part of '../information.dart';

class _FirstDayTab extends StatelessWidget {
  const _FirstDayTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: const [
        ExpandableSectionGroup(
          initiallyExpandedId: '',
          sections: [
            ExpandableSectionItem(
              id: 'induction_overview',
              title: 'Induction',
              child: InfoSectionList(items: _firstDayInductionOverview),
            ),
            ExpandableSectionItem(
              id: 'how_shifts_work',
              title: 'How Shifts Work',
              child: InfoSectionList(items: _firstDayHowShiftsWork),
            ),
            ExpandableSectionItem(
              id: 'living_at_ara',
              title: 'Living at ARA',
              child: InfoSectionList(items: _firstDayLivingAtAra),
            ),
          ],
        ),
      ],
    );
  }
}
