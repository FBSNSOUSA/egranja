import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper em torno do [FlutterSecureStorage] para gerenciar tokens JWT.
///
/// Armazena access token e refresh token de forma segura usando
/// Keychain (iOS) / Keystore (Android). Na web, usa localStorage
/// via flutter_secure_storage_web.
class SecureStorage {
  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            FlutterSecureStorage(
              aOptions: kIsWeb
                  ? const AndroidOptions()
                  : const AndroidOptions(encryptedSharedPreferences: true),
              webOptions: const WebOptions(
                dbName: 'egranja_auth',
                publicKey: 'egranja_web_key',
              ),
            );

  /// Salva o access token no armazenamento seguro.
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Recupera o access token armazenado.
  /// Retorna `null` se nao houver token salvo.
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  /// Salva o refresh token no armazenamento seguro.
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Recupera o refresh token armazenado.
  /// Retorna `null` se nao houver token salvo.
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  /// Remove todos os tokens do armazenamento seguro.
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
