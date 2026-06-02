import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_client.dart';
import '../../services/api_config.dart';
import '../../services/auth_store.dart';
import '../../services/information_service.dart';
import '../../services/optimistic_mutation_runner.dart';
import '../../services/optimistic_sync_store.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/expandable_section_group.dart';
import '../../widgets/info_section_list.dart';
import '../../widgets/info_tile_card.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/staff_action_sheet.dart';

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

enum _InformationStaffMode { none, edit, hide, delete }

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
  _InformationStaffMode _staffMode = _InformationStaffMode.none;
  late final OptimisticMutationRunner _mutationRunner;

  @override
  void initState() {
    super.initState();
    _mutationRunner = OptimisticMutationRunner(
      context.read<OptimisticSyncStore>(),
    );
    _loadCards();
  }

  @override
  void dispose() {
    _mutationRunner.dispose();
    super.dispose();
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

    final snapshot = _cards.map((card) => card.copy()).toList(growable: false);
    final payload = _cards.map((card) => card.toJson()).toList(growable: false);
    _mutationRunner.run(
      key: 'information_cards',
      applyOptimistic: () {},
      sync: () => _informationService.saveDocument(
        'cards',
        payload,
        token: token,
      ),
      revertOptimistic: () {
        if (!mounted) return;
        setState(() {
          _cards = snapshot.map((card) => card.copy()).toList();
        });
      },
      onPermanentFailure: (error) {
        if (!mounted) return;
        final message = error is ApiException
            ? error.message
            : 'Could not save information.';
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final isStaff = auth.isStaff;
    final visibleCards = _cards.where((card) => !card.deleted && !card.hidden).toList();
    final hiddenCards = _cards.where((card) => !card.deleted && card.hidden).toList();

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
                                final inlineEdit = isStaff && _staffMode == _InformationStaffMode.edit;
                                final inlineHide = isStaff && _staffMode == _InformationStaffMode.hide;
                                final inlineDelete = isStaff && _staffMode == _InformationStaffMode.delete;
                                final canDelete = _canDeleteCard(card);
                                return InfoTileCard(
                                  title: card.title,
                                  subtitle: card.subtitle,
                                  backgroundGradient:
                                      _sectionGradient(card.iconColor),
                                  textColor: ARAColors.cardBg,
                                  showArrow: _staffMode == _InformationStaffMode.none,
                                  backgroundIcon: card.icon,
                                  backgroundIconColor: ARAColors.cardBg,
                                  backgroundIconSize: isTopRow ? 112 : 106,
                                  backgroundIconOpacity: 0.14,
                                  backgroundIconRight: isTopRow ? -12 : -8,
                                  backgroundIconTop: isTopRow ? -14 : -6,
                                  backgroundIconAngle: isTopRow ? 0.05 : -0.04,
                                  pinTitleToBottom: true,
                                  actionIcon: inlineHide
                                      ? Icons.visibility_off_outlined
                                      : (inlineDelete && canDelete
                                          ? Icons.delete_outline
                                          : (inlineEdit ? Icons.edit_outlined : null)),
                                  actionTooltip: inlineHide
                                      ? 'Hide card'
                                      : (inlineDelete && canDelete
                                          ? 'Delete card'
                                          : (inlineEdit ? 'Edit card' : null)),
                                  actionColor: inlineDelete && canDelete
                                      ? ARAColors.danger
                                      : ARAColors.ink,
                                  onActionPressed: inlineHide
                                      ? () => _hideCard(card)
                                      : (inlineDelete && canDelete
                                          ? () => _deleteCard(card)
                                          : (inlineEdit ? () => _editCard(card) : null)),
                                  onTap: () => _handleCardTap(card, isStaff: isStaff),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        if (isStaff && hiddenCards.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 460),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'HIDDEN CARDS',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: ARAColors.subInk,
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 1.28,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: hiddenCards.map((card) {
                                      return InfoTileCard(
                                        title: card.title,
                                        subtitle: 'Hidden from volunteers',
                                        backgroundColor: ARAColors.cardBg,
                                        textColor: ARAColors.ink,
                                        backgroundIcon: card.icon,
                                        backgroundIconColor: card.iconColor.withValues(alpha: 0.45),
                                        backgroundIconOpacity: 0.16,
                                        backgroundIconSize: 106,
                                        backgroundIconRight: -8,
                                        backgroundIconTop: -6,
                                        pinTitleToBottom: true,
                                        actionIcon: Icons.visibility_outlined,
                                        actionTooltip: 'Unhide card',
                                        actionColor: ARAColors.ink,
                                        onActionPressed: () => _unhideCard(card),
                                        onTap: () => _openCard(card, isStaff: isStaff),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openHomeActionsSheet() async {
    final hasCards = _cards.where((card) => !card.deleted).isNotEmpty;
    final items = <StaffActionSheetItem>[
      StaffActionSheetItem(
        label: 'Add card',
        icon: Icons.add,
        onTap: _addCard,
      ),
      if (hasCards)
        StaffActionSheetItem(
          label: _staffMode == _InformationStaffMode.edit
              ? 'Stop editing cards'
              : 'Edit cards',
          icon: _staffMode == _InformationStaffMode.edit
              ? Icons.close
              : Icons.edit_outlined,
          onTap: () async {
            _setStaffMode(_InformationStaffMode.edit);
          },
        ),
      if (hasCards)
        StaffActionSheetItem(
          label: _staffMode == _InformationStaffMode.hide
              ? 'Stop hiding cards'
              : 'Hide cards',
          icon: _staffMode == _InformationStaffMode.hide
              ? Icons.close
              : Icons.visibility_off_outlined,
          onTap: () async {
            _setStaffMode(_InformationStaffMode.hide);
          },
        ),
      if (hasCards)
        StaffActionSheetItem(
          label: _staffMode == _InformationStaffMode.delete
              ? 'Stop deleting cards'
              : 'Delete cards',
          icon: _staffMode == _InformationStaffMode.delete
              ? Icons.close
              : Icons.delete_outline,
          color: _staffMode == _InformationStaffMode.delete
              ? null
              : ARAColors.danger,
          onTap: () async {
            _setStaffMode(_InformationStaffMode.delete);
          },
        ),
    ];

    await showStaffActionSheet(
      context,
      items: items,
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

  bool _canDeleteCard(_InformationCardModel card) {
    return !card.isShelterMap;
  }

  Future<void> _hideCard(_InformationCardModel card) async {
    if (!mounted) return;
    setState(() {
      card.hidden = true;
    });
    await _saveCardsToBackend();
  }

  Future<void> _unhideCard(_InformationCardModel card) async {
    if (!mounted) return;
    setState(() {
      card.hidden = false;
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

  void _setStaffMode(_InformationStaffMode mode) {
    if (!mounted) return;
    setState(() {
      _staffMode = _staffMode == mode ? _InformationStaffMode.none : mode;
    });
  }

  Future<void> _handleCardTap(
    _InformationCardModel card, {
    required bool isStaff,
  }) async {
    switch (_staffMode) {
      case _InformationStaffMode.edit:
        if (!isStaff) return;
        await _editCard(card);
        return;
      case _InformationStaffMode.hide:
        if (!isStaff) return;
        await _hideCard(card);
        return;
      case _InformationStaffMode.delete:
        if (!isStaff) return;
        if (!_canDeleteCard(card)) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            const SnackBar(content: Text('Shelter map can be hidden, but not deleted.')),
          );
          return;
        }
        await _deleteCard(card);
        return;
      case _InformationStaffMode.none:
        await _openCard(card, isStaff: isStaff);
        return;
    }
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
            card: card,
            isStaff: isStaff,
            editorController: editorController,
            child: content,
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













