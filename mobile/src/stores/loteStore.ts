/**
 * Store de lotes (Zustand).
 *
 * Gerencia o estado global dos lotes do usuario:
 * - Lista de lotes ativos e finalizados
 * - Lote selecionado para visualizacao/edicao
 * - CRUD de lotes
 * - Refresh e paginacao
 * - Dados de pesagens, mortalidade, racao e agua por lote
 */

import { create } from 'zustand';
import { apiGet, apiPost, apiPatch, apiDelete, PaginationMeta } from '@services/api';
import { useSyncStore } from './syncStore';

// ==========================================
// TIPOS
// ==========================================

export interface Galpao {
  id: string;
  nome: string;
  capacidade?: number;
}

export interface Lote {
  id: string;
  galpaoId: string;
  galpaoNome: string;
  dataAlojamento: string;
  dataPrevistaAbate: string;
  quantidade: number;
  tipo: 'Femea' | 'Macho' | 'Misto';
  linhagem?: string;
  pesoInicialG: number;
  status: 'ativo' | 'finalizado';
  dataFinalizacao?: string;
  avesEntregues?: number;
  pesoTotalEntregue?: number;
  sobraRacao?: number;
  // Indicadores calculados (vindos da API)
  mortalidadeAcumulada?: number;
  ultimoPesoMedio?: number;
  pesoBenchmark?: number;
  mortesRecentes?: number;
  dataMortesRecentes?: string;
  mortalidadeRecentePct?: number;
  temAlerta?: boolean;
  quantidadeAlertas?: number;
  // Indicadores consolidados
  diasDeVida?: number;
  avesVivas?: number;
  gpd?: number;
  ica?: number;
  iea?: number;
  iep?: number;
  viabilidade?: number;
  saldoRacao?: number;
  diasRestantesRacao?: number;
  consumoAguaDia?: number;
  relacaoAguaRacao?: number;
  createdAt: string;
  updatedAt: string;
}

export interface Pesagem {
  id: string;
  loteId: string;
  data: string;
  quantidadeTotal: number;
  pesoTotal: number;
  pesoMedio: number;
  pesoBenchmark?: number;
  desvioPct?: number;
  uniformidadeCV?: number;
  idade?: number;
  itens: PesagemItem[];
  createdAt: string;
}

export interface PesagemItem {
  id: string;
  pesagemId: string;
  quantidade: number;
  peso: number;
  pesoMedio: number;
}

export interface Mortalidade {
  id: string;
  loteId: string;
  data: string;
  quantidade: number;
  causa: string;
  observacao?: string;
  fotoUrl?: string;
  percentualDia?: number;
  createdAt: string;
}

export interface RecebimentoRacao {
  id: string;
  loteId: string;
  dataRecebimento: string;
  quantidadeKg: number;
  tipoRacaoId?: string;
  tipoRacaoNome?: string;
  fornecedor?: string;
  loteRacao?: string;
  origem: 'compra' | 'remanescente_anterior' | 'sobra_final';
  createdAt: string;
}

export interface ConsumoRacao {
  id: string;
  loteId: string;
  data: string;
  quantidadeKg: number;
  createdAt: string;
}

export interface ConsumoAgua {
  id: string;
  loteId: string;
  data: string;
  quantidadeLitros: number;
  consumoPorAve?: number;
  relacaoAguaRacao?: number;
  createdAt: string;
}

export interface NovoLotePayload {
  galpaoId: string;
  dataAlojamento: string;
  dataPrevistaAbate: string;
  quantidade: number;
  tipo: 'Femea' | 'Macho' | 'Misto';
  linhagem?: string;
  pesoInicialG: number;
}

export interface FinalizarLotePayload {
  dataFinalizacao: string;
  avesEntregues: number;
  pesoTotalEntregue: number;
  sobraRacao?: number;
  transferirSobraProximoLote?: boolean;
}

