import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_glass_background.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (success && authState == AuthState.authenticated) {
      context.go('/home');
      return;
    }

    if (authState == AuthState.pendingVerification) {
      context.go(
        '/verify-email',
        extra: _emailController.text.trim(),
      );
      return;
    }

    final errorMsg = ref.read(authErrorProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg ?? 'Invalid credentials. Please try again.'),
        backgroundColor: const Color(0xFFD90429),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleGuestMode() async {
    await ref.read(authProvider.notifier).loginAsGuest();
    if (mounted) context.go('/home');
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
                  const SizedBox(height: 12),
                  _BrandHeader(),
                  const SizedBox(height: 36),
                  AuthGlassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AuthColors.alabaster,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in with your verified email',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AuthColors.alabaster.withAlpha(160),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AuthTextField(
                            label: 'Email Address',
                            hint: 'name@example.com',
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: AuthValidators.email,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            label: 'Password',
                            hint: '••••••••',
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              if (v.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.go('/forgot-password'),
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AuthColors.roseGoldSolid,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _PrimaryAuthButton(
                            label: 'Sign In',
                            isLoading: isLoading,
                            onPressed: _handleLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.outfit(
                          color: AuthColors.alabaster.withAlpha(170),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/signup'),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.outfit(
                            color: AuthColors.alabaster,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: isLoading ? null : _handleGuestMode,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AuthColors.alabaster,
                      side: BorderSide(color: AuthColors.roseGoldSolid.withAlpha(100)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Continue as Guest',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRect(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 0.6,
            child: Image.asset(
              'assets/logo2.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Text(
          'DrivePrep',
          style: GoogleFonts.outfit(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AuthColors.alabaster,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryAuthButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AuthColors.alabaster,
        foregroundColor: AuthColors.midnightNavy,
        disabledBackgroundColor: AuthColors.alabaster.withAlpha(180),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isLoading
          ? const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(AuthColors.midnightNavy),
        ),
      )
          : Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}