part of '../information.dart';

class _BeforeYouArriveTab extends StatelessWidget {
  const _BeforeYouArriveTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: const [
        ExpandableSectionGroup(
          initiallyExpandedId: '',
          sections: [
            ExpandableSectionItem(
              id: 'arrival_check_in',
              title: 'Arrival & Check-In',
              child: InfoSectionList(items: _beforeYouArriveArrivalCheckIn),
            ),
            ExpandableSectionItem(
              id: 'how_to_get_here',
              title: 'How to Get Here',
              child: InfoSectionList(items: _beforeYouArriveHowToGetHere),
            ),
            ExpandableSectionItem(
              id: 'what_to_bring',
              title: 'What to Bring',
              child: InfoSectionList(items: _beforeYouArriveWhatToBring),
            ),
            ExpandableSectionItem(
              id: 'summer_preparation',
              title: 'Summer Preparation',
              child: InfoSectionList(items: _beforeYouArriveSummerPreparation),
            ),
            ExpandableSectionItem(
              id: 'winter_preparation',
              title: 'Winter Preparation',
              child: InfoSectionList(items: _beforeYouArriveWinterPreparation),
            ),
            ExpandableSectionItem(
              id: 'important_information',
              title: 'Important Information',
              child: InfoSectionList(items: _beforeYouArriveImportantInfo),
            ),
            ExpandableSectionItem(
              id: 'climate_preparation',
              title: 'Climate & Preparation',
              child: InfoSectionList(items: _beforeYouArriveClimatePrep),
            ),
          ],
        ),
      ],
    );
  }
}
