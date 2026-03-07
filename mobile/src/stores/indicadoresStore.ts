/**
 * Store de indicadores zootecnicos (Zustand).
 *
 * Gerencia indicadores calculados do lote selecionado:
 * - ICA (Indice de Conversao Alimentar)
 * - IEA (Indice de Eficiencia Alimentar)
 * - GPD (Ganho de Peso Diario)
 * - IEP (Indice de Eficiencia Produtiva)
 * - Viabilidade
 * - Aves vivas
 * - Saldo de racao + projecao
 * - Consumo de agua e relacao agua/racao
 * - Dados para graficos (evolucao peso, mortalidade)
 */

import { create } from 'zustand';
import { apiGet } from '@services/api';

// ==========================================
// TIPOS
// ==========================================

export interface Indicadores {
  /** Dias de vida do lote */
  diasDeVida: number;
  /** Aves vivas (quantidade original - mortalidade acumulada) */
  avesVivas: number;
  /** Quantidade original alojada */
  quantidadeOriginal: number;
  /** Mortalidade acumulada (numero) */
  mortalidadeAcumulada: number;
  /** Mortalidade acumulada (percentual) */
  mortalidadeAcumuladaPct: number;
  /** Mortalidade do dia (numero) */
  mortalidadeDia: number;
  /** Mortalidade do dia (percentual) */
  mortalidadeDiaPct: number;
  /** Ultimo peso medio registrado (gramas) */
  ultimoPesoMedio: number;
  /** Peso benchmark da linhagem para a idade (gramas) */
  pesoBenchmark: number;
  /** Desvio do peso em relacao ao benchmark (percentual) */
  pesoDesvioPct: number;
  /** GPD - Ganho de Peso Diario (g/dia) */
  gpd: number;
  /** ICA - Indice de Conversao Alimentar */
  ica: number;
  /** IEA - Indice de Eficiencia Alimentar */
  iea: number;
  /** IEP - Indice de Eficiencia Produtiva */
  iep: number;
  /** Classificacao do IEP */
  iepClassificacao: 'Ruim' | 'Regular' | 'Bom' | 'Excelente';
  /** Viabilidade (100% - mortalidade acumulada %) */
  viabilidade: number;
  /** Total de racao recebida (kg) */
  racaoRecebida: number;
  /** Total de racao consumida (kg) */
  racaoConsumida: number;
  /** Saldo de racao em estoque (kg) */
  saldoRacao: number;
  /** Estimativa de dias restantes de racao */
  diasRestantesRacao: number;
  /** Consumo medio diario de racao (kg) */
  consumoMedioDiarioRacao: number;
  /** Consumo de agua do dia (litros) */
  consumoAguaDia: number;
  /** Consumo de agua por ave por dia (mL) */
  consumoAguaPorAve: number;
  /** Relacao agua/racao */
  relacaoAguaRacao: number;
  /** Texto de projecao */
  projecaoTexto: string;
  /** Peso projetado no abate (g) */
  pesoProjetadoAbate: number;
  /** Dias ate atingir peso alvo */
  diasParaPesoAlvo: number;
}

export interface PontoGrafico {
  label: string;
  valor: number;
}

export interface DadosGraficoPeso {
  /** Dados reais de peso (dia a dia ou por pesagem) */
  pesoReal: PontoGrafico[];
  /** Dados do benchmark da linhagem */
  pesoBenchmark: PontoGrafico[];
}

export interface DadosGraficoMortalidade {
  /** Mortalidade diaria */
  mortalidadeDiaria: PontoGrafico[];
  /** Mortalidade acumulada */
  mortalidadeAcumulada: PontoGrafico[];
}

export interface DadosGraficoAgua {
  /** Consumo diario de agua */
  consumoDiario: PontoGrafico[];
}

export interface IndicadoresState {
  /** Indicadores do lote selecionado */
  indicadores: Indicadores | null;
  /** Dados para grafico de evolucao de peso */
  dadosGraficoPeso: DadosGraficoPeso | null;
  /** Dados para grafico de mortalidade */
  dadosGraficoMortalidade: DadosGraficoMortalidade | null;
  /** Dados para grafico de agua */
  dadosGraficoAgua: DadosGraficoAgua | null;
  /** Cache de indicadores por loteId */
  cache: Record<string, { indicadores: Indicadores; timestamp: number }>;
  /** Indica se esta carregando */
  isLoading: boolean;
  /** Mensagem de erro */
  errorMessage: string | null;

  // Acoes
  fetchIndicadores: (loteId: string, forceRefresh?: boolean) => Promise<void>;
  fetchDadosGraficoPeso: (loteId: string) => Promise<void>;
  fetchDadosGraficoMortalidade: (loteId: string) => Promise<void>;
  fetchDadosGraficoAgua: (loteId: string) => Promise<void>;
  limparIndicadores: () => void;
  limparCache: () => void;
}

/** Tempo de cache dos indicadores: 5 minutos */
const CACHE_TTL_MS = 5 * 60 * 1000;

// ==========================================
// STORE
// ==========================================

export const useIndicadoresStore = create<IndicadoresState>((set, get) => ({
  indicadores: null,
  dadosGraficoPeso: null,
  dadosGraficoMortalidade: null,
  dadosGraficoAgua: null,
  cache: {},
  isLoading: false,
  errorMessage: null,

  fetchIndicadores: async (loteId: string, forceRefresh = false) => {
    // Verificar cache
    if (!forceRefresh) {
      const cached = get().cache[loteId];
      if (cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
        set({ indicadores: cached.indicadores, isLoading: false });
        return;
      }
    }

    set({ isLoading: true, errorMessage: null });

    try {
      const response = await apiGet<Indicadores>(`/lotes/${loteId}/indicadores`);
      const indicadores = response.data;

      set((state) => ({
        indicadores,
        isLoading: false,
        cache: {
          ...state.cache,
          [loteId]: { indicadores, timestamp: Date.now() },
        },
      }));
    } catch (error: any) {
      set({
        isLoading: false,
        errorMessage: error?.error?.message || 'Erro ao carregar indicadores.',
      });
    }
  },

  fetchDadosGraficoPeso: async (loteId: string) => {
    try {
      const response = await apiGet<DadosGraficoPeso>(`/lotes/${loteId}/graficos/peso`);
      set({ dadosGraficoPeso: response.data });
    } catch (error: any) {
      console.warn('[IndicadoresStore] Erro ao carregar grafico de peso:', error);
    }
  },

  fetchDadosGraficoMortalidade: async (loteId: string) => {
    try {
      const response = await apiGet<DadosGraficoMortalidade>(`/lotes/${loteId}/graficos/mortalidade`);
      set({ dadosGraficoMortalidade: response.data });
    } catch (error: any) {
      console.warn('[IndicadoresStore] Erro ao carregar grafico de mortalidade:', error);
    }
  },

  fetchDadosGraficoAgua: async (loteId: string) => {
    try {
      const response = await apiGet<DadosGraficoAgua>(`/lotes/${loteId}/graficos/agua`);
      set({ dadosGraficoAgua: response.data });
    } catch (error: any) {
      console.warn('[IndicadoresStore] Erro ao carregar grafico de agua:', error);
    }
  },

  limparIndicadores: () => {
    set({
      indicadores: null,
      dadosGraficoPeso: null,
      dadosGraficoMortalidade: null,
      dadosGraficoAgua: null,
    });
  },

  limparCache: () => {
    set({ cache: {} });
  },
}));

export default useIndicadoresStore;
