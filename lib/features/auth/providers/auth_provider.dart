import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';
import '../utils/firebase_auth_errors.dart';

enum AuthState {
  initial,
  authenticated,
  guest,
  unauthenticated,
  loading,
  error,
  /// Account exists but email is not verified yet.
  pendingVerification,
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});

final authErrorProvider = StateProvider<String?>((ref) => null);

/// Email awaiting verification (for the verify-email screen).
final pendingVerificationEmailProvider = StateProvider<String?>((ref) => null);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService, this._ref) : super(AuthState.initial);

  final AuthService _authService;
  final Ref _ref;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void _setError(String message) {
    _ref.read(authErrorProvider.notifier).state = message;
    state = AuthState.error;
  }

  /// Sign in — only succeeds when email is verified.
  Future<bool> login(String email, String password) async {
    state = AuthState.loading;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      await _authService.setGuestMode(false);
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        _setError('Sign in failed. Please try again.');
        return false;
      }

      await user.reload();
      final refreshed = _firebaseAuth.currentUser;
      if (refreshed == null) {
        _setError('Sign in failed. Please try again.');
        return false;
      }

      if (!refreshed.emailVerified) {
        _ref.read(pendingVerificationEmailProvider.notifier).state =
            refreshed.email;
        // Keep session so resend works, but do not grant app access.
        state = AuthState.pendingVerification;
        return false;
      }

      final token = await refreshed.getIdToken();
      if (token != null && token.isNotEmpty) {
        await _authService.saveToken(token);
      }
      state = AuthState.authenticated;
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('[Auth] Login failed: ${e.code}');
      _setError(mapFirebaseAuthError(e));
      return false;
    } catch (e) {
      debugPrint('[Auth] Login unexpected: $e');
      _setError('An unexpected error occurred.');
      return false;
    }
  }

  /// Create account, send verification email.
  /// Keeps a Firebase session for email-only verification, but does not grant app access.
  Future<bool> signup({
    required String email,
    required String password,
    required String fullName,
    String? username,
  }) async {
    state = AuthState.loading;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      await _authService.setGuestMode(false);
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        _setError('Registration failed. Please try again.');
        return false;
      }

      final displayName = fullName.trim().isNotEmpty
          ? fullName.trim()
          : (username?.trim().isNotEmpty == true ? username!.trim() : null);
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      await user.sendEmailVerification();

      // No app auto-login — stay pending until email is verified, then user signs in.
      await _authService.deleteToken();
      _ref.read(pendingVerificationEmailProvider.notifier).state = email.trim();
      state = AuthState.pendingVerification;
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('[Auth] Signup failed: ${e.code}');
      _setError(mapFirebaseAuthError(e));
      return false;
    } catch (e) {
      debugPrint('[Auth] Signup unexpected: $e');
      _setError('An unexpected error occurred.');
      return false;
    }
  }

  /// Guest mode — unchanged local/offline behavior (no Firebase session).
  Future<bool> loginAsGuest() async {
    state = AuthState.loading;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      // Ensure any Firebase session is cleared so guest stays isolated.
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.signOut();
      }
      await _authService.setGuestMode(true);
      state = AuthState.guest;
      return true;
    } catch (e) {
      debugPrint('[Auth] Guest fallback: $e');
      await _authService.setGuestMode(true);
      state = AuthState.guest;
      return true;
    }
  }

  Future<void> logout() async {
    state = AuthState.loading;
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
    await _authService.deleteToken();
    await _authService.setGuestMode(false);
    _ref.read(pendingVerificationEmailProvider.notifier).state = null;
    state = AuthState.unauthenticated;
  }

  /// Firebase password-reset email.
  Future<bool> requestPasswordReset(String email) async {
    state = AuthState.loading;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      state = AuthState.unauthenticated;
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(mapFirebaseAuthError(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    }
  }

  /// Resend verification using the current Firebase session (email only — no password).
  Future<bool> resendVerificationEmail({required String email}) async {
    state = AuthState.loading;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null ||
          user.email?.toLowerCase() != email.trim().toLowerCase()) {
        _setError(
          'Verification session expired. Please sign in — if unverified, you will return here.',
        );
        return false;
      }

      await user.reload();
      final refreshed = _firebaseAuth.currentUser;
      if (refreshed == null) {
        _setError('Unable to resend verification email.');
        return false;
      }

      if (refreshed.emailVerified) {
        await _firebaseAuth.signOut();
        await _authService.deleteToken();
        state = AuthState.unauthenticated;
        _ref.read(authErrorProvider.notifier).state =
            'Email is already verified. Please sign in.';
        return false;
      }

      await refreshed.sendEmailVerification();
      state = AuthState.pendingVerification;
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(mapFirebaseAuthError(e));
      return false;
    } catch (e) {
      _setError('Failed to resend verification email.');
      return false;
    }
  }

  /// Check email verification for the current session, then sign out and require login.
  Future<bool> confirmEmailVerified({required String email}) async {
    state = AuthState.loading;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null ||
          user.email?.toLowerCase() != email.trim().toLowerCase()) {
        _setError(
          'Verification session expired. Please sign in to continue verification.',
        );
        return false;
      }

      await user.reload();
      final refreshed = _firebaseAuth.currentUser;
      if (refreshed == null || !refreshed.emailVerified) {
        state = AuthState.pendingVerification;
        _setError('Email not verified yet. Open the link in your inbox, then try again.');
        return false;
      }

      // Verified — clear session so the user signs in on the Login page.
      await _firebaseAuth.signOut();
      await _authService.deleteToken();
      _ref.read(pendingVerificationEmailProvider.notifier).state = null;
      state = AuthState.unauthenticated;
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(mapFirebaseAuthError(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    }
  }

  /// Restore session: guest OR verified Firebase user only.
  Future<void> checkAuthStatus() async {
    final isGuest = await _authService.isGuest();
    if (isGuest) {
      // Guest must not keep a Firebase session.
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.signOut();
      }
      state = AuthState.guest;
      return;
    }

    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await user.reload();
      } catch (_) {}
      final refreshed = _firebaseAuth.currentUser;
      if (refreshed != null && refreshed.emailVerified) {
        final token = await refreshed.getIdToken();
        if (token != null && token.isNotEmpty) {
          await _authService.saveToken(token);
        }
        state = AuthState.authenticated;
        return;
      }
      // Unverified or invalid session — clear and require login.
      await _firebaseAuth.signOut();
      await _authService.deleteToken();
    }

    state = AuthState.unauthenticated;
  }
}
