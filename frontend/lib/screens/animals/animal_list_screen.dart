import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../services/animals_service.dart';
import '../../services/api_client.dart';
import '../../services/api_config.dart';
import '../../services/auth_store.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/animal_grid.dart';
import '../../widgets/global_search_filter.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/staff_action_sheet.dart';
import 'animal_detail.dart';
import 'animal_editor.dart';
import 'animal_status_dialog.dart';

enum _AnimalStaffMode { none, edit, delete }

class AnimalListScreen extends StatefulWidget {
  final String title;
  final String species;
  final Color accentColor;
  final Color accentSoft;
  final String emptyText;

  const AnimalListScreen({
    super.key,
    required this.title,
    required this.species,
    required this.accentColor,
    required this.accentSoft,
    required this.emptyText,
  });

  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  late final AnimalsService _animalsService;
  late final GlobalSearchFilterController<Animal> _searchFilterController;
  List<Animal> _animals = const [];
  bool _isLoading = true;
  String? _loadError;
  _AnimalStaffMode _staffMode = _AnimalStaffMode.none;

  bool _needsCaution(Animal a) => a.isDangerous;

  @override
  void initState() {
    super.initState();
    _animalsService = AnimalsService(ApiClient(ApiConfig.baseUrl));
    _searchFilterController = GlobalSearchFilterController<Animal>(
      resourceType: 'animals_${widget.species.toLowerCase()}',
      titleOf: (animal) => animal.name,
      subtitleOf: (animal) => '${animal.breed} ${animal.age}'.trim(),
      tagsOf: (animal) => [
        animal.species,
        animal.gender,
        animal.zone,
        animal.kennel,
        ...animal.flags.map((flag) => flag.name),
      ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
      filterOptions: [
        GlobalFilterOption<Animal>(
          id: 'care_required',
          label: 'Care required',
          predicate: (animal) => animal.isDangerous,
        ),
        GlobalFilterOption<Animal>(
          id: 'in_treatment',
          label: 'In treatment',
          predicate: (animal) => animal.isInTreatment,
        ),
      ],
    )..addListener(_onSearchFilterChanged);
    _loadAnimals();
  }

  @override
  void dispose() {
    _searchFilterController
      ..reset(notify: false)
      ..removeListener(_onSearchFilterChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchFilterChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadAnimals() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final auth = context.read<AuthStore>();
      final animals = await _animalsService.getAnimals(
        species: widget.species,
        filter: AnimalFilter.all,
        search: '',
        token: auth.accessToken,
      );
      if (!mounted) return;
      setState(() {
        _animals = animals;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openAnimalDetail(Animal animal) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimalDetailScreen(animal: animal),
      ),
    );
    await _loadAnimals();
  }

  Future<void> _addAnimal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimalEditorScreen(
          initialSpecies: widget.species,
        ),
      ),
    );
    await _loadAnimals();
  }

  Future<void> _editAnimal(Animal animal) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimalEditorScreen(animal: animal),
      ),
    );
    await _loadAnimals();
  }

  Future<void> _deleteAnimal(Animal animal) async {
    final auth = context.read<AuthStore>();
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      _showMessage('Missing login token.');
      return;
    }

    await showAnimalStatusDialog(
      context,
      animal,
      () async {
        await _animalsService.deleteAnimal(id: animal.id, token: token);
        if (!mounted) return;
        _showMessage('${animal.name} removed');
        await _loadAnimals();
      },
      closeParentOnConfirm: false,
    );
  }

  Future<void> _handleAnimalTap(Animal animal) async {
    switch (_staffMode) {
      case _AnimalStaffMode.edit:
        await _editAnimal(animal);
        return;
      case _AnimalStaffMode.delete:
        await _deleteAnimal(animal);
        return;
      case _AnimalStaffMode.none:
        await _openAnimalDetail(animal);
        return;
    }
  }

  void _setStaffMode(_AnimalStaffMode mode) {
    if (!mounted) return;
    setState(() {
      _staffMode = _staffMode == mode ? _AnimalStaffMode.none : mode;
    });
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openAnimalActionsSheet() async {
    final items = <StaffActionSheetItem>[
      StaffActionSheetItem(
        label: 'Add animal',
        icon: Icons.add,
        onTap: _addAnimal,
      ),
      if (_animals.isNotEmpty)
        StaffActionSheetItem(
          label: _staffMode == _AnimalStaffMode.edit
              ? 'Stop editing animals'
              : 'Edit animals',
          icon: _staffMode == _AnimalStaffMode.edit
              ? Icons.close
              : Icons.edit_outlined,
          onTap: () async {
            _setStaffMode(_AnimalStaffMode.edit);
          },
        ),
      if (_animals.isNotEmpty)
        StaffActionSheetItem(
          label: _staffMode == _AnimalStaffMode.delete
              ? 'Stop deleting animals'
              : 'Delete animals',
          icon: _staffMode == _AnimalStaffMode.delete
              ? Icons.close
              : Icons.delete_outline,
          color: _staffMode == _AnimalStaffMode.delete
              ? null
              : ARAColors.danger,
          onTap: () async {
            _setStaffMode(_AnimalStaffMode.delete);
          },
        ),
    ];

    await showStaffActionSheet(
      context,
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final isStaff = auth.isStaff;
    final visibleAnimals = _searchFilterController.apply(_animals);
    final appBarActions = buildGlobalSearchFilterActions<Animal>(
      context: context,
      title: widget.title.toLowerCase(),
      items: _animals,
      controller: _searchFilterController,
      searchResultBuilder: (context, animal, onTap) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: Card(
          child: ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              backgroundColor: widget.accentSoft,
              backgroundImage: animal.photoBytes != null
                  ? MemoryImage(animal.photoBytes!)
                  : null,
              child: animal.photoBytes == null
                  ? Icon(Icons.pets, color: widget.accentColor)
                  : null,
            ),
            title: Text(animal.name),
            subtitle: Text(
              [
                animal.breed,
                animal.age,
                animal.zone,
                if (animal.flags.isNotEmpty) '${animal.flags.length} flags',
              ].where((v) => v.trim().isNotEmpty).join(' - '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
      onItemSelected: (animal) async {
        await _openAnimalDetail(animal);
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ...appBarActions,
          if (isStaff)
            IconButton(
              onPressed: _openAnimalActionsSheet,
              icon: const Icon(Icons.more_vert),
              tooltip: 'Animal actions',
            ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: Stack(
                children: [
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_loadError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildErrorState(),
                    )
                  else
                    AnimalGrid(
                      animals: visibleAnimals,
                      accentColor: widget.accentColor,
                      accentSoft: widget.accentSoft,
                      showCautionIcons: true,
                      needsCaution: _needsCaution,
                      actionIcon: isStaff && _staffMode == _AnimalStaffMode.delete
                          ? Icons.delete_outline
                          : (isStaff && _staffMode == _AnimalStaffMode.edit
                              ? Icons.edit_outlined
                              : null),
                      actionTooltip: isStaff && _staffMode == _AnimalStaffMode.delete
                          ? 'Delete animal'
                          : (isStaff && _staffMode == _AnimalStaffMode.edit
                              ? 'Edit animal'
                              : null),
                      actionColor: _staffMode == _AnimalStaffMode.delete
                          ? ARAColors.danger
                          : ARAColors.ink,
                      onActionPressed: isStaff && _staffMode != _AnimalStaffMode.none
                          ? (animal) => _handleAnimalTap(animal)
                          : null,
                      onTap: (animal) async {
                        await _handleAnimalTap(animal);
                      },
                    ),
                  if (!_isLoading &&
                      _loadError == null &&
                      visibleAnimals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildEmptyState(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ARAColors.surfaceWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ARAColors.surfaceWarmTint),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: ARAColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load animals. $_loadError',
              style: const TextStyle(color: ARAColors.subInk),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _loadAnimals,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ARAColors.surfaceWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ARAColors.surfaceWarmTint),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_off, color: ARAColors.subInk),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${widget.emptyText} Try adjusting search or filters.',
              style: const TextStyle(color: ARAColors.subInk),
            ),
          ),
        ],
      ),
    );
  }
}


