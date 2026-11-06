import 'package:flutter/material.dart';

import '../api/api_auth.dart';
import '../theme.dart';
import '../utils/validators.dart';
import '../widgets/common.dart';
import '../widgets/auth_shell.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await ApiAuth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _isLoading = false;
        _error = result.message;
      });
      return;
    }

    setState(() => _isLoading = false);
    Navigator.pop(context, _emailController.text.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      showBack: true,
      onBack: () => Navigator.pop(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Buat akun baru',
              style: Theme.of(context).textTheme.headlineLarge
                  ?.copyWith(fontSize: 26),
            ),
            const SizedBox(height: 8),
            Text(
              'Bergabunglah dengan komunitas Temuin.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            if (_error != null) ...[
              InfoBanner(
                message: _error!,
                icon: Icons.error_outline_rounded,
                backgroundColor: AppColors.errorSurface,
                foregroundColor: AppColors.error,
              ),
              const SizedBox(height: 18),
            ],
            AppTextField(
              controller: _nameController,
              label: 'Nama lengkap',
              prefixIcon: Icons.person_outline_rounded,
              autofillHints: const [AutofillHints.name],
              validator: (value) => validateRequired(value, 'Nama lengkap'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'nama@email.com',
              prefixIcon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: validatePassword,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _confirmController,
              label: 'Konfirmasi password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) =>
                  validateConfirmPassword(v, _passwordController.text),
              onFieldSubmitted: (_) => _handleRegister(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Daftar',
              isLoading: _isLoading,
              loadingLabel: 'Mendaftar...',
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Sudah punya akun?',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Masuk'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
