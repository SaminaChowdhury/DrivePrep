import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_glass_background.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String? email;

  const VerifyEmailScreen({super.key, this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  late String _email;

  @override
  void initState() {
    super.initState();
    _email = widget.email?.trim() ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_email.isEmpty) {
      _email = ref.read(pendingVerificationEmailProvider) ?? '';
    }
  }

  Future<void> _resend() async {
    if (_email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing email. Please sign up again.')),
      );
      return;
    }

    final ok = await ref.read(authProvider.notifier).resendVerificationEmail(
          email: _email,
        );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification email sent. Check your inbox.'),
          backgroundColor: const Color(0xFF00A896),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      final error = ref.read(authErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Could not resend email'),
          backgroundColor: const Color(0xFFD90429),
        ),
      );
    }
  }

  Future<void> _iveVerified() async {
    if (_email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing email. Please sign up again.')),
      );
      return;
    }

    final ok = await ref.read(authProvider.notifier).confirmEmailVerified(
          email: _email,
        );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email verified. Please sign in to continue.'),
          backgroundColor: const Color(0xFF00A896),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      context.go('/login');
    } else {
      final error = ref.read(authErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Email not verified yet'),
          backgroundColor: const Color(0xFFD90429),
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
                const SizedBox(height: 8),
                Icon(
                  Icons.mark_email_unread_rounded,
                  size: 64,
                  color: AuthColors.alabaster.withAlpha(220),
                ),
                const SizedBox(height: 16),
                Text(
                  'Verify Your Email',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AuthColors.alabaster,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _email.isEmpty
                      ? 'Open the verification link we sent, then tap below.'
                      : 'We sent a link to $_email.\nOpen it, then tap “I’ve Verified” — no password needed.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    height: 1.45,
                    color: AuthColors.alabaster.withAlpha(175),
                  ),
                ),
                const SizedBox(height: 28),
                AuthGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_email.isNotEmpty) ...[
                        Text(
                          'Verifying for',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AuthColors.alabaster.withAlpha(150),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AuthColors.alabaster,
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                      ElevatedButton(
                        onPressed: isLoading ? null : _iveVerified,
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
                                "I've Verified",
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
                              ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: isLoading ? null : _resend,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AuthColors.alabaster,
                          side: BorderSide(color: AuthColors.roseGoldSolid.withAlpha(120)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Resend Verification Email',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
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
