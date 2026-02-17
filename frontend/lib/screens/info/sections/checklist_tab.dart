part of '../information.dart';

class _ChecklistTab extends StatelessWidget {
  final Set<String> checkedItems;
  final void Function(String key, bool checked) onToggle;
  final VoidCallback onReset;

  const _ChecklistTab({
    required this.checkedItems,
    required this.onToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final total = _firstDayChecklist.length + _endOfShiftChecklist.length;
    final done = checkedItems.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        _ChecklistProgressCard(
          done: done,
          total: total,
          onReset: onReset,
        ),
        const SizedBox(height: 12),
        ExpandableSectionGroup(
          initiallyExpandedId: '',
          sections: [
            ExpandableSectionItem(
              id: 'first_day',
              title: 'First-day checklist for new volunteers',
              child: _InteractiveChecklist(
                prefix: 'first_day',
                items: _firstDayChecklist,
                checkedItems: checkedItems,
                onToggle: onToggle,
              ),
            ),
            ExpandableSectionItem(
              id: 'end_shift',
              title: 'End-of-shift checklist',
              child: _InteractiveChecklist(
                prefix: 'end_shift',
                items: _endOfShiftChecklist,
                checkedItems: checkedItems,
                onToggle: onToggle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
