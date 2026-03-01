part of '../information.dart';

ButtonStyle _editorPrimaryButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: ARAColors.brand,
    foregroundColor: ARAColors.ink,
    overlayColor: Colors.transparent,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
  );
}

ButtonStyle _editorOutlineButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: ARAColors.brandDark,
    backgroundColor: Colors.transparent,
    overlayColor: Colors.transparent,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    side: const BorderSide(color: ARAColors.surfaceWarmTint),
  );
}

class _EditableInfoSectionModel {
  final String id;
  String title;
  final InfoSectionListStyle style;
  final List<String> items;

  _EditableInfoSectionModel({
    required this.id,
    required this.title,
    required this.style,
    required List<String> items,
  }) : items = List<String>.from(items);

  _EditableInfoSectionModel copy() {
    return _EditableInfoSectionModel(
      id: id,
      title: title,
      style: style,
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'style': style.name,
      'items': List<String>.from(items),
    };
  }

  static _EditableInfoSectionModel? fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final styleName =
        raw['style']?.toString() ?? InfoSectionListStyle.bullet.name;
    final style = InfoSectionListStyle.values.firstWhere(
      (value) => value.name == styleName,
      orElse: () => InfoSectionListStyle.bullet,
    );
    final items = raw['items'] is List
        ? (raw['items'] as List).map((item) => item.toString()).toList()
        : <String>[];
    return _EditableInfoSectionModel(
      id: raw['id']?.toString() ?? '',
      title: raw['title']?.toString() ?? '',
      style: style,
      items: items,
    );
  }
}

class _EditableInfoSectionsController extends ChangeNotifier {
  bool _isEditing = false;

  bool get isEditing => _isEditing;

  void startEditing() {
    if (_isEditing) return;
    _isEditing = true;
    notifyListeners();
  }

  void stopEditing() {
    if (!_isEditing) return;
    _isEditing = false;
    notifyListeners();
  }
}

class _EditableInfoSections extends StatefulWidget {
  final String storageKey;
  final List<_EditableInfoSectionModel> initialSections;
  final _EditableInfoSectionsController? controller;

  const _EditableInfoSections({
    required this.storageKey,
    required this.initialSections,
    this.controller,
  });

  @override
  State<_EditableInfoSections> createState() => _EditableInfoSectionsState();
}

