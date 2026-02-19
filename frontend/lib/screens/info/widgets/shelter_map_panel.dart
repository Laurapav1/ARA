part of '../information.dart';

class _ShelterMapPanel extends StatelessWidget {
  final String selectedArea;
  final ValueChanged<String> onAreaSelected;

  const _ShelterMapPanel({
    required this.selectedArea,
    required this.onAreaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: DecoratedBox(
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
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 2.8,
            boundaryMargin: const EdgeInsets.all(60),
            child: SizedBox(
              width: 540,
              height: 340,
              child: Stack(
                children: [
                  const _MapParkBlob(
                      left: 26, top: 192, width: 160, height: 98),
                  const _MapParkBlob(
                      left: 382, top: 220, width: 136, height: 86),
                  _MapRoad(
                    left: 80,
                    top: 56,
                    width: 380,
                    angle: 0.10,
                  ),
                  _MapRoad(
                    left: 74,
                    top: 208,
                    width: 318,
                    angle: -0.18,
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
      ),
    );
  }
}

class _MapRoad extends StatelessWidget {
  final double left;
  final double top;
  final double width;
  final double angle;

  const _MapRoad({
    required this.left,
    required this.top,
    required this.width,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: 6,
          decoration: BoxDecoration(
            color: ARAColors.surfaceWarmTint,
            borderRadius: BorderRadius.circular(999),
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

class _MapParkBlob extends StatelessWidget {
  final double left;
  final double top;
  final double width;
  final double height;

  const _MapParkBlob({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ARAColors.surfaceWarmTint.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}
