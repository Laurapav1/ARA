// File: lib/models/zone_data.dart
import 'zone.dart';

class ZoneData {
  static const morningZones = <Zone>[
    Zone(
      name: 'Zone A',
      progress: 0.2,
      volunteers: 2,
      tasks: ['Feed', 'Clean kennels'],
      tip: 'Check water bowls first',
    ),
    Zone(
      name: 'Zone B',
      progress: 0.5,
      volunteers: 1,
      tasks: ['Sweep', 'Mop floor'],
      tip: 'Sweep before mopping',
    ),
    Zone(
      name: 'Zone C',
      progress: 0.0,
      volunteers: 0,
      tasks: ['Food prep'],
      tip: 'Feed kittens before cleaning',
    ),
    Zone(
      name: 'A Cattery',
      progress: 0.75,
      volunteers: 3,
      tasks: ['Quiet enrichment'],
      tip: 'Use soft voice zone',
    ),
    Zone(
      name: 'Pool Cattery',
      progress: 0.25,
      volunteers: 1,
      tasks: ['Playtime'],
      tip: 'Handle kittens gently',
    ),
    Zone(
      name: 'Adult Cattery',
      progress: 0.6,
      volunteers: 2,
      tasks: ['Clean litter', 'Refill water'],
      tip: 'Adults are sensitive to noise',
    ),
  ];

  static const eveningZones = <Zone>[
    Zone(
      name: 'Zone A',
      progress: 0.3,
      volunteers: 1,
      tasks: ['Clean bowls', 'Trash'],
      tip: 'Double-check kennels',
    ),
    // add the rest of your evening zones here...
  ];
}
