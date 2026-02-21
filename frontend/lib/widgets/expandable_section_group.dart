import 'package:flutter/material.dart';

import 'expandable_section.dart';

class ExpandableSectionItem {
  final String id;
  final String title;
  final Widget child;

  const ExpandableSectionItem({
    required this.id,
    required this.title,
    required this.child,
  });
}

class ExpandableSectionGroup extends StatefulWidget {
  final String initiallyExpandedId;
  final List<ExpandableSectionItem> sections;
  final double spacing;

  const ExpandableSectionGroup({
    super.key,
    required this.initiallyExpandedId,
    required this.sections,
    this.spacing = 10,
  });

  @override
  State<ExpandableSectionGroup> createState() => _ExpandableSectionGroupState();
}

class _ExpandableSectionGroupState extends State<ExpandableSectionGroup> {
  late String _expandedId;

  @override
  void initState() {
    super.initState();
    _expandedId = widget.initiallyExpandedId;
  }

  void _onChanged(String id, bool expanded) {
    setState(() => _expandedId = expanded ? id : '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.sections.length, (index) {
        final section = widget.sections[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == widget.sections.length - 1 ? 0 : widget.spacing,
          ),
          child: ExpandableSection(
            title: section.title,
            isExpanded: _expandedId == section.id,
            onChanged: (expanded) => _onChanged(section.id, expanded),
            child: section.child,
          ),
        );
      }),
    );
  }
}
