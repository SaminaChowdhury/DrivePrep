import 'package:firebase_auth/firebase_auth.dart';

/// Maps [FirebaseAuthException] codes to user-friendly messages.
String mapFirebaseAuthError(Object error) {
  if (error is! FirebaseAuthException) {
    return 'An unexpected error occurred. Please try again.';
  }

  switch (error.code) {
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
      return 'No account found with this email.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'invalid-credential':
      return 'Invalid email or password.';
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'operation-not-allowed':
      return 'Email/password sign-in is not enabled.';
    case 'weak-password':
      return 'Password is too weak. Use 8+ characters with mixed case and a number.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait and try again.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    case 'requires-recent-login':
      return 'Please sign in again to continue.';
    default:
      return error.message ?? 'Authentication failed. Please try again.';
  }
}
