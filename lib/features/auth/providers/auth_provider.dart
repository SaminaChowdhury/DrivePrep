import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';

enum AuthState {
  initial,
  authenticated,
  guest,
  unauthenticated,
  loading,
  error,
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});

/// Holds the most recent auth error message for UI display
final authErrorProvider = StateProvider<String?>((ref) => null);

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;
  late final Dio _dio;

  static const String _baseUrl = 'http://10.0.2.2:8000/api/v1/auth';

  AuthNotifier(this._authService, this._ref) : super(AuthState.initial) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Login with email and password using formUrlEncoded for OAuth2 compatibility
  Future<bool> login(String email, String password) async {
    state = AuthState.loading;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] as String? ??
            response.data['access_token'] as String? ??
            '';
        if (token.isNotEmpty) {
          await _authService.saveToken(token);
          state = AuthState.authenticated;
          return true;
        }
      }
      _ref.read(authErrorProvider.notifier).state = 'Authentication failed. Please try again.';
      state = AuthState.error;
      return false;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? e.message ?? 'Server connection error';
      debugPrint('[Auth Error] Login failed: $errorMsg');
      _ref.read(authErrorProvider.notifier).state = errorMsg.toString();
      state = AuthState.error;
      return false;
    } catch (e) {
      debugPrint('[Auth Error] Unexpected: $e');
      _ref.read(authErrorProvider.notifier).state = 'An unexpected error occurred.';
      state = AuthState.error;
      return false;
    }
  }

  /// Sign up with email, username, password, and full name
  Future<bool> signup(
    String email,
    String username,
    String password,
    String fullName,
  ) async {
    state = AuthState.loading;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      final response = await _dio.post(
        '/signup',
        data: {
          'email': email,
          'username': username,
          'password': password,
          'full_name': fullName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] as String? ??
            response.data['access_token'] as String? ??
            '';
        if (token.isNotEmpty) {
          await _authService.saveToken(token);
          state = AuthState.authenticated;
          return true;
        }
      }
      _ref.read(authErrorProvider.notifier).state = 'Registration failed. Please try again.';
      state = AuthState.error;
      return false;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? e.message ?? 'Server connection error';
      debugPrint('[Auth Error] Signup failed: $errorMsg');
      _ref.read(authErrorProvider.notifier).state = errorMsg.toString();
      state = AuthState.error;
      return false;
    } catch (e) {
      debugPrint('[Auth Error] Unexpected: $e');
      _ref.read(authErrorProvider.notifier).state = 'An unexpected error occurred.';
      state = AuthState.error;
      return false;
    }
  }

  /// Continue as guest without authentication, calling the backend guest endpoint
  Future<bool> loginAsGuest() async {
    state = AuthState.loading;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      final response = await _dio.post('/guest');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] as String? ??
            response.data['access_token'] as String? ??
            '';
        if (token.isNotEmpty) {
          await _authService.saveToken(token);
          await _authService.setGuestMode(true);
          state = AuthState.guest;
          return true;
        }
      }
      await _authService.setGuestMode(true);
      state = AuthState.guest;
      return true;
    } on DioException catch (e) {
      debugPrint('[Auth Warning] Backend guest creation failed: ${e.message}. Falling back to offline local guest mode.');
      await _authService.setGuestMode(true);
      state = AuthState.guest;
      return true;
    } catch (e) {
      debugPrint('[Auth Warning] Unexpected guest creation error: $e. Falling back to offline local guest mode.');
      await _authService.setGuestMode(true);
      state = AuthState.guest;
      return true;
    }
  }

  /// Logout and clear stored credentials
  Future<void> logout() async {
    state = AuthState.loading;
    await _authService.deleteToken();
    await _authService.setGuestMode(false);
    state = AuthState.unauthenticated;
  }

  /// Request a password reset code for the given email.
  Future<Map<String, dynamic>?> requestPasswordReset(String email) async {
    state = AuthState.loading;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      final response = await _dio.post('/forgot-password', data: {'email': email});
      state = AuthState.unauthenticated;
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? e.message ?? 'Request failed';
      _ref.read(authErrorProvider.notifier).state = errorMsg.toString();
      state = AuthState.error;
      return null;
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = 'An unexpected error occurred.';
      state = AuthState.error;
      return null;
    }
  }

  /// Reset password using token from email.
  Future<bool> resetPassword({required String token, required String newPassword}) async {
    state = AuthState.loading;
    _ref.read(authErrorProvider.notifier).state = null;
    try {
      final response = await _dio.post(
        '/reset-password',
        data: {'token': token, 'new_password': newPassword},
      );
      state = AuthState.unauthenticated;
      return response.statusCode == 200;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? e.message ?? 'Reset failed';
      _ref.read(authErrorProvider.notifier).state = errorMsg.toString();
      state = AuthState.error;
      return false;
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = 'An unexpected error occurred.';
      state = AuthState.error;
      return false;
    }
  }

  /// Check current authentication status from secure storage
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final isGuest = await _authService.isGuest();
      if (isGuest) {
        state = AuthState.guest;
      } else {
        state = AuthState.authenticated;
      }
      return;
    }

    final isGuest = await _authService.isGuest();
    if (isGuest) {
      state = AuthState.guest;
      return;
    }

    state = AuthState.unauthenticated;
  }
}
