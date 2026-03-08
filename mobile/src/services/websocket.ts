/**
 * Cliente WebSocket para chat em tempo real do eGranja.
 *
 * Funcionalidades:
 * - Conexao autenticada via JWT
 * - Reconexao automatica com backoff exponencial
 * - Envio/recebimento de mensagens tipadas
 * - Listeners para novas mensagens
 * - Indicador de digitacao (typing)
 * - Heartbeat para manter conexao viva
 */

import { getToken } from './auth';

// ==========================================
// CONFIGURACAO
// ==========================================

const WS_BASE_URL = process.env.EXPO_PUBLIC_WS_URL || 'ws://10.0.170.0:8080/api/v1/ws';

/** Intervalo de heartbeat (ms) */
const HEARTBEAT_INTERVAL = 30000;

/** Tentativas maximas de reconexao */
const MAX_RECONNECT_ATTEMPTS = 10;

/** Backoff inicial (ms) */
const INITIAL_BACKOFF = 1000;

/** Backoff maximo (ms) */
const MAX_BACKOFF = 30000;

// ==========================================
// TIPOS
// ==========================================

/** Tipos de mensagem WebSocket */
export type WSMessageType =
  | 'text'
  | 'photo'
  | 'audio'
  | 'solicitacao'
  | 'system'
  | 'typing'
  | 'read'
  | 'heartbeat';

/** Status de solicitacao formal */
export type SolicitacaoStatus = 'pendente' | 'respondida' | 'expirada';

/** Payload de mensagem recebida/enviada via WebSocket */
export interface WSMessage {
  id?: string;
  type: WSMessageType;
  lote_id: string;
  sender_id: string;
  sender_nome?: string;
  sender_tipo?: 'produtor' | 'tecnico';
  content?: string;
  media_url?: string;
  thumbnail_url?: string;
  /** Dados de solicitacao formal */
  solicitacao?: {
    id: string;
    titulo: string;
    descricao: string;
    prazo: string;
    status: SolicitacaoStatus;
    resposta?: string;
    resposta_media_url?: string;
  };
  created_at?: string;
}

/** Payload enviado para o servidor */
export interface WSSendPayload {
  type: WSMessageType;
  lote_id: string;
  content?: string;
  media_url?: string;
  thumbnail_url?: string;
  solicitacao?: {
    titulo: string;
    descricao: string;
    prazo: string;
  };
}

/** Callback de mensagem recebida */
export type WSMessageHandler = (message: WSMessage) => void;

/** Callback de mudanca de estado da conexao */
export type WSConnectionHandler = (connected: boolean) => void;

/** Callback de digitacao */
export type WSTypingHandler = (loteId: string, userId: string, isTyping: boolean) => void;

// ==========================================
// CLASSE WEBSOCKET CLIENT
// ==========================================

class WebSocketClient {
  private ws: WebSocket | null = null;
  private heartbeatTimer: ReturnType<typeof setInterval> | null = null;
  private reconnectTimer: ReturnType<typeof setTimeout> | null = null;
  private reconnectAttempts = 0;
  private isConnecting = false;
  private intentionalClose = false;

  /** Listeners registrados */
  private messageHandlers: Set<WSMessageHandler> = new Set();
  private connectionHandlers: Set<WSConnectionHandler> = new Set();
  private typingHandlers: Set<WSTypingHandler> = new Set();

  /** Canal atual (lote_id) */
  private currentLoteId: string | null = null;

  /**
   * Conecta ao WebSocket do backend com JWT.
   * Se ja estiver conectado, desconecta e reconecta.
   */
  async connect(loteId?: string): Promise<void> {
    if (this.isConnecting) return;
    this.isConnecting = true;
    this.intentionalClose = false;

    try {
      // Fechar conexao anterior se existir
      this.disconnect(false);

      const token = await getToken();
      if (!token) {
        console.warn('[WS] Sem token JWT. Nao e possivel conectar.');
        this.isConnecting = false;
        return;
      }

      if (loteId) {
        this.currentLoteId = loteId;
      }

      const url = loteId
        ? `${WS_BASE_URL}/lotes/${loteId}?token=${token}`
        : `${WS_BASE_URL}?token=${token}`;

      this.ws = new WebSocket(url);

      this.ws.onopen = () => {
        console.log('[WS] Conectado com sucesso.');
        this.isConnecting = false;
        this.reconnectAttempts = 0;
        this.startHeartbeat();
        this.notifyConnectionHandlers(true);
      };

      this.ws.onmessage = (event: WebSocketMessageEvent) => {
        try {
          const message: WSMessage = JSON.parse(event.data);
          this.handleMessage(message);
        } catch (error) {
          console.error('[WS] Erro ao parsear mensagem:', error);
        }
      };

      this.ws.onerror = (event: Event) => {
        console.error('[WS] Erro na conexao WebSocket:', event);
        this.isConnecting = false;
      };

      this.ws.onclose = (event: WebSocketCloseEvent) => {
        console.log(`[WS] Conexao fechada. Code: ${event.code}, Reason: ${event.reason}`);
        this.isConnecting = false;
        this.stopHeartbeat();
        this.notifyConnectionHandlers(false);

        // Reconectar se nao foi intencional
        if (!this.intentionalClose) {
          this.scheduleReconnect();
        }
      };
    } catch (error) {
      console.error('[WS] Erro ao conectar:', error);
      this.isConnecting = false;
      this.scheduleReconnect();
    }
  }

