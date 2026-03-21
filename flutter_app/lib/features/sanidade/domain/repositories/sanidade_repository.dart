import 'package:egranja_flutter/core/network/api_response.dart';

import '../entities/medicamento.dart';
import '../entities/vacinacao.dart';
import '../entities/visitante.dart';

/// Contrato do repositorio para o feature sanidade.
///
/// Define operacoes de leitura e escrita para vacinacoes,
/// medicamentos e visitantes de um lote.
abstract class SanidadeRepository {
  // ==========================================
  // VACINACOES
  // ==========================================

  /// Busca vacinacoes do lote com paginacao.
  Future<(List<Vacinacao>, PaginationMeta?)> fetchVacinacoes(
    String loteId, {
    int page = 1,
  });

  /// Cria uma nova vacinacao.
  Future<Vacinacao> criarVacinacao(
    String loteId,
    Map<String, dynamic> data,
  );

  // ==========================================
  // MEDICAMENTOS
  // ==========================================

  /// Busca medicamentos do lote com paginacao.
  Future<(List<Medicamento>, PaginationMeta?)> fetchMedicamentos(
    String loteId, {
    int page = 1,
  });

  /// Cria um novo medicamento.
  Future<Medicamento> criarMedicamento(
    String loteId,
    Map<String, dynamic> data,
  );

  // ==========================================
  // VISITANTES
  // ==========================================

  /// Busca visitantes do lote com paginacao.
  Future<(List<Visitante>, PaginationMeta?)> fetchVisitantes(
    String loteId, {
    int page = 1,
  });

  /// Cria um novo visitante.
  Future<Visitante> criarVisitante(
    String loteId,
    Map<String, dynamic> data,
  );
}
