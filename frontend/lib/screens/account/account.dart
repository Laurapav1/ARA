import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_store.dart';
import '../../services/api_client.dart';
import '../../widgets/offline_banner.dart';
import '../../theme/ara_theme.dart';
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _fmtIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<DateTime?> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        final scheme = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: scheme.copyWith(
              primary: ARAColors.brand,
              secondary: ARAColors.brand,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: ARAColors.brand),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final picked = await _pickDate(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() {
      _startDate = picked;

      // If end date exists but is before new start date, clear end date.
      if (_endDate != null && _endDate!.isBefore(picked)) {
        _endDate = null;
      }
    });
  }

  Future<void> _selectEndDate() async {
    final now = DateTime.now();

    // If start isn't set, default start to "now" for constraints,
    // but still require user to pick start for submit.
    final start = _startDate ?? now;

    final picked = await _pickDate(
      context: context,
      initialDate: _endDate ?? start,
      firstDate: start, // ✅ cannot end before start
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() => _endDate = picked);
  }

  bool get _datesValid {
    if (_startDate == null || _endDate == null) return false;
    return !_endDate!.isBefore(_startDate!);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ARAColors.brand,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submitRequest() async {
    final formOk = _formKey.currentState!.validate();

    if (!formOk) return;

    if (_startDate == null) {
      _showSnack('Please select your start date');
      return;
    }
    if (_endDate == null) {
      _showSnack('Please select your end date');
      return;
    }
    if (!_datesValid) {
      _showSnack('End date must be the same as or after the start date');
      return;
    }

    final auth = context.read<AuthStore>();
    try {
      await auth.signUp(
        firstName: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        volunteerFrom: _fmtIso(_startDate!),
        volunteerTo: _fmtIso(_endDate!),
      );
    } on ApiException catch (e) {
      if (e.errors != null && e.errors!.isNotEmpty) {
        final firstError = e.errors!.values.first.isNotEmpty
            ? e.errors!.values.first.first
            : null;
        _showSnack(firstError ?? e.message);
      } else {
        _showSnack(e.message);
      }
      return;
    } catch (_) {
      _showSnack('Signup failed. Please try again.');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Request submitted',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ARAColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your account is pending approval. You will get access once a staff member approves your request.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ARAColors.inkSoft,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 10),
              Text(
                'Stay dates: ${_fmt(_startDate!)} – ${_fmt(_endDate!)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ARAColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _formKey.currentState!.reset();
                  _nameController.clear();
                  _lastNameController.clear();
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: ARAColors.brand,
                  foregroundColor: ARAColors.ink,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateCard({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ARAColors.surfaceWarmAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue ? ARAColors.brandDark : ARAColors.transparent,
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: hasValue ? ARAColors.brandDark : ARAColors.subInk,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: ARAColors.subInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hasValue ? _fmt(value) : 'Select date',
              style: TextStyle(
                color: hasValue ? ARAColors.ink : ARAColors.subInk,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create account & request access',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: ARAColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Share your details and stay dates so we can approve access.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: ARAColors.subInk),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                  hintText: 'Enter your first name',
                                ),
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Please enter your first name'
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                  hintText: 'Enter your last name',
                                ),
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Please enter your last name'
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  hintText: 'Enter your email',
                                ),
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Please enter your email'
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  hintText: 'Create a password',
                                ),
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Please enter a password'
                                        : null,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'You’ll use this password to sign in once your request is approved.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: ARAColors.subInk),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 1,
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withValues(alpha: 0.5),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'Stay dates',
                                      style: TextStyle(
                                        color: ARAColors.inkSoft,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 64,
                                    height: 1,
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _dateCard(
                                      label: 'Start',
                                      value: _startDate,
                                      icon: Icons.calendar_today,
                                      onTap: _selectStartDate,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _dateCard(
                                      label: 'End',
                                      value: _endDate,
                                      icon: Icons.event_available,
                                      onTap: _selectEndDate,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: _submitRequest,
                                style: FilledButton.styleFrom(
                                  backgroundColor: ARAColors.brand,
                                  foregroundColor: ARAColors.ink,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Submit Request',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Theme.of(context).dividerColor,
                                      height: 1,
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'Already have access?',
                                      style: TextStyle(
                                        color: ARAColors.subInk,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Theme.of(context).dividerColor,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: ARAColors.brandDark,
                                  ),
                                  child: const Text('Sign in'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
