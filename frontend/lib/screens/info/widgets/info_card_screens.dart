part of '../information.dart';

class _InformationCardModel {
  final String id;
  IconData icon;
  Color iconColor;
  final _InfoSection? section;

  String title;
  String subtitle;
  final List<String> infoItems;
  bool deleted;

  _InformationCardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.section,
    List<String>? infoItems,
    this.deleted = false,
  }) : infoItems = infoItems ?? <String>[];

  _InformationCardModel copy() {
    return _InformationCardModel(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      section: section,
      infoItems: List<String>.from(infoItems),
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
      'deleted': deleted,
    };
  }

  static _InformationCardModel? fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final iconMap = raw['icon'];
    if (iconMap is! Map<String, dynamic>) return null;
    final codePoint = iconMap['codePoint'];
    if (codePoint is! int) return null;

    return _InformationCardModel(
      id: raw['id']?.toString() ?? '',
      title: raw['title']?.toString() ?? '',
      subtitle: raw['subtitle']?.toString() ?? '',
      icon: IconData(
        codePoint,
        fontFamily: iconMap['fontFamily']?.toString(),
        fontPackage: iconMap['fontPackage']?.toString(),
        matchTextDirection: iconMap['matchTextDirection'] == true,
      ),
      iconColor: Color(raw['iconColor'] is int
          ? raw['iconColor'] as int
          : ARAColors.brand.toARGB32()),
      section: _sectionFromName(raw['section']?.toString()),
      infoItems: (raw['infoItems'] is List)
          ? (raw['infoItems'] as List)
                .map((item) => item.toString())
                .toList(growable: false)
          : const [],
      deleted: raw['deleted'] == true,
    );
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
  bool _isEditingInformation = false;

  Future<void> _addInformation() async {
    final text = await _showInformationItemDialog(context: context);
    if (!mounted) return;
    if (text == null) return;

    setState(() {
      widget.card.infoItems.add(text);
    });
  }

  Future<void> _editInformation(int index) async {
    final text = await _showInformationItemDialog(
      context: context,
      initialValue: widget.card.infoItems[index],
    );
    if (!mounted) return;
    if (text == null) return;

    setState(() {
      widget.card.infoItems[index] = text;
    });
  }

  Future<void> _deleteInformation(int index) async {
    setState(() {
      widget.card.infoItems.removeAt(index);
    });
  }

  Future<void> _handleCardMenuSelection(String value) async {
    switch (value) {
      case 'edit_information':
        setState(() => _isEditingInformation = true);
        return;
      case 'done_editing':
        setState(() => _isEditingInformation = false);
        return;
    }
  }

  Future<void> _openCardActionsSheet() async {
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
                _isEditingInformation
                    ? 'Done editing information'
                    : 'Edit information',
              ),
              onTap: () async {
                Navigator.pop(ctx);
                if (!mounted) return;
                await _handleCardMenuSelection(
                  _isEditingInformation ? 'done_editing' : 'edit_information',
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
      appBar: AppBar(
        title: Text(widget.card.title),
        actions: widget.isStaff
            ? [
                IconButton(
                  onPressed: _openCardActionsSheet,
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Card actions',
                ),
              ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const OfflineBanner(),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Overview',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.card.subtitle,
                  style: const TextStyle(color: ARAColors.subInk),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.card.infoItems.isEmpty)
                  const Text(
                    'No information added yet.',
                    style: TextStyle(color: ARAColors.subInk),
                  ),
                ...widget.card.infoItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final text = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: ARAColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ARAColors.surfaceWarmTint),
                    ),
                    child: ListTile(
                      title: Text(text),
                      trailing: widget.isStaff && _isEditingInformation
                          ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editInformation(index);
                                  return;
                                }
                                _deleteInformation(index);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                }),
                if (widget.isStaff && _isEditingInformation)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _addInformation,
                      icon: const Icon(Icons.add),
                      label: const Text('Add information'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isStaff && _isEditingInformation
          ? FloatingActionButton(
              onPressed: _addInformation,
              backgroundColor: ARAColors.brand,
              foregroundColor: ARAColors.ink,
              child: const Icon(Icons.add),
            )
          : null,
    );
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
