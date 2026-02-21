part of '../information.dart';

class _CleaningPanelBody extends StatefulWidget {
  final List<String> doItems;
  final List<String> doNotItems;
  final List<String> doneWhenItems;

  const _CleaningPanelBody({
    required this.doItems,
    required this.doNotItems,
    required this.doneWhenItems,
  });

  @override
  State<_CleaningPanelBody> createState() => _CleaningPanelBodyState();
}

class _CleaningPanelBodyState extends State<_CleaningPanelBody> {
  String _expandedId = '';

  void _setExpanded(String id, bool expanded) {
    setState(() => _expandedId = expanded ? id : '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpandableSection(
          title: 'How to clean correctly',
          isExpanded: _expandedId == 'do',
          onChanged: (expanded) => _setExpanded('do', expanded),
          child: InfoSectionList(items: widget.doItems),
        ),
        const SizedBox(height: 8),
        ExpandableSection(
          title: 'Do not forget',
          isExpanded: _expandedId == 'do_not',
          onChanged: (expanded) => _setExpanded('do_not', expanded),
          child: InfoSectionList(items: widget.doNotItems),
        ),
        const SizedBox(height: 8),
        ExpandableSection(
          title: 'Done when',
          isExpanded: _expandedId == 'done',
          onChanged: (expanded) => _setExpanded('done', expanded),
          child: InfoSectionList(items: widget.doneWhenItems),
        ),
      ],
    );
  }
}
