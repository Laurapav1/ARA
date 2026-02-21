part of '../information.dart';

class _LivingInfoTab extends StatelessWidget {
  const _LivingInfoTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: const [
        ExpandableSectionGroup(
          initiallyExpandedId: '',
          sections: [
            ExpandableSectionItem(
              id: 'accommodation',
              title: 'Accommodation',
              child: InfoSectionList(items: _livingInfoAccommodation),
            ),
            ExpandableSectionItem(
              id: 'facilities',
              title: 'Facilities',
              child: InfoSectionList(items: _livingInfoFacilities),
            ),
            ExpandableSectionItem(
              id: 'local_area',
              title: 'Local Area',
              child: InfoSectionList(items: _livingInfoLocalArea),
            ),
          ],
        ),
      ],
    );
  }
}
