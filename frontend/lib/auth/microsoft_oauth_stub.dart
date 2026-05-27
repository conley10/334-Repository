class MicrosoftOAuthWeb {
  static const redirectUri =
      'http://localhost:8765/auth-callback';

  static void startLogin() {
    throw UnsupportedError(
      'Microsoft login is only supported on Flutter web.',
    );
  }

  static String? getReturnedCode() {
    return null;
  }

  static String? getCodeVerifier() {
    return null;
  }

  static void clearCodeVerifier() {}

  static void saveLoginMode(bool isAdmin) {}

  static bool getSavedLoginMode() {
    return false;
  }
}