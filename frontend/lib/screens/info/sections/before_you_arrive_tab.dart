part of '../information.dart';

class _BeforeYouArriveTab extends StatelessWidget {
  final _EditableInfoSectionsController? editorController;

  const _BeforeYouArriveTab({this.editorController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        _EditableInfoSections(
          controller: editorController,
          storageKey: 'info_before_you_arrive',
          initialSections: [
            _EditableInfoSectionModel(
              id: 'arrival_check_in',
              title: 'Arrival & Check-In',
              style: InfoSectionListStyle.bullet,
              items: _beforeYouArriveArrivalCheckIn,
            ),
            _EditableInfoSectionModel(
              id: 'how_to_get_here',
              title: 'How to Get Here',
              style: InfoSectionListStyle.bullet,
              items: _beforeYouArriveHowToGetHere,
            ),
            _EditableInfoSectionModel(
              id: 'what_to_bring',
              title: 'What to Bring',
              style: InfoSectionListStyle.bullet,
              items: _beforeYouArriveWhatToBring,
            ),
            _EditableInfoSectionModel(
              id: 'summer_preparation',
              title: 'Summer Preparation',
              style: InfoSectionListStyle.bullet,
              items: _beforeYouArriveSummerPreparation,
            ),
            _EditableInfoSectionModel(
              id: 'winter_preparation',
              title: 'Winter Preparation',
              style: InfoSectionListStyle.bullet,
              items: _beforeYouArriveWinterPreparation,
            ),
            _EditableInfoSectionModel(
              id: 'important_information',
              title: 'Important Information',
              style: InfoSectionListStyle.bullet,
              items: _beforeYouArriveImportantInfo,
            ),
            _EditableInfoSectionModel(
              id: 'climate_preparation',
              title: 'Climate & Preparation',
              style: InfoSectionListStyle.bullet,
              items: _beforeYouArriveClimatePrep,
            ),
          ],
        ),
      ],
    );
  }
}
