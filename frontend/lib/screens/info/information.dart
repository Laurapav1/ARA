import 'package:flutter/material.dart';
import '../../widgets/offline_banner.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showZoneGuide(BuildContext context, String zone) async {
    final tasks = _zoneGuides[zone] ?? const <String>[];
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D9596).withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.map, color: Color(0xFF2D9596)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Guide • $zone',
                          style: Theme.of(ctx).textTheme.titleLarge),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (_, i) => ListTile(
                      dense: true,
                      leading:
                          const Icon(Icons.task_alt, color: Color(0xFF265073)),
                      title: Text(tasks[i]),
                    ),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: tasks.length,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showChecklist(
      BuildContext context, String title, List<String> items) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF265073).withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.checklist_rtl,
                          color: Color(0xFF265073)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(title,
                          style: Theme.of(ctx).textTheme.titleLarge),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (_, i) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle_outline,
                          color: Color(0xFF2D9596)),
                      title: Text(items[i]),
                    ),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: items.length,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2D9596).withOpacity(0.08),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              // Hero header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: FadeTransition(
                  opacity: _fade,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF265073),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.info,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Information Hub',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF265073),
                              ),
                            ),
                            Text(
                              'Maps • Guides • Safety • Contacts',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: SlideTransition(
                  position: _slide,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    children: [
                      _SectionHeader(
                        title: 'Shelter Map',
                        trailing: Text('Pinch to zoom',
                            style: Theme.of(context).textTheme.labelSmall),
                      ),
                      const SizedBox(height: 12),
                      _MapCard(
                        onZoneTap: (z) => _showZoneGuide(context, z),
                      ),
                      const SizedBox(height: 24),
                      const _SectionHeader(title: 'Zones'),
                      const SizedBox(height: 12),
                      _ZoneChips(
                        zones: _zoneGuides.keys.toList(),
                        onTap: (z) => _showZoneGuide(context, z),
                      ),
                      const SizedBox(height: 28),
                      const _SectionHeader(title: 'Quick Actions'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _QuickActionCard(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                            ),
                            icon: Icons.checklist_rtl,
                            title: 'First-day checklist',
                            subtitle: 'Start here on day one',
                            onTap: () => _showChecklist(context,
                                'First-day checklist', _firstDayChecklist),
                          ),
                          _QuickActionCard(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
                            ),
                            icon: Icons.done_all,
                            title: 'End-of-shift',
                            subtitle: 'Make sure nothing is missed',
                            onTap: () => _showChecklist(context,
                                'End-of-shift checklist', _endOfShiftChecklist),
                          ),
                          _QuickActionCard(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEC407A), Color(0xFFC2185B)],
                            ),
                            icon: Icons.report_gmailerrorred,
                            title: 'Incident steps',
                            subtitle: 'What to do immediately',
                            onTap: () => _showChecklist(
                                context, 'Incident procedure', _incidentSteps),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const _SectionHeader(title: 'Safety Flags'),
                      const SizedBox(height: 12),
                      const _SafetyFlags(),
                      const SizedBox(height: 28),
                      const _SectionHeader(title: 'Tips & How-tos'),
                      const SizedBox(height: 12),
                      const _TipsAccordion(),
                      const SizedBox(height: 28),
                      const _SectionHeader(title: 'Contacts'),
                      const SizedBox(height: 12),
                      const _ContactsList(),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Last updated just now',
                          style: TextStyle(
                            color: scheme.outline,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
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

/* ---------- Data (you can swap for your mock DB) ---------- */

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
        Expanded(
          child: Text(
            title,
            style: text?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF265073),
            ),
          ),
        ),
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
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D9596), Color(0xFF265073)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D9596).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Map placeholder (swap with Image.asset if you add a real map)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.08),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Shelter map (pinch to zoom)',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(24),
                minScale: 1,
                maxScale: 4,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Quick zone pills overlay
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final z in _zoneGuides.keys)
                      ActionChip(
                        backgroundColor: Colors.white.withOpacity(.9),
                        label: Text(z),
                        avatar: const Icon(Icons.place, size: 18),
                        onPressed: () => onZoneTap(z),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
      spacing: 10,
      runSpacing: 10,
      children: zones
          .map(
            (z) => Chip(
              backgroundColor: const Color(0xFF2D9596).withOpacity(.08),
              side: BorderSide(color: const Color(0xFF2D9596).withOpacity(.35)),
              avatar: const Icon(Icons.map, size: 18, color: Color(0xFF2D9596)),
              label: Text(z, style: const TextStyle(color: Color(0xFF265073))),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onDeleted: null,
              // Use GestureDetector to make the Chip tappable like ActionChip
            ),
          )
          .toList(),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1),
        width: 320,
        height: 120,
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.colors.first.withOpacity(0.28),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                widget.icon,
                size: 120,
                color: Colors.white.withOpacity(.18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.28),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            )),
                        const SizedBox(height: 4),
                        Text(widget.subtitle,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(.92),
                            )),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
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
      elevation: 0,
      child: ExpansionTile(
        title: Text(title,
            style: const TextStyle(
              color: Color(0xFF265073),
              fontWeight: FontWeight.w700,
            )),
        children: bullets
            .map((b) => ListTile(
                  dense: true,
                  leading:
                      const Icon(Icons.arrow_right, color: Color(0xFF2D9596)),
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
      elevation: 0,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2D9596),
          child: Icon(Icons.phone, color: Colors.white),
        ),
        title: Text(name,
            style: const TextStyle(
              color: Color(0xFF265073),
              fontWeight: FontWeight.w700,
            )),
        subtitle: Text(phone),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call $phone (hook up url_launcher later)')),
        ),
      ),
    );
  }
}