  /**
   * Desconecta do WebSocket.
   * @param intentional Se true, nao tenta reconectar.
   */
  disconnect(intentional = true): void {
    this.intentionalClose = intentional;

    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }

    this.stopHeartbeat();

    if (this.ws) {
      this.ws.onopen = null;
      this.ws.onmessage = null;
      this.ws.onerror = null;
      this.ws.onclose = null;
      this.ws.close(1000, 'Client disconnect');
      this.ws = null;
    }

    if (intentional) {
      this.reconnectAttempts = 0;
      this.currentLoteId = null;
      this.notifyConnectionHandlers(false);
    }
  }

  /**
   * Envia mensagem pelo WebSocket.
   */
  send(payload: WSSendPayload): boolean {
    if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
      console.warn('[WS] Nao conectado. Mensagem nao enviada.');
      return false;
    }

    try {
      this.ws.send(JSON.stringify(payload));
      return true;
    } catch (error) {
      console.error('[WS] Erro ao enviar mensagem:', error);
      return false;
    }
  }

  /**
   * Envia indicador de digitacao.
   */
  sendTyping(loteId: string): void {
    this.send({
      type: 'typing',
      lote_id: loteId,
    });
  }

  /**
   * Marca mensagens como lidas.
   */
  sendRead(loteId: string): void {
    this.send({
      type: 'read',
      lote_id: loteId,
    });
  }

  /**
   * Verifica se esta conectado.
   */
  get isConnected(): boolean {
    return this.ws !== null && this.ws.readyState === WebSocket.OPEN;
  }

  // ==========================================
  // LISTENERS
  // ==========================================

  /** Registra listener de mensagens. Retorna funcao de unsubscribe. */
  onMessage(handler: WSMessageHandler): () => void {
    this.messageHandlers.add(handler);
    return () => {
      this.messageHandlers.delete(handler);
    };
  }

  /** Registra listener de conexao. Retorna funcao de unsubscribe. */
  onConnectionChange(handler: WSConnectionHandler): () => void {
    this.connectionHandlers.add(handler);
    return () => {
      this.connectionHandlers.delete(handler);
    };
  }

  /** Registra listener de typing. Retorna funcao de unsubscribe. */
  onTyping(handler: WSTypingHandler): () => void {
    this.typingHandlers.add(handler);
    return () => {
      this.typingHandlers.delete(handler);
    };
  }

  // ==========================================
  // METODOS PRIVADOS
  // ==========================================

  /** Processa mensagem recebida do servidor. */
  private handleMessage(message: WSMessage): void {
    switch (message.type) {
      case 'typing':
        this.typingHandlers.forEach((handler) =>
          handler(message.lote_id, message.sender_id, true),
        );
        break;

      case 'heartbeat':
        // Resposta do servidor ao heartbeat; ignorar
        break;

      default:
        // Mensagens de texto, foto, audio, solicitacao, system
        this.messageHandlers.forEach((handler) => handler(message));
        break;
    }
  }

  /** Notifica handlers de mudanca de conexao. */
  private notifyConnectionHandlers(connected: boolean): void {
    this.connectionHandlers.forEach((handler) => handler(connected));
  }

  /** Inicia heartbeat periodico. */
  private startHeartbeat(): void {
    this.stopHeartbeat();
    this.heartbeatTimer = setInterval(() => {
      if (this.ws && this.ws.readyState === WebSocket.OPEN) {
        this.ws.send(JSON.stringify({ type: 'heartbeat' }));
      }
    }, HEARTBEAT_INTERVAL);
  }

  /** Para heartbeat. */
  private stopHeartbeat(): void {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer);
      this.heartbeatTimer = null;
    }
  }

  /**
   * Agenda reconexao com backoff exponencial.
   * Backoff: 1s, 2s, 4s, 8s, 16s, 30s (max)
   */
  private scheduleReconnect(): void {
    if (this.reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
      console.warn('[WS] Maximo de tentativas de reconexao atingido.');
      return;
    }

    const backoff = Math.min(
      INITIAL_BACKOFF * Math.pow(2, this.reconnectAttempts),
      MAX_BACKOFF,
    );

    console.log(
      `[WS] Reconectando em ${backoff}ms (tentativa ${this.reconnectAttempts + 1}/${MAX_RECONNECT_ATTEMPTS})`,
    );

    this.reconnectTimer = setTimeout(() => {
      this.reconnectAttempts++;
      this.connect(this.currentLoteId || undefined);
    }, backoff);
  }
}

// ==========================================
// SINGLETON EXPORT
// ==========================================

/** Instancia global do cliente WebSocket */
export const wsClient = new WebSocketClient();

export default wsClient;
