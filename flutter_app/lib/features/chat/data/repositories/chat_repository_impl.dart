import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/features/chat/data/models/conversa_model.dart';
import 'package:egranja_flutter/features/chat/data/models/mensagem_model.dart';
import 'package:egranja_flutter/features/chat/domain/entities/conversa.dart';
import 'package:egranja_flutter/features/chat/domain/entities/mensagem.dart';
import 'package:egranja_flutter/features/chat/domain/repositories/chat_repository.dart';

/// Implementacao do [ChatRepository] usando [ApiClient].
class ChatRepositoryImpl implements ChatRepository {
  final ApiClient _apiClient;

  /// Tamanho da pagina para busca de mensagens.
  static const int _pageSize = 50;

  ChatRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Conversa>> fetchConversas() async {
    final response = await _apiClient.apiGet<List<ConversaModel>>(
      '/chat/conversas',
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => ConversaModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response.data;
  }

  @override
  Future<(List<Mensagem>, bool hasMore)> fetchMensagens(
    String loteId, {
    int page = 1,
  }) async {
    final response = await _apiClient.apiGet<List<MensagemModel>>(
      '/chat/lotes/$loteId/mensagens',
      queryParams: {
        'page': page,
        'limit': _pageSize,
      },
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => MensagemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    final mensagens = response.data;
    final hasMore = mensagens.length >= _pageSize;
    return (mensagens as List<Mensagem>, hasMore);
  }

  @override
  Future<Mensagem> enviarMensagem(
    String loteId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.apiPost<MensagemModel>(
      '/chat/lotes/$loteId/mensagens',
      data: data,
      fromJson: (json) =>
          MensagemModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<void> marcarComoLida(String loteId) async {
    await _apiClient.apiPost<Map<String, dynamic>>(
      '/chat/lotes/$loteId/lida',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
