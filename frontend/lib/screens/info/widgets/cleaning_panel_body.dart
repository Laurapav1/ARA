part of '../information.dart';

class _CleaningPanelBody extends StatefulWidget {
  final List<String> doItems;
  final List<String> doNotItems;
  final List<String> doneWhenItems;
  final String doTitle;
  final String doNotTitle;
  final String doneWhenTitle;

  const _CleaningPanelBody({
    required this.doItems,
    required this.doNotItems,
    required this.doneWhenItems,
    required this.doTitle,
    required this.doNotTitle,
    required this.doneWhenTitle,
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
          title: widget.doTitle,
          isExpanded: _expandedId == 'do',
          onChanged: (expanded) => _setExpanded('do', expanded),
          child: InfoSectionList(items: widget.doItems),
        ),
        const SizedBox(height: 8),
        ExpandableSection(
          title: widget.doNotTitle,
          isExpanded: _expandedId == 'do_not',
          onChanged: (expanded) => _setExpanded('do_not', expanded),
          child: InfoSectionList(items: widget.doNotItems),
        ),
        const SizedBox(height: 8),
        ExpandableSection(
          title: widget.doneWhenTitle,
          isExpanded: _expandedId == 'done',
          onChanged: (expanded) => _setExpanded('done', expanded),
          child: InfoSectionList(items: widget.doneWhenItems),
        ),
      ],
    );
  }
}
