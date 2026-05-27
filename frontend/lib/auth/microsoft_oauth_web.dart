import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'package:crypto/crypto.dart';

class MicrosoftOAuthWeb {
  static const tenantId = 'aab4897d-5f99-4439-b442-c204c65875b5';
  static const clientId = '502aec32-eeaa-47f4-a7fb-b6ccba51a09d';
  static const redirectUri = 'http://localhost:8765/auth-callback';

  static const _codeVerifierKey = 'campuspark_pkce_code_verifier';
  static const _loginModeKey = 'campuspark_login_mode';

  static void saveLoginMode(bool isAdmin) {
    html.window.localStorage[_loginModeKey] = isAdmin ? 'admin' : 'driver';
  }

  static bool getSavedLoginMode() {
    return html.window.localStorage[_loginModeKey] == 'admin';
  }

  static void startLogin() {
    final verifier = _generateCodeVerifier();
    final challenge = _generateCodeChallenge(verifier);

    html.window.localStorage[_codeVerifierKey] = verifier;

    final uri = Uri.https(
      'login.microsoftonline.com',
      '/$tenantId/oauth2/v2.0/authorize',
      {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'response_mode': 'query',
        'scope': 'openid profile email offline_access',
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
        'prompt': 'select_account',
      },
    );

    html.window.location.assign(uri.toString());
  }

  static String? getReturnedCode() {
    return Uri.base.queryParameters['code'];
  }

  static String? getCodeVerifier() {
    return html.window.localStorage[_codeVerifierKey];
  }

  static void clearCodeVerifier() {
    html.window.localStorage.remove(_codeVerifierKey);
  }

  static String _generateCodeVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();

    return List.generate(
      64,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  static String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);

    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}