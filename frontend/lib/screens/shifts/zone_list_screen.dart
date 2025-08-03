// File: lib/screens/zone_list_screen.dart

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
  // track whether *you* are signed up for each zone
  late List<bool> _signedUp;

  @override
  void initState() {
    super.initState();
    _zones = widget.zones.map((z) => z.copy()).toList();
    _signedUp = List<bool>.filled(_zones.length, false);
  }

  Color _cardColor(int index) {
    final zone = _zones[index];

    // 1) Done → green
    if (zone.progress >= 1.0) return Colors.green.shade100;

    // 2) Anyone signed up (others or you) → yellow
    final hasAnyone = zone.volunteers + (_signedUp[index] ? 1 : 0) > 0;
    if (hasAnyone) return Colors.yellow.shade100;

    // 3) Otherwise → red
    return Colors.red.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OfflineBanner(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _zones.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final zone = _zones[index];
              final done = zone.progress >= 1.0;

              return Card(
                color: _cardColor(index),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  title: Text(
                    zone.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Tasks: ${zone.tasks.join(', ')}'),
                      const SizedBox(height: 4),
                      Text('Tip: ${zone.tip}'),
                    ],
                  ),
                  // show existing volunteers + you if signed up
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < zone.volunteers; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            radius: 12,
                            child: Icon(Icons.person, size: 16),
                          ),
                        ),
                      if (_signedUp[index])
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.blue.shade200,
                            child: Icon(Icons.person, size: 16),
                          ),
                        ),
                      if (!done)
                        TextButton(
                          child: const Text('Done'),
                          onPressed: () {
                            setState(() {
                              // mark as complete
                              _zones[index] = zone.copyWith(progress: 1.0);
                            });
                          },
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.check_circle),
                          onPressed: null,
                        ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      // toggle your signup
                      _signedUp[index] = !_signedUp[index];
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
