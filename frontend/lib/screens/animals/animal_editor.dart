import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../models/handling_flag.dart';
import '../../services/mock_database.dart';
import '../../theme/ara_theme.dart';

class AnimalEditorScreen extends StatefulWidget {
  final Animal? animal;
  final String? initialSpecies;

  const AnimalEditorScreen({
    super.key,
    this.animal,
    this.initialSpecies,
  });

  @override
  State<AnimalEditorScreen> createState() => _AnimalEditorScreenState();
}

class _AnimalEditorScreenState extends State<AnimalEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _breedController;
  late final TextEditingController _genderController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _historyController;
  late final TextEditingController _zoneController;

  late String _species;
  late bool _isDangerous;
  late bool _isInTreatment;
  late Set<HandlingFlag> _flags;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _nameController = TextEditingController(text: a?.name ?? '');
    _ageController = TextEditingController(text: a?.age ?? '');
    _breedController = TextEditingController(text: a?.breed ?? '');
    _genderController = TextEditingController(text: a?.gender ?? '');
    _descriptionController = TextEditingController(text: a?.description ?? '');
    _historyController = TextEditingController(text: a?.history ?? '');
    _zoneController = TextEditingController(text: a?.zone ?? '');
    _species = a?.species ?? widget.initialSpecies ?? 'dog';
    _isDangerous = a?.isDangerous ?? false;
    _isInTreatment = a?.isInTreatment ?? false;
    _flags = Set<HandlingFlag>.from(a?.flags ?? const {});
    _photoBytes = a?.photoBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _genderController.dispose();
    _descriptionController.dispose();
    _historyController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final db = context.read<MockDatabase>();
    final existing = widget.animal;
    final id = existing?.id ?? 'a${DateTime.now().millisecondsSinceEpoch}';

    final updated = Animal(
      id: id,
      name: _nameController.text.trim(),
      species: _species,
      personality: existing?.personality ?? '',
      isDangerous: _isDangerous,
      isInTreatment: _isInTreatment,
      photoBytes: _photoBytes,
      age: _ageController.text.trim(),
      breed: _breedController.text.trim(),
      gender: _genderController.text.trim(),
      description: _descriptionController.text.trim(),
      history: _historyController.text.trim(),
      trainingVideos: existing?.trainingVideos ?? const [],
      flags: _flags,
      zone: _zoneController.text.trim(),
      kennel: existing?.kennel ?? '',
    );

    if (existing == null) {
      db.addAnimal(updated);
    } else {
      db.updateAnimal(updated);
    }

    Navigator.pop(context);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1200,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  Future<void> _pickBirthDate() async {
    final current = DateTime.tryParse(_ageController.text.trim());
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 2, now.month, now.day),
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _ageController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  List<String> _locationOptions() {
    if (_species == 'cat') {
      return const [
        'A cattery',
        'Adult side cattery',
        'Pool side cattery',
      ];
    }
    return const ['Zone A', 'Zone B', 'Zone C'];
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final dividerColor = Theme.of(context).dividerColor;
    final fieldFill = Theme.of(context).cardColor;
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: dividerColor),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: ARAColors.brand, width: 2),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fieldFill,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(
        color: ARAColors.subInk,
        fontSize: 14,
      ),
      floatingLabelStyle: const TextStyle(
        color: ARAColors.subInk,
        fontSize: 12,
      ),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: focusedBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.animal != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit animal' : ''),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionTitle(title: 'Identity'),
              const SizedBox(height: 8),
              _SectionCard(
                child: Column(
                  children: [
                    _FieldCard(
                      child: TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          label: 'Name',
                          hint: 'Enter name',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldCard(
                      child: _PhotoPicker(
                        photoBytes: _photoBytes,
                        onPickCamera: () async =>
                            _pickPhoto(ImageSource.camera),
                        onPickGallery: () async =>
                            _pickPhoto(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _SectionTitle(title: 'Basic facts'),
              const SizedBox(height: 8),
              _SectionCard(
                child: Column(
                  children: [
                    _TwoColumnRow(
                      left: _FieldCard(
                        child: TextFormField(
                          controller: _ageController,
                          readOnly: true,
                          decoration: _inputDecoration(
                            label: 'Age',
                            hint: 'Select date',
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: _pickBirthDate,
                        ),
                      ),
                      right: _FieldCard(
                        child: TextFormField(
                          controller: _breedController,
                          decoration: _inputDecoration(
                            label: 'Breed',
                            hint: 'Enter breed',
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TwoColumnRow(
                      left: _FieldCard(
                        child: _AnchoredDropdown(
                          label: 'Gender',
                          controller: _genderController,
                          options: const ['Female', 'Male'],
                        ),
                      ),
                      right: _FieldCard(
                        child: _AnchoredDropdown(
                          label: 'Zone',
                          controller: _zoneController,
                          options: _locationOptions(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _SectionTitle(title: 'Care & safety'),
              const SizedBox(height: 8),
              _SectionCard(
                child: Column(
                  children: [
                    _OutlineBox(
                      child: SwitchListTile(
                        value: _isDangerous,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) => setState(() {
                          _isDangerous = value;
                          if (!_isDangerous) _flags = <HandlingFlag>{};
                        }),
                        title: const Text('Requires extra caution'),
                        activeColor: ARAColors.brand,
                      ),
                    ),
                    if (_isDangerous) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Handling flags',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      _OutlineBox(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: HandlingFlag.values.map((flag) {
                            final selected = _flags.contains(flag);
                            return FilterChip(
                              selected: selected,
                              showCheckmark: false,
                              avatar: Icon(
                                flag.icon,
                                size: 16,
                                color: flag.color,
                              ),
                              label: Text(flag.label),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    selected ? ARAColors.ink : ARAColors.subInk,
                              ),
                              backgroundColor: ARAColors.surfaceWarm,
                              selectedColor: flag.color.withValues(alpha: 0.16),
                              side: BorderSide(
                                color: selected
                                    ? flag.color.withValues(alpha: 0.6)
                                    : ARAColors.surfaceWarmTint,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onSelected: (value) => setState(() {
                                value ? _flags.add(flag) : _flags.remove(flag);
                              }),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _FieldCard(
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration(
                          label: 'Handling notes',
                          hint: 'Add notes',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _SectionTitle(title: 'Background & history'),
              const SizedBox(height: 8),
              _SectionCard(
                child: _FieldCard(
                  child: TextFormField(
                    controller: _historyController,
                    decoration: _inputDecoration(
                      label: 'History',
                      hint: 'Add history',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save changes' : 'Add animal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final Uint8List? photoBytes;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;

  const _PhotoPicker({
    required this.photoBytes,
    required this.onPickCamera,
    required this.onPickGallery,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    final fieldFill = Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: fieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 64,
              height: 64,
              color: ARAColors.surfaceWarm,
              child: photoBytes == null
                  ? const Icon(Icons.photo_camera, color: ARAColors.subInk)
                  : Image.memory(photoBytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              photoBytes == null ? 'Add photo' : 'Change photo',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: ARAColors.ink,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: onPickCamera,
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Camera'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onPickGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Gallery'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: ARAColors.subInk,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: child,
    );
  }
}

class _FieldCard extends StatelessWidget {
  final Widget child;

  const _FieldCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _OutlineBox extends StatelessWidget {
  final Widget child;

  const _OutlineBox({required this.child});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    final fieldFill = Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: fieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor),
      ),
      child: child,
    );
  }
}

class _TwoColumnRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _TwoColumnRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _AnchoredDropdown extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final List<String> options;

  const _AnchoredDropdown({
    required this.label,
    required this.controller,
    required this.options,
  });

  @override
  State<_AnchoredDropdown> createState() => _AnchoredDropdownState();
}

class _AnchoredDropdownState extends State<_AnchoredDropdown> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final GlobalKey _fieldKey = GlobalKey();
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _toggleOverlay() {
    if (_isOpen) {
      setState(_removeOverlay);
      _focusNode.unfocus();
      return;
    }

    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final topLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ARAColors.brand,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // header (the visible “field” when open)
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      Text(
                                        widget.controller.text.isEmpty
                                            ? 'Select'
                                            : widget.controller.text,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: ARAColors.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.expand_less),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 240),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.options.length,
                            itemBuilder: (context, index) {
                              final option = widget.options[index];
                              final selected = option == widget.controller.text;
                              return InkWell(
                                onTap: () {
                                  widget.controller.text = option;
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
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(option),
                                  ),
                                ),
                              );
                            },
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

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    final fieldFill = Theme.of(context).cardColor;

    InputDecoration decoration(bool isOpen) {
      final fieldBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isOpen ? ARAColors.brand : dividerColor,
          width: isOpen ? 2 : 1,
        ),
      );
      return InputDecoration(
        labelText: widget.label,
        hintText: 'Select',
        filled: true,
        fillColor: fieldFill,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          color: ARAColors.subInk,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: ARAColors.subInk,
          fontSize: 12,
        ),
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder,
        suffixIcon: Icon(
          _isOpen ? Icons.expand_less : Icons.expand_more,
        ),
      );
    }

    return Opacity(
      // hide the underlying field when overlay is open so it
      // doesn’t “double-render” under the dropdown card
      opacity: _isOpen ? 0.0 : 1.0,
      child: TextFormField(
        key: _fieldKey,
        controller: widget.controller,
        focusNode: _focusNode,
        readOnly: true,
        decoration: decoration(_isOpen),
        onTap: _toggleOverlay,
      ),
    );
  }
}
