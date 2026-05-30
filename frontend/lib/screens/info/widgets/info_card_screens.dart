part of '../information.dart';

class _InformationCardModel {
  final String id;
  IconData icon;
  Color iconColor;
  final _InfoSection? section;

  String title;
  String subtitle;
  final List<String> infoItems;
  final List<_EditableInfoSectionModel> sections;
  InfoSectionListStyle listStyle;
  bool hidden;
  bool deleted;

  bool get isShelterMap => section == _InfoSection.shelterMap;

  _InformationCardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.section,
    List<String>? infoItems,
    List<_EditableInfoSectionModel>? sections,
    this.listStyle = InfoSectionListStyle.bullet,
    this.hidden = false,
    this.deleted = false,
  }) : infoItems = infoItems ?? <String>[],
       sections = sections?.map((section) => section.copy()).toList() ?? <_EditableInfoSectionModel>[];

  _InformationCardModel copy() {
    return _InformationCardModel(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      section: section,
      infoItems: List<String>.from(infoItems),
      sections: sections.map((section) => section.copy()).toList(),
      listStyle: listStyle,
      hidden: hidden,
      deleted: deleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'icon': {
        'codePoint': icon.codePoint,
        'fontFamily': icon.fontFamily,
        'fontPackage': icon.fontPackage,
        'matchTextDirection': icon.matchTextDirection,
      },
      'iconColor': iconColor.toARGB32(),
      'section': section?.name,
      'infoItems': List<String>.from(infoItems),
      'sections': sections.map((section) => section.toJson()).toList(growable: false),
      'listStyle': listStyle.name,
      'hidden': hidden,
      'deleted': deleted,
    };
  }

  static _InformationCardModel? fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final iconMap = raw['icon'];
    if (iconMap is! Map<String, dynamic>) return null;
    final codePoint = iconMap['codePoint'];
    if (codePoint is! int) return null;

    final icon = _iconFromJson(iconMap);

    return _InformationCardModel(
      id: raw['id']?.toString() ?? '',
      title: raw['title']?.toString() ?? '',
      subtitle: raw['subtitle']?.toString() ?? '',
      icon: icon,
      iconColor: Color(raw['iconColor'] is int
          ? raw['iconColor'] as int
          : ARAColors.brand.toARGB32()),
      section: _sectionFromName(raw['section']?.toString()),
      infoItems: (raw['infoItems'] is List)
          ? (raw['infoItems'] as List)
                .map((item) => item.toString())
                .toList(growable: false)
          : const [],
      sections: _sectionsFromJson(raw['sections']),
      listStyle: _listStyleFromName(raw['listStyle']?.toString()),
      hidden: raw['hidden'] == true,
      deleted: raw['deleted'] == true,
    );
  }

  static IconData _iconFromJson(Map<String, dynamic> iconMap) {
    final codePoint = iconMap['codePoint'];
    if (codePoint is! int) return Icons.description_outlined;

    final fontFamily = iconMap['fontFamily']?.toString();
    final fontPackage = iconMap['fontPackage']?.toString();
    final matchTextDirection = iconMap['matchTextDirection'] == true;

    for (final option in _cardIconOptions) {
      final icon = option.icon;
      if (icon.codePoint == codePoint &&
          icon.fontFamily == fontFamily &&
          icon.fontPackage == fontPackage &&
          icon.matchTextDirection == matchTextDirection) {
        return icon;
      }
    }

    return Icons.description_outlined;
  }

  static List<_EditableInfoSectionModel> _sectionsFromJson(dynamic raw) {
    if (raw is! List) return <_EditableInfoSectionModel>[];
    final sections = <_EditableInfoSectionModel>[];
    for (final row in raw) {
      final section = _EditableInfoSectionModel.fromJson(row);
      if (section != null) sections.add(section);
    }
    return sections;
  }

  static InfoSectionListStyle _listStyleFromName(String? name) {
    if (name == InfoSectionListStyle.numbered.name) {
      return InfoSectionListStyle.numbered;
    }
    return InfoSectionListStyle.bullet;
  }

  static _InfoSection? _sectionFromName(String? name) {
    if (name == null || name.isEmpty) return null;
    for (final section in _InfoSection.values) {
      if (section.name == name) return section;
    }
    return null;
  }
}

class _InformationCardScreen extends StatefulWidget {
  final _InformationCardModel card;
  final bool isStaff;

  const _InformationCardScreen({
    required this.card,
    required this.isStaff,
  });

  @override
  State<_InformationCardScreen> createState() => _InformationCardScreenState();
}

