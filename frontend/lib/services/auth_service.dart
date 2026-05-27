import 'api_client.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<void> exchangeMicrosoftCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    final response = await _apiClient.post(
      '/auth/token',
      authenticated: false,
      body: {
        'provider': 'microsoft',
        'code': code,
        'codeVerifier': codeVerifier,
        'redirectUri': redirectUri,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(500, 'Invalid auth response.');
    }

    final token = response['accessToken']?.toString();

    if (token == null || token.isEmpty) {
      throw ApiException(500, 'No access token returned.');
    }

    await _apiClient.saveToken(token);
  }

  Future<void> logout() {
    return _apiClient.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }
}