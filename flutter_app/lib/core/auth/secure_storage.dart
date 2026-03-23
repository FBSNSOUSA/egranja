import 'secure_storage_native.dart' if (dart.library.js_interop) 'secure_storage_web.dart'
    as platform_storage;

/// Wrapper para gerenciar tokens JWT.
///
/// No mobile, usa FlutterSecureStorage (Keychain/Keystore).
/// Na web, usa localStorage simples (sem criptografia client-side).
class SecureStorage {
  static const String accessTokenKey = 'egranja_access_token';
  static const String refreshTokenKey = 'egranja_refresh_token';

  /// Salva o access token.
  Future<void> saveAccessToken(String token) async {
    await platform_storage.write(key: accessTokenKey, value: token);
  }

  /// Recupera o access token armazenado.
  Future<String?> getAccessToken() async {
    return platform_storage.read(key: accessTokenKey);
  }

  /// Salva o refresh token.
  Future<void> saveRefreshToken(String token) async {
    await platform_storage.write(key: refreshTokenKey, value: token);
  }

  /// Recupera o refresh token armazenado.
  Future<String?> getRefreshToken() async {
    return platform_storage.read(key: refreshTokenKey);
  }

  /// Remove todos os tokens.
  Future<void> clearTokens() async {
    await Future.wait([
      platform_storage.delete(key: accessTokenKey),
      platform_storage.delete(key: refreshTokenKey),
    ]);
  }
}
