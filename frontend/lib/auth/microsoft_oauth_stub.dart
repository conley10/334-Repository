class MicrosoftOAuthWeb {
  static const redirectUri = 'http://localhost:8765/auth-callback';

  static void startLogin() {
    throw UnsupportedError(
      'Microsoft login is only supported on Flutter web. Run with: flutter run -d chrome --web-port=8765',
    );
  }

  static String? getReturnedCode() {
    return null;
  }

  static String? getCodeVerifier() {
    return null;
  }

  static void clearCodeVerifier() {}
}