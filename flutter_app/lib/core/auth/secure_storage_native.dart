import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Implementacao mobile: usa FlutterSecureStorage (Keychain/Keystore).
final _storage = const FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

Future<void> write({required String key, required String value}) async {
  await _storage.write(key: key, value: value);
}

Future<String?> read({required String key}) async {
  return _storage.read(key: key);
}

Future<void> delete({required String key}) async {
  await _storage.delete(key: key);
}