class _InformationCardScreenState extends State<_InformationCardScreen> {
  late final List<_EditableInfoSectionModel> _sections;
  late final List<_EditableInfoSectionModel> _savedSections;
  bool _isEditingInformation = false;

  @override
  void initState() {
    super.initState();
    _sections = _buildInitialSections();
    _savedSections = _sections.map((section) => section.copy()).toList();
  }

  List<_EditableInfoSectionModel> _buildInitialSections() {
    if (widget.card.sections.isNotEmpty) {
      return widget.card.sections.map((section) => section.copy()).toList();
    }

    if (widget.card.infoItems.isNotEmpty) {
      return [
        _EditableInfoSectionModel(
          id: 'information',
          title: 'Information',
          style: widget.card.listStyle,
          items: widget.card.infoItems,
        ),
      ];
    }

    return <_EditableInfoSectionModel>[];
  }

  Future<void> _addSection() async {
    final title = await _showSectionTitleDialog(title: 'Add section');
    if (!mounted || title == null) return;
    setState(() {
      _sections.add(
        _EditableInfoSectionModel(
          id: 'section_',
          title: title,
          style: InfoSectionListStyle.bullet,
          items: const [],
        ),
      );
    });
  }

  Future<void> _editSectionTitle(_EditableInfoSectionModel section) async {
    final title = await _showSectionTitleDialog(
      title: 'Edit section',
      initialValue: section.title,
    );
    if (!mounted || title == null) return;
    setState(() {
      section.title = title;
    });
  }

