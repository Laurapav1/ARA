import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_client.dart';
import '../../services/api_config.dart';
import '../../services/auth_store.dart';
import '../../services/information_service.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/expandable_section_group.dart';
import '../../widgets/info_section_list.dart';
import '../../widgets/info_tile_card.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/screen_header.dart';

part 'information_content.dart';
part 'sections/info_section_enum.dart';
part 'sections/overview_tab.dart';
part 'sections/cleaning_tab.dart';
part 'sections/safety_tab.dart';
part 'sections/before_you_arrive_tab.dart';
part 'sections/first_day_tab.dart';
part 'sections/living_info_tab.dart';
part 'widgets/cleaning_panel_body.dart';
part 'widgets/overview_map_content.dart';
part 'widgets/shelter_map_panel.dart';
part 'widgets/editable_info_sections.dart';
part 'widgets/info_card_dialogs.dart';
part 'widgets/info_card_screens.dart';
part 'widgets/material_icon_catalog.dart';

final InformationService _informationService =
    InformationService(ApiClient(ApiConfig.baseUrl));

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  static const String _defaultHeaderTitle = 'Information';
  static const String _defaultHeaderSubtitle = 'Everything you need to know';

  List<_InformationCardModel> _cards = const [];
  String _headerTitle = _defaultHeaderTitle;
  String _headerSubtitle = _defaultHeaderSubtitle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final defaults = _InfoSection.values
        .map(
          (section) => _InformationCardModel(
            id: section.name,
            title: section.label,
            subtitle: section.subtitle,
            icon: section.icon,
            iconColor: section.iconColor,
            section: section,
          ),
        )
        .toList();

    try {
      final auth = context.read<AuthStore>();
      final headerData = await _informationService.getDocument(
        'screen_header',
        token: auth.accessToken,
      );
      if (headerData is Map<String, dynamic>) {
        _headerTitle =
            headerData['title']?.toString() ?? _defaultHeaderTitle;
        _headerSubtitle =
            headerData['subtitle']?.toString() ?? _defaultHeaderSubtitle;
      }

      final data = await _informationService.getDocument(
        'cards',
        token: auth.accessToken,
      );

      final loaded = <_InformationCardModel>[];
      if (data is List) {
        for (final row in data) {
          final card = _InformationCardModel.fromJson(row);
          if (card != null) loaded.add(card);
        }
      }

      _cards = loaded.isEmpty ? defaults : loaded;
    } catch (_) {
      _cards = defaults;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _saveCardsToBackend() async {
    final auth = context.read<AuthStore>();
    final token = auth.accessToken;
    if (!auth.isStaff || token == null || token.isEmpty) return;
    await _informationService.saveDocument(
      'cards',
      _cards.map((card) => card.toJson()).toList(growable: false),
      token: token,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final isStaff = auth.isStaff;
    final visibleCards = _cards.where((card) => !card.deleted).toList();

    return Scaffold(
      backgroundColor: ARAColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            ScreenHeader(
              title: _headerTitle,
              subtitle: _headerSubtitle,
              trailing: isStaff
                  ? IconButton(
                      onPressed: _openHomeActionsSheet,
                      icon: const Icon(Icons.more_vert),
                      tooltip: 'Information actions',
                    )
                  : null,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
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
                              children: visibleCards.asMap().entries.map((entry) {
                                final index = entry.key;
                                final card = entry.value;
                                final isTopRow = index < 2;
                                return InfoTileCard(
                                  title: card.title,
                                  subtitle: card.subtitle,
                                  backgroundGradient:
                                      _sectionGradient(card.iconColor),
                                  textColor: ARAColors.cardBg,
                                  showArrow: true,
                                  backgroundIcon: card.icon,
                                  backgroundIconColor: ARAColors.cardBg,
                                  backgroundIconSize: isTopRow ? 112 : 106,
                                  backgroundIconOpacity: 0.14,
                                  backgroundIconRight: isTopRow ? -12 : -8,
                                  backgroundIconTop: isTopRow ? -14 : -6,
                                  backgroundIconAngle: isTopRow ? 0.05 : -0.04,
                                  pinTitleToBottom: true,
                                  onTap: () => _openCard(card, isStaff: isStaff),
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

  Future<void> _openHomeActionsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add card'),
              onTap: () async {
                Navigator.pop(ctx);
                if (!mounted) return;
                await _addCard();
              },
            ),
            if (_cards.where((card) => !card.deleted).isNotEmpty)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit card'),
                onTap: () async {
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  await _openCardSelectionSheet(
                    title: 'Edit card',
                    onSelected: _editCard,
                  );
                },
              ),
            if (_cards.where((card) => !card.deleted).isNotEmpty)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: ARAColors.danger),
                title: const Text(
                  'Delete card',
                  style: TextStyle(color: ARAColors.danger),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  await _openCardSelectionSheet(
                    title: 'Delete card',
                    onSelected: _deleteCard,
                    destructive: true,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCard() async {
    final result = await _showCardEditorDialog(
      context: context,
      title: 'Add information card',
      initialIcon: Icons.description_outlined,
      initialIconColor: ARAColors.infoSectionOverviewIcon,
    );
    if (!mounted) return;
    if (result == null) return;

    setState(() {
      _cards.add(
        _InformationCardModel(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          title: result.title,
          subtitle: result.subtitle,
          icon: result.icon,
          iconColor: result.iconColor,
        ),
      );
    });

    await _saveCardsToBackend();
  }

  Future<void> _editCard(_InformationCardModel card) async {
    final result = await _showCardEditorDialog(
      context: context,
      title: 'Edit information card',
      initialTitle: card.title,
      initialSubtitle: card.subtitle,
      initialIcon: card.icon,
      initialIconColor: card.iconColor,
    );
    if (!mounted || result == null) return;

    setState(() {
      card.title = result.title;
      card.subtitle = result.subtitle;
      card.icon = result.icon;
      card.iconColor = result.iconColor;
    });

    await _saveCardsToBackend();
  }

  Future<void> _deleteCard(_InformationCardModel card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete card'),
        content: Text('Delete "${card.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: ARAColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    setState(() {
      card.deleted = true;
      _cards.removeWhere((existing) => existing.deleted);
    });

    await _saveCardsToBackend();
  }

  Future<void> _openCardSelectionSheet({
    required String title,
    required Future<void> Function(_InformationCardModel card) onSelected,
    bool destructive = false,
  }) async {
    final visibleCards = _cards.where((card) => !card.deleted).toList();
    if (visibleCards.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ARAColors.inkStrong,
                  ),
                ),
              ),
            ),
            ...visibleCards.map((card) {
              return ListTile(
                leading: Icon(
                  destructive ? Icons.delete_outline : card.icon,
                  color: destructive ? ARAColors.danger : null,
                ),
                title: Text(
                  card.title,
                  style: TextStyle(
                    color: destructive ? ARAColors.danger : ARAColors.inkStrong,
                  ),
                ),
                subtitle: card.subtitle.isEmpty ? null : Text(card.subtitle),
                onTap: () async {
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  await onSelected(card);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _openCard(
    _InformationCardModel card, {
    required bool isStaff,
  }) async {
    if (card.section != null) {
      final section = card.section!;
      final editorController = _EditableInfoSectionsController();
      final content = switch (section) {
        _InfoSection.shelterMap =>
          _OverviewTab(editorController: editorController),
        _InfoSection.cleaning => const _CleaningTab(),
        _InfoSection.safety =>
          _SafetyTab(editorController: editorController),
        _InfoSection.beforeYouArrive =>
          _BeforeYouArriveTab(editorController: editorController),
        _InfoSection.firstDay =>
          _FirstDayTab(editorController: editorController),
        _InfoSection.livingInfo =>
          _LivingInfoTab(editorController: editorController),
      };

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _InformationSectionScreen(
            title: card.title,
            child: content,
            card: card,
            isStaff: isStaff,
            editorController: editorController,
          ),
        ),
      );

      if (!mounted) return;
      setState(() {
        _cards.removeWhere((existing) => existing.deleted);
      });
      await _saveCardsToBackend();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _InformationCardScreen(
          card: card,
          isStaff: isStaff,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {
      _cards.removeWhere((existing) => existing.deleted);
    });
    await _saveCardsToBackend();
  }

  Gradient _sectionGradient(Color iconColor) {
    final start = Color.lerp(iconColor, Colors.white, 0.24)!;
    final end = Color.lerp(iconColor, Colors.black, 0.08)!;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [start, end],
    );
  }
}
