import 'package:egranja_flutter/features/checklist/domain/entities/checklist.dart';

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

  /// Marca ou desmarca um item do checklist.
  ///
  /// Retorna o [Checklist] atualizado apos a operacao.
  /// Lanca [NetworkException] ou [ServerException] em caso de erro.
  Future<Checklist> marcarItem(
    String checklistId,
    String itemId,
    bool concluido,
    String? observacao,
  );
}
