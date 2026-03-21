import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/features/home/data/models/novo_lote_payload.dart';
import 'package:egranja_flutter/features/home/domain/entities/galpao.dart';
import 'package:egranja_flutter/features/home/domain/entities/lote.dart';

/// Contrato do repositorio de dados da Home.
///
/// Define operacoes necessarias para a tela principal do app:
/// listagem de lotes ativos, criacao de novo lote e listagem de galpoes.
abstract class HomeRepository {
  /// Busca lotes ativos com paginacao.
  ///
  /// Retorna uma tupla com a lista de lotes e metadados de paginacao.
  Future<(List<Lote>, PaginationMeta?)> fetchLotesAtivos({int page = 1});

  /// Cria um novo lote.
  Future<Lote> criarLote(NovoLotePayload payload);

  /// Busca a lista de galpoes disponiveis.
  Future<List<Galpao>> fetchGalpaos();
}
