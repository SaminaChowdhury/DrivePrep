import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_glass_background.dart';
import '../widgets/auth_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final success = await ref.read(authProvider.notifier).signup(
          email: email,
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Account created. Please verify your email before signing in.',
          ),
          backgroundColor: const Color(0xFF00A896),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      // No auto-login — go to verification screen.
      context.go('/verify-email', extra: email);
      return;
    }

    final errorMsg = ref.read(authErrorProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg ?? 'Registration failed. Please try again.'),
        backgroundColor: const Color(0xFFD90429),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState == AuthState.loading;

    return Scaffold(
      body: AuthGlassBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'DrivePrep',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AuthColors.alabaster,
                    ),
                  ),
                  Text(
                    'Create your revision profile',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AuthColors.alabaster.withAlpha(160),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AuthGlassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign Up',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AuthColors.alabaster,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'We will send a verification link to your email',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AuthColors.alabaster.withAlpha(150),
                            ),
                          ),
                          const SizedBox(height: 18),
                          AuthTextField(
                            label: 'Full Name',
                            hint: 'John Doe',
                            controller: _fullNameController,
                            prefixIcon: Icons.person_outline_rounded,
                            validator: AuthValidators.fullName,
                          ),
                          const SizedBox(height: 12),
                          AuthTextField(
                            label: 'Email',
                            hint: 'john@example.com',
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: AuthValidators.email,
                          ),
                          const SizedBox(height: 12),
                          AuthTextField(
                            label: 'Password',
                            hint: 'Min 8 chars, mixed case + number',
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: AuthValidators.password,
                          ),
                          const SizedBox(height: 12),
                          AuthTextField(
                            label: 'Confirm Password',
                            hint: '••••••••',
                            controller: _confirmPasswordController,
                            prefixIcon: Icons.lock_clock_outlined,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: (v) => AuthValidators.confirmPassword(
                              v,
                              _passwordController.text,
                            ),
                          ),
                          const SizedBox(height: 22),
                          ElevatedButton(
                            onPressed: isLoading ? null : _handleSignup,
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
                                    'Create Account',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.outfit(
                          color: AuthColors.alabaster.withAlpha(160),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'Login',
                          style: GoogleFonts.outfit(
                            color: AuthColors.alabaster,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
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