export interface LoteState {
  /** Lista de lotes ativos */
  lotesAtivos: Lote[];
  /** Lista de lotes finalizados */
  lotesFinalizados: Lote[];
  /** Lote atualmente selecionado */
  loteSelecionado: Lote | null;
  /** Lista de galpoes disponiveis */
  galpaos: Galpao[];
  /** Pesagens do lote selecionado */
  pesagens: Pesagem[];
  /** Mortalidades do lote selecionado */
  mortalidades: Mortalidade[];
  /** Recebimentos de racao do lote selecionado */
  recebimentosRacao: RecebimentoRacao[];
  /** Consumos de racao do lote selecionado */
  consumosRacao: ConsumoRacao[];
  /** Consumos de agua do lote selecionado */
  consumosAgua: ConsumoAgua[];
  /** Metadados de paginacao */
  pagination: PaginationMeta | null;
  /** Indica se esta carregando */
  isLoading: boolean;
  /** Indica se esta carregando mais itens (paginacao) */
  isLoadingMore: boolean;
  /** Indica se esta salvando */
  isSaving: boolean;
  /** Mensagem de erro */
  errorMessage: string | null;
  /** Mensagem de sucesso */
  successMessage: string | null;

  // Acoes
  fetchLotesAtivos: (page?: number) => Promise<void>;
  fetchLotesFinalizados: (page?: number) => Promise<void>;
  fetchLoteById: (loteId: string) => Promise<void>;
  fetchGalpaos: () => Promise<void>;
  criarLote: (payload: NovoLotePayload) => Promise<boolean>;
  finalizarLote: (loteId: string, payload: FinalizarLotePayload) => Promise<boolean>;
  selecionarLote: (lote: Lote | null) => void;
  fetchPesagens: (loteId: string, page?: number) => Promise<void>;
  fetchMortalidades: (loteId: string, page?: number) => Promise<void>;
  fetchRecebimentosRacao: (loteId: string, page?: number) => Promise<void>;
  fetchConsumosRacao: (loteId: string, page?: number) => Promise<void>;
  fetchConsumosAgua: (loteId: string, page?: number) => Promise<void>;
  criarPesagem: (loteId: string, itens: Array<{ quantidade: number; peso: number }>) => Promise<boolean>;
  criarMortalidade: (loteId: string, data: { data: string; quantidade: number; causa: string; observacao?: string; fotoUrl?: string }) => Promise<boolean>;
  criarRecebimentoRacao: (loteId: string, data: { dataRecebimento: string; quantidadeKg: number; tipoRacaoNome?: string; fornecedor?: string; loteRacao?: string }) => Promise<boolean>;
  criarConsumoRacao: (loteId: string, data: { data: string; quantidadeKg: number }) => Promise<boolean>;
  criarConsumoAgua: (loteId: string, data: { data: string; quantidadeLitros: number }) => Promise<boolean>;
  refresh: () => Promise<void>;
  clearMessages: () => void;
}

// ==========================================
// STORE
// ==========================================

