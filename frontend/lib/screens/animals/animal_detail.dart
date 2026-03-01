import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../models/handling_flag.dart';
import '../../services/animals_service.dart';
import '../../services/api_client.dart';
import '../../services/api_config.dart';
import '../../services/auth_store.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/expandable_section.dart';
import '../../widgets/handling_flag_chips.dart';
import '../../widgets/offline_banner.dart';
import 'animal_editor.dart';
import 'animal_status_dialog.dart';

class AnimalDetailScreen extends StatefulWidget {
  final Animal animal;
  const AnimalDetailScreen({super.key, required this.animal});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  late final AnimalsService _animalsService;
  late Animal _animal;
  bool _moreInfoExpanded = false;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _animalsService = AnimalsService(ApiClient(ApiConfig.baseUrl));
    _animal = widget.animal;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final auth = context.read<AuthStore>();
      final detailed = await _animalsService.getAnimalById(
        widget.animal.id,
        token: auth.accessToken,
      );
      if (!mounted) return;
      setState(() => _animal = detailed);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAnimal() async {
    final auth = context.read<AuthStore>();
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      _showMessage('Missing login token.');
      return;
    }
    try {
      await _animalsService.deleteAnimal(id: _animal.id, token: token);
    } catch (e) {
      _showMessage('Failed to remove animal: $e');
      rethrow;
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _editAnimal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimalEditorScreen(animal: _animal),
      ),
    );
    await _loadDetails();
  }

  Future<void> _changeStatus() async {
    await showAnimalStatusDialog(
      context,
      _animal,
      _deleteAnimal,
    );
  }

  Future<void> _openAnimalActionsSheet() async {
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
              title: const Text('Edit details'),
              onTap: () async {
                Navigator.pop(ctx);
                if (!mounted) return;
                await _editAnimal();
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: ARAColors.danger),
              title: const Text(
                'Change status',
                style: TextStyle(color: ARAColors.danger),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                if (!mounted) return;
                await _changeStatus();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final isStaff = auth.isStaff;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_animal.name),
        titleTextStyle: ARATypography.detailNavTitle,
        actions: isStaff
            ? [
                IconButton(
                  onPressed: _openAnimalActionsSheet,
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Animal actions',
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _ErrorState(error: _loadError!, onRetry: _loadDetails)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const OfflineBanner(),
                    const SizedBox(height: 16),
                    _buildHero(_animal),
                    const SizedBox(height: 16),
                    _buildInfoRow(_animal),
                    const SizedBox(height: 16),
                    _buildNotesSection(_animal),
                    const SizedBox(height: 12),
                    _buildMoreInfo(context, _animal),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }

  Widget _buildHero(Animal a) {
    final heroMedia = a.photoBytes == null
        ? const DecoratedBox(
            decoration: BoxDecoration(gradient: ARAColors.softBackgroundGradient),
            child: Center(
              child: Icon(Icons.pets, size: 80, color: ARAColors.brandDark),
            ),
          )
        : Image.memory(
            a.photoBytes!,
            fit: BoxFit.cover,
          );

    return Container(
      height: 270,
      decoration: BoxDecoration(
        color: ARAColors.surfaceWarm,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ARAColors.surfaceWarmTint),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: heroMedia,
            ),
          ),
          if (a.flags.isNotEmpty)
            Positioned(
              right: 12,
              bottom: 12,
              child: _FlagOverlay(flags: a.flags),
            ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                a.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(Animal a) {
    final needsCaution = a.isDangerous;
    final location = _buildLocationLabel(a);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                label: 'Safety Status',
                value: needsCaution ? 'Use caution' : 'Friendly',
                isWarning: needsCaution,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                label: 'Kennel / Zone',
                value: location,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildNotesSection(Animal a) {
    return Column(
      children: [
        _NoteCard(
          title: 'Handling Notes',
          body: _buildHandlingNotes(a),
        ),
      ],
    );
  }

  Widget _buildMoreInfo(BuildContext context, Animal a) {
    return ExpandableSection(
      title: 'More information',
      isExpanded: _moreInfoExpanded,
      onChanged: (expanded) => setState(() => _moreInfoExpanded = expanded),
      borderRadius: 18,
      headerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      backgroundColor: ARAColors.cardBg,
      borderColor: ARAColors.surfaceWarmTint,
      titleStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: ARAColors.ink,
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.pets,
            label: 'Age',
            value: _formatAge(a.age),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: ARAColors.surfaceWarmTint),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.bubble_chart_outlined,
            label: 'Breed',
            value: _orNotSet(a.breed),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: ARAColors.surfaceWarmTint),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.wc,
            label: 'Gender',
            value: _orNotSet(a.gender),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: ARAColors.surfaceWarmTint),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.place_outlined,
            label: 'History',
            value: a.history.isNotEmpty ? a.history : 'No history yet.',
          ),
        ],
      ),
    );
  }

  String _orNotSet(String value) {
    if (value.trim().isEmpty) return 'Not set';
    return value.trim();
  }

  String _formatAge(String value) {
    if (value.trim().isEmpty) return 'Not set';
    final years = int.tryParse(value.trim());
    if (years == null) return value.trim();
    return years == 1 ? '1 year' : '$years years';
  }

  String _buildHandlingNotes(Animal a) {
    if (a.description.trim().isNotEmpty) return a.description.trim();
    if (a.isDangerous || a.flags.isNotEmpty) {
      return 'Check the handling flags for this animal.';
    }
    return 'No handling notes yet.';
  }

  String _buildLocationLabel(Animal a) {
    if (a.zone.trim().isNotEmpty) return a.zone.trim();
    return 'Not set';
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: ARAColors.danger),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ARAColors.subInk),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;

  const _InfoTile({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning ? ARAColors.cautionSurface : ARAColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isWarning ? ARAColors.cautionBorder : ARAColors.surfaceWarmTint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ARAColors.subInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isWarning ? ARAColors.cautionText : ARAColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String title;
  final String body;

  const _NoteCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ARAColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ARAColors.surfaceWarmTint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ARAColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: ARAColors.subInk)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ARAColors.subInk),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ARAColors.subInk,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ARAColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlagOverlay extends StatelessWidget {
  final Set<HandlingFlag> flags;

  const _FlagOverlay({required this.flags});

  @override
  Widget build(BuildContext context) {
    return HandlingFlagChips(flags: flags);
  }
}
