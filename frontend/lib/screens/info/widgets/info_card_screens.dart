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
  Future<void> _editCard() async {
    final result = await _showCardEditorDialog(
      context: context,
      title: 'Edit information card',
      initialTitle: widget.card.title,
      initialSubtitle: widget.card.subtitle,
      initialIcon: widget.card.icon,
      initialIconColor: widget.card.iconColor,
    );
    if (!mounted) return;
    if (result == null) return;

    setState(() {
      widget.card.title = result.title;
      widget.card.subtitle = result.subtitle;
      widget.card.icon = result.icon;
      widget.card.iconColor = result.iconColor;
    });
  }

  Future<void> _deleteCard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete card'),
        content: Text('Delete "${widget.card.title}"?'),
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

    if (confirmed != true) return;

    widget.card.deleted = true;
    if (!mounted) return;
    Navigator.pop(context);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ARAColors.bg,
      appBar: AppBar(
        title: Text(widget.card.title),
        actions: widget.isStaff
            ? [
                IconButton(
                  onPressed: _editCard,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit card',
                ),
                IconButton(
                  onPressed: _deleteCard,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete card',
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
                      trailing: widget.isStaff
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
                if (widget.isStaff)
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
      floatingActionButton: widget.isStaff
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

  const _InformationSectionScreen({
    required this.title,
    required this.child,
    this.card,
    this.isStaff = false,
  });

  @override
  State<_InformationSectionScreen> createState() =>
      _InformationSectionScreenState();
}

class _InformationSectionScreenState extends State<_InformationSectionScreen> {
  Future<void> _editCard() async {
    final card = widget.card;
    if (card == null) return;
    final result = await _showCardEditorDialog(
      context: context,
      title: 'Edit information card',
      initialTitle: card.title,
      initialSubtitle: card.subtitle,
      initialIcon: card.icon,
      initialIconColor: card.iconColor,
    );
    if (!mounted) return;
    if (result == null) return;
    setState(() {
      card.title = result.title;
      card.subtitle = result.subtitle;
      card.icon = result.icon;
      card.iconColor = result.iconColor;
    });
  }

  Future<void> _deleteCard() async {
    final card = widget.card;
    if (card == null) return;
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
    if (!mounted) return;

    if (confirmed != true) return;
    card.deleted = true;
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _openStaffActions() async {
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
              title: const Text('Edit card'),
              onTap: () async {
                Navigator.pop(ctx);
                if (!mounted) return;
                await _editCard();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: ARAColors.danger),
              title: const Text('Delete card',
                  style: TextStyle(color: ARAColors.danger)),
              onTap: () async {
                Navigator.pop(ctx);
                if (!mounted) return;
                await _deleteCard();
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
                          onPressed: _openStaffActions,
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
