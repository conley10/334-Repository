import 'api_client.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<String> exchangeToken({
    required String provider,
    required String code,
    required String codeVerifier,
  }) async {
    final response = await _apiClient.post(
      '/auth/token',
      authenticated: false,
      body: {
        'provider': provider,
        'code': code,
        'codeVerifier': codeVerifier,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(500, 'Unexpected auth response from server.');
    }

    final accessToken = response['accessToken']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(500, 'Auth response did not include accessToken.');
    }

    await _apiClient.saveToken(accessToken);
    return accessToken;
  }

  Future<void> logout() {
    return _apiClient.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }
}
