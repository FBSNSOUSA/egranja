/**
 * Store de sincronizacao offline (Zustand).
 *
 * Gerencia o estado de conectividade e operacoes pendentes:
 * - Status online/offline
 * - Fila de operacoes pendentes (FIFO)
 * - Contagem de pendencias
 * - Data da ultima sincronizacao
 * - Sincronizacao em lote quando conexao restaurada
 *
 * Operacoes offline entram em fila com timestamp e UUID gerado no cliente.
 * Resolucao de conflitos: last-write-wins baseada em updated_at (servidor vence).
 */

import { create } from 'zustand';
import { apiPost } from '@services/api';
import type { PendingOperation } from '@services/api';

// ==========================================
// TIPOS
// ==========================================

/** Resultado da sincronizacao de uma operacao individual */
export interface SyncResult {
  operationId: string;
  success: boolean;
  error?: string;
}

/** Resposta do endpoint de sync em lote */
export interface SyncBatchResponse {
  results: SyncResult[];
  synced: number;
  failed: number;
}

export interface SyncState {
  /** Numero de operacoes pendentes de sincronizacao */
  pendingOperations: PendingOperation[];

  /** Contagem rapida de operacoes pendentes */
  pendingCount: number;

  /** Indica se o dispositivo esta conectado a internet */
  isOnline: boolean;

  /** Data/hora da ultima sincronizacao bem-sucedida */
  lastSync: Date | null;

  /** Indica se esta sincronizando no momento */
  isSyncing: boolean;

  /** Mensagem de erro da ultima sincronizacao */
  syncError: string | null;

  /**
   * Adiciona uma operacao a fila de pendencias.
   * Chamado automaticamente pelo interceptor do Axios quando sem conexao.
   */
  addPendingOp: (operation: PendingOperation) => void;

  /**
   * Remove uma operacao da fila (apos sincronizar com sucesso).
   */
  removePendingOp: (operationId: string) => void;

  /**
   * Sincroniza todas as operacoes pendentes com o servidor.
   * Chamado automaticamente quando conexao e restaurada.
   *
   * Usa o endpoint POST /sync que aceita array de operacoes
   * e retorna resultados consolidados.
   */
  syncAll: () => Promise<void>;

  /**
   * Atualiza o status de conectividade.
   * Chamado pelo listener do NetInfo no App.tsx.
   * Se mudou de offline para online, dispara sincronizacao automatica.
   */
  setOnline: (online: boolean) => void;

  /**
   * Limpa todas as operacoes pendentes (uso em logout).
   */
  clearPending: () => void;
}

// ==========================================
// STORE
// ==========================================

