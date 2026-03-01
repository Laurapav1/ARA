part of '../information.dart';

ButtonStyle _editorCancelTextButtonStyle() {
  return TextButton.styleFrom(
    foregroundColor: ARAColors.brandDeep,
    backgroundColor: Colors.transparent,
    overlayColor: Colors.transparent,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
  );
}

class _CardEditorResult {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _CardEditorResult({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

class _CardIconOption {
  final String label;
  final IconData icon;

  const _CardIconOption({
    required this.label,
    required this.icon,
  });
}

const List<_CardIconOption> _featuredCardIconOptions = [
  _CardIconOption(label: 'Document', icon: Icons.description_outlined),
  _CardIconOption(label: 'Shield', icon: Icons.shield_outlined),
  _CardIconOption(label: 'Map', icon: Icons.map_outlined),
  _CardIconOption(label: 'Home', icon: Icons.home_outlined),
  _CardIconOption(label: 'Checklist', icon: Icons.checklist_outlined),
  _CardIconOption(label: 'Calendar', icon: Icons.calendar_month_outlined),
  _CardIconOption(label: 'Flight', icon: Icons.flight_land_outlined),
  _CardIconOption(label: 'Star', icon: Icons.star_outline),
  _CardIconOption(label: 'Cleaning', icon: Icons.cleaning_services_outlined),
  _CardIconOption(label: 'Paw', icon: Icons.pets_outlined),
  _CardIconOption(label: 'Info', icon: Icons.info_outline),
  _CardIconOption(label: 'Warning', icon: Icons.warning_amber_outlined),
  _CardIconOption(label: 'Help', icon: Icons.help_outline),
  _CardIconOption(label: 'Location', icon: Icons.location_on_outlined),
  _CardIconOption(label: 'Directions', icon: Icons.directions_outlined),
  _CardIconOption(label: 'Car', icon: Icons.directions_car_outlined),
  _CardIconOption(label: 'Bus', icon: Icons.directions_bus_outlined),
  _CardIconOption(label: 'Train', icon: Icons.train_outlined),
  _CardIconOption(label: 'Bed', icon: Icons.bed_outlined),
  _CardIconOption(label: 'Kitchen', icon: Icons.kitchen_outlined),
  _CardIconOption(label: 'Restaurant', icon: Icons.restaurant_outlined),
  _CardIconOption(label: 'Water', icon: Icons.water_drop_outlined),
  _CardIconOption(label: 'Phone', icon: Icons.phone_outlined),
  _CardIconOption(label: 'Mail', icon: Icons.mail_outline),
  _CardIconOption(label: 'Chat', icon: Icons.chat_bubble_outline),
  _CardIconOption(label: 'Camera', icon: Icons.photo_camera_outlined),
  _CardIconOption(label: 'Image', icon: Icons.image_outlined),
  _CardIconOption(label: 'People', icon: Icons.people_outline),
  _CardIconOption(label: 'Person', icon: Icons.person_outline),
  _CardIconOption(label: 'Volunteer', icon: Icons.volunteer_activism_outlined),
  _CardIconOption(label: 'Medical', icon: Icons.medical_services_outlined),
  _CardIconOption(label: 'Health', icon: Icons.health_and_safety_outlined),
  _CardIconOption(label: 'Work', icon: Icons.work_outline),
  _CardIconOption(label: 'Time', icon: Icons.schedule_outlined),
  _CardIconOption(label: 'Task', icon: Icons.task_alt_outlined),
  _CardIconOption(label: 'Lock', icon: Icons.lock_outline),
  _CardIconOption(label: 'Key', icon: Icons.key_outlined),
  _CardIconOption(label: 'Build', icon: Icons.build_outlined),
  _CardIconOption(label: 'Settings', icon: Icons.settings_outlined),
  _CardIconOption(label: 'Laundry', icon: Icons.local_laundry_service_outlined),
  _CardIconOption(label: 'Wifi', icon: Icons.wifi_outlined),
  _CardIconOption(label: 'Shopping', icon: Icons.shopping_basket_outlined),
  _CardIconOption(label: 'Park', icon: Icons.park_outlined),
  _CardIconOption(label: 'Forest', icon: Icons.forest_outlined),
  _CardIconOption(label: 'Sun', icon: Icons.wb_sunny_outlined),
  _CardIconOption(label: 'Night', icon: Icons.nightlight_outlined),
  _CardIconOption(label: 'Rain', icon: Icons.umbrella_outlined),
  _CardIconOption(label: 'Trash', icon: Icons.delete_outline),
  _CardIconOption(label: 'Edit', icon: Icons.edit_outlined),
  _CardIconOption(label: 'Book', icon: Icons.menu_book_outlined),
  _CardIconOption(label: 'School', icon: Icons.school_outlined),
  _CardIconOption(label: 'Heart', icon: Icons.favorite_border),
  _CardIconOption(label: 'Dog', icon: Icons.pets_outlined),
];

const List<Color> _cardColorOptions = [
  ARAColors.infoSectionOverviewIcon,
  ARAColors.infoSectionCleaningIcon,
  ARAColors.infoSectionSafetyIcon,
  ARAColors.infoSectionChecklistIcon,
  ARAColors.brandDark,
  ARAColors.brandDeep,
  Color(0xFF2E7D32),
  Color(0xFF00897B),
  Color(0xFF0277BD),
  Color(0xFF3949AB),
  Color(0xFF6A1B9A),
  Color(0xFFAD1457),
  Color(0xFFE65100),
  Color(0xFF8D6E63),
  Color(0xFF546E7A),
  Color(0xFF455A64),
];

Future<_CardEditorResult?> _showCardEditorDialog({
  required BuildContext context,
  required String title,
  String initialTitle = '',
  String initialSubtitle = '',
  IconData initialIcon = Icons.description_outlined,
  Color initialIconColor = ARAColors.infoSectionOverviewIcon,
}) async {
  final titleController = TextEditingController(text: initialTitle);
  final subtitleController = TextEditingController(text: initialSubtitle);
  var selectedIcon = initialIcon;
  var selectedColor = initialIconColor;

  final result = await showDialog<_CardEditorResult>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Card title'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(labelText: 'Card subtitle'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              _AnchoredIconDropdown(
                label: 'Icon',
                value: selectedIcon,
                options: _cardIconOptions,
                onChanged: (value) {
                  setDialogState(() => selectedIcon = value);
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Color',
                  style: Theme.of(dialogContext).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _cardColorOptions.map((color) {
                  final isSelected =
                      color.toARGB32() == selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? ARAColors.ink : Colors.white,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: _editorCancelTextButtonStyle(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final enteredTitle = titleController.text.trim();
              final enteredSubtitle = subtitleController.text.trim();
              if (enteredTitle.isEmpty || enteredSubtitle.isEmpty) {
                return;
              }

              Navigator.pop(
                ctx,
                _CardEditorResult(
                  title: enteredTitle,
                  subtitle: enteredSubtitle,
                  icon: selectedIcon,
                  iconColor: selectedColor,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );

  titleController.dispose();
  subtitleController.dispose();
  return result;
}

Future<String?> _showInformationItemDialog({
  required BuildContext context,
  String initialValue = '',
}) async {
  final controller = TextEditingController(text: initialValue);

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(initialValue.isEmpty ? 'Add information' : 'Edit information'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Information text'),
        textCapitalization: TextCapitalization.sentences,
        minLines: 2,
        maxLines: 4,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          style: _editorCancelTextButtonStyle(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isEmpty) return;
            Navigator.pop(ctx, value);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );

  controller.dispose();
  return result;
}

class _AnchoredIconDropdown extends StatefulWidget {
  final String label;
  final IconData value;
  final List<_CardIconOption> options;
  final ValueChanged<IconData> onChanged;

  const _AnchoredIconDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  State<_AnchoredIconDropdown> createState() => _AnchoredIconDropdownState();
}

class _AnchoredIconDropdownState extends State<_AnchoredIconDropdown> {
  static const int _maxVisibleOptions = 120;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _fieldKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshOverlay);
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController
      ..removeListener(_refreshOverlay)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _refreshOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
    _searchController.clear();
  }

  void _toggleOverlay() {
    if (!mounted) return;
    if (_isOpen) {
      setState(_removeOverlay);
      _focusNode.unfocus();
      return;
    }

    final renderBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    final overlay = overlayState?.context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlayState == null || overlay == null) return;

    final topLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final size = renderBox.size;
    final cardColor = Theme.of(context).cardColor;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final query = _searchController.text.trim().toLowerCase();
        final matchingOptions = widget.options.where((option) {
          if (query.isEmpty) return true;
          final label = option.label.toLowerCase();
          return label.contains(query) ||
              label.replaceAll(' ', '_').contains(query.replaceAll(' ', '_'));
        }).toList(growable: false);
        final filteredOptions = matchingOptions
            .take(_maxVisibleOptions)
            .toList(growable: false);
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (!mounted) return;
            setState(_removeOverlay);
            _focusNode.unfocus();
          },
          child: Stack(
            children: [
              Positioned(
                left: topLeft.dx,
                top: topLeft.dy,
                width: size.width,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ARAColors.brand, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: _toggleOverlay,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildSelectedLabel(widget.value),
                                ),
                                const Icon(Icons.expand_less),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'Search icons',
                              prefixIcon: Icon(Icons.search),
                              isDense: true,
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 240),
                          child: filteredOptions.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'No icons found',
                                      style: TextStyle(color: ARAColors.subInk),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredOptions.length,
                                  itemBuilder: (context, index) {
                                    final option = filteredOptions[index];
                                    final selected = option.icon == widget.value;
                                    return InkWell(
                                      onTap: () {
                                        widget.onChanged(option.icon);
                                        if (!mounted) return;
                                        setState(_removeOverlay);
                                        _focusNode.unfocus();
                                      },
                                      child: Container(
                                        color: selected
                                            ? ARAColors.surfaceWarm
                                            : Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(option.icon),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(option.label),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        if (matchingOptions.length > filteredOptions.length)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Showing first ${filteredOptions.length} matches. Keep typing to narrow the list.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ARAColors.subInk,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlayState.insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _focusNode.requestFocus();
  }

  Widget _buildSelectedLabel(IconData value) {
    final option = widget.options.firstWhere(
      (candidate) => candidate.icon == value,
      orElse: () => widget.options.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12,
            color: ARAColors.subInk,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(option.icon, size: 18, color: ARAColors.ink),
            const SizedBox(width: 8),
            Text(
              option.label,
              style: const TextStyle(
                fontSize: 14,
                color: ARAColors.ink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    final fieldFill = Theme.of(context).cardColor;
    return Opacity(
      opacity: _isOpen ? 0.0 : 1.0,
      child: InkWell(
        key: _fieldKey,
        onTap: _toggleOverlay,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isOpen ? ARAColors.brand : dividerColor,
              width: _isOpen ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: _buildSelectedLabel(widget.value)),
              Icon(_isOpen ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
      ),
    );
  }
}
