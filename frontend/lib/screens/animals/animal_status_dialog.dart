import 'package:flutter/material.dart';

import '../../models/animal.dart';
import '../../theme/ara_theme.dart';

Future<void> showAnimalStatusDialog(
  BuildContext context,
  Animal currentAnimal,
  Future<void> Function() onConfirm,
) {
  StatusChoice selection = StatusChoice.adopted;
  return showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.pets, color: ARAColors.ink),
            SizedBox(width: 12),
            Text('Change status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose the new status for ${currentAnimal.name}. This will remove them from the active list.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: ARAColors.subInk),
            ),
            const SizedBox(height: 16),
            _StatusOption(
              title: 'Adopted',
              subtitle: 'No longer available, but kept in records',
              value: StatusChoice.adopted,
              groupValue: selection,
              onChanged: (value) => setState(() => selection = value),
            ),
            const SizedBox(height: 10),
            _StatusOption(
              title: 'Remove',
              subtitle: 'Removed from records',
              value: StatusChoice.removed,
              groupValue: selection,
              onChanged: (value) => setState(() => selection = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await onConfirm();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: ARAColors.brand,
              foregroundColor: ARAColors.ink,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ),
  );
}

enum StatusChoice { adopted, removed }

class _StatusOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final StatusChoice value;
  final StatusChoice groupValue;
  final ValueChanged<StatusChoice> onChanged;

  const _StatusOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return Material(
      color: ARAColors.surfaceWarm,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isSelected ? ARAColors.brandDark : ARAColors.surfaceWarmTint,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Radio<StatusChoice>(
                value: value,
                groupValue: groupValue,
                onChanged: (val) {
                  if (val != null) onChanged(val);
                },
                activeColor: ARAColors.brandDark,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ARAColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: ARAColors.subInk,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
