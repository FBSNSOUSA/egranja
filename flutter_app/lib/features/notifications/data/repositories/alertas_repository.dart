import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/features/notifications/domain/entities/alerta.dart';

/// Repositorio para buscar alertas da API.
class AlertasRepository {
  final ApiClient _apiClient;

  AlertasRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Busca todos os alertas do usuario autenticado.
  ///
  /// O backend diferencia automaticamente entre produtor (seus lotes)
  /// e tecnico (lotes vinculados).
  Future<List<Alerta>> fetchAlertas() async {
    final response = await _apiClient.apiGet<List<Alerta>>(
      '/alertas',
      fromJson: (json) {
        final list = (json as List<dynamic>?) ?? [];
        return list
            .map((e) => Alerta.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response.data;
  }

  /// Busca alertas de um lote especifico.
  Future<List<Alerta>> fetchAlertasByLote(String loteId) async {
    final response = await _apiClient.apiGet<List<Alerta>>(
      '/lotes/$loteId/alertas',
      fromJson: (json) {
        final list = (json as List<dynamic>?) ?? [];
        return list
            .map((e) => Alerta.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response.data;
  }
}
