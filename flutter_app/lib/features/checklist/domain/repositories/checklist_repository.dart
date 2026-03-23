import 'package:egranja_flutter/features/checklist/domain/entities/checklist.dart';
import 'package:egranja_flutter/features/checklist/domain/entities/checklist_item.dart';

/// Contrato do repositorio de checklist diario.
///
/// Define as operacoes de leitura e atualizacao do checklist
/// de manejo, consumidas pela camada de apresentacao.
abstract class ChecklistRepository {
  /// Busca o checklist de um lote para uma data especifica.
  ///
  /// Retorna `null` se nao houver checklist para a data informada.
  /// Lanca [NetworkException] ou [ServerException] em caso de erro.
  Future<Checklist?> fetchChecklist(String loteId, String data);

  /// Atualiza os itens do checklist de um lote para uma data especifica.
  ///
  /// O backend espera PATCH /lotes/{loteId}/checklists/{data}
  /// com o corpo contendo a lista completa de itens atualizada.
  ///
  /// [loteId] identificador do lote.
  /// [data] data no formato YYYY-MM-DD.
  /// [itens] lista completa de itens com estados atualizados.
  ///
  /// Retorna o [Checklist] atualizado apos a operacao.
  /// Lanca [NetworkException] ou [ServerException] em caso de erro.
  Future<Checklist> atualizarItens(
    String loteId,
    String data,
    List<ChecklistItem> itens,
  );
}
