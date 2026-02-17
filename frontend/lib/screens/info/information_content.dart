part of 'information.dart';

class _ZoneInfoContent {
  final List<String> zones;
  final List<String> kennelCleaning;
  final List<String> kennelDoNotForget;
  final List<String> catteryCleaning;
  final List<String> catteryDoNotForget;
  final List<String> bowlCleaningZones;
  final List<String> bowlCleaningCatteries;
  final List<String> bowlCleaningParks;
  final List<String> accommodationCleaning;
  final List<String> trashTasks;
  final List<String> doNotForget;
  final List<String> extraTasks;

  const _ZoneInfoContent({
    required this.zones,
    required this.kennelCleaning,
    required this.kennelDoNotForget,
    required this.catteryCleaning,
    required this.catteryDoNotForget,
    required this.bowlCleaningZones,
    required this.bowlCleaningCatteries,
    required this.bowlCleaningParks,
    required this.accommodationCleaning,
    required this.trashTasks,
    required this.doNotForget,
    required this.extraTasks,
  });
}

class _CleaningPanelData {
  final String id;
  final String title;
  final List<String> doItems;
  final List<String> doNotItems;
  final List<String> doneWhenItems;

  const _CleaningPanelData({
    required this.id,
    required this.title,
    required this.doItems,
    required this.doNotItems,
    required this.doneWhenItems,
  });
}

class _MapSpot {
  final String label;
  final double left;
  final double top;

  const _MapSpot({
    required this.label,
    required this.left,
    required this.top,
  });
}

const List<_MapSpot> _mapSpots = [
  _MapSpot(
    label: 'Reception',
    left: 54,
    top: 88,
  ),
  _MapSpot(
    label: 'Zone A',
    left: 176,
    top: 124,
  ),
  _MapSpot(
    label: 'Zone B',
    left: 284,
    top: 148,
  ),
  _MapSpot(
    label: 'Zone C',
    left: 402,
    top: 136,
  ),
  _MapSpot(
    label: 'Catteries',
    left: 244,
    top: 246,
  ),
  _MapSpot(
    label: 'Park North',
    left: 106,
    top: 256,
  ),
  _MapSpot(
    label: 'Park South',
    left: 432,
    top: 266,
  ),
  _MapSpot(
    label: 'Volunteer accommodation',
    left: 66,
    top: 188,
  ),
];

Color _pinColor(String label) {
  const facility = ARAColors.brandDeep;
  const zone = ARAColors.brandDark;
  if (label == 'Reception' ||
      label == 'Catteries' ||
      label == 'Volunteer accommodation') {
    return facility;
  }
  return zone;
}

_ZoneInfoContent _zoneContent() {
  return const _ZoneInfoContent(
    zones: [
      'Reception',
      'Zone A',
      'Zone B',
      'Zone C',
      'Catteries',
      'Park North',
      'Park South',
      'Volunteer accommodation',
    ],
    kennelCleaning: [
      'pick up the poo',
      'Mop all the floor of the kennel',
      'Move the beds and the bowls to mop underneath',
      'Throw away the water from the water bowls',
      'Check the blankets from the beds : if they are dirty with pree or poo, or too humid/wet : put the dirty ones in front of the kennels',
      'put fresh water until the top',
      'put new blankets if needed',
    ],
    kennelDoNotForget: [
      'Brush the floow in front of the kennels',
      'Check after mopping that there is no more poo on the floor/wall',
      'close the kennel once you are not cleaning it',
      'change the water from the mop bucket frequently',
    ],
    catteryCleaning: [
      'Pick up poo and the pee from the sandboxes',
      'put a bit of fresh sand after',
      'throw the water saway and put freash water',
      'brush the floor',
      'mop the floow',
      'Collect the pee and the poo in a smal trash bag. When this one is full, put it in the big trash container from the cattery',
    ],
    catteryDoNotForget: [
      'Never use bleach to clean',
      'Squeeze the mop tas mush as possible for the floor to dry fast',
      'if the sandbox is very wet or very dirty , throw the sand away, clean the box and put freasg sand',
    ],
    bowlCleaningZones: [
      'Always use a metal spoonge and dishsoap. Make sure you scratch enough to get rid of limestone',
      'You have sinks in the dog kitchen, dog laundry, zone b and zone c to clean',
      'always separate the 2 food bowls inside the kennels',
      '1 water bowls and 1 food bowl per dog in the kennel, and the size of the bowls according to the size of the dogs',
      'If there is food in a bowl, put it in a clean bowl from the dog kitchen then put it back in the kennel and clean other one',
    ],
    bowlCleaningCatteries: [
      'always use a metal spoonge and dishsop',
      'you have sinks in the A cattery and in the corridor between the upstaris catteries to clean',
      'make sure you scratch enough to get rid of the limestone',
      'put the food from the bowls in a big bowl or a bucket, clean the bowls and then put the food back in the bowls',
    ],
    bowlCleaningParks: [
      'Always use a metal spoonge and dishsoap',
      'you have sinks in the dog kitchen, dog laundry, zone b, and zone c to clean',
      'make sure to put the same bowls/buckets and same number of bowls/buckets in the parks',
      'always refill with water until the top after cleaning them',
      'Organise and communicate between yourself to make sure all the bowls will be washed',
    ],
    accommodationCleaning: [
      'Microwaves and oven',
      'fridges',
      'toilet and bathroom',
      'sink/tables/stove',
      'under the beds /vaccum and mop',
      'floor (vaccum and mop)',
      'sofa (change blankes)',
      'This task is to do during the shift time. It means it has be done ccorrectly. It is very important to keeo the place clean and hygienic',
      'you will find all the cleaning products in the house/trailer. if nit, there is more in the storage room',
    ],
    trashTasks: [
      'Use small bags for cattery waste and move full bags to big containers.',
      'Empty full trash bags from work areas.',
      'Replace bag liners after emptying bins.',
      'Report overflow or missing bags to coordinator.',
    ],
    doNotForget: [
      'Coordinate cleaning between volunteers so no area is missed.',
      'Keep tools and cleaning rooms tidy after use.',
      'Communicate if you cannot complete a task.',
      'Do not leave your shift earlier unless staff approves it.',
    ],
    extraTasks: [
      'Take pictures of the dogs/cats',
      'brush dog/cats',
      'bath dogs (ask a staff first)',
      'sweep the floor in zone Zone A/B/C',
      'sweep the floor in front of the dog kitchen',
      'clean the leash room',
      'tidy the << lost and found >> clostes',
    ],
  );
}

