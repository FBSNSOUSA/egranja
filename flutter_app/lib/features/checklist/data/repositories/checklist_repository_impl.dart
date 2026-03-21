import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/features/checklist/data/models/checklist_model.dart';
import 'package:egranja_flutter/features/checklist/domain/entities/checklist.dart';
import 'package:egranja_flutter/features/checklist/domain/repositories/checklist_repository.dart';

/// Implementacao do [ChecklistRepository] usando [ApiClient].
class ChecklistRepositoryImpl implements ChecklistRepository {
  final ApiClient _apiClient;

  ChecklistRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Checklist?> fetchChecklist(String loteId, String data) async {
    try {
      final response = await _apiClient.apiGet<ChecklistModel>(
        '/lotes/$loteId/checklist',
        queryParams: {'data': data},
        fromJson: (json) =>
            ChecklistModel.fromJson(json as Map<String, dynamic>),
      );
      return response.data;
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

  @override
  Future<Checklist> marcarItem(
    String checklistId,
    String itemId,
    bool concluido,
    String? observacao,
  ) async {
    final response = await _apiClient.apiPatch<ChecklistModel>(
      '/checklist/$checklistId/itens/$itemId',
      data: {
        'concluido': concluido,
        'observacao': ?observacao,
      },
      fromJson: (json) =>
          ChecklistModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