export const useSyncStore = create<SyncState>((set, get) => ({
  pendingOperations: [],
  pendingCount: 0,
  isOnline: true, // Assume online ate o NetInfo informar o contrario
  lastSync: null,
  isSyncing: false,
  syncError: null,

  addPendingOp: (operation: PendingOperation) => {
    set((state) => {
      const updated = [...state.pendingOperations, operation];
      return {
        pendingOperations: updated,
        pendingCount: updated.length,
      };
    });
    console.log(
      `[Sync] Operacao adicionada a fila: ${operation.method} ${operation.url} ` +
      `(total pendente: ${get().pendingCount})`,
    );
  },

  removePendingOp: (operationId: string) => {
    set((state) => {
      const updated = state.pendingOperations.filter((op) => op.id !== operationId);
      return {
        pendingOperations: updated,
        pendingCount: updated.length,
      };
    });
  },

  syncAll: async () => {
    const state = get();

    // Nao sincronizar se nao ha pendencias
    if (state.pendingOperations.length === 0) {
      console.log('[Sync] Nenhuma operacao pendente para sincronizar.');
      return;
    }

    // Nao sincronizar se esta offline
    if (!state.isOnline) {
      console.log('[Sync] Dispositivo offline. Sincronizacao adiada.');
      return;
    }

    // Evitar sincronizacoes simultaneas
    if (state.isSyncing) {
      console.log('[Sync] Sincronizacao ja em andamento.');
      return;
    }

    set({ isSyncing: true, syncError: null });

    try {
      console.log(
        `[Sync] Iniciando sincronizacao de ${state.pendingOperations.length} operacoes...`,
      );

      // Ordenar por data de criacao (FIFO)
      const sortedOps = [...state.pendingOperations].sort(
        (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
      );

      // Preparar payload para sync em lote
      const syncPayload = sortedOps.map((op) => ({
        id: op.id,
        method: op.method,
        url: op.url,
        data: op.data,
        created_at: op.createdAt,
      }));

      // Enviar lote de operacoes para o servidor
      const response = await apiPost<SyncBatchResponse>('/sync', {
        operations: syncPayload,
      });

      const { results, synced, failed } = response.data;

      // Remover operacoes sincronizadas com sucesso
      const successIds = results
        .filter((r) => r.success)
        .map((r) => r.operationId);

      set((currentState) => {
        const remaining = currentState.pendingOperations.filter(
          (op) => !successIds.includes(op.id),
        );
        return {
          pendingOperations: remaining,
          pendingCount: remaining.length,
          lastSync: new Date(),
          isSyncing: false,
          syncError: failed > 0
            ? `${synced} sincronizadas, ${failed} falharam. Serao reenviadas.`
            : null,
        };
      });

      console.log(
        `[Sync] Sincronizacao concluida: ${synced} sucesso, ${failed} falhas.`,
      );

      // Logar operacoes que falharam para debug
      const failedOps = results.filter((r) => !r.success);
      if (failedOps.length > 0) {
        console.warn('[Sync] Operacoes que falharam:', failedOps);
      }
    } catch (error) {
      console.error('[Sync] Erro na sincronizacao em lote:', error);

      // Tentar sincronizar individualmente como fallback
      await syncIndividually(get, set);
    }
  },

  setOnline: (online: boolean) => {
    const wasOffline = !get().isOnline;
    set({ isOnline: online });

    // Se mudou de offline para online, sincronizar automaticamente
    if (wasOffline && online) {
      console.log('[Sync] Conexao restaurada. Iniciando sincronizacao automatica...');
      // Pequeno delay para garantir que a conexao estabilizou
      setTimeout(() => {
        get().syncAll();
      }, 2000);
    }
  },

  clearPending: () => {
    set({
      pendingOperations: [],
      pendingCount: 0,
      syncError: null,
    });
  },
}));

// ==========================================
// FUNCAO AUXILIAR: SYNC INDIVIDUAL (FALLBACK)
// ==========================================

/**
 * Sincroniza operacoes uma a uma quando o endpoint de sync em lote falha.
 * Mais lento, mas garante que operacoes validas sejam sincronizadas
 * mesmo que algumas falhem.
 */
async function syncIndividually(
  get: () => SyncState,
  set: (partial: Partial<SyncState> | ((state: SyncState) => Partial<SyncState>)) => void,
): Promise<void> {
  const operations = [...get().pendingOperations].sort(
    (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
  );

  let synced = 0;
  let failed = 0;

  for (const op of operations) {
    try {
      // Importar api dinamicamente para evitar dependencia circular
      const { default: api } = await import('@services/api');

      await api.request({
        method: op.method.toLowerCase(),
        url: op.url,
        data: op.data,
      });

      // Operacao bem-sucedida: remover da fila
      get().removePendingOp(op.id);
      synced++;
    } catch (error) {
      console.warn(`[Sync] Falha ao sincronizar operacao ${op.id}:`, error);
      failed++;
      // Manter na fila para proxima tentativa
    }
  }

  set({
    lastSync: synced > 0 ? new Date() : get().lastSync,
    isSyncing: false,
    syncError: failed > 0
      ? `${synced} sincronizadas, ${failed} falharam. Serao reenviadas.`
      : null,
  });

  console.log(
    `[Sync] Sync individual concluido: ${synced} sucesso, ${failed} falhas.`,
  );
}

export default useSyncStore;
