part of '../information.dart';

class _OverviewMapContent extends StatelessWidget {
  final List<String> zones;
  final String selectedArea;
  final ValueChanged<String> onAreaSelected;
  final String Function(String area) areaSummary;

  const _OverviewMapContent({
    required this.zones,
    required this.selectedArea,
    required this.onAreaSelected,
    required this.areaSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tap a zone to see a short description.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _ShelterMapPanel(
          selectedArea: selectedArea,
          onAreaSelected: onAreaSelected,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: zones.map((zone) {
              final selected = zone == selectedArea;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  onPressed: () => onAreaSelected(zone),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: selected
                        ? ARAColors.brand.withValues(alpha: 0.20)
                        : ARAColors.cardBg,
                    side: BorderSide(
                      color:
                          selected ? ARAColors.brandDark : ARAColors.surfaceWarmTint,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    minimumSize: const Size(0, 38),
                  ),
                  child: Text(
                    zone,
                    style: TextStyle(
                      color: selected ? ARAColors.inkStrong : ARAColors.subInk,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ARAColors.surfaceWarmSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ARAColors.surfaceWarmTint),
          ),
          child: Text(
            areaSummary(selectedArea),
            style: const TextStyle(color: ARAColors.ink),
          ),
        ),
      ],
    );
  }
}
