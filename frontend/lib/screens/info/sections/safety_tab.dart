part of '../information.dart';

class _SafetyTab extends StatelessWidget {
  const _SafetyTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: const [
        _SectionCard(
          title: 'Safety and incidents (general)',
          child: _SafetyContent(),
        ),
      ],
    );
  }
}

class _SafetyContent extends StatelessWidget {
  const _SafetyContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rules',
          style: TextStyle(fontWeight: FontWeight.w700, color: ARAColors.inkStrong),
        ),
        SizedBox(height: 8),
        _BulletList(items: _safetyRules),
        SizedBox(height: 12),
        Text(
          'Incident steps',
          style: TextStyle(fontWeight: FontWeight.w700, color: ARAColors.inkStrong),
        ),
        SizedBox(height: 8),
        _NumberedList(items: _incidentSteps),
      ],
    );
  }
}