const List<String> _overviewStructureBullets = [
  'Dogs are divided into Zones A, B and C so work stays organized.',
  'Cats are housed in separate catteries with their own routines.',
  'Morning shift usually covers feed + clean + first checks.',
  'Evening shift focuses on refresh, clean-up and close-out checks.',
  'Most volunteers start at Reception to confirm the task board.',
  'If unsure where to begin, ask the shift coordinator first.',
];

const List<String> _overviewWhoIsWhoBullets = [
  'Coordinator: assigns priorities and answers task questions during shift.',
  'Vet: handles health concerns and approves medical-related actions.',
  'Manager: handles operational issues and final decisions when needed.',
  'During your shift, contact the Coordinator first for guidance.',
  'Use the shelter phone/WhatsApp group for urgent updates if requested.',
];

const List<String> _overviewMorningFlow = [
  'Check task board and assigned zone.',
  'Feed animals and refill water.',
  'Clean your assigned zones.',
  'Review notes for behavior or health updates.',
  'Update completed tasks before handover.',
];

const List<String> _safetyRules = [
  'Always lock the doors from the kennels',
  'Do no give food when dogs are in the parks',
  'During the walks, the staff members will tell you the dog and the road to take',
  'Only give Kongs or chewale treat when the dog is alone in the kennel',
  'Always go with the dog from the corriddor back of the kennels in zone A',
  'If you do not feel comfortable to enter in a kennel, do not go. Let the staff or volunteers know for the kennel to clean',
  'always put the harness back, on the side og the kennels',
  'always pick up the poo with poo bags on walks and bring it back, do not leave the bag in the nature',
];

const List<String> _incidentSteps = [
  'Secure the animal and move people to a safe position.',
  'Call the coordinator and request help.',
  'Provide first aid only within your training level.',
  'Document who, what, where and when in the incident log.',
  'Disinfect affected area and replace used supplies.',
];

const List<String> _firstDayChecklist = [
  'Sign in, get orientation and confirm your assigned zone.',
  'Walk through map, gates and emergency points.',
  'Learn cleaning flow for kennels and catteries.',
  'Review safety rules and incident reporting steps.',
  'Confirm gate return-time rules before starting tasks.',
];

const List<String> _endOfShiftChecklist = [
  'Finish final bowl and water checks for your zone.',
  'Remove trash and leave cleaning tools ready for next shift.',
  'Update logs and handover notes (animals, incidents, supplies).',
  'Confirm all gates and doors are secured.',
  'Sign out and return borrowed keys or equipment.',
];

const List<String> _cleaningStandardSteps = [
  'Pick up waste first.',
  'Move items so all surfaces can be cleaned.',
  'Clean/scrub, then mop/disinfect where required.',
  'Refill fresh water and reset bowls/beds/litter.',
  'Secure doors and gates before leaving the area.',
  'Leave area dry, hygienic, and ready for the next person.',
];


