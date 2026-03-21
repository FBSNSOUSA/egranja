import 'package:egranja_flutter/core/network/api_response.dart';

import '../entities/custo.dart';
import '../entities/remuneracao.dart';
import '../entities/resumo_financeiro.dart';

/// Contrato do repositorio para o feature financeiro.
///
/// Define operacoes de leitura e escrita relacionadas ao
/// modulo financeiro: resumo, custos e remuneracao.
abstract class FinanceiroRepository {
  /// Busca o resumo financeiro consolidado de um lote.
  Future<ResumoFinanceiro> fetchResumo(String loteId);

  /// Busca custos de um lote com paginacao.
  Future<(List<Custo>, PaginationMeta?)> fetchCustos(
    String loteId, {
    int page = 1,
  });

  /// Cria um novo custo para o lote.
  Future<Custo> criarCusto(String loteId, Map<String, dynamic> data);

  /// Busca a remuneracao de um lote.
  Future<List<Remuneracao>> fetchRemuneracao(String loteId);
}
