import 'package:flutter/material.dart';
import '../common/access_gate.dart';
import 'shifts.dart';

class ShiftsEntryScreen extends StatelessWidget {
  final bool isApproved;
  final bool isPending;
  final VoidCallback onOpenAccount;
  final VoidCallback onOpenInfo;

  const ShiftsEntryScreen({
    super.key,
    required this.isApproved,
    required this.isPending,
    required this.onOpenAccount,
    required this.onOpenInfo,
  });

  @override
  Widget build(BuildContext context) {
    return AccessGate(
      allowed: isApproved,
      title: isPending ? 'Waiting for approval' : 'Volunteer access required',
      message: isPending
          ? 'Your request is pending review. You will get access once approved.'
          : 'Sign in or submit a volunteer request\nto access shifts.',
      ctaLabel: isPending ? 'Go to Info' : 'Apply or Sign In',
      onCta: isPending ? onOpenInfo : onOpenAccount,
      child: const ShiftsScreen(),
    );
  }
}
