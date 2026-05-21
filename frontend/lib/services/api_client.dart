import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Default API root: local Docker in debug, production URL in release.
String _defaultApiBaseUrl() {
  const fromEnv = String.fromEnvironment('API_BASE_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (kDebugMode) return 'http://localhost:5000';
  return 'https://api.campuspark.edu.au/v1';
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    FlutterSecureStorage? storage,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage(),
        baseUrl = baseUrl ?? _defaultApiBaseUrl();

  final http.Client _httpClient;
  final FlutterSecureStorage _storage;
  final String baseUrl;

  static const _tokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _tokenExpiresAtKey = 'tokenExpiresAt';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  /// ISO-8601 UTC instant when the access token should be treated as expired.
  Future<void> saveTokenExpiresAt(DateTime expiresAt) async {
    await _storage.write(key: _tokenExpiresAtKey, value: expiresAt.toUtc().toIso8601String());
  }

  Future<DateTime?> getTokenExpiresAt() async {
    final raw = await _storage.read(key: _tokenExpiresAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiresAtKey);
  }

  Future<Map<String, String>> _headers({bool authenticated = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw ApiException(401, 'No bearer token found. Please log in first.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$cleanPath');

    if (queryParameters == null || queryParameters.isEmpty) return uri;

    return uri.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) async {
    final response = await _httpClient.get(
      _uri(path, queryParameters),
      headers: await _headers(authenticated: authenticated),
    );
    return _decode(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    late final http.Response response;
    try {
      response = await _httpClient.post(
        _uri(path),
        headers: await _headers(authenticated: authenticated),
        body: jsonEncode(body ?? <String, dynamic>{}),
      );
    } catch (e) {
      throw ApiException(
        0,
        'Cannot reach the API at $baseUrl. Start the backend (docker compose up in backend/) '
        'and ensure it listens on port 5000.',
      );
    }
    return _decode(response);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final response = await _httpClient.patch(
      _uri(path),
      headers: await _headers(authenticated: authenticated),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decode(response);
  }

  Future<void> delete(String path, {bool authenticated = true}) async {
    final response = await _httpClient.delete(
      _uri(path),
      headers: await _headers(authenticated: authenticated),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, _errorMessage(response));
    }
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, _errorMessage(response));
    }

    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            response.reasonPhrase ??
            'Request failed';
      }
    } catch (_) {
      // Fall through to generic message.
    }

    return response.reasonPhrase ?? 'Request failed';
  }
}
