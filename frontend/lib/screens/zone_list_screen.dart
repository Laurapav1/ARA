// File: lib/screens/zone_list_screen.dart
import 'package:flutter/material.dart';
import '../widgets/offline_banner.dart';
import '../models/zone.dart';

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

  @override
  void initState() {
    super.initState();
    // Make a local, mutable copy
    _zones = widget.zones.map((z) => z.copy()).toList();
  }

  Color _cardColor(double progress) {
    if (progress >= 1.0) {
      return Colors.green.shade100;
    } else if (progress > 0) {
      return Colors.yellow.shade100;
    } else {
      return Colors.red.shade100;
    }
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
                color: _cardColor(zone.progress),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  title: Text(zone.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Tasks: ${zone.tasks.join(', ')}'),
                      const SizedBox(height: 4),
                      Text('Tip: ${zone.tip}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Volunteer icons
                      for (var i = 0; i < zone.volunteers; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            radius: 12,
                            child: Icon(Icons.person, size: 16),
                          ),
                        ),

                      // Done button or QR button
                      if (!done)
                        TextButton(
                          child: const Text('Done'),
                          onPressed: () {
                            setState(() {
                              _zones[index] =
                                  zone.copyWith(progress: 1.0);
                            });
                          },
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.qr_code),
                          onPressed: () {
                            // TODO: Launch QR scanner or display QR code
                          },
                        ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Navigate to detailed tasks for this zone
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
