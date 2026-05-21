import 'dart:convert';

/// Reads display name from a Microsoft JWT (id_token or JWT access_token).
String? displayNameFromJwt(String? jwt) {
  final claims = jwtPayload(jwt);
  if (claims == null) return null;

  final given = _stringClaim(claims, 'given_name');
  if (given != null) return given;

  final name = _stringClaim(claims, 'name');
  if (name != null) {
    final first = name.split(RegExp(r'\s+')).firstWhere((p) => p.isNotEmpty, orElse: () => '');
    return first.isNotEmpty ? first : name;
  }

  final preferred = _stringClaim(claims, 'preferred_username');
  if (preferred != null) return preferred.split('@').first;

  final email = _stringClaim(claims, 'email');
  if (email != null) return email.split('@').first;

  final unique = _stringClaim(claims, 'unique_name');
  if (unique != null) return unique.split('@').first;

  return null;
}

Map<String, dynamic>? jwtPayload(String? jwt) {
  if (jwt == null || jwt.isEmpty) return null;
  final parts = jwt.split('.');
  if (parts.length < 2) return null;

  try {
    var payload = parts[1];
    final mod = payload.length % 4;
    if (mod == 2) {
      payload += '==';
    } else if (mod == 3) {
      payload += '=';
    } else if (mod != 0) {
      return null;
    }

    final normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
    final decoded = utf8.decode(base64.decode(normalized));
    final json = jsonDecode(decoded);
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return Map<String, dynamic>.from(json);
    return null;
  } catch (_) {
    return null;
  }
}

String? _stringClaim(Map<String, dynamic> claims, String key) {
  final value = claims[key];
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
