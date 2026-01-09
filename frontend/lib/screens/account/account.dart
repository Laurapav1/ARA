import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mock_database.dart';
import '../../widgets/offline_banner.dart';
import '../../theme/ara_theme.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

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
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
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

  void _submitRequest() {
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

    final db = context.read<MockDatabase>();
    db.submitVolunteerRequest(
      firstName: _nameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      startOfStay: _startDate!,
      endOfStay: _endDate!,
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF66BB6A),
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Request Submitted',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF265073),
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your account is pending approval. You will get access once a staff member approves your request.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              // Optional: show selected period (small, nice feedback)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${_fmt(_startDate!)} to ${_fmt(_endDate!)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _quickSignIn() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign in'),
        actionsAlignment: MainAxisAlignment.center,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<MockDatabase>()
                  .setVolunteerStatus(VolunteerStatus.approved);
              _showSnack('Signed in. You can view shifts now.');
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _dateRow({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue ? ARAColors.brand : Colors.grey.shade200,
            width: hasValue ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasValue ? ARAColors.brand : Colors.grey.shade600,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                hasValue ? '$label: ${_fmt(value)}' : '$label: Select date',
                style: TextStyle(
                  color:
                      hasValue ? const Color(0xFF265073) : Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header card with your brand gradient
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [ARAColors.brand, ARAColors.brandDark],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.volunteer_activism,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Join as Volunteer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Help us make a difference',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.90),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

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
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),

                          // ✅ Start / End pickers (matches your screenshot layout)
                          _dateRow(
                            label: 'Start',
                            value: _startDate,
                            icon: Icons.calendar_today,
                            onTap: _selectStartDate,
                          ),
                          const SizedBox(height: 16),
                          _dateRow(
                            label: 'End',
                            value: _endDate,
                            icon: Icons.event_available,
                            onTap: _selectEndDate,
                          ),

                          const SizedBox(height: 20),

                          // Info note (amber family)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                              border: const Border.fromBorderSide(
                                BorderSide(color: Color(0xFFFFE0B2)),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: ARAColors.brand),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your request will be reviewed by our staff team before you can access the volunteer portal.',
                                    style: TextStyle(
                                      color: ARAColors.brand,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          FilledButton(
                            onPressed: _submitRequest,
                            child: const Text(
                              'Submit Request',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _quickSignIn,
                            child: const Text('Already approved? Sign in'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

