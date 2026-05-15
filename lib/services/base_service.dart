library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import '../constants/app_constants.dart';

typedef ApiResponse = Map<String, dynamic>;
typedef UnauthorizedCallback = Future<void> Function();

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({required this.message, this.statusCode, this.originalError});

  @override
  String toString() => message;
}

class BaseService {
  BaseService() {
    _initDio();
  }

  static const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  static UnauthorizedCallback? onUnauthorized;
  late final Dio _dio;

  static Future<void> saveToken(String token) {
    return secureStorage.write(key: AppConstants.storageKeyToken, value: token);
  }

  static Future<String?> readToken() {
    return secureStorage.read(key: AppConstants.storageKeyToken);
  }

  static Future<void> clearToken() {
    return secureStorage.delete(key: AppConstants.storageKeyToken);
  }

  static Future<void> saveUser(Map<String, dynamic> user) {
    return secureStorage.write(
      key: AppConstants.storageKeyUser,
      value: jsonEncode(user),
    );
  }

  static Future<Map<String, dynamic>?> readUser() async {
    final raw = await secureStorage.read(key: AppConstants.storageKeyUser);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUser() {
    return secureStorage.delete(key: AppConstants.storageKeyUser);
  }

  static Future<void> clearSession() async {
    await clearToken();
    await clearUser();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
        contentType: 'application/json',
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await readToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await clearSession();
      await onUnauthorized?.call();
    }

    handler.next(err);
  }

  Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: AppConstants.errorUnknown, originalError: e);
    }
  }

  Future<ApiResponse> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: AppConstants.errorUnknown, originalError: e);
    }
  }

  Future<ApiResponse> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: AppConstants.errorUnknown, originalError: e);
    }
  }

  Future<ApiResponse> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: AppConstants.errorUnknown, originalError: e);
    }
  }

  ApiResponse _handleResponse(Response response) {
    if (response.statusCode == null) {
      throw ApiException(message: AppConstants.errorUnknown);
    }

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (response.data is Map<String, dynamic>) {
        return response.data as ApiResponse;
      }

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }

      return {'data': response.data};
    }

    throw ApiException(
      message: _extractMessage(response.data),
      statusCode: response.statusCode,
    );
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: AppConstants.errorTimeout,
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractMessage(error.response?.data);

        if (statusCode == 401) {
          return ApiException(
            message: AppConstants.errorUnauthorized,
            statusCode: 401,
          );
        }

        if (statusCode == 403) {
          return ApiException(
            message: AppConstants.errorForbidden,
            statusCode: 403,
          );
        }

        if (statusCode == 404) {
          return ApiException(
            message: AppConstants.errorNotFound,
            statusCode: 404,
          );
        }

        if (statusCode == 422) {
          return ApiException(
            message:
                _extractValidationMessage(error.response?.data) ??
                AppConstants.errorValidation,
            statusCode: 422,
          );
        }

        if (statusCode != null && statusCode >= 500) {
          return ApiException(
            message: AppConstants.errorServer,
            statusCode: statusCode,
          );
        }

        return ApiException(message: message, statusCode: statusCode);
      case DioExceptionType.connectionError:
        return ApiException(message: AppConstants.errorNetworkConnection);
      default:
        return ApiException(
          message: AppConstants.errorUnknown,
          originalError: error,
        );
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? AppConstants.errorServer;
    }

    if (data is Map) {
      return data['message']?.toString() ?? AppConstants.errorServer;
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return AppConstants.errorServer;
  }

  String? _extractValidationMessage(dynamic data) {
    if (data is! Map) {
      return null;
    }

    final fallbackMessage = data['message']?.toString();
    final errors = data['errors'];
    if (errors is! Map) {
      return fallbackMessage;
    }

    for (final value in errors.values) {
      if (value is List) {
        final first = value
            .map((item) => item.toString().trim())
            .firstWhere((item) => item.isNotEmpty, orElse: () => '');
        if (first.isNotEmpty) {
          return first;
        }
      } else if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallbackMessage;
  }
}
