import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/api_client.dart';
import '../../../services/auth_store.dart';
import '../../../theme/ara_theme.dart';

Future<bool?> showChangePasswordDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => const _ChangePasswordDialog(),
  );
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate() || _submitting) {
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthStore>().changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Unable to change password right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Change password'),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowButtonSpacing: 10,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentController,
              obscureText: true,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: 'Current password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newController,
              obscureText: true,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: 'New password',
                prefixIcon: Icon(Icons.lock_reset),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Enter a new password';
                }
                if (trimmed.length < 6) {
                  return 'Use at least 6 characters';
                }
                if (trimmed == _currentController.text.trim()) {
                  return 'Choose a different password';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmController,
              obscureText: true,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
              validator: (value) {
                if ((value?.trim() ?? '') != _newController.text.trim()) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ARAColors.danger.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ARAColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          style: FilledButton.styleFrom(
            minimumSize: const Size(140, 44),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
