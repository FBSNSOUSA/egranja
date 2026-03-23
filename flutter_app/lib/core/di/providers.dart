import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_service.dart';
import '../auth/secure_storage.dart';
import '../constants/api_constants.dart';
import '../database/app_database.dart';
import '../database/daos/pesagens_dao.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../utils/media_upload_helper.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// ── Database ────────────────────────────────────────────────────────────
/// Singleton do banco de dados local Drift.
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// DAO de pesagens e itens de pesagem.
final pesagensDaoProvider = Provider<PesagensDao>((ref) {
  return ref.watch(databaseProvider).pesagensDao;
});

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
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );
  return dio;
});

// ── Media Upload ───────────────────────────────────────────────────
/// Helper para upload de midias (fotos e audios).
final mediaUploadHelperProvider = Provider<MediaUploadHelper>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MediaUploadHelper(apiClient: apiClient);
});

// ── Connectivity ───────────────────────────────────────────────────────
/// Stream que emite `true` quando ha conexao e `false` quando offline.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    return results.any((r) => r != ConnectivityResult.none);
  });
});
