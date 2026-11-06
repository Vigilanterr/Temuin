import 'package:flutter/material.dart';

import '../api/api_auth.dart';
import '../theme.dart';
import '../utils/validators.dart';
import '../widgets/auth_shell.dart';
import '../widgets/common.dart';
import 'app_shell.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await ApiAuth.login(
      _emailController.text.trim().toLowerCase(),
      _passwordController.text,
    );
    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _isLoading = false;
        _error = result.message;
      });
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

  Future<void> _openRegister() async {
    final registeredEmail = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
    if (registeredEmail != null && mounted) {
      _emailController.text = registeredEmail;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil. Silakan masuk.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selamat datang kembali',
              style: Theme.of(context).textTheme.headlineLarge
                  ?.copyWith(fontSize: 26),
            ),
            const SizedBox(height: 8),
            Text(
              'Masuk untuk melanjutkan ke laporan barang.',
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
              controller: _emailController,
              label: 'Email',
              hint: 'nama@email.com',
              prefixIcon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              textCapitalization: TextCapitalization.none,
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Password Anda',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: validatePassword,
              onFieldSubmitted: (_) => _handleLogin(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Masuk',
              isLoading: _isLoading,
              loadingLabel: 'Memeriksa akun...',
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Belum punya akun?',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _openRegister,
                  child: const Text('Daftar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
