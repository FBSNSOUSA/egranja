import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/features/granja/data/models/granja_model.dart';
import 'package:egranja_flutter/features/granja/domain/entities/granja.dart';
import 'package:egranja_flutter/features/granja/domain/entities/granja_form.dart';
import 'package:egranja_flutter/features/granja/domain/repositories/granja_repository.dart';

/// Implementacao do [GranjaRepository] usando [ApiClient].
class GranjaRepositoryImpl implements GranjaRepository {
  final ApiClient _apiClient;

  GranjaRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<Granja>> fetchGranjas() async {
    final response = await _apiClient.apiGet<List<GranjaModel>>(
      '/granjas',
      fromJson: (json) {
        final list = (json as List<dynamic>?) ?? [];
        return list
            .map((e) => GranjaModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response.data;
  }

  @override
  Future<Granja> fetchGranjaById(String id) async {
    final response = await _apiClient.apiGet<GranjaModel>(
      '/granjas/$id',
      fromJson: (json) => GranjaModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<Granja> criarGranja(GranjaFormPayload payload) async {
    final response = await _apiClient.apiPost<GranjaModel>(
      '/granjas',
      data: payload.toJson(),
      fromJson: (json) => GranjaModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<Granja> atualizarGranja(String id, GranjaFormPayload payload) async {
    final response = await _apiClient.apiPatch<GranjaModel>(
      '/granjas/$id',
      data: payload.toJson(),
      fromJson: (json) => GranjaModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<void> deletarGranja(String id) async {
    await _apiClient.apiDelete<Map<String, dynamic>>(
      '/granjas/$id',
      fromJson: (json) => (json as Map<String, dynamic>?) ?? {},
    );
  }
}
