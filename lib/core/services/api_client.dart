import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_service.dart';
import 'auth_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  final authService = ref.watch(authServiceProvider);
  return ApiClient(connectivity: connectivity, authService: authService);
});

class ApiClient {
  final ConnectivityStatus connectivity;
  final AuthService authService;
  late final Dio _dio;

  // For local development on Android emulator, 10.0.2.2 is localhost.
  // We'll set a default base URL which can be customized later.
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  ApiClient({required this.connectivity, required this.authService}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (connectivity == ConnectivityStatus.isDisconnected) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'No internet connection',
                type: DioExceptionType.connectionError,
              ),
            );
          }

          // Fetch stored JWT and attach to Authorization headers
          final token = await authService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log request details
          debugPrint('--> [API REQUEST] ${options.method} ${options.path}');
          debugPrint('Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('Body: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('<-- [API RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          debugPrint('[API ERROR] ${error.type} - ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Exception translator
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Network timeout occurred');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final message = error.response?.data?['detail'] ?? 'Bad response';
        return ApiException(message: '$message (Status: $status)', statusCode: status);
      case DioExceptionType.connectionError:
        return NetworkException('Failed to connect to the server. Check your connection.');
      default:
        return ApiException(message: error.message ?? 'An unknown error occurred');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException({required this.message, this.statusCode});
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}
