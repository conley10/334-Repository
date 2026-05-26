import 'dart:html' as html;

import 'pkce_utils.dart';

class MicrosoftOAuthWeb {
  static const tenantId = 'aab4897d-5f99-4439-b442-c204c65875b5';
  static const clientId = '502aec32-eeaa-47f4-a7fb-b6ccba51a09d';
  static const redirectUri = 'http://localhost:8765/auth-callback';

  static const _verifierKey = 'microsoft_code_verifier';

  static void startLogin() {
    final verifier = PkceUtils.generateCodeVerifier();
    final challenge = PkceUtils.generateCodeChallenge(verifier);

    html.window.localStorage[_verifierKey] = verifier;

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
    return html.window.localStorage[_verifierKey];
  }

  static void clearCodeVerifier() {
    html.window.localStorage.remove(_verifierKey);
  }
}