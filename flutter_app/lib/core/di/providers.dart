import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_service.dart';
import '../auth/secure_storage.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// ── Auth ────────────────────────────────────────────────────────────────
/// Estado de autenticacao derivado do [authNotifierProvider].
///
/// Retorna `true` quando o usuario esta autenticado, `false` caso contrario.
/// Mantido para compatibilidade com codigo que espera um `bool` simples.
final authStateProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.status == AuthStatus.authenticated;
});

// ── Network ─────────────────────────────────────────────────────────────
/// Provider do [NetworkInfo].
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo();
});

/// Provider do [ApiClient] configurado com auth interceptor.
///
/// Depende de [NetworkInfo], [AuthService] e [SecureStorage].
final apiClientProvider = Provider<ApiClient>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  final authService = ref.watch(authServiceProvider);
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(
    networkInfo: networkInfo,
    authService: authService,
    storage: storage,
  );
});

// ── Dio (HTTP Client) ──────────────────────────────────────────────────
/// Instancia global do Dio (legado, preferir [apiClientProvider]).
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  return dio;
});

// ── Connectivity ───────────────────────────────────────────────────────
/// Stream que emite `true` quando ha conexao e `false` quando offline.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    return results.any((r) => r != ConnectivityResult.none);
  });
});
