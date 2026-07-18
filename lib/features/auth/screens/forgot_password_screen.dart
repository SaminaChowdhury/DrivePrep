import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_glass_background.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showResetForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref.read(authProvider.notifier).requestPasswordReset(
          _emailController.text.trim(),
        );
    if (!mounted) return;
    if (result != null) {
      setState(() => _showResetForm = true);
      if (result['reset_token'] != null) {
        _tokenController.text = result['reset_token'] as String;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String? ?? 'Check your email for reset instructions.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = ref.read(authErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Request failed'), backgroundColor: const Color(0xFFD90429)),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_tokenController.text.isEmpty || _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid token and password (6+ characters)')),
      );
      return;
    }
    final success = await ref.read(authProvider.notifier).resetPassword(
          token: _tokenController.text.trim(),
          newPassword: _passwordController.text,
        );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. You can now sign in.')),
      );
      context.go('/login');
    } else {
      final error = ref.read(authErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Reset failed'), backgroundColor: const Color(0xFFD90429)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState == AuthState.loading;

    return Scaffold(
      body: AuthGlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Forgot Password',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _showResetForm
                      ? 'Enter the reset code and your new password'
                      : 'Enter your email to receive a reset code',
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withAlpha(160)),
                ),
                const SizedBox(height: 28),
                AuthGlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_showResetForm) ...[
                          AuthTextField(
                            label: 'Email Address',
                            hint: 'name@example.com',
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Email is required';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(val)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: isLoading ? null : _requestReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0F4C81),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text('Send Reset Code', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                          ),
                        ] else ...[
                          AuthTextField(
                            label: 'Reset Code',
                            hint: 'Paste code from email',
                            controller: _tokenController,
                            prefixIcon: Icons.vpn_key_outlined,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            label: 'New Password',
                            hint: '••••••••',
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.length < 6) return 'Min 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: isLoading ? null : _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0F4C81),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text('Update Password', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
