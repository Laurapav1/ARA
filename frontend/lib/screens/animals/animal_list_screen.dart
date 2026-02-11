import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../services/animals_service.dart';
import '../../services/api_client.dart';
import '../../services/api_config.dart';
import '../../services/auth_store.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/animal_grid.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/search_field.dart';
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
  String _query = '';
  AnimalFilter _activeFilter = AnimalFilter.all;
  List<Animal> _animals = const [];
  bool _isLoading = true;
  String? _loadError;

  bool _needsCaution(Animal a) => a.isDangerous || a.flags.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _animalsService = AnimalsService(ApiClient(ApiConfig.baseUrl));
    _loadAnimals();
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
        filter: _activeFilter,
        search: _query,
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
    final showCautionIcon = _activeFilter == AnimalFilter.all;

    return Scaffold(
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
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SearchField(
                onChanged: (value) {
                  setState(() => _query = value);
                  _loadAnimals();
                },
                hintText: 'Search by name',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: AnimalFilterRow(
                activeFilter: _activeFilter,
                onChanged: (value) {
                  setState(() => _activeFilter = value);
                  _loadAnimals();
                },
                onMoreFilters: () {},
              ),
            ),
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
                      animals: _animals,
                      accentColor: widget.accentColor,
                      accentSoft: widget.accentSoft,
                      showCautionIcons: showCautionIcon,
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
                  if (!_isLoading && _loadError == null && _animals.isEmpty)
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
              widget.emptyText,
              style: const TextStyle(color: ARAColors.subInk),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(backgroundColor: ARAColors.cardBg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
