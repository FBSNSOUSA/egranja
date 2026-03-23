import 'package:egranja_flutter/core/network/api_response.dart';

import '../entities/agua.dart';
import '../entities/finalizar_lote_payload.dart';
import '../entities/grafico_data.dart';
import '../entities/indicadores.dart';
import '../entities/lote.dart';
import '../entities/mortalidade.dart';
import '../entities/pesagem.dart';
import '../entities/racao.dart';

/// Contrato do repositorio para o feature lote_detail.
///
/// Define todas as operacoes de leitura e escrita relacionadas
/// ao detalhe de um lote: indicadores, pesagens, mortalidade,
/// racao e agua.
abstract class LoteDetailRepository {
  // ==========================================
  // LOTE
  // ==========================================

  /// Busca os dados de um lote pelo [loteId].
  Future<Lote> fetchLote(String loteId);

  /// Finaliza um lote com os dados do [payload].
  Future<Lote> finalizarLote(String loteId, FinalizarLotePayload payload);

  // ==========================================
  // INDICADORES
  // ==========================================

  /// Busca os indicadores consolidados do lote.
  Future<Indicadores> fetchIndicadores(String loteId);

  /// Busca os dados para o grafico de evolucao de peso.
  Future<DadosGraficoPeso> fetchDadosGraficoPeso(String loteId);

  /// Busca os dados para o grafico de mortalidade.
  Future<DadosGraficoMortalidade> fetchDadosGraficoMortalidade(String loteId);

  // ==========================================
  // PESAGENS
  // ==========================================

  /// Busca pesagens do lote com paginacao.
  Future<(List<Pesagem>, PaginationMeta?)> fetchPesagens(
    String loteId, {
    int page = 1,
  });

  /// Cria uma nova pesagem com a data e a lista de [items].
  Future<Pesagem> criarPesagem(
    String loteId,
    String data,
    List<Map<String, dynamic>> items,
  );

  // ==========================================
  // MORTALIDADE
  // ==========================================

  /// Busca registros de mortalidade do lote com paginacao.
  Future<(List<Mortalidade>, PaginationMeta?)> fetchMortalidades(
    String loteId, {
    int page = 1,
  });

  /// Cria um novo registro de mortalidade.
  Future<Mortalidade> criarMortalidade(
    String loteId,
    Map<String, dynamic> data,
  );

  // ==========================================
  // RACAO
  // ==========================================

  /// Busca recebimentos de racao do lote com paginacao.
  Future<(List<RecebimentoRacao>, PaginationMeta?)> fetchRecebimentosRacao(
    String loteId, {
    int page = 1,
  });

  /// Cria um novo recebimento de racao.
  Future<RecebimentoRacao> criarRecebimentoRacao(
    String loteId,
    Map<String, dynamic> data,
  );

  /// Busca consumos de racao do lote com paginacao.
  Future<(List<ConsumoRacao>, PaginationMeta?)> fetchConsumosRacao(
    String loteId, {
    int page = 1,
  });

  /// Cria um novo consumo de racao.
  Future<ConsumoRacao> criarConsumoRacao(
    String loteId,
    Map<String, dynamic> data,
  );

  // ==========================================
  // AGUA
  // ==========================================

  /// Busca consumos de agua do lote com paginacao.
  Future<(List<ConsumoAgua>, PaginationMeta?)> fetchConsumosAgua(
    String loteId, {
    int page = 1,
  });

  /// Cria um novo consumo de agua.
  Future<ConsumoAgua> criarConsumoAgua(
    String loteId,
    Map<String, dynamic> data,
  );
}
