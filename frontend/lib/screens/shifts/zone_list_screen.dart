// File: lib/screens/shifts/zone_list_screen.dart
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

class _ZoneListScreenState extends State<ZoneListScreen>
    with SingleTickerProviderStateMixin {
  late List<Zone> _zones;
  late List<bool> _signedUp;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _zones = widget.zones.map((z) => z.copy()).toList();
    _signedUp = List<bool>.filled(_zones.length, false);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _cardColor(int index) {
    final zone = _zones[index];
    if (zone.progress >= 1.0) return const Color(0xFF66BB6A);
    final hasAnyone = zone.volunteers + (_signedUp[index] ? 1 : 0) > 0;
    if (hasAnyone) return const Color(0xFFFFCA28);
    return const Color(0xFFEF5350);
  }

  IconData _statusIcon(int index) {
    final zone = _zones[index];
    if (zone.progress >= 1.0) return Icons.check_circle;
    final hasAnyone = zone.volunteers + (_signedUp[index] ? 1 : 0) > 0;
    if (hasAnyone) return Icons.schedule;
    return Icons.warning_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OfflineBanner(),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2D9596),
                const Color(0xFF2D9596).withOpacity(0.8),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
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
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
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
                        color: Colors.white.withOpacity(0.9),
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
              final delay = index * 0.1;

              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      delay,
                      delay + 0.5,
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                        delay,
                        delay + 0.5,
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ZoneCard(
                      zone: zone,
                      color: _cardColor(index),
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ZoneCard extends StatefulWidget {
  final Zone zone;
  final Color color;
  final IconData icon;
  final bool isSignedUp;
  final bool isDone;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const _ZoneCard({
    required this.zone,
    required this.color,
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
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.zone.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF265073),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.zone.tasks.length} tasks',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildVolunteerIcons(),
                  if (!widget.isDone)
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: widget.color,
                      onPressed: widget.onComplete,
                      style: IconButton.styleFrom(
                        backgroundColor: widget.color.withOpacity(0.1),
                      ),
                    ),
                ],
              ),
            ),
            if (_isExpanded)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Tasks:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.zone.tasks.map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: widget.color,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: ${widget.zone.tip}',
                              style: TextStyle(
                                color: Colors.amber.shade900,
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
    );
  }

  Widget _buildVolunteerIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.zone.volunteers; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, size: 16, color: Colors.grey.shade700),
            ),
          ),
        if (widget.isSignedUp)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF2D9596),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
