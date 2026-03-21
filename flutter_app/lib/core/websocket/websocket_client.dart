import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../auth/auth_service.dart';
import '../constants/api_constants.dart';
import 'websocket_message.dart';

/// Callback de mensagem recebida.
typedef WSMessageHandler = void Function(WSMessage message);

/// Callback de mudanca de estado da conexao.
typedef WSConnectionHandler = void Function(bool connected);

/// Callback de digitacao.
typedef WSTypingHandler = void Function(
  String loteId,
  String userId,
  bool isTyping,
);

/// Cliente WebSocket para chat em tempo real do eGranja.
///
/// Funcionalidades:
/// - Conexao autenticada via JWT (token em query params)
/// - Reconexao automatica com backoff exponencial
/// - Heartbeat periodico para manter conexao viva
/// - Listeners com padrao de unsubscribe (retornam callback de remocao)
/// - Envio/recebimento de mensagens tipadas
///
/// Portado de `/mobile/src/services/websocket.ts`.
class WebSocketClient {
  final AuthService _authService;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  int _reconnectAttempts = 0;
  bool _isConnecting = false;
  bool _intentionalClose = false;

  /// Canal atual (lote_id).
  String? _currentLoteId;

  /// Listeners registrados.
  final Set<WSMessageHandler> _messageHandlers = {};
  final Set<WSConnectionHandler> _connectionHandlers = {};
  final Set<WSTypingHandler> _typingHandlers = {};

  /// Intervalo de heartbeat.
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  /// Tentativas maximas de reconexao.
  static const int _maxReconnectAttempts = 10;

  /// Backoff inicial (ms).
  static const int _initialBackoffMs = 1000;

  /// Backoff maximo (ms).
  static const int _maxBackoffMs = 30000;

  WebSocketClient({required AuthService authService})
      : _authService = authService;

  /// Verifica se esta conectado.
  bool get isConnected => _channel != null && !_isConnecting;

  // ==========================================
  // CONEXAO
  // ==========================================

