import { useQuery } from '@tanstack/react-query';
import {
  Layers,
  Bird,
  TrendingDown,
  Calculator,
  CloudSun,
  AlertTriangle,
} from 'lucide-react';
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts';
import { dashboardService } from '../services/api';
import StatCard from '../components/StatCard';
import Badge, { severidadeVariant } from '../components/Badge';
import LoadingSkeleton from '../components/LoadingSkeleton';
import type { Indicadores, ICAHistorico, PesoLote, Alerta, PrevisaoTempo } from '../types';
import { format, parseISO } from 'date-fns';
import { ptBR } from 'date-fns/locale';

// Dados mock para demo sem backend
const mockIndicadores: Indicadores = {
  lotes_ativos: 24, aves_totais: 312000, mortalidade_media: 3.2, ica_medio: 1.72,
  lotes_ativos_variacao: 8.3, aves_totais_variacao: 12.5, mortalidade_variacao: -0.4, ica_variacao: -2.1,
};

const mockICAHistorico: ICAHistorico[] = [
  { mes: '2025-08', ica: 1.82 }, { mes: '2025-09', ica: 1.78 }, { mes: '2025-10', ica: 1.75 },
  { mes: '2025-11', ica: 1.74 }, { mes: '2025-12', ica: 1.71 }, { mes: '2026-01', ica: 1.72 },
];

const mockPesoLotes: PesoLote[] = [
  { lote: 'Lote 01', peso_medio: 2.85 }, { lote: 'Lote 02', peso_medio: 2.42 },
  { lote: 'Lote 03', peso_medio: 1.98 }, { lote: 'Lote 04', peso_medio: 3.12 },
  { lote: 'Lote 05', peso_medio: 2.65 }, { lote: 'Lote 06', peso_medio: 1.45 },
];

const mockAlertas: Alerta[] = [
  { id: 1, tipo: 'sensor', mensagem: 'Temperatura acima de 32°C no Galpão 3', lote_nome: 'Lote 04', granja_nome: 'Granja São José', severidade: 'alta', data: '2026-03-07T14:30:00', lida: false },
  { id: 2, tipo: 'mortalidade', mensagem: 'Mortalidade diária acima do esperado', lote_nome: 'Lote 02', granja_nome: 'Granja Boa Vista', severidade: 'media', data: '2026-03-07T10:15:00', lida: false },
  { id: 3, tipo: 'clima', mensagem: 'Alerta de chuva forte prevista para amanhã', lote_nome: undefined, granja_nome: 'Granja São José', severidade: 'baixa', data: '2026-03-06T18:00:00', lida: true },
  { id: 4, tipo: 'producao', mensagem: 'ICA acima de 2.0 - verificar consumo de ração', lote_nome: 'Lote 07', granja_nome: 'Granja Nova', severidade: 'critica', data: '2026-03-06T09:00:00', lida: true },
];

const mockPrevisao: PrevisaoTempo[] = [
  { data: '2026-03-07', temperatura_min: 18, temperatura_max: 29, umidade: 65, condicao: 'Parcialmente nublado', icone: 'cloud-sun', vento_kmh: 12, precipitacao_mm: 0 },
  { data: '2026-03-08', temperatura_min: 20, temperatura_max: 32, umidade: 70, condicao: 'Chuva leve', icone: 'cloud-rain', vento_kmh: 18, precipitacao_mm: 8 },
  { data: '2026-03-09', temperatura_min: 17, temperatura_max: 26, umidade: 55, condicao: 'Ensolarado', icone: 'sun', vento_kmh: 8, precipitacao_mm: 0 },
];

