import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/offline_banner.dart';
import '../../theme/ara_theme.dart';
import '../../services/auth_store.dart';
import '../../services/volunteers_service.dart';
import '../../services/api_client.dart';
import '../../widgets/search_field.dart';

class VolunteerRequestsScreen extends StatefulWidget {
  const VolunteerRequestsScreen({super.key});

  @override
  State<VolunteerRequestsScreen> createState() =>
      _VolunteerRequestsScreenState();
}

class _VolunteerRequestsScreenState extends State<VolunteerRequestsScreen> {
  final _service = VolunteersService();
  List<PendingVolunteer> _requests = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<List<PendingVolunteer>> _loadPending() async {
    final auth = context.read<AuthStore>();
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      throw ApiException(401, 'Please sign in as staff.');
    }
    try {
      final list = await _service.getPending(token: token);
      if (!mounted) return list;
      setState(() {
        _requests = list;
        _loading = false;
        _error = null;
      });
      auth.setPendingRequestsCount(_requests.length);
      return list;
    } on ApiException catch (e) {
      if (!mounted) return [];
      setState(() {
        _loading = false;
        _error = e.message;
      });
      auth.setPendingRequestsCount(0);
      return [];
    } catch (_) {
      if (!mounted) return [];
      setState(() {
        _loading = false;
        _error = 'Could not load requests.';
      });
      auth.setPendingRequestsCount(0);
      return [];
    }
  }

  Future<void> _approve(PendingVolunteer request) async {
    final auth = context.read<AuthStore>();
    final token = auth.accessToken ?? '';
    try {
      await _service.approve(id: request.id, token: token);
      setState(() {
        _requests = _requests.where((r) => r.id != request.id).toList();
      });
      auth.setPendingRequestsCount(_requests.length);
      _showSnack('${request.fullName} approved!', ARAColors.success);
    } on ApiException catch (e) {
      _showSnack(e.message, ARAColors.danger);
    }
  }

  Future<void> _decline(PendingVolunteer request) async {
    final auth = context.read<AuthStore>();
    final token = auth.accessToken ?? '';
    try {
      await _service.decline(id: request.id, token: token);
      setState(() {
        _requests = _requests.where((r) => r.id != request.id).toList();
      });
      auth.setPendingRequestsCount(_requests.length);
      _showSnack('Request declined', ARAColors.danger);
    } on ApiException catch (e) {
      _showSnack(e.message, ARAColors.danger);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleRequests = _filterRequests(_requests, _query);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Volunteer requests',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: ARAColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _loading ? 'Loading...' : '${_requests.length} pending',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: ARAColors.subInk),
                    ),
                  ],
                ),
              ),
            ),
            if (!_loading && _error == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: SearchField(
                  onChanged: (value) => setState(() => _query = value),
                  hintText: 'Search by name or email',
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState(context, _error!)
                      : _requests.isEmpty
                          ? _buildEmptyState(context)
                          : visibleRequests.isEmpty
                              ? _buildNoResultsState(context)
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: visibleRequests.length,
                                  itemBuilder: (context, index) {
                                    final request = visibleRequests[index];
                                    return _VolunteerRequestCard(
                                      request: request,
                                      onAccept: () => _approve(request),
                                      onDecline: () =>
                                          _showDeclineDialog(context, request),
                                    );
                                  },
                                ),
            ),
          ],
        ),
      ),
    );
  }

  List<PendingVolunteer> _filterRequests(
    List<PendingVolunteer> requests,
    String query,
  ) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return requests;
    final needle = trimmed.toLowerCase();
    return requests
        .where((r) =>
            r.fullName.toLowerCase().contains(needle) ||
            r.email.toLowerCase().contains(needle))
        .toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ARAColors.surfaceCool,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline,
                size: 80, color: ARAColors.subInk),
          ),
          const SizedBox(height: 24),
          Text(
            'All caught up!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ARAColors.ink,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending volunteer requests',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ARAColors.subInk,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: ARAColors.subInk),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ARAColors.subInk,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 72, color: ARAColors.subInk),
          const SizedBox(height: 16),
          Text(
            'No matches found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ARAColors.ink,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different name or email.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ARAColors.subInk,
                ),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, PendingVolunteer request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: ARAColors.brandDark),
            SizedBox(width: 12),
            Text('Decline Request'),
          ],
        ),
        content: const Text(
          'Are you sure you want to decline this volunteer request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _decline(request);
            },
            style: FilledButton.styleFrom(
              backgroundColor: ARAColors.danger,
              foregroundColor: ARAColors.cardBg,
            ),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }
}

class _VolunteerRequestCard extends StatelessWidget {
  final PendingVolunteer request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _VolunteerRequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: ARAColors.ink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ARAColors.surfaceCoolSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person,
                      color: ARAColors.brandDark, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.fullName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: ARAColors.ink,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ARAColors.subInk,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoPill(
                    title: 'Requested',
                    value: request.requestedAtLabel,
                    icon: Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoPill(
                    title: 'Stay',
                    value: request.stayLabel,
                    icon: Icons.event_available,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: ARAColors.dangerLight),
                      foregroundColor: ARAColors.danger,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Decline',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onAccept,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: ARAColors.brand,
                      foregroundColor: ARAColors.ink,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoPill({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ARAColors.surfaceCoolSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ARAColors.brandDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ARAColors.subInk,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ARAColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
