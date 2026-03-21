import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_interceptor.dart';
import '../auth/auth_service.dart';
import '../auth/secure_storage.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import 'api_response.dart';
import 'network_info.dart';

/// Operacao pendente para sincronizacao offline.
class PendingOperation {
  final String id;
  final String method;
  final String url;
  final dynamic data;
  final String createdAt;

  const PendingOperation({
    required this.id,
    required this.method,
    required this.url,
    this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'url': url,
      'data': data,
      'createdAt': createdAt,
    };
  }

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'] as String,
      method: json['method'] as String,
      url: json['url'] as String,
      data: json['data'],
      createdAt: json['createdAt'] as String,
    );
  }
}

/// Callback para adicionar operacoes pendentes a fila de sincronizacao.
typedef PendingOperationCallback = void Function(PendingOperation op);

/// Cliente HTTP para comunicacao com a API eGranja.
///
/// Funcionalidades:
/// - Base URL configuravel via [ApiConstants]
/// - Interceptor de request: adiciona JWT no header Authorization
/// - Interceptor de response: refresh automatico quando recebe 401
/// - Tratamento de erro de rede (salva operacao offline)
/// - Helpers tipados: [apiGet], [apiPost], [apiPatch], [apiDelete], [apiUpload]
class ApiClient {
  late final Dio _dio;
  // ignore: unused_field
  final NetworkInfo _networkInfo;
  final AuthService _authService;
  final SecureStorage _storage;

  /// Callback opcional para enfileirar operacoes offline.
  /// Sera injetado pelo modulo de sync quando disponivel.
  PendingOperationCallback? onPendingOperation;

  static const _uuid = Uuid();

  ApiClient({
    required NetworkInfo networkInfo,
    required AuthService authService,
    required SecureStorage storage,
    this.onPendingOperation,
  })  : _networkInfo = networkInfo,
        _authService = authService,
        _storage = storage {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Adicionar interceptor de autenticacao
    _dio.interceptors.add(
      AuthInterceptor(
        storage: _storage,
        authService: _authService,
        dio: _dio,
      ),
    );

    // Adicionar interceptor de log (apenas em debug)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('[HTTP] $obj'),
        ),
      );
    }
  }

  /// Acesso direto ao Dio subjacente (para casos excepcionais).
  Dio get dio => _dio;

  // ==========================================
  // HELPERS TIPADOS
  // ==========================================

  /// GET request tipado.
  Future<SuccessResponse<T>> apiGet<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParams,
      );
      return _parseSuccessResponse(response.data!, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request tipado.
  Future<SuccessResponse<T>> apiPost<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
      );
      return _parseSuccessResponse(response.data!, fromJson);
    } on DioException catch (e) {
      _handleNetworkOffline(e, 'POST', path, data);
      throw _handleDioError(e);
    }
  }

  /// PATCH request tipado.
  Future<SuccessResponse<T>> apiPatch<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        path,
        data: data,
      );
      return _parseSuccessResponse(response.data!, fromJson);
    } on DioException catch (e) {
      _handleNetworkOffline(e, 'PATCH', path, data);
      throw _handleDioError(e);
    }
  }

  /// DELETE request tipado.
  Future<SuccessResponse<T>> apiDelete<T>(
    String path, {
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(path);
      return _parseSuccessResponse(response.data!, fromJson);
    } on DioException catch (e) {
      _handleNetworkOffline(e, 'DELETE', path, null);
      throw _handleDioError(e);
    }
  }

  /// Upload de arquivo (foto/audio) com multipart/form-data.
  /// Retorna URL do arquivo no servidor.
  Future<SuccessResponse<Map<String, dynamic>>> apiUpload(
    String filePath,
    String type,
    String name,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: name,
          contentType: DioMediaType.parse(type),
        ),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: ApiConstants.uploadTimeout,
          receiveTimeout: ApiConstants.uploadTimeout,
        ),
      );

      return _parseSuccessResponse(
        response.data!,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==========================================
  // METODOS PRIVADOS
  // ==========================================

  /// Parseia uma resposta de sucesso da API.
  SuccessResponse<T> _parseSuccessResponse<T>(
    Map<String, dynamic> body,
    T Function(dynamic json) fromJson,
  ) {
    return SuccessResponse<T>.fromJson(body, fromJson);
  }

  /// Salva operacao offline se o erro for de rede e o metodo for mutacao.
  void _handleNetworkOffline(
    DioException error,
    String method,
    String path,
    dynamic data,
  ) {
    // Apenas salvar se for erro de rede (sem resposta do servidor)
    if (error.response != null) return;

    final isMutation = ['POST', 'PATCH', 'PUT', 'DELETE'].contains(method);
    if (!isMutation) return;

    final pendingOp = PendingOperation(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 7)}',
      method: method,
      url: path,
      data: data,
      createdAt: DateTime.now().toIso8601String(),
    );

    debugPrint(
      '[API] Erro de rede detectado. Salvando operacao offline: ${pendingOp.id}',
    );

    onPendingOperation?.call(pendingOp);
  }

  /// Converte [DioException] em excecoes tipadas do eGranja.
  Exception _handleDioError(DioException error) {
    // Erro de rede (sem conexao / timeout)
    if (error.response == null) {
      return const NetworkException(
        code: 'NETWORK_ERROR',
        message:
            'Sem conexao com a internet. Os dados serao sincronizados quando a conexao for restaurada.',
      );
    }

    // Verificar se o erro ja e uma AuthException (vindo do interceptor)
    if (error.error is AuthException) {
      return error.error as AuthException;
    }

    final status = error.response!.statusCode ?? 0;
    final responseData = error.response!.data;

    // Tentar parsear ErrorResponse do backend
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('error')) {
      try {
        final errorResponse = ErrorResponse.fromJson(responseData);
        return ServerException(
          code: errorResponse.error.code,
          message: errorResponse.error.message,
        );
      } catch (_) {
        // Se nao conseguir parsear, usar mensagem padrao
      }
    }

    // Mensagem padrao baseada no status HTTP
    return ServerException(
      code: 'HTTP_$status',
      message: _getDefaultErrorMessage(status),
    );
  }

  /// Retorna mensagem de erro padrao baseada no status HTTP.
  String _getDefaultErrorMessage(int status) {
    const messages = {
      400: 'Dados invalidos. Verifique os campos e tente novamente.',
      403: 'Voce nao tem permissao para realizar esta acao.',
      404: 'Recurso nao encontrado.',
      409: 'Conflito de dados. Tente novamente.',
      422: 'Dados invalidos. Verifique os campos e tente novamente.',
      429: 'Muitas requisicoes. Aguarde um momento e tente novamente.',
      500: 'Erro interno do servidor. Tente novamente mais tarde.',
      502: 'Servidor indisponivel. Tente novamente mais tarde.',
      503: 'Servico temporariamente indisponivel. Tente novamente mais tarde.',
    };
    return messages[status] ?? 'Ocorreu um erro inesperado. Tente novamente.';
  }
}
