import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:egranja_flutter/features/chat/domain/entities/mensagem.dart';
import 'package:egranja_flutter/features/chat/domain/repositories/chat_repository.dart';
import 'package:egranja_flutter/features/chat/presentation/providers/chat_provider.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockRepository;
  late ChatNotifier notifier;

  const loteId = 'lote-chat-123';

  final fakeMensagem = Mensagem(
    id: 'msg-1',
    loteId: loteId,
    tipo: MensagemTipo.texto,
    conteudo: 'Ola, tudo bem?',
    remetenteId: 'user-1',
    remetenteNome: 'Joao',
    remetenteTipo: 'produtor',
    lida: false,
    createdAt: DateTime(2025, 6, 15, 10, 0),
  );

  final fakeMensagem2 = Mensagem(
    id: 'msg-2',
    loteId: loteId,
    tipo: MensagemTipo.texto,
    conteudo: 'Tudo certo!',
    remetenteId: 'user-2',
    remetenteNome: 'Carlos',
    remetenteTipo: 'tecnico',
    lida: false,
    createdAt: DateTime(2025, 6, 15, 10, 5),
  );

  setUp(() {
    mockRepository = MockChatRepository();
    notifier = ChatNotifier(repository: mockRepository, loteId: loteId);
  });

  group('ChatNotifier', () {
    group('fetchMensagens', () {
      test('sucesso: carrega mensagens e seta hasMore', () async {
        when(() => mockRepository.fetchMensagens(loteId, page: 1))
            .thenAnswer((_) async => ([fakeMensagem], true));

        await notifier.fetchMensagens();

        expect(notifier.state.mensagens.length, 1);
        expect(notifier.state.mensagens[0].conteudo, 'Ola, tudo bem?');
        expect(notifier.state.isLoading, false);
        expect(notifier.state.hasMore, true);
        expect(notifier.state.currentPage, 1);
        expect(notifier.state.error, isNull);
      });

      test('erro: seta mensagem de erro', () async {
        when(() => mockRepository.fetchMensagens(loteId, page: 1))
            .thenThrow(Exception('Falha na rede'));

        await notifier.fetchMensagens();

        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, isNotNull);
        expect(notifier.state.mensagens, isEmpty);
      });
    });

    group('loadMore', () {
      test('sucesso: adiciona mensagens a lista', () async {
        // Primeiro fetch
        when(() => mockRepository.fetchMensagens(loteId, page: 1))
            .thenAnswer((_) async => ([fakeMensagem], true));

        await notifier.fetchMensagens();
        expect(notifier.state.mensagens.length, 1);

        // Load more - pagina 2
        when(() => mockRepository.fetchMensagens(loteId, page: 2))
            .thenAnswer((_) async => ([fakeMensagem2], false));

        await notifier.loadMore();

        expect(notifier.state.mensagens.length, 2);
        expect(notifier.state.hasMore, false);
        expect(notifier.state.currentPage, 2);
      });

      test('sem mais paginas: nao faz requisicao', () async {
        // Fetch com hasMore = false
        when(() => mockRepository.fetchMensagens(loteId, page: 1))
            .thenAnswer((_) async => ([fakeMensagem], false));

        await notifier.fetchMensagens();
        expect(notifier.state.hasMore, false);

        await notifier.loadMore();

        // Nao deve ter chamado fetchMensagens page 2
        verifyNever(() => mockRepository.fetchMensagens(loteId, page: 2));
      });
    });

    group('enviarTexto', () {
      test('sucesso: adiciona mensagem no inicio da lista', () async {
        when(() => mockRepository.enviarMensagem(loteId, any()))
            .thenAnswer((_) async => fakeMensagem);

        await notifier.enviarTexto('Ola, tudo bem?');

        expect(notifier.state.mensagens.length, 1);
        expect(notifier.state.mensagens[0].id, 'msg-1');
        expect(notifier.state.isSending, false);
        expect(notifier.state.error, isNull);
      });

      test('texto vazio: nao envia', () async {
        await notifier.enviarTexto('   ');

        verifyNever(() => mockRepository.enviarMensagem(any(), any()));
        expect(notifier.state.isSending, false);
      });

      test('erro: seta mensagem de erro', () async {
        when(() => mockRepository.enviarMensagem(loteId, any()))
            .thenThrow(Exception('Falha ao enviar'));

        await notifier.enviarTexto('Teste');

        expect(notifier.state.isSending, false);
        expect(notifier.state.error, isNotNull);
      });
    });

    group('onMensagemRecebida', () {
      test('adiciona mensagem recebida no inicio', () {
        notifier.onMensagemRecebida(fakeMensagem);

        expect(notifier.state.mensagens.length, 1);
        expect(notifier.state.mensagens[0].id, 'msg-1');
      });

      test('evita duplicatas', () {
        notifier.onMensagemRecebida(fakeMensagem);
        notifier.onMensagemRecebida(fakeMensagem); // Mesma mensagem

        expect(notifier.state.mensagens.length, 1);
      });
    });

    group('marcarComoLida', () {
      test('chama repository marcarComoLida', () async {
        when(() => mockRepository.marcarComoLida(loteId))
            .thenAnswer((_) async {});

        await notifier.marcarComoLida();

        verify(() => mockRepository.marcarComoLida(loteId)).called(1);
      });
    });
  });
}
