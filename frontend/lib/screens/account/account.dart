import 'package:flutter/material.dart';
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
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF66BB6A).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Color(0xFF66BB6A), size: 64),
                ),
                const SizedBox(height: 24),
                Text(
                  'Request Submitted!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF265073),
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'A staff member will review your request soon. You\'ll receive access once approved.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _formKey.currentState!.reset();
                    _nameController.clear();
                    _lastNameController.clear();
                    setState(() => _selectedDate = null);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Please select your end of stay date')),
            ],
          ),
          backgroundColor: ARAColors.brand,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The Scaffold already uses your white-ish bg via ARATheme.light.scaffoldBackgroundColor
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
                            color: Colors.black.withOpacity(0.08),
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
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.volunteer_activism,
                                color: Colors.white, size: 48),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Join as Volunteer',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Help us make a difference',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Form (inherits InputDecorationTheme from ARATheme)
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

                          // End-of-stay picker
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedDate == null
                                      ? Colors.grey.shade200
                                      : ARAColors.brand,
                                  width: _selectedDate == null ? 1 : 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: _selectedDate == null
                                        ? Colors.grey.shade600
                                        : ARAColors.brand,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      _selectedDate == null
                                          ? 'Select end of stay'
                                          : 'End of stay: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                      style: TextStyle(
                                        color: _selectedDate == null
                                            ? Colors.grey.shade600
                                            : const Color(0xFF265073),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.grey.shade400),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

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
                                        color: ARAColors.brand, fontSize: 13),
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
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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
