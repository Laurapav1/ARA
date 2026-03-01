import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_store.dart';
import '../../services/api_client.dart';
import '../../widgets/form_field_card.dart';
import '../../theme/ara_theme.dart';
import 'login_screen.dart';
import 'widgets/auth_form_shell.dart';

class RequestAccessScreen extends StatefulWidget {
  const RequestAccessScreen({super.key});

  @override
  State<RequestAccessScreen> createState() => _RequestAccessScreenState();
}

class _RequestAccessScreenState extends State<RequestAccessScreen> {
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
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _selectStayRange() async {
    final now = _dateOnly(DateTime.now());
    final pickedRange = await showDialog<DateTimeRange>(
      context: context,
      builder: (ctx) => _StayDateRangeDialog(
        initialStart: _startDate,
        initialEnd: _endDate,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
      ),
    );
    if (pickedRange == null) return;
    setState(() {
      _startDate = _dateOnly(pickedRange.start);
      _endDate = _dateOnly(pickedRange.end);
    });
  }

  bool get _datesValid {
    if (_startDate == null || _endDate == null) return false;
    return _endDate!.isAfter(_startDate!);
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

  void _clearRequestForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
    });
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
      _showSnack('End stay must be after the start stay');
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
                  _clearRequestForm();
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
          color: ARAColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                hasValue ? ARAColors.brandDark : Theme.of(context).dividerColor,
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: hasValue ? ARAColors.ink : ARAColors.subInk,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    final fieldFill = Theme.of(context).cardColor;
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: dividerColor),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: ARAColors.brand, width: 2),
    );

    return AuthFormShell(
      title: 'Create account & request access',
      subtitle: 'Share your details and stay dates so we can approve access.',
      showOfflineBanner: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                              FormFieldCard(
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'First Name',
                                    prefixIcon: const Icon(Icons.person_outline),
                                    hintText: 'Enter your first name',
                                    filled: true,
                                    fillColor: fieldFill,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    labelStyle: const TextStyle(
                                      color: ARAColors.subInk,
                                      fontSize: 14,
                                    ),
                                    floatingLabelStyle: const TextStyle(
                                      color: ARAColors.subInk,
                                      fontSize: 12,
                                    ),
                                    border: fieldBorder,
                                    enabledBorder: fieldBorder,
                                    focusedBorder: focusedBorder,
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                          ? 'Please enter your first name'
                                          : null,
                                ),
                              ),
                              const SizedBox(height: 14),
                              FormFieldCard(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Last Name',
                                    prefixIcon: const Icon(Icons.person_outline),
                                    hintText: 'Enter your last name',
                                    filled: true,
                                    fillColor: fieldFill,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    labelStyle: const TextStyle(
                                      color: ARAColors.subInk,
                                      fontSize: 14,
                                    ),
                                    floatingLabelStyle: const TextStyle(
                                      color: ARAColors.subInk,
                                      fontSize: 12,
                                    ),
                                    border: fieldBorder,
                                    enabledBorder: fieldBorder,
                                    focusedBorder: focusedBorder,
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                          ? 'Please enter your last name'
                                          : null,
                                ),
                              ),
                              const SizedBox(height: 14),
                              FormFieldCard(
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    hintText: 'Enter your email',
                                    filled: true,
                                    fillColor: fieldFill,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    labelStyle: const TextStyle(
                                      color: ARAColors.subInk,
                                      fontSize: 14,
                                    ),
                                    floatingLabelStyle: const TextStyle(
                                      color: ARAColors.subInk,
                                      fontSize: 12,
                                    ),
                                    border: fieldBorder,
                                    enabledBorder: fieldBorder,
                                    focusedBorder: focusedBorder,
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                          ? 'Please enter your email'
                                          : null,
                                ),
                              ),
                              const SizedBox(height: 14),
                              FormFieldCard(
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    hintText: 'Create a password',
                                    filled: true,
                                    fillColor: fieldFill,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    labelStyle: const TextStyle(
                                      color: ARAColors.subInk,
                                      fontSize: 14,
                                    ),
                                    floatingLabelStyle: const TextStyle(
                                      color: ARAColors.subInk,
                                      fontSize: 12,
                                    ),
                                    border: fieldBorder,
                                    enabledBorder: fieldBorder,
                                    focusedBorder: focusedBorder,
                                  ),
                                  validator: (value) {
                                    final password = value?.trim() ?? '';
                                    if (password.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (password.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "You'll use this password to sign in once your request is approved.",
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
                                      label: 'Start stay',
                                      value: _startDate,
                                      icon: Icons.calendar_today,
                                      onTap: _selectStayRange,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _dateCard(
                                      label: 'End stay',
                                      value: _endDate,
                                      icon: Icons.event_available,
                                      onTap: _selectStayRange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: _submitRequest,
                                child: const Text('Submit Request'),
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
                                  onPressed: () => Navigator.pushReplacement(
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
    );
  }
}

class _StayDateRangeDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final DateTime firstDate;
  final DateTime lastDate;

  const _StayDateRangeDialog({
    required this.initialStart,
    required this.initialEnd,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_StayDateRangeDialog> createState() => _StayDateRangeDialogState();
}

class _StayDateRangeDialogState extends State<_StayDateRangeDialog> {
  DateTime? _start;
  DateTime? _end;
  late DateTime _focusedMonth;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  bool _isDisabled(DateTime day) =>
      day.isBefore(widget.firstDate) || day.isAfter(widget.lastDate);

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart != null ? _dateOnly(widget.initialStart!) : null;
    _end = widget.initialEnd != null ? _dateOnly(widget.initialEnd!) : null;

    final fallback = _dateOnly(DateTime.now());
    _focusedMonth = _start ?? fallback;
    if (_focusedMonth.isBefore(widget.firstDate)) _focusedMonth = widget.firstDate;
    if (_focusedMonth.isAfter(widget.lastDate)) _focusedMonth = widget.lastDate;
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
  }

  void _onDayTap(DateTime day) {
    if (_isDisabled(day)) return;
    setState(() {
      if (_start == null || _end != null) {
        _start = day;
        _end = null;
        return;
      }
      if (day.isAfter(_start!)) {
        _end = day;
        Navigator.of(context).pop(DateTimeRange(start: _start!, end: _end!));
      } else {
        _start = day;
        _end = null;
      }
    });
  }

  void _changeMonth(int delta) {
    final next = DateTime(_focusedMonth.year, _focusedMonth.month + delta, 1);
    final minMonth = DateTime(widget.firstDate.year, widget.firstDate.month, 1);
    final maxMonth = DateTime(widget.lastDate.year, widget.lastDate.month, 1);
    if (next.isBefore(minMonth) || next.isAfter(maxMonth)) return;
    setState(() => _focusedMonth = next);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final monthLabel = localizations.formatMonthYear(_focusedMonth);
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstWeekdaySundayBased = firstOfMonth.weekday % 7;
    final leadingBlanks = (firstWeekdaySundayBased -
            localizations.firstDayOfWeekIndex +
            7) %
        7;
    final totalCells = ((leadingBlanks + daysInMonth + 6) ~/ 7) * 7;
    final today = _dateOnly(DateTime.now());

    final title = _start == null || _end != null
        ? 'Select arrival date'
        : 'Select departure date';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: ARAColors.surfaceWarm,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: ARAColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: ARAColors.subInk),
                  tooltip: 'Close',
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      monthLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: ARAColors.inkStrong,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(7, (index) {
                final weekday =
                    (localizations.firstDayOfWeekIndex + index) % 7;
                return Expanded(
                  child: Center(
                    child: Text(
                      localizations.narrowWeekdays[weekday],
                      style: const TextStyle(
                        color: ARAColors.subInk,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.05,
              ),
              itemCount: totalCells,
              itemBuilder: (context, index) {
                final dayNumber = index - leadingBlanks + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final day =
                    DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                final isStart = _start != null && _isSameDay(day, _start!);
                final isEnd = _end != null && _isSameDay(day, _end!);
                final inRange = _start != null &&
                    _end != null &&
                    day.isAfter(_start!) &&
                    day.isBefore(_end!);
                final isSelected = isStart || isEnd;
                final isToday = _isSameDay(day, today);
                final isDisabled = _isDisabled(day);

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isDisabled ? null : () => _onDayTap(day),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (inRange)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 16,
                          bottom: 16,
                          child: Container(
                            color: ARAColors.brand.withValues(alpha: 0.20),
                          ),
                        ),
                      if (isStart && _end != null)
                        Positioned(
                          left: 20,
                          right: 0,
                          top: 16,
                          bottom: 16,
                          child: Container(
                            color: ARAColors.brand.withValues(alpha: 0.20),
                          ),
                        ),
                      if (isEnd && _start != null)
                        Positioned(
                          left: 0,
                          right: 20,
                          top: 16,
                          bottom: 16,
                          child: Container(
                            color: ARAColors.brand.withValues(alpha: 0.20),
                          ),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? ARAColors.brand : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            color: isDisabled
                                ? ARAColors.subInk.withValues(alpha: 0.38)
                                : isSelected
                                    ? ARAColors.ink
                                    : ARAColors.inkStrong,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isToday && !isSelected)
                        Positioned(
                          bottom: 9,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: ARAColors.subInk.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

