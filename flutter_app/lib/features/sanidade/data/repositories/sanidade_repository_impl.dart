import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';

import '../../domain/entities/medicamento.dart';
import '../../domain/entities/vacinacao.dart';
import '../../domain/entities/visitante.dart';
import '../../domain/repositories/sanidade_repository.dart';

/// Quantidade padrao de itens por pagina nas listagens.
const int _perPage = 20;

/// Implementacao concreta de [SanidadeRepository] usando [ApiClient].
///
/// Todos os endpoints seguem o padrao do backend Go:
/// - Respostas de sucesso: `{ "success": true, "data": ..., "meta"?: ... }`
/// - Listas paginadas retornam `(List<T>, PaginationMeta?)`
class SanidadeRepositoryImpl implements SanidadeRepository {
  final ApiClient _apiClient;

  SanidadeRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  // ==========================================
  // VACINACOES
  // ==========================================

  @override
  Future<(List<Vacinacao>, PaginationMeta?)> fetchVacinacoes(
    String loteId, {
    int page = 1,
  }) async {
    final response = await _apiClient.apiGet<List<Vacinacao>>(
      '/lotes/$loteId/vacinacoes',
      queryParams: {'page': page, 'per_page': _perPage},
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => Vacinacao.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return (response.data, response.meta);
  }

  @override
  Future<Vacinacao> criarVacinacao(
    String loteId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.apiPost<Vacinacao>(
      '/lotes/$loteId/vacinacoes',
      data: data,
      fromJson: (json) => Vacinacao.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  // ==========================================
  // MEDICAMENTOS
  // ==========================================

  @override
  Future<(List<Medicamento>, PaginationMeta?)> fetchMedicamentos(
    String loteId, {
    int page = 1,
  }) async {
    final response = await _apiClient.apiGet<List<Medicamento>>(
      '/lotes/$loteId/medicamentos',
      queryParams: {'page': page, 'per_page': _perPage},
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => Medicamento.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return (response.data, response.meta);
  }

  @override
  Future<Medicamento> criarMedicamento(
    String loteId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.apiPost<Medicamento>(
      '/lotes/$loteId/medicamentos',
      data: data,
      fromJson: (json) => Medicamento.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  // ==========================================
  // VISITANTES
  // ==========================================

  @override
  Future<(List<Visitante>, PaginationMeta?)> fetchVisitantes(
    String loteId, {
    int page = 1,
  }) async {
    final response = await _apiClient.apiGet<List<Visitante>>(
      '/lotes/$loteId/visitantes',
      queryParams: {'page': page, 'per_page': _perPage},
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => Visitante.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return (response.data, response.meta);
  }

  @override
  Future<Visitante> criarVisitante(
    String loteId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.apiPost<Visitante>(
      '/lotes/$loteId/visitantes',
      data: data,
      fromJson: (json) => Visitante.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
