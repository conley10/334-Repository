import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PkceUtils {
  static String generateCodeVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();

    return List.generate(
      64,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  static String generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);

    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}