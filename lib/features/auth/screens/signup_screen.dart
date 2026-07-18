import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
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
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).signup(
            _emailController.text.trim(),
            _usernameController.text.trim(),
            _passwordController.text,
            _fullNameController.text.trim(),
          );
      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authProvider);
    final isLoading = authState == AuthState.loading;

    return Scaffold(
      body: AuthGlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SizedBox(
              height: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 32,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 1),

                  Column(
                    children: [
                      Text(
                        'DrivePrep',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Create your revision profile',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withAlpha(160),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  AuthGlassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sign Up',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Full Name
                          AuthTextField(
                            label: 'Full Name',
                            hint: 'John Doe',
                            controller: _fullNameController,
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Username
                          AuthTextField(
                            label: 'Username',
                            hint: 'johndoe123',
                            controller: _usernameController,
                            prefixIcon: Icons.alternate_email_rounded,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Username is required';
                              }
                              if (val.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Email
                          AuthTextField(
                            label: 'Email',
                            hint: 'john@example.com',
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Email is required';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(val)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Password
                          AuthTextField(
                            label: 'Password',
                            hint: '••••••••',
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Password is required';
                              }
                              if (val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Confirm Password
                          AuthTextField(
                            label: 'Confirm Password',
                            hint: '••••••••',
                            controller: _confirmPasswordController,
                            prefixIcon: Icons.lock_clock_outlined,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Confirm password is required';
                              }
                              if (val != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Sign Up Button
                          ElevatedButton(
                            onPressed: isLoading ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0F4C81),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F4C81)),
                                    ),
                                  )
                                : Text(
                                    'Create Profile',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Already have account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.outfit(
                          color: Colors.white.withAlpha(160),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.outfit(
                            color: Colors.cyanAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
