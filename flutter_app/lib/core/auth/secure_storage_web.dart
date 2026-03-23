import 'package:web/web.dart' as web;

/// Implementacao web: usa localStorage (sem criptografia).
Future<void> write({required String key, required String value}) async {
  web.window.localStorage.setItem(key, value);
}

Future<String?> read({required String key}) async {
  return web.window.localStorage.getItem(key);
}

Future<void> delete({required String key}) async {
  web.window.localStorage.removeItem(key);
}
