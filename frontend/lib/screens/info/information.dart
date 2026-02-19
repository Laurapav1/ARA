import 'package:flutter/material.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/info_tile_card.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/expandable_section.dart';
import '../../widgets/expandable_section_group.dart';
import '../../widgets/info_section_list.dart';
part 'information_content.dart';
part 'sections/info_section_enum.dart';
part 'sections/overview_tab.dart';
part 'sections/cleaning_tab.dart';
part 'sections/safety_tab.dart';
part 'sections/checklist_tab.dart';
part 'widgets/cleaning_panel_body.dart';
part 'widgets/overview_map_content.dart';
part 'widgets/shelter_map_panel.dart';

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
