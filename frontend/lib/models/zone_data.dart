import 'zone.dart';

enum ShiftSeason { summer, winter }

class ShiftSchedule {
  final String label;
  final String morning;
  final String evening;

  const ShiftSchedule({
    required this.label,
    required this.morning,
    required this.evening,
  });
}

class ZoneData {
  static ShiftSeason seasonFor(DateTime date) {
    final month = date.month;
    return (month >= 5 && month <= 9) ? ShiftSeason.summer : ShiftSeason.winter;
  }

  static const ShiftSchedule summerSchedule = ShiftSchedule(
    label: 'Summer',
    morning: '08:00 AM - 12:00 PM',
    evening: '05:00 PM - 07:00 PM',
  );

  static const ShiftSchedule winterSchedule = ShiftSchedule(
    label: 'Winter',
    morning: '09:00 AM - 01:00 PM',
    evening: '04:00 PM - 06:00 PM',
  );

  static ShiftSchedule scheduleFor(DateTime date) {
    return seasonFor(date) == ShiftSeason.summer
        ? summerSchedule
        : winterSchedule;
  }

  static const morningZones = <Zone>[
    Zone(
      name: 'Zone A',
      progress: 0.2,
      volunteers: 2,
      tasks: ['Feed', 'Clean kennels', 'Refill water'],
      tip: 'Start with water bowls',
    ),
    Zone(
      name: 'Zone B',
      progress: 0.5,
      volunteers: 1,
      tasks: ['Sweep', 'Mop floor', 'Reset bedding'],
      tip: 'Sweep before mopping',
    ),
    Zone(
      name: 'Zone C',
      progress: 0.0,
      volunteers: 0,
      tasks: ['Food prep', 'Label diets', 'Stock supplies'],
      tip: 'Note special diets first',
    ),
    Zone(
      name: 'A Cattery',
      progress: 0.75,
      volunteers: 3,
      tasks: ['Quiet enrichment', 'Litter check', 'Water refill'],
      tip: 'Use a soft voice',
    ),
    Zone(
      name: 'Pool Side Cattery',
      progress: 0.25,
      volunteers: 1,
      tasks: ['Playtime', 'Litter check', 'Wipe surfaces'],
      tip: 'Handle kittens gently',
    ),
    Zone(
      name: 'Adult Side Cattery',
      progress: 0.6,
      volunteers: 2,
      tasks: ['Clean litter', 'Refill water', 'Observe behavior'],
      tip: 'Adults are sensitive to noise',
    ),
  ];

  static List<Zone> eveningZonesFor(DateTime date) {
    final zones = <Zone>[
      const Zone(
        name: 'Woden House Park',
        progress: 0.0,
        volunteers: 0,
        tasks: ['Check fences', 'Pick up waste', 'Refresh water'],
        tip: 'Close both gates before entering',
      ),
      const Zone(
        name: 'Big Park',
        progress: 0.0,
        volunteers: 0,
        tasks: ['Water refill', 'Pick up waste', 'Secure toys'],
        tip: 'Count dogs when exiting',
      ),
      const Zone(
        name: 'Between Park',
        progress: 0.0,
        volunteers: 0,
        tasks: ['Walk through', 'Pick up waste', 'Lock gates'],
        tip: 'Do a final sweep of corners',
      ),
      const Zone(
        name: 'Small Park',
        progress: 0.0,
        volunteers: 0,
        tasks: ['Water refill', 'Pick up waste', 'Check shade'],
        tip: 'Note any broken fencing',
      ),
      const Zone(
        name: 'Back Park',
        progress: 0.0,
        volunteers: 0,
        tasks: ['Pick up waste', 'Secure equipment', 'Lock gates'],
        tip: 'Report any damage',
      ),
    ];

    final weekday = date.weekday;
    final includeTrash =
        weekday == DateTime.monday || weekday == DateTime.friday;
    final includeEndOfShift = weekday == DateTime.sunday;

    if (includeEndOfShift) {
      zones.add(
        const Zone(
          name: 'End of Shift Checks',
          progress: 0.0,
          volunteers: 0,
          tasks: [
            'Check water - Zone A',
            'Check water - Zone B',
            'Check water - Zone C',
            'Check kitchen bowls',
          ],
          tip: 'Record issues in the log',
        ),
      );
    }

    if (includeTrash) {
      zones.add(
        const Zone(
          name: 'Trash Prep',
          progress: 0.0,
          volunteers: 0,
          tasks: [
            'Replace bin liners',
            'Tie trash bags',
            'Move bins to pickup area',
          ],
          tip: 'Double bag wet waste',
        ),
      );
    }

    return zones;
  }
}
