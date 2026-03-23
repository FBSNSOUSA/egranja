import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/features/home/data/models/galpao_model.dart';
import 'package:egranja_flutter/features/home/data/models/lote_model.dart';
import 'package:egranja_flutter/features/home/data/models/novo_lote_payload.dart';
import 'package:egranja_flutter/features/home/domain/entities/galpao.dart';
import 'package:egranja_flutter/features/home/domain/entities/lote.dart';
import 'package:egranja_flutter/features/home/domain/repositories/home_repository.dart';

/// Implementacao do [HomeRepository] usando [ApiClient].
class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _apiClient;

  HomeRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<(List<Lote>, PaginationMeta?)> fetchLotesAtivos({
    int page = 1,
  }) async {
    final response = await _apiClient.apiGet<List<LoteModel>>(
      '/lotes',
      queryParams: {
        'status': 'ativo',
        'page': page,
      },
      fromJson: (json) {
        final list = (json as List<dynamic>?) ?? [];
        return list
            .map((e) => LoteModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return (response.data as List<Lote>, response.meta);
  }

  @override
  Future<Lote> criarLote(NovoLotePayload payload) async {
    final response = await _apiClient.apiPost<LoteModel>(
      '/lotes',
      data: payload.toJson(),
      fromJson: (json) => LoteModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<List<Galpao>> fetchGalpaos() async {
    final response = await _apiClient.apiGet<List<GalpaoModel>>(
      '/galpaos',
      fromJson: (json) {
        final list = (json as List<dynamic>?) ?? [];
        return list
            .map((e) => GalpaoModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response.data;
  }
}
