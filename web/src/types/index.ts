// ===================== Autenticação =====================
export interface LoginRequest {
  login: string;
  senha: string;
}

export interface LoginResponse {
  token: string;
  refresh_token: string;
  usuario: Usuario;
}

// ===================== Usuário =====================
export interface Usuario {
  id: number;
  nome: string;
  login: string;
  tipo: 'admin' | 'integradora' | 'tecnico' | 'produtor';
  email?: string;
  telefone?: string;
  ativo: boolean;
  ultimo_acesso?: string;
  created_at: string;
  updated_at: string;
}

// ===================== Granja =====================
export interface Granja {
  id: number;
  nome: string;
  endereco: string;
  cidade: string;
  estado: string;
  latitude?: number;
  longitude?: number;
  produtor_id: number;
  produtor_nome?: string;
  total_galpoes: number;
  lotes_ativos: number;
  created_at: string;
  updated_at: string;
}

export interface GranjaForm {
  nome: string;
  endereco: string;
  cidade: string;
  estado: string;
  latitude?: number;
  longitude?: number;
  produtor_id: number;
}

// ===================== Galpão =====================
export interface Galpao {
  id: number;
  granja_id: number;
  nome: string;
  comprimento: number;
  largura: number;
  orientacao: string;
  capacidade: number;
  lote_ativo?: LoteResumo;
  sensores?: SensorIoT[];
  created_at: string;
}

// ===================== Lote =====================
export interface Lote {
  id: number;
  nome: string;
  granja_id: number;
  granja_nome?: string;
  galpao_id: number;
  galpao_nome?: string;
  linhagem: string;
  data_alojamento: string;
  data_saida?: string;
  qtd_alojada: number;
  qtd_atual: number;
  idade_dias: number;
  status: 'ativo' | 'finalizado';
  mortalidade_perc: number;
  ica: number;
  peso_medio: number;
  created_at: string;
  updated_at: string;
}

export interface LoteResumo {
  id: number;
  nome: string;
  linhagem: string;
  idade_dias: number;
  qtd_atual: number;
  status: 'ativo' | 'finalizado';
}

export interface LoteForm {
  nome: string;
  granja_id: number;
  galpao_id: number;
  linhagem: string;
  data_alojamento: string;
  qtd_alojada: number;
}

// ===================== Pesagem =====================
export interface Pesagem {
  id: number;
  lote_id: number;
  data: string;
  idade_dias: number;
  amostra: number;
  peso_medio: number;
  uniformidade: number;
  desvio_padrao: number;
  peso_benchmark?: number;
  created_at: string;
}

// ===================== Mortalidade =====================
export interface Mortalidade {
  id: number;
  lote_id: number;
  data: string;
  idade_dias: number;
  quantidade: number;
  causa?: string;
  acumulada: number;
  percentual: number;
  created_at: string;
}

// ===================== Ração =====================
export interface RacaoRecebimento {
  id: number;
  lote_id: number;
  data: string;
  tipo_racao: string;
  quantidade_kg: number;
  fornecedor?: string;
  nota_fiscal?: string;
}

export interface RacaoConsumo {
  id: number;
  lote_id: number;
  data: string;
  idade_dias: number;
  quantidade_kg: number;
  tipo_racao: string;
  consumo_ave_g: number;
}

// ===================== Água =====================
export interface ConsumoAgua {
  id: number;
  lote_id: number;
  data: string;
  idade_dias: number;
  quantidade_litros: number;
  consumo_ave_ml: number;
}

// ===================== Sanidade =====================
export interface Vacinacao {
  id: number;
  lote_id: number;
  data: string;
  vacina: string;
  via_aplicacao: string;
  responsavel: string;
  observacao?: string;
}

export interface Medicamento {
  id: number;
  lote_id: number;
  data_inicio: string;
  data_fim: string;
  medicamento: string;
  dosagem: string;
  motivo: string;
  responsavel: string;
}

export interface Visitante {
  id: number;
  lote_id: number;
  data: string;
  nome: string;
  empresa: string;
  motivo: string;
}

// ===================== Financeiro =====================
export interface CustoLote {
  categoria: string;
  valor: number;
  percentual: number;
}

export interface ResumoFinanceiro {
  receita_bruta: number;
  custo_total: number;
  lucro_liquido: number;
  custo_por_kg: number;
  custos: CustoLote[];
}

// ===================== Indicadores / KPIs =====================
export interface Indicadores {
  lotes_ativos: number;
  aves_totais: number;
  mortalidade_media: number;
  ica_medio: number;
  lotes_ativos_variacao: number;
  aves_totais_variacao: number;
  mortalidade_variacao: number;
  ica_variacao: number;
}

export interface ICAHistorico {
  mes: string;
  ica: number;
}

export interface PesoLote {
  lote: string;
  peso_medio: number;
}

// ===================== Alertas =====================
export interface Alerta {
  id: number;
  tipo: 'clima' | 'mortalidade' | 'sensor' | 'producao';
  mensagem: string;
  lote_nome?: string;
  granja_nome?: string;
  severidade: 'baixa' | 'media' | 'alta' | 'critica';
  data: string;
  lida: boolean;
}

// ===================== Clima =====================
export interface PrevisaoTempo {
  data: string;
  temperatura_min: number;
  temperatura_max: number;
  umidade: number;
  condicao: string;
  icone: string;
  vento_kmh: number;
  precipitacao_mm: number;
}

// ===================== IoT / Sensores =====================
export interface SensorIoT {
  id: number;
  galpao_id: number;
  galpao_nome: string;
  granja_nome: string;
  tipo: 'temperatura' | 'umidade' | 'co2' | 'amonia';
  modelo: string;
  status: 'online' | 'offline' | 'alerta';
  ultima_leitura?: IoTReading;
}

export interface IoTReading {
  id: number;
  sensor_id: number;
  valor: number;
  unidade: string;
  timestamp: string;
}

export interface IoTGalpaoResumo {
  galpao_id: number;
  galpao_nome: string;
  granja_nome: string;
  temperatura?: number;
  umidade?: number;
  co2?: number;
  amonia?: number;
  status: 'normal' | 'alerta' | 'critico';
  ultima_atualizacao: string;
  historico_temperatura: IoTReading[];
  historico_umidade: IoTReading[];
}

// ===================== Relatórios =====================
export interface RelatorioFechamento {
  lote_id: number;
  formato: 'pdf' | 'csv';
}

export interface RelatorioComparativo {
  lote_ids: number[];
  formato: 'pdf' | 'csv';
}

// ===================== Paginação =====================
export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
}

// ===================== API Response =====================
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}
