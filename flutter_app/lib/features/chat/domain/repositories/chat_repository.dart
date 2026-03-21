import 'package:egranja_flutter/features/chat/domain/entities/conversa.dart';
import 'package:egranja_flutter/features/chat/domain/entities/mensagem.dart';

/// Contrato do repositorio de chat.
///
/// Define operacoes de conversas e mensagens para a feature de chat.
abstract class ChatRepository {
  /// Busca a lista de conversas do usuario logado.
  Future<List<Conversa>> fetchConversas();

  /// Busca mensagens de um lote com paginacao.
  ///
  /// [loteId] identificador do lote.
  /// [page] numero da pagina (default 1).
  /// Retorna uma tupla com a lista de mensagens e se ha mais paginas.
  Future<(List<Mensagem>, bool hasMore)> fetchMensagens(
    String loteId, {
    int page = 1,
  });

  /// Envia uma mensagem de texto para um lote.
  ///
  /// [loteId] identificador do lote.
  /// [data] mapa com os dados da mensagem (tipo, conteudo, media_url, etc).
  Future<Mensagem> enviarMensagem(String loteId, Map<String, dynamic> data);

  /// Marca todas as mensagens de um lote como lidas.
  Future<void> marcarComoLida(String loteId);
}
