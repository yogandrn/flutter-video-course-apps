// lib/cores/network/api_client.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../constant/app_constants.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  static String messageOf(Object e) =>
      e is ApiException ? e.message : 'Something went wrong.';

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) => _send(() => _dio.post(path, data: body, queryParameters: query));

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) => _send(() => _dio.put(path, data: body, queryParameters: query));

  Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) => _send(() => _dio.delete(path, data: body, queryParameters: query));

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final data = (await request()).data;
      // GitHub raw serves JSON as text/plain, so Dio leaves it as a String.
      return data is String ? jsonDecode(data) : data;
    } on DioException catch (e) {
      throw ApiException(_messageOf(e), statusCode: e.response?.statusCode);
    } on FormatException {
      throw ApiException('Invalid response format.');
    }
  }

  String _messageOf(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      'Connection timed out. Please try again.',
    DioExceptionType.connectionError => 'No internet connection.',
    DioExceptionType.badResponse => 'Server error (${e.response?.statusCode}).',
    _ => 'Something went wrong.',
  };
}