class _EditableInfoSectionsState extends State<_EditableInfoSections> {
  late final List<_EditableInfoSectionModel> _sections;
  late final List<_EditableInfoSectionModel> _savedSections;
  bool _loading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _sections = widget.initialSections.map((s) => s.copy()).toList();
    _savedSections = widget.initialSections.map((s) => s.copy()).toList();
    widget.controller?.addListener(_syncEditingFromController);
    _loadSections();
  }

  @override
  void didUpdateWidget(covariant _EditableInfoSections oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller?.removeListener(_syncEditingFromController);
    widget.controller?.addListener(_syncEditingFromController);
    _syncEditingFromController();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_syncEditingFromController);
    super.dispose();
  }

  Future<void> _loadSections() async {
    try {
      final auth = context.read<AuthStore>();
      final data = await _informationService.getDocument(
        widget.storageKey,
        token: auth.accessToken,
      );
      if (!mounted) return;
      if (data is List) {
        final loaded = <_EditableInfoSectionModel>[];
        for (final row in data) {
          final section = _EditableInfoSectionModel.fromJson(row);
          if (section != null) loaded.add(section);
        }
        if (loaded.isNotEmpty) {
          _sections
            ..clear()
            ..addAll(loaded);
          _savedSections
            ..clear()
            ..addAll(loaded.map((section) => section.copy()));
        }
      }
    } catch (_) {
      // Keep defaults if backend load fails.
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _syncEditingFromController() {
    final nextValue = widget.controller?.isEditing ?? false;
    if (!mounted || _isEditing == nextValue) return;
    setState(() => _isEditing = nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = context.watch<AuthStore>().isStaff;
    final isEditing = isStaff && _isEditing;
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        ExpandableSectionGroup(
          initiallyExpandedId: '',
          sections: _sections
              .map(
                (section) => ExpandableSectionItem(
                  id: section.id,
                  title: section.title,
                  child: _EditableInfoSectionBody(
                    section: section,
                    isEditing: isEditing,
                    onAddBullet: () => _addBullet(section),
                    onEditBullet: (index) => _editBullet(section, index),
                    onDeleteBullet: (index) => _deleteBullet(section, index),
                    onSectionActions: () => _openSectionActions(section),
                  ),
                ),
              )
              .toList(),
        ),
        if (isStaff) ...[
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isEditing && widget.controller == null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _startEditing,
                    style: _editorPrimaryButtonStyle(),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit information'),
                  ),
                ),
              if (isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addSection,
                    icon: const Icon(Icons.add),
                    label: const Text('Add section'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ARAColors.brandDark,
                      backgroundColor: Colors.transparent,
                      overlayColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      side: const BorderSide(
                        color: ARAColors.surfaceWarmTint,
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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
        ],
      ],
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
    widget.controller?.startEditing();
  }

  void _cancelEditing() {
    setState(() {
      _sections
        ..clear()
        ..addAll(_savedSections.map((section) => section.copy()));
      _isEditing = false;
    });
    widget.controller?.stopEditing();
  }

  Future<void> _addSection() async {
    final title = await _showSectionTitleDialog(title: 'Add section');
    if (!mounted) return;
    if (title == null) return;
    setState(() {
      _sections.add(
        _EditableInfoSectionModel(
          id: 'section_${DateTime.now().millisecondsSinceEpoch}',
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
    if (!mounted) return;
    if (title == null) return;
    setState(() {
      section.title = title;
    });
  }

  Future<void> _deleteSection(_EditableInfoSectionModel section) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete section'),
        content: Text('Delete "${section.title}"?'),
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
    if (!mounted) return;
    if (confirmed != true) return;
    setState(() {
      _sections.remove(section);
    });
  }

  Future<void> _addBullet(_EditableInfoSectionModel section) async {
    final value = await _showInformationItemDialog(context: context);
    if (!mounted) return;
    if (value == null) return;
    setState(() {
      section.items.add(value);
    });
  }

  Future<void> _editBullet(_EditableInfoSectionModel section, int index) async {
    final value = await _showInformationItemDialog(
      context: context,
      initialValue: section.items[index],
    );
    if (!mounted) return;
    if (value == null) return;
    setState(() {
      section.items[index] = value;
    });
  }

  void _deleteBullet(_EditableInfoSectionModel section, int index) {
    setState(() {
      section.items.removeAt(index);
    });
  }

  Future<void> _openSectionActions(_EditableInfoSectionModel section) async {
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
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit section title'),
              onTap: () async {
                Navigator.pop(ctx);
                if (!mounted) return;
                await _editSectionTitle(section);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: ARAColors.danger),
              title: const Text(
                'Delete section',
                style: TextStyle(color: ARAColors.danger),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                if (!mounted) return;
                await _deleteSection(section);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    _saveChangesAsync();
  }

  Future<void> _saveChangesAsync() async {
    final auth = context.read<AuthStore>();
    final token = auth.accessToken;
    if (!auth.isStaff || token == null || token.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Staff login required.')));
      return;
    }

    await _informationService.saveDocument(
      widget.storageKey,
      _sections.map((section) => section.toJson()).toList(growable: false),
      token: token,
    );

    if (!mounted) return;
    setState(() {
      _savedSections
        ..clear()
        ..addAll(_sections.map((section) => section.copy()));
      _isEditing = false;
    });
    widget.controller?.stopEditing();
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(const SnackBar(content: Text('Changes saved')));
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

class _EditableInfoSectionBody extends StatelessWidget {
  final _EditableInfoSectionModel section;
  final bool isEditing;
  final VoidCallback onAddBullet;
  final Future<void> Function(int index) onEditBullet;
  final void Function(int index) onDeleteBullet;
  final VoidCallback onSectionActions;

  const _EditableInfoSectionBody({
    required this.section,
    required this.isEditing,
    required this.onAddBullet,
    required this.onEditBullet,
    required this.onDeleteBullet,
    required this.onSectionActions,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return InfoSectionList(items: section.items, style: section.style);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (section.items.isEmpty)
          const Text(
            'No bullets added yet.',
            style: TextStyle(color: ARAColors.subInk),
          )
        else
          ...section.items.asMap().entries.map((entry) {
            final index = entry.key;
            final text = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EditableSectionMarker(
                    index: index,
                    style: section.style,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(color: ARAColors.ink),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onEditBullet(index),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Edit bullet',
                    color: ARAColors.subInk,
                  ),
                  IconButton(
                    onPressed: () => onDeleteBullet(index),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    tooltip: 'Delete bullet',
                    color: ARAColors.danger,
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAddBullet,
            icon: const Icon(Icons.add),
            label: const Text('Add bullet'),
            style: _editorOutlineButtonStyle(),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onSectionActions,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit section'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ARAColors.subInk,
              backgroundColor: Colors.transparent,
              overlayColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              side: const BorderSide(color: ARAColors.surfaceWarmTint),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditableSectionMarker extends StatelessWidget {
  final int index;
  final InfoSectionListStyle style;

  const _EditableSectionMarker({
    required this.index,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (style == InfoSectionListStyle.numbered) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SizedBox(
          width: 14,
          height: 14,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: ARAColors.brand,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.only(top: 6),
      child: SizedBox(
        width: 8,
        height: 8,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ARAColors.brand,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