  /// Conecta ao WebSocket do backend com JWT.
  ///
  /// Se [loteId] for fornecido, conecta ao canal especifico do lote.
  /// Se ja estiver conectado, desconecta e reconecta.
  Future<void> connect(String? loteId) async {
    if (_isConnecting) return;
    _isConnecting = true;
    _intentionalClose = false;

    try {
      // Fechar conexao anterior se existir
      disconnect(intentional: false);

      final token = await _authService.getToken();
      if (token == null) {
        debugPrint('[WS] Sem token JWT. Nao e possivel conectar.');
        _isConnecting = false;
        return;
      }

      if (loteId != null) {
        _currentLoteId = loteId;
      }

      final wsUrl = ApiConstants.wsUrl;
      final url = _currentLoteId != null
          ? '$wsUrl/lotes/$_currentLoteId?token=$token'
          : '$wsUrl?token=$token';

      final uri = Uri.parse(url);
      _channel = WebSocketChannel.connect(uri);

      // Aguardar conexao estar pronta
      await _channel!.ready.then((_) {
        debugPrint('[WS] Conectado com sucesso.');
        _isConnecting = false;
        _reconnectAttempts = 0;
        _startHeartbeat();
        _notifyConnectionHandlers(true);
      }).catchError((Object error) {
        debugPrint('[WS] Erro ao conectar: $error');
        _isConnecting = false;
        _scheduleReconnect();
      });

      // Escutar mensagens
      _subscription = _channel!.stream.listen(
        (dynamic data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            final message = WSMessage.fromJson(json);
            _handleMessage(message);
          } catch (e) {
            debugPrint('[WS] Erro ao parsear mensagem: $e');
          }
        },
        onError: (Object error) {
          debugPrint('[WS] Erro na conexao WebSocket: $error');
          _isConnecting = false;
        },
        onDone: () {
          debugPrint('[WS] Conexao fechada.');
          _isConnecting = false;
          _stopHeartbeat();
          _notifyConnectionHandlers(false);

          // Reconectar se nao foi intencional
          if (!_intentionalClose) {
            _scheduleReconnect();
          }
        },
      );
    } catch (e) {
      debugPrint('[WS] Erro ao conectar: $e');
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  /// Desconecta do WebSocket.
  ///
  /// Se [intentional] for `true`, nao tenta reconectar.
  void disconnect({bool intentional = true}) {
    _intentionalClose = intentional;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _stopHeartbeat();

    _subscription?.cancel();
    _subscription = null;

    if (_channel != null) {
      _channel!.sink.close(1000, 'Client disconnect');
      _channel = null;
    }

    if (intentional) {
      _reconnectAttempts = 0;
      _currentLoteId = null;
      _notifyConnectionHandlers(false);
    }
  }

  // ==========================================
  // ENVIO
  // ==========================================

  /// Envia mensagem pelo WebSocket.
  /// Retorna `true` se enviou com sucesso, `false` caso contrario.
  bool send(WSSendPayload payload) {
    if (_channel == null) {
      debugPrint('[WS] Nao conectado. Mensagem nao enviada.');
      return false;
    }

    try {
      _channel!.sink.add(jsonEncode(payload.toJson()));
      return true;
    } catch (e) {
      debugPrint('[WS] Erro ao enviar mensagem: $e');
      return false;
    }
  }

  /// Envia indicador de digitacao.
  void sendTyping(String loteId) {
    send(WSSendPayload(
      type: WSMessageType.typing,
      loteId: loteId,
    ));
  }

  /// Marca mensagens como lidas.
  void sendRead(String loteId) {
    send(WSSendPayload(
      type: WSMessageType.read,
      loteId: loteId,
    ));
  }

  // ==========================================
  // LISTENERS
  // ==========================================

  /// Registra listener de mensagens. Retorna funcao de unsubscribe.
  void Function() onMessage(WSMessageHandler handler) {
    _messageHandlers.add(handler);
    return () {
      _messageHandlers.remove(handler);
    };
  }

  /// Registra listener de conexao. Retorna funcao de unsubscribe.
  void Function() onConnectionChange(WSConnectionHandler handler) {
    _connectionHandlers.add(handler);
    return () {
      _connectionHandlers.remove(handler);
    };
  }

  /// Registra listener de typing. Retorna funcao de unsubscribe.
  void Function() onTyping(WSTypingHandler handler) {
    _typingHandlers.add(handler);
    return () {
      _typingHandlers.remove(handler);
    };
  }

  // ==========================================
  // METODOS PRIVADOS
  // ==========================================

  /// Processa mensagem recebida do servidor.
  void _handleMessage(WSMessage message) {
    switch (message.type) {
      case WSMessageType.typing:
        for (final handler in _typingHandlers) {
          handler(message.loteId, message.senderId, true);
        }

      case WSMessageType.heartbeat:
        // Resposta do servidor ao heartbeat; ignorar
        break;

      default:
        // Mensagens de texto, foto, audio, solicitacao, system, read
        for (final handler in _messageHandlers) {
          handler(message);
        }
    }
  }

  /// Notifica handlers de mudanca de conexao.
  void _notifyConnectionHandlers(bool connected) {
    for (final handler in _connectionHandlers) {
      handler(connected);
    }
  }

  /// Inicia heartbeat periodico.
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'heartbeat'}));
        } catch (e) {
          debugPrint('[WS] Erro ao enviar heartbeat: $e');
        }
      }
    });
  }

  /// Para heartbeat.
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Agenda reconexao com backoff exponencial.
  /// Backoff: 1s, 2s, 4s, 8s, 16s, 30s (max).
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[WS] Maximo de tentativas de reconexao atingido.');
      return;
    }

    final backoffMs = min(
      _initialBackoffMs * pow(2, _reconnectAttempts).toInt(),
      _maxBackoffMs,
    );

    debugPrint(
      '[WS] Reconectando em ${backoffMs}ms '
      '(tentativa ${_reconnectAttempts + 1}/$_maxReconnectAttempts)',
    );

    _reconnectTimer = Timer(Duration(milliseconds: backoffMs), () {
      _reconnectAttempts++;
      connect(_currentLoteId);
    });
  }

  /// Libera todos os recursos.
  void dispose() {
    disconnect(intentional: true);
    _messageHandlers.clear();
    _connectionHandlers.clear();
    _typingHandlers.clear();
  }
}
