import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _guestKey = 'is_guest';

  final FlutterSecureStorage _storage;

  AuthService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  /// Save JWT token securely
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    // Clear guest flag when a real token is saved
    await _storage.write(key: _guestKey, value: 'false');
  }

  /// Retrieve stored JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete stored JWT token (logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _guestKey);
  }

  /// Check if user is currently logged in (has a valid token)
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Save guest status
  Future<void> setGuestMode(bool isGuest) async {
    await _storage.write(key: _guestKey, value: isGuest.toString());
    if (isGuest) {
      // Remove any existing token for guest mode
      await _storage.delete(key: _tokenKey);
    }
  }

  /// Check if user is in guest mode
  Future<bool> isGuest() async {
    final value = await _storage.read(key: _guestKey);
    return value == 'true';
  }
}
