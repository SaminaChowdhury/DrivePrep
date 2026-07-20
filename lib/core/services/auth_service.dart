import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Local persistence helpers for guest mode + optional ID token cache.
/// Firebase Auth handles session persistence for verified users.
class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _guestKey = 'is_guest';

  final FlutterSecureStorage _storage;
  final FirebaseAuth _firebaseAuth;

  AuthService({
    FlutterSecureStorage? storage,
    FirebaseAuth? firebaseAuth,
  })  : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            ),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  /// Persist Firebase ID token for API Authorization headers.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _guestKey, value: 'false');
  }

  Future<String?> getToken() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && user.emailVerified) {
      try {
        final fresh = await user.getIdToken();
        if (fresh != null && fresh.isNotEmpty) {
          await _storage.write(key: _tokenKey, value: fresh);
          return fresh;
        }
      } catch (_) {
        // Fall through to cached token.
      }
    }
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _guestKey);
  }

  /// True when a verified Firebase session exists (not guest).
  Future<bool> isLoggedIn() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;
    await user.reload();
    final refreshed = _firebaseAuth.currentUser;
    return refreshed != null && refreshed.emailVerified;
  }

  Future<void> setGuestMode(bool isGuest) async {
    await _storage.write(key: _guestKey, value: isGuest.toString());
    if (isGuest) {
      await _storage.delete(key: _tokenKey);
    }
  }

  Future<bool> isGuest() async {
    final value = await _storage.read(key: _guestKey);
    return value == 'true';
  }
}
