import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../models/handling_flag.dart';
import '../../services/animals_service.dart';
import '../../services/api_client.dart';
import '../../services/api_config.dart';
import '../../services/auth_store.dart';
import '../../theme/ara_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final isStaff = auth.isStaff;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(_animal.name)),
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
                    if (isStaff) ...[
                      FilledButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnimalEditorScreen(animal: _animal),
                            ),
                          );
                          await _loadDetails();
                        },
                        child: const Text('Edit details'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => showAnimalStatusDialog(
                          context,
                          _animal,
                          _deleteAnimal,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ARAColors.danger,
                          side: const BorderSide(color: Color(0xFFE47070)),
                        ),
                        child: const Text('Change status'),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _buildHero(Animal a) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: ARAColors.surfaceWarm,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ARAColors.surfaceWarmTint),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: ARAColors.softBackgroundGradient),
              child: Center(
                child: Icon(Icons.pets, size: 80, color: ARAColors.brandDark),
              ),
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
    final needsCaution = a.isDangerous || a.flags.isNotEmpty;
    final location = _buildLocationLabel(a);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                label: 'Handling',
                value: needsCaution ? 'Use caution' : 'No special notes',
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
    return Container(
      decoration: BoxDecoration(
        color: ARAColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ARAColors.surfaceWarmTint),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: const Text(
            'More information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ARAColors.ink,
            ),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down),
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
          color: isWarning ? ARAColors.cautionBorder : ARAColors.surfaceWarmTint,
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
