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
        _SectionCard(
          title: 'Checklist progress',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: ARAColors.surfaceWarmTint,
                color: ARAColors.brandDark,
                minHeight: 10,
              ),
              const SizedBox(height: 8),
              Text('$done of $total completed'),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.replay),
                label: const Text('Reset checks'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'First-day checklist for new volunteers',
          child: _InteractiveChecklist(
            prefix: 'first_day',
            items: _firstDayChecklist,
            checkedItems: checkedItems,
            onToggle: onToggle,
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'End-of-shift checklist',
          child: _InteractiveChecklist(
            prefix: 'end_shift',
            items: _endOfShiftChecklist,
            checkedItems: checkedItems,
            onToggle: onToggle,
          ),
        ),
      ],
    );
  }
}