export const useLoteStore = create<LoteState>((set, get) => ({
  lotesAtivos: [],
  lotesFinalizados: [],
  loteSelecionado: null,
  galpaos: [],
  pesagens: [],
  mortalidades: [],
  recebimentosRacao: [],
  consumosRacao: [],
  consumosAgua: [],
  pagination: null,
  isLoading: false,
  isLoadingMore: false,
  isSaving: false,
  errorMessage: null,
  successMessage: null,

  fetchLotesAtivos: async (page = 1) => {
    const isFirstPage = page === 1;
    set({ [isFirstPage ? 'isLoading' : 'isLoadingMore']: true, errorMessage: null });

    try {
      const response = await apiGet<Lote[]>('/lotes', { status: 'ativo', page, per_page: 20 });
      set((state) => ({
        lotesAtivos: isFirstPage
          ? response.data
          : [...state.lotesAtivos, ...response.data],
        pagination: response.meta || null,
        isLoading: false,
        isLoadingMore: false,
      }));
    } catch (error: any) {
      set({
        isLoading: false,
        isLoadingMore: false,
        errorMessage: error?.error?.message || 'Erro ao carregar lotes ativos.',
      });
    }
  },

  fetchLotesFinalizados: async (page = 1) => {
    const isFirstPage = page === 1;
    set({ [isFirstPage ? 'isLoading' : 'isLoadingMore']: true, errorMessage: null });

    try {
      const response = await apiGet<Lote[]>('/lotes', { status: 'finalizado', page, per_page: 20 });
      set((state) => ({
        lotesFinalizados: isFirstPage
          ? response.data
          : [...state.lotesFinalizados, ...response.data],
        pagination: response.meta || null,
        isLoading: false,
        isLoadingMore: false,
      }));
    } catch (error: any) {
      set({
        isLoading: false,
        isLoadingMore: false,
        errorMessage: error?.error?.message || 'Erro ao carregar lotes finalizados.',
      });
    }
  },

  fetchLoteById: async (loteId: string) => {
    set({ isLoading: true, errorMessage: null });

    try {
      const response = await apiGet<Lote>(`/lotes/${loteId}`);
      set({
        loteSelecionado: response.data,
        isLoading: false,
      });
    } catch (error: any) {
      set({
        isLoading: false,
        errorMessage: error?.error?.message || 'Erro ao carregar detalhes do lote.',
      });
    }
  },

  fetchGalpaos: async () => {
    try {
      const response = await apiGet<Galpao[]>('/galpaos');
      set({ galpaos: response.data });
    } catch (error: any) {
      console.warn('[LoteStore] Erro ao carregar galpoes:', error);
    }
  },

  criarLote: async (payload: NovoLotePayload) => {
    set({ isSaving: true, errorMessage: null, successMessage: null });

    try {
      const response = await apiPost<Lote>('/lotes', payload);
      set((state) => ({
        lotesAtivos: [response.data, ...state.lotesAtivos],
        isSaving: false,
        successMessage: 'Lote criado com sucesso!',
      }));
      return true;
    } catch (error: any) {
      // Se erro de rede, o interceptor ja salvou offline
      const isNetworkError = error?.error?.code === 'NETWORK_ERROR';
      set({
        isSaving: false,
        errorMessage: isNetworkError
          ? undefined
          : (error?.error?.message || 'Erro ao criar lote.'),
        successMessage: isNetworkError
          ? 'Lote salvo localmente. Sera sincronizado quando houver conexao.'
          : undefined,
      });
      return isNetworkError;
    }
  },

  finalizarLote: async (loteId: string, payload: FinalizarLotePayload) => {
    set({ isSaving: true, errorMessage: null, successMessage: null });

    try {
      const response = await apiPatch<Lote>(`/lotes/${loteId}/finalizar`, payload);
      set((state) => ({
        lotesAtivos: state.lotesAtivos.filter((l) => l.id !== loteId),
        lotesFinalizados: [response.data, ...state.lotesFinalizados],
        loteSelecionado: response.data,
        isSaving: false,
        successMessage: 'Lote finalizado com sucesso!',
      }));
      return true;
    } catch (error: any) {
      const isNetworkError = error?.error?.code === 'NETWORK_ERROR';
      set({
        isSaving: false,
        errorMessage: isNetworkError
          ? undefined
          : (error?.error?.message || 'Erro ao finalizar lote.'),
        successMessage: isNetworkError
          ? 'Finalizacao salva localmente. Sera sincronizada quando houver conexao.'
          : undefined,
      });
      return isNetworkError;
    }
  },

  selecionarLote: (lote: Lote | null) => {
    set({
      loteSelecionado: lote,
      pesagens: [],
      mortalidades: [],
      recebimentosRacao: [],
      consumosRacao: [],
      consumosAgua: [],
    });
  },

  fetchPesagens: async (loteId: string, page = 1) => {
    const isFirstPage = page === 1;
    set({ [isFirstPage ? 'isLoading' : 'isLoadingMore']: true });

    try {
      const response = await apiGet<Pesagem[]>(`/lotes/${loteId}/pesagens`, { page, per_page: 20 });
      set((state) => ({
        pesagens: isFirstPage
          ? response.data
          : [...state.pesagens, ...response.data],
        pagination: response.meta || null,
        isLoading: false,
        isLoadingMore: false,
      }));
    } catch (error: any) {
      set({
        isLoading: false,
        isLoadingMore: false,
        errorMessage: error?.error?.message || 'Erro ao carregar pesagens.',
      });
    }
  },

  fetchMortalidades: async (loteId: string, page = 1) => {
    const isFirstPage = page === 1;
    set({ [isFirstPage ? 'isLoading' : 'isLoadingMore']: true });

    try {
      const response = await apiGet<Mortalidade[]>(`/lotes/${loteId}/mortalidades`, { page, per_page: 20 });
      set((state) => ({
        mortalidades: isFirstPage
          ? response.data
          : [...state.mortalidades, ...response.data],
        pagination: response.meta || null,
        isLoading: false,
        isLoadingMore: false,
      }));
    } catch (error: any) {
      set({
        isLoading: false,
        isLoadingMore: false,
        errorMessage: error?.error?.message || 'Erro ao carregar mortalidade.',
      });
    }
  },

  fetchRecebimentosRacao: async (loteId: string, page = 1) => {
    const isFirstPage = page === 1;
    set({ [isFirstPage ? 'isLoading' : 'isLoadingMore']: true });

    try {
      const response = await apiGet<RecebimentoRacao[]>(`/lotes/${loteId}/racao/recebimentos`, { page, per_page: 20 });
      set((state) => ({
        recebimentosRacao: isFirstPage
          ? response.data
          : [...state.recebimentosRacao, ...response.data],
        pagination: response.meta || null,
        isLoading: false,
        isLoadingMore: false,
      }));
    } catch (error: any) {
      set({
        isLoading: false,
        isLoadingMore: false,
        errorMessage: error?.error?.message || 'Erro ao carregar recebimentos.',
      });
    }
  },

  fetchConsumosRacao: async (loteId: string, page = 1) => {
    const isFirstPage = page === 1;
    set({ [isFirstPage ? 'isLoading' : 'isLoadingMore']: true });

    try {
      const response = await apiGet<ConsumoRacao[]>(`/lotes/${loteId}/racao/consumos`, { page, per_page: 20 });
      set((state) => ({
        consumosRacao: isFirstPage
          ? response.data
          : [...state.consumosRacao, ...response.data],
        pagination: response.meta || null,
        isLoading: false,
        isLoadingMore: false,
      }));
    } catch (error: any) {
      set({
        isLoading: false,
        isLoadingMore: false,
        errorMessage: error?.error?.message || 'Erro ao carregar consumos de racao.',
      });
    }
  },

  fetchConsumosAgua: async (loteId: string, page = 1) => {
    const isFirstPage = page === 1;
    set({ [isFirstPage ? 'isLoading' : 'isLoadingMore']: true });

    try {
      const response = await apiGet<ConsumoAgua[]>(`/lotes/${loteId}/agua`, { page, per_page: 20 });
      set((state) => ({
        consumosAgua: isFirstPage
          ? response.data
          : [...state.consumosAgua, ...response.data],
        pagination: response.meta || null,
        isLoading: false,
        isLoadingMore: false,
      }));
    } catch (error: any) {
      set({
        isLoading: false,
        isLoadingMore: false,
        errorMessage: error?.error?.message || 'Erro ao carregar consumos de agua.',
      });
    }
  },

  criarPesagem: async (loteId: string, itens: Array<{ quantidade: number; peso: number }>) => {
    set({ isSaving: true, errorMessage: null, successMessage: null });

    try {
      const response = await apiPost<Pesagem>(`/lotes/${loteId}/pesagens`, { itens });
      set((state) => ({
        pesagens: [response.data, ...state.pesagens],
        isSaving: false,
        successMessage: 'Pesagem registrada com sucesso!',
      }));
      return true;
    } catch (error: any) {
      const isNetworkError = error?.error?.code === 'NETWORK_ERROR';
      set({
        isSaving: false,
        errorMessage: isNetworkError ? undefined : (error?.error?.message || 'Erro ao registrar pesagem.'),
        successMessage: isNetworkError ? 'Pesagem salva localmente. Sera sincronizada.' : undefined,
      });
      return isNetworkError;
    }
  },

  criarMortalidade: async (loteId: string, data) => {
    set({ isSaving: true, errorMessage: null, successMessage: null });

    try {
      const response = await apiPost<Mortalidade>(`/lotes/${loteId}/mortalidades`, data);
      set((state) => ({
        mortalidades: [response.data, ...state.mortalidades],
        isSaving: false,
        successMessage: 'Mortalidade registrada com sucesso!',
      }));
      return true;
    } catch (error: any) {
      const isNetworkError = error?.error?.code === 'NETWORK_ERROR';
      set({
        isSaving: false,
        errorMessage: isNetworkError ? undefined : (error?.error?.message || 'Erro ao registrar mortalidade.'),
        successMessage: isNetworkError ? 'Mortalidade salva localmente. Sera sincronizada.' : undefined,
      });
      return isNetworkError;
    }
  },

  criarRecebimentoRacao: async (loteId: string, data) => {
    set({ isSaving: true, errorMessage: null, successMessage: null });

    try {
      const response = await apiPost<RecebimentoRacao>(`/lotes/${loteId}/racao/recebimentos`, data);
      set((state) => ({
        recebimentosRacao: [response.data, ...state.recebimentosRacao],
        isSaving: false,
        successMessage: 'Recebimento de racao registrado!',
      }));
      return true;
    } catch (error: any) {
      const isNetworkError = error?.error?.code === 'NETWORK_ERROR';
      set({
        isSaving: false,
        errorMessage: isNetworkError ? undefined : (error?.error?.message || 'Erro ao registrar recebimento.'),
        successMessage: isNetworkError ? 'Recebimento salvo localmente. Sera sincronizado.' : undefined,
      });
      return isNetworkError;
    }
  },

  criarConsumoRacao: async (loteId: string, data) => {
    set({ isSaving: true, errorMessage: null, successMessage: null });

    try {
      const response = await apiPost<ConsumoRacao>(`/lotes/${loteId}/racao/consumos`, data);
      set((state) => ({
        consumosRacao: [response.data, ...state.consumosRacao],
        isSaving: false,
        successMessage: 'Consumo de racao registrado!',
      }));
      return true;
    } catch (error: any) {
      const isNetworkError = error?.error?.code === 'NETWORK_ERROR';
      set({
        isSaving: false,
        errorMessage: isNetworkError ? undefined : (error?.error?.message || 'Erro ao registrar consumo.'),
        successMessage: isNetworkError ? 'Consumo salvo localmente. Sera sincronizado.' : undefined,
      });
      return isNetworkError;
    }
  },

  criarConsumoAgua: async (loteId: string, data) => {
    set({ isSaving: true, errorMessage: null, successMessage: null });

    try {
      const response = await apiPost<ConsumoAgua>(`/lotes/${loteId}/agua`, data);
      set((state) => ({
        consumosAgua: [response.data, ...state.consumosAgua],
        isSaving: false,
        successMessage: 'Consumo de agua registrado!',
      }));
      return true;
    } catch (error: any) {
      const isNetworkError = error?.error?.code === 'NETWORK_ERROR';
      set({
        isSaving: false,
        errorMessage: isNetworkError ? undefined : (error?.error?.message || 'Erro ao registrar consumo de agua.'),
        successMessage: isNetworkError ? 'Consumo salvo localmente. Sera sincronizado.' : undefined,
      });
      return isNetworkError;
    }
  },

  refresh: async () => {
    const state = get();
    await state.fetchLotesAtivos(1);
    if (state.loteSelecionado) {
      await state.fetchLoteById(state.loteSelecionado.id);
    }
  },

  clearMessages: () => {
    set({ errorMessage: null, successMessage: null });
  },
}));

export default useLoteStore;
