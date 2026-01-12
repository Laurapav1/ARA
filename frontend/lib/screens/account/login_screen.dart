import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_store.dart';
import '../../services/api_client.dart';
import '../../widgets/form_field_card.dart';
import '../../theme/ara_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
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

  Future<void> _signIn() async {
    final formOk = _formKey.currentState!.validate();
    if (!formOk) return;

    final auth = context.read<AuthStore>();
    try {
      await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      _showSnack('Signed in. You can view shifts now.');
      Navigator.pop(context);
    } on ApiException catch (error) {
      if (error.errors != null && error.errors!.isNotEmpty) {
        final firstError = error.errors!.values.first.isNotEmpty
            ? error.errors!.values.first.first
            : null;
        _showSnack(firstError ?? error.message);
        return;
      }
      _showSnack(error.message);
    } catch (_) {
      _showSnack('Login failed. Please try again.');
    }
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: ARAColors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: ARAColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use your approved account to access shifts and updates.',
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
                        FormFieldCard(
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: const Icon(Icons.email_outlined),
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
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outline),
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
                                    ? 'Please enter your password'
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: _signIn,
                          style: FilledButton.styleFrom(
                            backgroundColor: ARAColors.brand,
                            foregroundColor: ARAColors.ink,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Need access? Request approval'),
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
    );
  }
}
