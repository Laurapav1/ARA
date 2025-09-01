import 'package:flutter/material.dart';
import '../../widgets/offline_banner.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Information')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(
                  title: 'Shelter Map',
                  trailing:
                      Text('Pinch to zoom', style: theme.textTheme.labelSmall),
                ),
                _MapCard(
                  onZoneTap: (zone) => _showZoneGuide(context, zone),
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'Zones'),
                const SizedBox(height: 8),
                _ZoneChips(
                  zones: _zoneGuides.keys.toList(),
                  onTap: (z) => _showZoneGuide(context, z),
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickActionButton(
                      icon: Icons.checklist_rtl,
                      label: 'First-day checklist',
                      onTap: () => _showChecklist(
                          context, 'First-day checklist', _firstDayChecklist),
                    ),
                    _QuickActionButton(
                      icon: Icons.done_all,
                      label: 'End-of-shift',
                      onTap: () => _showChecklist(context,
                          'End-of-shift checklist', _endOfShiftChecklist),
                    ),
                    _QuickActionButton(
                      icon: Icons.report_gmailerrorred,
                      label: 'Incident steps',
                      onTap: () => _showChecklist(
                          context, 'Incident procedure', _incidentSteps),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Safety Flags'),
                const SizedBox(height: 8),
                const _SafetyFlags(),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Tips & How-tos'),
                const SizedBox(height: 8),
                const _TipsAccordion(),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Contacts'),
                const SizedBox(height: 8),
                const _ContactsList(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showZoneGuide(BuildContext context, String zone) {
    final tasks = _zoneGuides[zone] ?? const <String>[];
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Guide • $zone',
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...tasks.map((t) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.task_alt),
                      title: Text(t),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showChecklist(
      BuildContext context, String title, List<String> items) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(title, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...items.map((t) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(t),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- Data you can later swap to your mock DB ---------- */

const Map<String, List<String>> _zoneGuides = {
  'Zone A': [
    'Kennels 1–10: morning clean',
    'Refill water bowls',
    'Feed according to board',
    'Note any diarrhoea/cough',
    'Walk dogs assigned to Zone A (15–20 min)',
  ],
  'Zone B': [
    'Kennels 11–20: sweep & disinfect',
    'Park 1 rotation (max 2 dogs)',
    'Red tag dogs need muzzle',
    'Laundry drop-off by 11:00',
  ],
  'Quarantine': [
    'No cross-zone tools',
    'Gloves & boot dip required',
    'Waste bagged and sealed',
  ],
};

const List<String> _firstDayChecklist = [
  'Sign in & get badge',
  'Read safety flags board',
  'Shadow an experienced volunteer',
  'Learn leash & gate rules',
  'Locate first aid & emergency exits',
];

const List<String> _endOfShiftChecklist = [
  'Return keys & badge',
  'Update whiteboard (food/water/notes)',
  'Log incidents (if any)',
  'Laundry started / folded',
  'Tools cleaned & stored',
];

const List<String> _incidentSteps = [
  'Secure dog/cat safely',
  'Inform coordinator immediately',
  'Provide basic first aid if trained',
  'Record incident in log (who/what/when)',
  'Disinfect area and tools',
];

/* -------------------- UI pieces -------------------- */

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.titleLarge;
    return Row(
      children: [
        Expanded(child: Text(title, style: text)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MapCard extends StatelessWidget {
  final void Function(String zone) onZoneTap;
  const _MapCard({required this.onZoneTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Replace with Image.asset('assets/shelter_map.png') if you add a real map
          SizedBox(
            height: 220,
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(24),
              minScale: 1,
              maxScale: 4,
              child: Container(
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Text('Map placeholder (pinch to zoom)'),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _LegendItem(icon: Icons.pets, label: 'Kennels'),
                _LegendItem(icon: Icons.park, label: 'Parks'),
                _LegendItem(icon: Icons.warning, label: 'Quarantine'),
                _LegendItem(icon: Icons.water_drop, label: 'Water point'),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _LegendItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _ZoneChips extends StatelessWidget {
  final List<String> zones;
  final void Function(String) onTap;
  const _ZoneChips({required this.zones, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: zones
          .map(
            (z) => ActionChip(
              label: Text(z),
              onPressed: () => onTap(z),
            ),
          )
          .toList(),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ]),
      ),
    );
  }
}

class _SafetyFlags extends StatelessWidget {
  const _SafetyFlags();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _FlagPill(
            icon: Icons.mood_bad,
            color: Colors.red,
            text: 'Bite risk • Red tag'),
        _FlagPill(
            icon: Icons.heart_broken,
            color: Colors.orange,
            text: 'Fearful • Slow approach'),
        _FlagPill(
            icon: Icons.sick,
            color: Colors.purple,
            text: 'Quarantine • PPE required'),
        _FlagPill(
            icon: Icons.emoji_food_beverage,
            color: Colors.blue,
            text: 'Special diet'),
      ],
    );
  }
}

class _FlagPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _FlagPill(
      {required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(text),
      ]),
    );
  }
}

class _TipsAccordion extends StatelessWidget {
  const _TipsAccordion();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TipsTile(
          title: 'Cleaning',
          bullets: [
            'Sweep before disinfectant',
            'Let surfaces dry fully',
            'Separate tools for quarantine',
          ],
        ),
        _TipsTile(
          title: 'Feeding',
          bullets: [
            'Follow whiteboard portions',
            'Fresh water every shift',
            'Log special diets',
          ],
        ),
        _TipsTile(
          title: 'Safety',
          bullets: [
            'One dog per gate at a time',
            'Two points of contact on leash',
            'Ask for help with red tags',
          ],
        ),
      ],
    );
  }
}

class _TipsTile extends StatelessWidget {
  final String title;
  final List<String> bullets;
  const _TipsTile({required this.title, required this.bullets});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(title),
        children: bullets
            .map((b) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.arrow_right),
                  title: Text(b),
                ))
            .toList(),
      ),
    );
  }
}

class _ContactsList extends StatelessWidget {
  const _ContactsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ContactTile(name: 'Volunteer Coordinator', phone: '+351 900 000 001'),
        _ContactTile(name: 'Vet (on call)', phone: '+351 900 000 002'),
        _ContactTile(name: 'Emergency', phone: '112'),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String name;
  final String phone;
  const _ContactTile({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.phone),
        title: Text(name),
        subtitle: Text(phone),
        trailing: const Icon(Icons.chevron_right),
        // TODO: hook up with url_launcher to dial/WhatsApp if you add that dependency.
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call $phone (connect with url_launcher)')),
        ),
      ),
    );
  }
}
