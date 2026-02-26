part of '../information.dart';

class _CleaningPanelBody extends StatelessWidget {
  final String storageKey;
  final List<String> doItems;
  final List<String> doNotItems;
  final List<String> doneWhenItems;
  final String doTitle;
  final String doNotTitle;
  final String doneWhenTitle;

  const _CleaningPanelBody({
    required this.storageKey,
    required this.doItems,
    required this.doNotItems,
    required this.doneWhenItems,
    required this.doTitle,
    required this.doNotTitle,
    required this.doneWhenTitle,
  });

  @override
  Widget build(BuildContext context) {
    return _EditableInfoSections(
      storageKey: storageKey,
      initialSections: [
        _EditableInfoSectionModel(
          id: 'do',
          title: doTitle,
          style: InfoSectionListStyle.bullet,
          items: doItems,
        ),
        _EditableInfoSectionModel(
          id: 'do_not',
          title: doNotTitle,
          style: InfoSectionListStyle.bullet,
          items: doNotItems,
        ),
        _EditableInfoSectionModel(
          id: 'done',
          title: doneWhenTitle,
          style: InfoSectionListStyle.bullet,
          items: doneWhenItems,
        ),
      ],
    );
  }
}
