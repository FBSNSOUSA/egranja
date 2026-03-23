import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/features/checklist/data/models/checklist_model.dart';
import 'package:egranja_flutter/features/checklist/domain/entities/checklist.dart';
import 'package:egranja_flutter/features/checklist/domain/entities/checklist_item.dart';
import 'package:egranja_flutter/features/checklist/domain/repositories/checklist_repository.dart';

/// Implementacao do [ChecklistRepository] usando [ApiClient].
class ChecklistRepositoryImpl implements ChecklistRepository {
  final ApiClient _apiClient;

  ChecklistRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Itens padrao do checklist diario de manejo avicola.
  ///
  /// Ordem segue a rotina matinal recomendada pela Embrapa/ABPA:
  /// 1. Mortalidade primeiro (recolher aves mortas e registrar)
  /// 2. Ambiencia (temperatura, umidade)
  /// 3. Agua e racao (disponibilidade e funcionamento)
  /// 4. Ventilacao e cortinas
  /// 5. Observacao comportamental do lote
  /// 6. Cama (qualidade e umidade)
  /// 7. Registros de consumo
  /// 8. Iluminacao (programa de luz)
  /// 9. Equipamentos (aquecedores, ventiladores, nebulizadores)
  static const _itensPadrao = [
    {'descricao': 'Verificar mortalidade (recolher aves mortas)', 'completado': false},
    {'descricao': 'Verificar temperatura e umidade do galpao', 'completado': false},
    {'descricao': 'Verificar disponibilidade de agua (nipples/bebedouros)', 'completado': false},
    {'descricao': 'Verificar comedouros e nivel de racao', 'completado': false},
    {'descricao': 'Verificar ventilacao e cortinas', 'completado': false},
    {'descricao': 'Observar comportamento das aves', 'completado': false},
    {'descricao': 'Verificar cama (umidade, compactacao)', 'completado': false},
    {'descricao': 'Registrar consumo de agua e racao', 'completado': false},
    {'descricao': 'Verificar iluminacao (programa de luz)', 'completado': false},
    {'descricao': 'Inspecionar equipamentos (aquecedores, ventiladores, nebulizadores)', 'completado': false},
  ];

  @override
  Future<Checklist?> fetchChecklist(String loteId, String data) async {
    try {
      final response = await _apiClient.apiGet<List<ChecklistModel>>(
        '/lotes/$loteId/checklists',
        queryParams: {'page': 1, 'per_page': 100},
        fromJson: (json) {
          if (json == null) return <ChecklistModel>[];
          final list = json as List<dynamic>;
          return list
              .map(
                  (e) => ChecklistModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

      // Filtrar pelo checklist da data solicitada
      final checklists = response.data;
      for (final cl in checklists) {
        // Backend retorna data como ISO timestamp (ex: "2026-03-22T00:00:00Z")
        // Comparar apenas a parte da data (YYYY-MM-DD)
        final clDate = cl.data.length >= 10 ? cl.data.substring(0, 10) : cl.data;
        if (clDate == data) return cl;
      }

      // Nenhum checklist para esta data - criar automaticamente (somente para hoje)
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      if (data == todayStr) {
        return await _criarChecklist(loteId, data);
      }
      return null;
    } catch (e) {
      // Se a API retornar 404 (sem checklist para a data), retorna null
      if (e.toString().contains('404') ||
          e.toString().contains('nao encontrado') ||
          e.toString().contains('Recurso nao encontrado')) {
        return null;
      }
      rethrow;
    }
  }

  /// Cria um novo checklist para a data informada com itens padrao.
  Future<Checklist> _criarChecklist(String loteId, String data) async {
    final response = await _apiClient.apiPost<ChecklistModel>(
      '/lotes/$loteId/checklists',
      data: {
        'data': data,
        'itens': _itensPadrao,
      },
      fromJson: (json) =>
          ChecklistModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<Checklist> atualizarItens(
    String loteId,
    String data,
    List<ChecklistItem> itens,
  ) async {
    // Backend: PATCH /lotes/{loteId}/checklists/{data}
    // onde {data} e no formato YYYY-MM-DD.
    // O corpo deve conter a lista completa de itens com estados atualizados.
    final response = await _apiClient.apiPatch<ChecklistModel>(
      '/lotes/$loteId/checklists/$data',
      data: {
        'itens': itens.map((e) => e.toJson()).toList(),
      },
      fromJson: (json) =>
          ChecklistModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
