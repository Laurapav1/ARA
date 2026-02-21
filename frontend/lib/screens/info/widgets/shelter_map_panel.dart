part of '../information.dart';

class _ShelterMapPanel extends StatefulWidget {
  static const String _mapAssetPath = 'assets/images/ARA-map.png';
  static const double _mapWidth = 540;
  static const double _mapHeight = 540;
  static const double _viewportHeight = 300;

  final String selectedArea;
  final ValueChanged<String> onAreaSelected;

  const _ShelterMapPanel({
    required this.selectedArea,
    required this.onAreaSelected,
  });

  @override
  State<_ShelterMapPanel> createState() => _ShelterMapPanelState();
}

class _ShelterMapPanelState extends State<_ShelterMapPanel> {
  final TransformationController _controller = TransformationController();
  bool _initialViewportSet = false;

  @override
  void reassemble() {
    super.reassemble();
    _initialViewportSet = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setInitialViewport(BoxConstraints constraints) {
    if (_initialViewportSet || constraints.maxWidth <= 0) {
      return;
    }

    final viewportWidth = constraints.maxWidth;

    // Start near the left-center of the map where core zones are clustered.
    const focusX = 130.0;
    const focusY = 300.0;

    final rawDx = (viewportWidth / 2) - focusX;
    final rawDy = (_ShelterMapPanel._viewportHeight / 2) - focusY;

    final minDx = viewportWidth - _ShelterMapPanel._mapWidth;
    final minDy = _ShelterMapPanel._viewportHeight - _ShelterMapPanel._mapHeight;

    final dx = rawDx.clamp(minDx, 0.0).toDouble();
    final dy = rawDy.clamp(minDy, 0.0).toDouble();

    _controller.value = Matrix4.identity()..translateByDouble(dx, dy, 0.0, 1.0);
    _initialViewportSet = true;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _ShelterMapPanel._viewportHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _setInitialViewport(constraints);

          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 1,
              maxScale: 3,
              constrained: false,
              boundaryMargin: EdgeInsets.zero,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _ShelterMapPanel._mapWidth,
                height: _ShelterMapPanel._mapHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        _ShelterMapPanel._mapAssetPath,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => DecoratedBox(
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
                        selected: widget.selectedArea == spot.label,
                        onTap: () => widget.onAreaSelected(spot.label),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  static const double _dotSize = 22;

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
      left: left - (_dotSize / 2),
      top: top - (_dotSize / 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (selected)
                Positioned(
                  bottom: _dotSize + 8,
                  child: Container(
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
              AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: selected ? 1.12 : 1.0,
                child: Container(
                  width: _dotSize,
                  height: _dotSize,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
