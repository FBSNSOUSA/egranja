import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';

import '../../domain/entities/agua.dart';
import '../../domain/entities/finalizar_lote_payload.dart';
import '../../domain/entities/grafico_data.dart';
import '../../domain/entities/indicadores.dart';
import '../../domain/entities/lote.dart';
import '../../domain/entities/mortalidade.dart';
import '../../domain/entities/pesagem.dart';
import '../../domain/entities/racao.dart';
import '../../domain/repositories/lote_detail_repository.dart';

/// Quantidade padrao de itens por pagina nas listagens.
const int _perPage = 20;

/// Implementacao concreta de [LoteDetailRepository] usando [ApiClient].
///
/// Todos os endpoints seguem o padrao do backend Go:
/// - Respostas de sucesso: `{ "success": true, "data": ..., "meta"?: ... }`
/// - Listas paginadas retornam `(List<T>, PaginationMeta?)`
class LoteDetailRepositoryImpl implements LoteDetailRepository {
  final ApiClient _apiClient;

  LoteDetailRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  // ==========================================
  // LOTE
  // ==========================================

  @override
  Future<Lote> fetchLote(String loteId) async {
    final response = await _apiClient.apiGet<Lote>(
      '/lotes/$loteId',
      fromJson: (json) => Lote.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<Lote> finalizarLote(
    String loteId,
    FinalizarLotePayload payload,
  ) async {
    final response = await _apiClient.apiPatch<Lote>(
      '/lotes/$loteId/finalizar',
      data: payload.toJson(),
      fromJson: (json) => Lote.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  // ==========================================
  // INDICADORES
  // ==========================================

  @override
  Future<Indicadores> fetchIndicadores(String loteId) async {
    final response = await _apiClient.apiGet<Indicadores>(
      '/lotes/$loteId/indicadores',
      fromJson: (json) => Indicadores.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<DadosGraficoPeso> fetchDadosGraficoPeso(String loteId) async {
    // O backend nao possui endpoint dedicado para dados de grafico.
    // Busca todas as pesagens e constroi os dados do grafico client-side.
    final response = await _apiClient.apiGet<List<Pesagem>>(
      '/lotes/$loteId/pesagens',
      queryParams: {'per_page': 100},
      fromJson: (json) => (json as List<dynamic>?)
              ?.map((e) => Pesagem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

    final pesagens = response.data;
    final pesoReal = pesagens.map((p) {
      final date = DateTime.tryParse(p.data);
      final label = date != null
          ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}'
          : p.data;
      return PontoGrafico(label: label, valor: p.pesoMedio);
    }).toList();

    return DadosGraficoPeso(
      pesoReal: pesoReal,
      pesoBenchmark: const [], // Benchmark nao disponivel via API
    );
  }

  @override
  Future<DadosGraficoMortalidade> fetchDadosGraficoMortalidade(
    String loteId,
  ) async {
    // O backend nao possui endpoint dedicado para dados de grafico.
    // Busca todas as mortalidades e constroi os dados do grafico client-side.
    final response = await _apiClient.apiGet<List<Mortalidade>>(
      '/lotes/$loteId/mortalidades',
      queryParams: {'per_page': 100},
      fromJson: (json) => (json as List<dynamic>?)
              ?.map((e) => Mortalidade.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

    final mortalidades = response.data;

    // Ordenar por data
    final sorted = List<Mortalidade>.from(mortalidades)
      ..sort((a, b) => a.data.compareTo(b.data));

    final diaria = <PontoGrafico>[];
    final acumulada = <PontoGrafico>[];
    int acum = 0;

    for (final m in sorted) {
      final date = DateTime.tryParse(m.data);
      final label = date != null
          ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}'
          : m.data;
      diaria.add(PontoGrafico(label: label, valor: m.quantidade.toDouble()));
      acum += m.quantidade;
      acumulada.add(PontoGrafico(label: label, valor: acum.toDouble()));
    }

    return DadosGraficoMortalidade(
      mortalidadeDiaria: diaria,
      mortalidadeAcumulada: acumulada,
    );
  }

  // ==========================================
  // PESAGENS
  // ==========================================

  @override
  Future<(List<Pesagem>, PaginationMeta?)> fetchPesagens(
    String loteId, {
    int page = 1,
  }) async {
    final response = await _apiClient.apiGet<List<Pesagem>>(
      '/lotes/$loteId/pesagens',
      queryParams: {'page': page, 'per_page': _perPage},
      fromJson: (json) => (json as List<dynamic>?)
              ?.map((e) => Pesagem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
    return (response.data, response.meta);
  }

  @override
  Future<Pesagem> criarPesagem(
    String loteId,
    String data,
    List<Map<String, dynamic>> items,
  ) async {
    final response = await _apiClient.apiPost<Pesagem>(
      '/lotes/$loteId/pesagens',
      data: {'data': data, 'items': items},
      fromJson: (json) => Pesagem.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  // ==========================================
  // MORTALIDADE
  // ==========================================

  @override
  Future<(List<Mortalidade>, PaginationMeta?)> fetchMortalidades(
    String loteId, {
    int page = 1,
  }) async {
    final response = await _apiClient.apiGet<List<Mortalidade>>(
      '/lotes/$loteId/mortalidades',
      queryParams: {'page': page, 'per_page': _perPage},
      fromJson: (json) => (json as List<dynamic>?)
              ?.map((e) => Mortalidade.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
    return (response.data, response.meta);
  }

  @override
  Future<Mortalidade> criarMortalidade(
    String loteId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.apiPost<Mortalidade>(
      '/lotes/$loteId/mortalidades',
      data: data,
      fromJson: (json) => Mortalidade.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  // ==========================================
  // RACAO
  // ==========================================

  @override
  Future<(List<RecebimentoRacao>, PaginationMeta?)> fetchRecebimentosRacao(
    String loteId, {
    int page = 1,
  }) async {
    final response = await _apiClient.apiGet<List<RecebimentoRacao>>(
      '/lotes/$loteId/feed_receipts',
      queryParams: {'page': page, 'per_page': _perPage},
      fromJson: (json) => (json as List<dynamic>?)
              ?.map((e) =>
                  RecebimentoRacao.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
    return (response.data, response.meta);
  }

  @override
  Future<RecebimentoRacao> criarRecebimentoRacao(
    String loteId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.apiPost<RecebimentoRacao>(
      '/lotes/$loteId/feed_receipts',
      data: data,
      fromJson: (json) =>
          RecebimentoRacao.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<(List<ConsumoRacao>, PaginationMeta?)> fetchConsumosRacao(
    String loteId, {
    int page = 1,
  }) async {
    final response = await _apiClient.apiGet<List<ConsumoRacao>>(
      '/lotes/$loteId/feed_consumptions',
      queryParams: {'page': page, 'per_page': _perPage},
      fromJson: (json) => (json as List<dynamic>?)
              ?.map(
                  (e) => ConsumoRacao.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
    return (response.data, response.meta);
  }

  @override
  Future<ConsumoRacao> criarConsumoRacao(
    String loteId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.apiPost<ConsumoRacao>(
      '/lotes/$loteId/feed_consumptions',
      data: data,
      fromJson: (json) => ConsumoRacao.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  // ==========================================
  // AGUA
  // ==========================================

  @override
  Future<(List<ConsumoAgua>, PaginationMeta?)> fetchConsumosAgua(
    String loteId, {
    int page = 1,
  }) async {
    final response = await _apiClient.apiGet<List<ConsumoAgua>>(
      '/lotes/$loteId/water_consumptions',
      queryParams: {'page': page, 'per_page': _perPage},
      fromJson: (json) => (json as List<dynamic>?)
              ?.map(
                  (e) => ConsumoAgua.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
    return (response.data, response.meta);
  }

  @override
  Future<ConsumoAgua> criarConsumoAgua(
    String loteId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.apiPost<ConsumoAgua>(
      '/lotes/$loteId/water_consumptions',
      data: data,
      fromJson: (json) => ConsumoAgua.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
