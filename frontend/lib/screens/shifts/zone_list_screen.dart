import 'package:flutter/material.dart';
import '../../widgets/offline_banner.dart';
import '../../models/zone.dart';

class ZoneListScreen extends StatefulWidget {
  final String shiftType;
  final List<Zone> zones;

  const ZoneListScreen({
    Key? key,
    required this.shiftType,
    required this.zones,
  }) : super(key: key);

  @override
  _ZoneListScreenState createState() => _ZoneListScreenState();
}

class _ZoneListScreenState extends State<ZoneListScreen> {
  late List<Zone> _zones;
  late List<bool> _signedUp;

  @override
  void initState() {
    super.initState();
    _zones = widget.zones.map((z) => z.copy()).toList();
    _signedUp = List<bool>.filled(_zones.length, false);
  }

  // State colors:
  //  - Done: green
  //  - In progress (someone on it): **yellow**
  //  - Unassigned: red
  Color _cardColor(int index) {
    final zone = _zones[index];
    if (zone.progress >= 1.0) return const Color(0xFF2E7D32); // green 800
    final hasAnyone = zone.volunteers + (_signedUp[index] ? 1 : 0) > 0;
    if (hasAnyone) return const Color(0xFFFFC107); // **Amber 500 (yellow)**
    return const Color(0xFFEF5350); // red 400
  }

  IconData _statusIcon(int index) {
    final zone = _zones[index];
    if (zone.progress >= 1.0) return Icons.check_circle;
    final hasAnyone = zone.volunteers + (_signedUp[index] ? 1 : 0) > 0;
    if (hasAnyone) return Icons.schedule;
    return Icons.warning_rounded;
  }

  // Choose readable text color for each background
  _TextPalette _paletteFor(Color bg) {
    if (bg.value == const Color(0xFFFFC107).value) {
      // Yellow: use dark text for contrast
      return const _TextPalette(
        primary: Color(0xFF2D2A00),
        secondary: Color(0xFF4A4600),
        overlay: Color(0x33000000), // dark translucent
        onAccentIcon: Color(0xFF2D2A00),
      );
    }
    // Red/Green (darker): use white
    return const _TextPalette(
      primary: Colors.white,
      secondary: Color(0xFFEFF3F6),
      overlay: Color(0x22FFFFFF),
      onAccentIcon: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OfflineBanner(),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2D9596), Color(0xFF2D9596)],
            ),
          ),
          child: const Row(
            children: [
              _HeaderIcon(),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zones & Tasks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tap to sign up • Long press for details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _zones.length,
            itemBuilder: (context, index) {
              final zone = _zones[index];
              final done = zone.progress >= 1.0;
              final bg = _cardColor(index);
              final pal = _paletteFor(bg);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ZoneCard(
                  zone: zone,
                  bg: bg,
                  palette: pal,
                  icon: _statusIcon(index),
                  isSignedUp: _signedUp[index],
                  isDone: done,
                  onTap: () {
                    setState(() {
                      _signedUp[index] = !_signedUp[index];
                    });
                  },
                  onComplete: () {
                    setState(() {
                      _zones[index] = zone.copyWith(progress: 1.0);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.location_on,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _ZoneCard extends StatefulWidget {
  final Zone zone;
  final Color bg;
  final _TextPalette palette;
  final IconData icon;
  final bool isSignedUp;
  final bool isDone;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const _ZoneCard({
    required this.zone,
    required this.bg,
    required this.palette,
    required this.icon,
    required this.isSignedUp,
    required this.isDone,
    required this.onTap,
    required this.onComplete,
  });

  @override
  State<_ZoneCard> createState() => _ZoneCardState();
}

class _ZoneCardState extends State<_ZoneCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final pal = widget.palette;

    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(color: widget.bg),
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: () => setState(() => _isExpanded = !_isExpanded),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: pal.overlay,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: pal.onAccentIcon, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.zone.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: pal.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.zone.tasks.length} tasks',
                            style: TextStyle(
                              color: pal.secondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildVolunteerIcons(),
                    if (!widget.isDone) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.check),
                        color: pal.primary,
                        onPressed: widget.onComplete,
                        style: IconButton.styleFrom(
                          backgroundColor: pal.overlay,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_isExpanded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(color: pal.overlay),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: pal.primary.withOpacity(0.35)),
                      const SizedBox(height: 12),
                      Text(
                        'Tasks:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: pal.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.zone.tasks.map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 18, color: pal.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task,
                                  style: TextStyle(color: pal.secondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: pal.overlay,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: pal.primary.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                color: pal.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tip: ${widget.zone.tip}',
                                style: TextStyle(
                                  color: pal.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildVolunteerIcons() {
    // Always white chip background so it’s readable on any card color
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.zone.volunteers; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 16, color: Colors.black87),
            ),
          ),
        if (widget.isSignedUp)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 16, color: Colors.black87),
            ),
          ),
      ],
    );
  }
}

class _TextPalette {
  final Color primary;
  final Color secondary;
  final Color overlay;
  final Color onAccentIcon;
  const _TextPalette({
    required this.primary,
    required this.secondary,
    required this.overlay,
    required this.onAccentIcon,
  });
}
