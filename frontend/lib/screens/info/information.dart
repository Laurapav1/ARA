import 'package:flutter/material.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/info_tile_card.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/expandable_section.dart';
import '../../widgets/expandable_section_group.dart';
part 'information_content.dart';
part 'sections/info_section_enum.dart';
part 'sections/overview_tab.dart';
part 'sections/cleaning_tab.dart';
part 'sections/safety_tab.dart';
part 'sections/checklist_tab.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final Set<String> _checkedItems = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ARAColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            const ScreenHeader(
              title: 'Information',
              subtitle: 'Everything you need to know',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.28,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children:
                            _InfoSection.values.asMap().entries.map((entry) {
                          final index = entry.key;
                          final section = entry.value;
                          final isTopRow = index < 2;
                          return InfoTileCard(
                            title: section.label,
                            subtitle: section.subtitle,
                            backgroundGradient: _sectionGradient(section),
                            textColor: ARAColors.cardBg,
                            showArrow: true,
                            backgroundIcon: section.icon,
                            backgroundIconColor: ARAColors.cardBg,
                            backgroundIconSize: isTopRow ? 112 : 106,
                            backgroundIconOpacity: 0.14,
                            backgroundIconRight: isTopRow ? -12 : -8,
                            backgroundIconTop: isTopRow ? -14 : -6,
                            backgroundIconAngle: isTopRow ? 0.05 : -0.04,
                            pinTitleToBottom: true,
                            onTap: () => _openSection(section),
                          );
                        }).toList(),
                      ),
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

  void _openSection(_InfoSection section) {
    final content = switch (section) {
      _InfoSection.overview => const _OverviewTab(),
      _InfoSection.cleaning => const _CleaningTab(),
      _InfoSection.safety => const _SafetyTab(),
      _InfoSection.checklist => _ChecklistTab(
          checkedItems: _checkedItems,
          onToggle: _onToggleItem,
          onReset: _onResetChecklist,
        ),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _InformationSectionScreen(
          title: section.label,
          child: content,
        ),
      ),
    );
  }

  void _onToggleItem(String key, bool checked) {
    setState(() {
      if (checked) {
        _checkedItems.add(key);
      } else {
        _checkedItems.remove(key);
      }
    });
  }

  void _onResetChecklist() {
    setState(_checkedItems.clear);
  }

  Gradient _sectionGradient(_InfoSection section) {
    final start = Color.lerp(section.iconColor, Colors.white, 0.24)!;
    final end = Color.lerp(section.iconColor, Colors.black, 0.08)!;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [start, end],
    );
  }
}

class _InformationSectionScreen extends StatelessWidget {
  final String title;
  final Widget child;

  const _InformationSectionScreen({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ARAColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: ARAColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ARAColors.inkStrong,
                ),
              ),
            if (title.isNotEmpty) const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _CleaningPanelBody extends StatefulWidget {
  final List<String> doItems;
  final List<String> doNotItems;
  final List<String> doneWhenItems;

  const _CleaningPanelBody({
    required this.doItems,
    required this.doNotItems,
    required this.doneWhenItems,
  });

  @override
  State<_CleaningPanelBody> createState() => _CleaningPanelBodyState();
}

class _CleaningPanelBodyState extends State<_CleaningPanelBody> {
  String _expandedId = 'do';

  void _setExpanded(String id, bool expanded) {
    setState(() => _expandedId = expanded ? id : '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpandableSection(
          title: 'How to clean correctly',
          isExpanded: _expandedId == 'do',
          onChanged: (expanded) => _setExpanded('do', expanded),
          child: _PlainBulletList(items: widget.doItems),
        ),
        const SizedBox(height: 8),
        ExpandableSection(
          title: 'Do not forget',
          isExpanded: _expandedId == 'do_not',
          onChanged: (expanded) => _setExpanded('do_not', expanded),
          child: _PlainBulletList(items: widget.doNotItems),
        ),
        const SizedBox(height: 8),
        ExpandableSection(
          title: 'Done when',
          isExpanded: _expandedId == 'done',
          onChanged: (expanded) => _setExpanded('done', expanded),
          child: _PlainBulletList(items: widget.doneWhenItems),
        ),
      ],
    );
  }
}

class _OverviewMapContent extends StatelessWidget {
  final List<String> zones;
  final String selectedArea;
  final ValueChanged<String> onAreaSelected;
  final String Function(String area) areaSummary;

