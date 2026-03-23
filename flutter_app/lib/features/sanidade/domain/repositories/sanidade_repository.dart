import 'package:egranja_flutter/core/network/api_response.dart';

import '../entities/medicamento.dart';
import '../entities/vacinacao.dart';
import '../entities/visitante.dart';

/// Contrato do repositorio para o feature sanidade.
///
/// Define operacoes de leitura e escrita para vacinacoes,
/// medicamentos e visitantes.
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

  /// Busca visitantes da granja com paginacao.
  /// [granjaId] identificador da granja (not loteId).
  Future<(List<Visitante>, PaginationMeta?)> fetchVisitantes(
    String granjaId, {
    int page = 1,
  });

  /// Cria um novo visitante.
  /// [granjaId] identificador da granja (not loteId).
  Future<Visitante> criarVisitante(
    String granjaId,
    Map<String, dynamic> data,
  );

  /// Registra a saida de um visitante.
  Future<void> registrarSaida(String granjaId, String visitanteId);
}
