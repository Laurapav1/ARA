import 'package:flutter/material.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/info_tile_card.dart';
import '../../widgets/screen_header.dart';
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
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.42,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _InfoSection.values.map((section) {
                          return InfoTileCard(
                            title: section.label,
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: section.iconTint,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                section.icon,
                                size: 30,
                                color: section.iconColor,
                              ),
                            ),
                            titleTopGap: 8,
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

class _CleaningStandardBlock extends StatelessWidget {
  const _CleaningStandardBlock();

  @override
  Widget build(BuildContext context) {
    return const _NumberedList(items: _cleaningStandardSteps);
  }
}

class _CleaningPanelBody extends StatelessWidget {
  final List<String> doItems;
  final List<String> doNotItems;
  final List<String> doneWhenItems;

  const _CleaningPanelBody({
    required this.doItems,
    required this.doNotItems,
    required this.doneWhenItems,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MinorSectionTitle('How to clean correctly'),
          _PlainBulletList(items: doItems),
          const SizedBox(height: 8),
          const _MinorSectionTitle('Do not forget'),
          _PlainBulletList(items: doNotItems),
          const SizedBox(height: 8),
          const _MinorSectionTitle('Done when'),
          _PlainBulletList(items: doneWhenItems),
        ],
      ),
    );
  }
}

class _MinorSectionTitle extends StatelessWidget {
  final String text;

  const _MinorSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: ARAColors.inkStrong,
          fontWeight: FontWeight.w700,
        ),
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




