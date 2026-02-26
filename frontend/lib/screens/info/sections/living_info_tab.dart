part of '../information.dart';

class _LivingInfoTab extends StatelessWidget {
  const _LivingInfoTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        _EditableInfoSections(
          storageKey: 'info_living_info',
          initialSections: [
            _EditableInfoSectionModel(
              id: 'accommodation',
              title: 'Accommodation',
              style: InfoSectionListStyle.bullet,
              items: _livingInfoAccommodation,
            ),
            _EditableInfoSectionModel(
              id: 'facilities',
              title: 'Facilities',
              style: InfoSectionListStyle.bullet,
              items: _livingInfoFacilities,
            ),
            _EditableInfoSectionModel(
              id: 'local_area',
              title: 'Local Area',
              style: InfoSectionListStyle.bullet,
              items: _livingInfoLocalArea,
            ),
          ],
        ),
      ],
    );
  }
}
