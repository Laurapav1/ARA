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
import 'animal_detail.dart';
import 'animal_editor.dart';

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
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final isStaff = auth.isStaff;
    final visibleAnimals = _searchFilterController.apply(_animals);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: buildGlobalSearchFilterActions<Animal>(
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
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnimalDetailScreen(animal: animal),
              ),
            );
            await _loadAnimals();
          },
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: isStaff
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnimalEditorScreen(
                      initialSpecies: widget.species,
                    ),
                  ),
                );
                await _loadAnimals();
              },
              backgroundColor: ARAColors.brand,
              foregroundColor: ARAColors.ink,
              child: const Icon(Icons.add),
            )
          : null,
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
                      onTap: (animal) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnimalDetailScreen(animal: animal),
                          ),
                        );
                        await _loadAnimals();
                      },
                    ),
                  if (!_isLoading &&
                      _loadError == null &&
                      visibleAnimals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildEmptyState(),
                    ),
                  if (isStaff)
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SizedBox(height: 96),
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