  const _OverviewMapContent({
    required this.zones,
    required this.selectedArea,
    required this.onAreaSelected,
    required this.areaSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tap a zone to see a short description.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _ShelterMapPanel(
          selectedArea: selectedArea,
          onAreaSelected: onAreaSelected,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: zones.map((zone) {
              final selected = zone == selectedArea;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  onPressed: () => onAreaSelected(zone),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: selected
                        ? ARAColors.brand.withValues(alpha: 0.20)
                        : ARAColors.cardBg,
                    side: BorderSide(
                      color:
                          selected ? ARAColors.brandDark : ARAColors.surfaceWarmTint,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    minimumSize: const Size(0, 38),
                  ),
                  child: Text(
                    zone,
                    style: TextStyle(
                      color: selected ? ARAColors.inkStrong : ARAColors.subInk,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ARAColors.surfaceWarmSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ARAColors.surfaceWarmTint),
          ),
          child: Text(
            areaSummary(selectedArea),
            style: const TextStyle(color: ARAColors.ink),
          ),
        ),
      ],
    );
  }
}

class _ChecklistProgressCard extends StatelessWidget {
  final int done;
  final int total;
  final VoidCallback onReset;

  const _ChecklistProgressCard({
    required this.done,
    required this.total,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Checklist progress',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: total == 0 ? 0 : done / total,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: ARAColors.surfaceWarmTint,
            color: ARAColors.brandDark,
            minHeight: 10,
          ),
          const SizedBox(height: 8),
          Text('$done of $total completed'),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.replay),
            label: const Text('Reset checks'),
          ),
        ],
      ),
    );
  }
}

class _ShelterMapPanel extends StatelessWidget {
  final String selectedArea;
  final ValueChanged<String> onAreaSelected;

  const _ShelterMapPanel({
    required this.selectedArea,
    required this.onAreaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: DecoratedBox(
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
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 2.8,
            boundaryMargin: const EdgeInsets.all(60),
            child: SizedBox(
              width: 540,
              height: 340,
              child: Stack(
                children: [
                  const _MapParkBlob(
                      left: 26, top: 192, width: 160, height: 98),
                  const _MapParkBlob(
                      left: 382, top: 220, width: 136, height: 86),
                  _MapRoad(
                    left: 80,
                    top: 56,
                    width: 380,
                    angle: 0.10,
                  ),
                  _MapRoad(
                    left: 74,
                    top: 208,
                    width: 318,
                    angle: -0.18,
                  ),
                  ..._mapSpots.map(
                    (spot) => _MapPin(
                      left: spot.left,
                      top: spot.top,
                      label: spot.label,
                      selected: selectedArea == spot.label,
                      onTap: () => onAreaSelected(spot.label),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapRoad extends StatelessWidget {
  final double left;
  final double top;
  final double width;
  final double angle;

  const _MapRoad({
    required this.left,
    required this.top,
    required this.width,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: 6,
          decoration: BoxDecoration(
            color: ARAColors.surfaceWarmTint,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
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
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: selected ? 1.08 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: selected ? 1 : 0,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 26 : 20,
                  height: selected ? 26 : 20,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapParkBlob extends StatelessWidget {
  final double left;
  final double top;
  final double width;
  final double height;

  const _MapParkBlob({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ARAColors.surfaceWarmTint.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;

  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: ARAColors.brand,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(color: ARAColors.ink),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PlainBulletList extends StatelessWidget {
  final List<String> items;

  const _PlainBulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text('•', style: TextStyle(color: ARAColors.brand)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(color: ARAColors.ink),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _NumberedList extends StatelessWidget {
  final List<String> items;

  const _NumberedList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ARAColors.brand.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ARAColors.inkStrong,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  items[i],
                  style: const TextStyle(color: ARAColors.ink),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _InteractiveChecklist extends StatelessWidget {
  final String prefix;
  final List<String> items;
  final Set<String> checkedItems;
  final void Function(String key, bool checked) onToggle;

  const _InteractiveChecklist({
    required this.prefix,
    required this.items,
    required this.checkedItems,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (i) {
        final key = '$prefix-$i';
        final checked = checkedItems.contains(key);
        return CheckboxListTile(
          value: checked,
          onChanged: (value) => onToggle(key, value ?? false),
          contentPadding: EdgeInsets.zero,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(items[i]),
        );
      }),
    );
  }
}
