import '../auth/jwt_claims.dart';
import 'api_client.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  static const _expiryBuffer = Duration(minutes: 2);

  Future<String> exchangeToken({
    required String provider,
    required String code,
    required String codeVerifier,
    String? redirectUri,
  }) async {
    final body = <String, dynamic>{
      'provider': provider,
      'code': code,
      'codeVerifier': codeVerifier,
      if (redirectUri != null && redirectUri.isNotEmpty) 'redirectUri': redirectUri,
    };

    final response = await _apiClient.post(
      '/auth/token',
      authenticated: false,
      body: body,
    );

    return _persistAuthResponse(response);
  }

  Future<String> refreshSession() async {
    final refreshToken = await _apiClient.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw ApiException(401, 'No saved sign-in session. Please sign in with Microsoft again.');
    }

    final response = await _apiClient.post(
      '/auth/refresh',
      authenticated: false,
      body: <String, dynamic>{
        'provider': 'microsoft',
        'refreshToken': refreshToken,
      },
    );

    return _persistAuthResponse(response, previousRefreshToken: refreshToken);
  }

  /// Returns true when a stored session is still valid or was refreshed silently.
  Future<bool> tryRestoreSession() async {
    if (await _hasValidAccessToken()) return true;

    try {
      await refreshSession();
      return true;
    } on ApiException {
      await logout();
      return false;
    }
  }

  Future<bool> _hasValidAccessToken() async {
    final token = await _apiClient.getToken();
    if (token == null || token.isEmpty) return false;

    final expiresAt = await _apiClient.getTokenExpiresAt();
    if (expiresAt == null) return true;

    return DateTime.now().toUtc().isBefore(expiresAt.subtract(_expiryBuffer));
  }

  Future<String> _persistAuthResponse(
    dynamic response, {
    String? previousRefreshToken,
  }) async {
    if (response is! Map<String, dynamic>) {
      throw ApiException(500, 'Unexpected auth response from server.');
    }

    final accessToken = response['accessToken']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(500, 'Auth response did not include accessToken.');
    }

    final refreshToken = response['refreshToken']?.toString();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _apiClient.saveRefreshToken(refreshToken);
    } else if (previousRefreshToken != null && previousRefreshToken.isNotEmpty) {
      await _apiClient.saveRefreshToken(previousRefreshToken);
    }

    final expiresIn = response['expiresIn'];
    if (expiresIn is int && expiresIn > 0) {
      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: expiresIn));
      await _apiClient.saveTokenExpiresAt(expiresAt);
    }

    await _apiClient.saveToken(accessToken);

    final idToken = response['idToken']?.toString();
    if (idToken != null && idToken.isNotEmpty) {
      await _apiClient.saveIdToken(idToken);
    }

    await _persistDisplayName(
      apiName: response['displayName']?.toString(),
      idToken: idToken,
      accessToken: accessToken,
    );

    return accessToken;
  }

  /// Fills [displayName] from stored id_token when missing (e.g. old session).
  Future<void> ensureDisplayName() async {
    final existing = await _apiClient.getDisplayName();
    if (existing != null && existing.isNotEmpty) return;

    final idToken = await _apiClient.getIdToken();
    final accessToken = await _apiClient.getToken();
    await _persistDisplayName(idToken: idToken, accessToken: accessToken);
  }

  Future<void> _persistDisplayName({
    String? apiName,
    String? idToken,
    String? accessToken,
  }) async {
    final fromApi = apiName?.trim();
    final name = (fromApi != null && fromApi.isNotEmpty)
        ? fromApi
        : displayNameFromJwt(idToken) ?? displayNameFromJwt(accessToken);

    if (name != null && name.isNotEmpty) {
      await _apiClient.saveDisplayName(name);
    }
  }

  Future<String?> getDisplayName() => _apiClient.getDisplayName();

  Future<void> logout() {
    return _apiClient.clearToken();
  }

  Future<bool> isLoggedIn() async {
    if (await _hasValidAccessToken()) return true;
    final refresh = await _apiClient.getRefreshToken();
    return refresh != null && refresh.isNotEmpty;
  }
}