export default function Dashboard() {
  const { data: indicadores, isLoading: loadingIndicadores } = useQuery<Indicadores>({
    queryKey: ['dashboard', 'indicadores'],
    queryFn: async () => {
      try { const res = await dashboardService.getIndicadores(); return res.data.data || res.data; }
      catch { return mockIndicadores; }
    },
  });

  const { data: icaHistorico, isLoading: loadingICA } = useQuery<ICAHistorico[]>({
    queryKey: ['dashboard', 'ica-historico'],
    queryFn: async () => {
      try { const res = await dashboardService.getICAHistorico(); return res.data.data || res.data; }
      catch { return mockICAHistorico; }
    },
  });

  const { data: pesoLotes, isLoading: loadingPeso } = useQuery<PesoLote[]>({
    queryKey: ['dashboard', 'peso-lotes'],
    queryFn: async () => {
      try { const res = await dashboardService.getPesoLotes(); return res.data.data || res.data; }
      catch { return mockPesoLotes; }
    },
  });

  const { data: alertas } = useQuery<Alerta[]>({
    queryKey: ['dashboard', 'alertas'],
    queryFn: async () => {
      try { const res = await dashboardService.getAlertas(); return res.data.data || res.data; }
      catch { return mockAlertas; }
    },
  });

  const { data: previsao } = useQuery<PrevisaoTempo[]>({
    queryKey: ['dashboard', 'previsao'],
    queryFn: async () => {
      try { const res = await dashboardService.getPrevisaoTempo(); return res.data.data || res.data; }
      catch { return mockPrevisao; }
    },
  });

  const formatarNumero = (num: number) => num.toLocaleString('pt-BR');

  const formatarData = (dateStr: string) => {
    try { return format(parseISO(dateStr), "dd/MM/yyyy HH:mm", { locale: ptBR }); }
    catch { return dateStr; }
  };

  const formatarMes = (mesStr: string) => {
    try { return format(parseISO(mesStr + '-01'), 'MMM/yy', { locale: ptBR }); }
    catch { return String(mesStr); }
  };

  if (loadingIndicadores) {
    return (
      <div className="space-y-6">
        <LoadingSkeleton type="cards" count={4} />
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <LoadingSkeleton type="chart" />
          <LoadingSkeleton type="chart" />
        </div>
      </div>
    );
  }

  const kpi = indicadores || mockIndicadores;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-sm text-gray-500 mt-1">Visão geral da operação avícola</p>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard titulo="Lotes Ativos" valor={kpi.lotes_ativos} icone={Layers} variacao={kpi.lotes_ativos_variacao} />
        <StatCard titulo="Aves Totais" valor={formatarNumero(kpi.aves_totais)} icone={Bird} variacao={kpi.aves_totais_variacao} />
        <StatCard titulo="Mortalidade Média" valor={kpi.mortalidade_media.toFixed(1).replace('.', ',')} icone={TrendingDown} variacao={kpi.mortalidade_variacao} sufixo="%" />
        <StatCard titulo="ICA Médio" valor={kpi.ica_medio.toFixed(2).replace('.', ',')} icone={Calculator} variacao={kpi.ica_variacao} />
      </div>

      {/* Gráficos */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card">
          <h3 className="text-base font-semibold text-gray-900 mb-4">Evolução do ICA - Últimos 6 Meses</h3>
          {loadingICA ? (
            <div className="h-64 animate-pulse bg-gray-100 rounded" />
          ) : (
            <ResponsiveContainer width="100%" height={280}>
              <LineChart data={icaHistorico || mockICAHistorico}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="mes" tickFormatter={(v) => formatarMes(String(v))} tick={{ fontSize: 12, fill: '#888' }} />
                <YAxis domain={['auto', 'auto']} tick={{ fontSize: 12, fill: '#888' }} tickFormatter={(v) => Number(v).toFixed(2)} />
                <Tooltip
                  formatter={(value) => [Number(value).toFixed(2).replace('.', ','), 'ICA']}
                  labelFormatter={(label) => formatarMes(String(label))}
                />
                <Line type="monotone" dataKey="ica" stroke="#2E7D32" strokeWidth={2.5} dot={{ r: 4, fill: '#2E7D32' }} activeDot={{ r: 6 }} />
              </LineChart>
            </ResponsiveContainer>
          )}
        </div>

        <div className="card">
          <h3 className="text-base font-semibold text-gray-900 mb-4">Peso Médio por Lote Ativo (kg)</h3>
          {loadingPeso ? (
            <div className="h-64 animate-pulse bg-gray-100 rounded" />
          ) : (
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={pesoLotes || mockPesoLotes}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="lote" tick={{ fontSize: 12, fill: '#888' }} />
                <YAxis tick={{ fontSize: 12, fill: '#888' }} />
                <Tooltip formatter={(value) => [Number(value).toFixed(2).replace('.', ',') + ' kg', 'Peso Médio']} />
                <Legend />
                <Bar dataKey="peso_medio" name="Peso Médio" fill="#4CAF50" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>

      {/* Alertas e Previsão */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 card p-0">
          <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <h3 className="text-base font-semibold text-gray-900 flex items-center gap-2">
              <AlertTriangle className="w-5 h-5 text-amber-500" />
              Últimos Alertas
            </h3>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50">
                  <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Tipo</th>
                  <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Mensagem</th>
                  <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Lote</th>
                  <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Data</th>
                  <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Severidade</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {(alertas || mockAlertas).map((alerta) => (
                  <tr key={alerta.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 text-sm">
                      <Badge variant={alerta.tipo === 'sensor' ? 'info' : alerta.tipo === 'mortalidade' ? 'danger' : alerta.tipo === 'clima' ? 'warning' : 'neutral'} size="sm">
                        {alerta.tipo}
                      </Badge>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-700 max-w-xs truncate">{alerta.mensagem}</td>
                    <td className="px-4 py-3 text-sm text-gray-600">{alerta.lote_nome || '-'}</td>
                    <td className="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">{formatarData(alerta.data)}</td>
                    <td className="px-4 py-3">
                      <Badge variant={severidadeVariant(alerta.severidade)} size="sm">{alerta.severidade}</Badge>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div className="card">
          <h3 className="text-base font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <CloudSun className="w-5 h-5 text-blue-500" />
            Previsão do Tempo
          </h3>
          <div className="space-y-3">
            {(previsao || mockPrevisao).map((dia) => (
              <div key={dia.data} className="p-3 bg-gray-50 rounded-lg flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-900">{format(parseISO(dia.data), "EEEE, dd/MM", { locale: ptBR })}</p>
                  <p className="text-xs text-gray-500 mt-0.5">{dia.condicao}</p>
                </div>
                <div className="text-right">
                  <p className="text-sm font-semibold text-gray-900">{dia.temperatura_min}° / {dia.temperatura_max}°</p>
                  <p className="text-xs text-gray-500">{dia.umidade}% umid. | {dia.precipitacao_mm}mm</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
