import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';

import '../../domain/entities/custo.dart';
import '../../domain/entities/remuneracao.dart';
import '../../domain/entities/resumo_financeiro.dart';
import '../../domain/repositories/financeiro_repository.dart';

/// Quantidade padrao de itens por pagina nas listagens.
const int _perPage = 20;

/// Implementacao concreta de [FinanceiroRepository] usando [ApiClient].
///
/// Todos os endpoints seguem o padrao do backend Go:
/// - Respostas de sucesso: `{ "success": true, "data": ..., "meta"?: ... }`
/// - Listas paginadas retornam `(List<T>, PaginationMeta?)`
class FinanceiroRepositoryImpl implements FinanceiroRepository {
  final ApiClient _apiClient;

  FinanceiroRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  // ==========================================
  // RESUMO
  // ==========================================

  @override
  Future<ResumoFinanceiro> fetchResumo(String loteId) async {
    final response = await _apiClient.apiGet<ResumoFinanceiro>(
      '/lotes/$loteId/financeiro/resumo',
      fromJson: (json) =>
          ResumoFinanceiro.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  // ==========================================
  // CUSTOS
  // ==========================================

  @override
  Future<(List<Custo>, PaginationMeta?)> fetchCustos(
    String loteId, {
    int page = 1,
  }) async {
    final response = await _apiClient.apiGet<List<Custo>>(
      '/lotes/$loteId/custos',
      queryParams: {'page': page, 'per_page': _perPage},
      fromJson: (json) => json == null
          ? <Custo>[]
          : (json as List<dynamic>)
              .map((e) => Custo.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
    return (response.data, response.meta);
  }

  @override
  Future<Custo> criarCusto(String loteId, Map<String, dynamic> data) async {
    final response = await _apiClient.apiPost<Custo>(
      '/lotes/$loteId/custos',
      data: data,
      fromJson: (json) => Custo.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  // ==========================================
  // REMUNERACAO
  // ==========================================

  @override
  Future<List<Remuneracao>> fetchRemuneracao(String loteId) async {
    // O backend nao possui endpoint GET para listar remuneracoes.
    // As remuneracoes sao retornadas dentro do relatorio financeiro.
    final response = await _apiClient.apiGet<Map<String, dynamic>>(
      '/lotes/$loteId/financeiro/relatorio',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    final data = response.data;
    final remuneracoesJson = data['remuneracoes'] as List<dynamic>? ?? [];
    return remuneracoesJson
        .map((e) => Remuneracao.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
