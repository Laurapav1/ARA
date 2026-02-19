part of '../information.dart';

class _ShelterMapPanel extends StatelessWidget {
  static const String _mapAssetPath = 'assets/images/ARA-map.png';

  final String selectedArea;
  final ValueChanged<String> onAreaSelected;

  const _ShelterMapPanel({
    required this.selectedArea,
    required this.onAreaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 3,
          constrained: false,
          alignment: Alignment.topLeft,
          boundaryMargin: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: 540,
            height: 540,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    _mapAssetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ARAColors.surfaceWarm,
                            ARAColors.surfaceWarmAlt,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ..._mapSpots.map(
                  (spot) => _MapPin(
                    left: spot.left,
                    top: spot.top,
                    label: spot.label,
                    selected: selectedArea == spot.label,
                    onTap: () => onAreaSelected(spot.label),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final double left;
  final double top;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MapPin({
    required this.left,
    required this.top,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: selected ? 1.08 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: selected ? 1 : 0,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: ARAColors.brand.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ARAColors.inkStrong,
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 26 : 20,
                  height: selected ? 26 : 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pinColor(label),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
