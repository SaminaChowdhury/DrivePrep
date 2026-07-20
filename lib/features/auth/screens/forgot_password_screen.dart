import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';
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
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(authProvider.notifier).requestPasswordReset(
          _emailController.text.trim(),
        );

    if (!mounted) return;

    if (ok) {
      setState(() => _emailSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password reset email sent. Check your inbox.'),
          backgroundColor: const Color(0xFF00A896),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      final error = ref.read(authErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Request failed'),
          backgroundColor: const Color(0xFFD90429),
          behavior: SnackBarBehavior.floating,
        ),
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
                    icon: const Icon(Icons.arrow_back_rounded, color: AuthColors.alabaster),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Forgot Password',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AuthColors.alabaster,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _emailSent
                      ? 'We sent a reset link to your email. Follow it to set a new password.'
                      : 'Enter your account email and we will send a reset link.',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AuthColors.alabaster.withAlpha(170),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                AuthGlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          label: 'Email Address',
                          hint: 'name@example.com',
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: AuthValidators.email,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: isLoading ? null : _sendReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AuthColors.alabaster,
                            foregroundColor: AuthColors.midnightNavy,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AuthColors.midnightNavy,
                                    ),
                                  ),
                                )
                              : Text(
                                  _emailSent ? 'Resend Reset Link' : 'Send Reset Link',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Back to Sign In',
                    style: GoogleFonts.outfit(
                      color: AuthColors.alabaster,
                      fontWeight: FontWeight.w700,
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
