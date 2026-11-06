import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/session.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static const String _baseUrl = 'https://temuin-backend.devrpl.site/api';
  static const Duration _timeout = Duration(seconds: 20);

  static Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
    };
  }

  static Future<dynamic> get(String endpoint) {
    return _send(
      () => http
          .get(Uri.parse('$_baseUrl$endpoint'), headers: _headers())
          .timeout(_timeout),
    );
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) {
    return _send(
      () => http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers(),
            body: jsonEncode(data),
          )
          .timeout(_timeout),
    );
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) {
    return _send(
      () => http
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers(),
            body: jsonEncode(data),
          )
          .timeout(_timeout),
    );
  }

  static Future<dynamic> delete(String endpoint, {Map<String, dynamic>? data}) {
    return _send(() async {
      final request = http.Request('DELETE', Uri.parse('$_baseUrl$endpoint'));
      request.headers.addAll(_headers());
      if (data != null) request.body = jsonEncode(data);
      final streamed = await request.send().timeout(_timeout);
      return http.Response.fromStream(streamed);
    });
  }

  static Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Koneksi ke server timeout. Silakan coba lagi.');
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on FormatException {
      throw const ApiException('Respons server tidak dapat dibaca.');
    } catch (_) {
      throw const ApiException(
        'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.',
      );
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final body = _decodeBody(response.body);
    final status = response.statusCode;

    if (status >= 200 && status < 300) {
      return body;
    }

    final rawMessage = body is Map ? (body['error'] ?? body['message']) : null;
    final message = rawMessage?.toString().trim();
    throw ApiException(
      (message == null || message.isEmpty) ? _fallbackMessage(status) : message,
      statusCode: status,
    );
  }

  static dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  static String _fallbackMessage(int status) {
    return switch (status) {
      400 => 'Permintaan tidak valid.',
      401 => 'Sesi Anda tidak valid. Silakan masuk kembali.',
      403 => 'Anda tidak memiliki akses ke data ini.',
      404 => 'Data tidak ditemukan.',
      >= 500 => 'Server sedang bermasalah. Silakan coba lagi.',
      _ => 'Terjadi kesalahan pada server.',
    };
  }
}