  Future<void> _deleteSection(_EditableInfoSectionModel section) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete section'),
            content: Text('Delete ""?'),
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
        ) ??
        false;
    if (!mounted || !confirmed) return;
    setState(() {
      _sections.remove(section);
    });
  }

  Future<void> _addBullet(_EditableInfoSectionModel section) async {
    final value = await _showInformationItemDialog(context: context);
    if (!mounted || value == null) return;
    setState(() {
      section.items.add(value);
    });
  }

  Future<void> _editBullet(_EditableInfoSectionModel section, int index) async {
    final value = await _showInformationItemDialog(
      context: context,
      initialValue: section.items[index],
    );
    if (!mounted || value == null) return;
    setState(() {
      section.items[index] = value;
    });
  }

  void _deleteBullet(_EditableInfoSectionModel section, int index) {
    setState(() {
      section.items.removeAt(index);
    });
  }

  void _toggleSectionStyle(_EditableInfoSectionModel section) {
    final index = _sections.indexOf(section);
    if (index < 0) return;
    setState(() {
      _sections[index] = _EditableInfoSectionModel(
        id: section.id,
        title: section.title,
        style: section.style == InfoSectionListStyle.bullet
            ? InfoSectionListStyle.numbered
            : InfoSectionListStyle.bullet,
        items: section.items,
      );
    });
  }

  Future<void> _openSectionActions(_EditableInfoSectionModel section) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit section title'),
              onTap: () => Navigator.pop(ctx, 'edit_title'),
            ),
            ListTile(
              leading: Icon(
                section.style == InfoSectionListStyle.bullet
                    ? Icons.format_list_numbered
                    : Icons.format_list_bulleted,
              ),
              title: Text(
                section.style == InfoSectionListStyle.bullet
                    ? 'Use numbered list'
                    : 'Use bullet list',
              ),
              onTap: () => Navigator.pop(ctx, 'toggle_style'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: ARAColors.danger),
              title: const Text(
                'Delete section',
                style: TextStyle(color: ARAColors.danger),
              ),
              onTap: () => Navigator.pop(ctx, 'delete_section'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'edit_title':
        await _editSectionTitle(section);
        return;
      case 'toggle_style':
        _toggleSectionStyle(section);
        return;
      case 'delete_section':
        await _deleteSection(section);
        return;
    }
  }

  void _saveChanges() {
    final snapshot = _sections.map((section) => section.copy()).toList();
    setState(() {
      _savedSections
        ..clear()
        ..addAll(snapshot.map((section) => section.copy()));
      _isEditingInformation = false;
    });
    widget.card.sections
      ..clear()
      ..addAll(snapshot.map((section) => section.copy()));
    widget.card.subtitle = '';
    final flattenedItems = snapshot.expand((section) => section.items).toList();
    widget.card.infoItems
      ..clear()
      ..addAll(flattenedItems);
    widget.card.listStyle = snapshot.isNotEmpty
        ? snapshot.first.style
        : InfoSectionListStyle.bullet;
  }

  void _cancelEditing() {
    setState(() {
      _sections
        ..clear()
        ..addAll(_savedSections.map((section) => section.copy()));
      _isEditingInformation = false;
    });
  }

  Future<void> _openCardActionsSheet() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notes_outlined),
              title: Text(
                _isEditingInformation ? 'Done editing information' : 'Edit information',
              ),
              onTap: () => Navigator.pop(
                ctx,
                _isEditingInformation ? 'done_editing' : 'edit_information',
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    setState(() {
      _isEditingInformation = action == 'edit_information';
    });
    if (!_isEditingInformation) {
      _cancelEditing();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSections = _sections.isNotEmpty;

    return Scaffold(
      backgroundColor: ARAColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 8),
              child: _BackTitleHeader(
                title: widget.card.title,
                onBack: () => Navigator.pop(context),
                actions: widget.isStaff
                    ? [
                        IconButton(
                          onPressed: _openCardActionsSheet,
                          icon: const Icon(Icons.more_vert),
                          tooltip: 'Card actions',
                        ),
                      ]
                    : const [],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  if (hasSections)
                    ExpandableSectionGroup(
                      initiallyExpandedId: '',
                      sections: _sections
                          .map(
                            (section) => ExpandableSectionItem(
                              id: section.id,
                              title: section.title,
                              child: _EditableInfoSectionBody(
                                section: section,
                                isEditing: _isEditingInformation,
                                onAddBullet: () => _addBullet(section),
                                onEditBullet: (index) => _editBullet(section, index),
                                onDeleteBullet: (index) => _deleteBullet(section, index),
                                onSectionActions: () => _openSectionActions(section),
                              ),
                            ),
                          )
                          .toList(),
                    )
                  else
                    _SectionCard(
                      title: 'Information',
                      child: Text(
                        widget.isStaff
                            ? 'No content added yet. Press Edit information to start.'
                            : 'No information added yet.',
                        style: const TextStyle(color: ARAColors.subInk),
                      ),
                    ),
                  if (widget.isStaff && _isEditingInformation) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addSection,
                        icon: const Icon(Icons.add),
                        label: const Text('Add section'),
                        style: _editorOutlineButtonStyle(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _cancelEditing,
                        style: _editorOutlineButtonStyle(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saveChanges,
                        style: _editorPrimaryButtonStyle(),
                        child: const Text('Save changes'),
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

  Future<String?> _showSectionTitleDialog({
    required String title,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Section title'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) return;
              Navigator.pop(ctx, trimmed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }
}
class _InformationSectionScreen extends StatefulWidget {
  final String title;
  final Widget child;
  final _InformationCardModel? card;
  final bool isStaff;
  final _EditableInfoSectionsController? editorController;

  const _InformationSectionScreen({
    required this.title,
    required this.child,
    this.card,
    this.isStaff = false,
    this.editorController,
  });

  @override
  State<_InformationSectionScreen> createState() =>
      _InformationSectionScreenState();
}

class _InformationSectionScreenState extends State<_InformationSectionScreen> {
  Future<void> _handleSectionMenuSelection(String value) async {
    switch (value) {
      case 'edit_information':
        widget.editorController?.startEditing();
        setState(() {});
        return;
      case 'done_editing':
        widget.editorController?.stopEditing();
        setState(() {});
        return;
    }
  }

  Future<void> _openSectionActionsSheet() async {
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
              leading: const Icon(Icons.notes_outlined),
              title: Text(
                widget.editorController?.isEditing == true
                    ? 'Done editing information'
                    : 'Edit information',
              ),
              onTap: () async {
                Navigator.pop(ctx);
                if (!mounted) return;
                await _handleSectionMenuSelection(
                  widget.editorController?.isEditing == true
                      ? 'done_editing'
                      : 'edit_information',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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
              child: _BackTitleHeader(
                title: widget.card?.title ?? widget.title,
                onBack: () => Navigator.pop(context),
                actions: widget.isStaff && widget.card != null
                    ? [
                        IconButton(
                          onPressed: _openSectionActionsSheet,
                          icon: const Icon(Icons.more_vert),
                          tooltip: 'Card actions',
                        ),
                      ]
                    : const [],
              ),
            ),
            Expanded(child: widget.child),
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

class _BackTitleHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final List<Widget> actions;

  const _BackTitleHeader({
    required this.title,
    required this.onBack,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back,
            color: ARATypography.backNavTone,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            title,
            style: ARATypography.backNavTitle,
          ),
        ),
        ...actions,
      ],
    );
  }
}










