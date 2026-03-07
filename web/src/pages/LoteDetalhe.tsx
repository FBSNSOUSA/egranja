import { useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { ArrowLeft, Bird, TrendingDown, Calculator, Scale, Droplets, Wheat, Stethoscope, DollarSign } from 'lucide-react';
import {
  LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Legend, AreaChart, Area, PieChart, Pie, Cell,
} from 'recharts';
import { loteService } from '../services/api';
import StatCard from '../components/StatCard';
import Badge from '../components/Badge';
import LoadingSkeleton from '../components/LoadingSkeleton';
import type { Lote, Pesagem, Mortalidade, RacaoConsumo, ConsumoAgua } from '../types';
import { format, parseISO } from 'date-fns';
import { ptBR } from 'date-fns/locale';

const mockLote: Lote = {
  id: 1, nome: 'Lote 01', granja_id: 1, granja_nome: 'Granja São José',
  galpao_id: 1, galpao_nome: 'Galpão 1', linhagem: 'Cobb 500',
  data_alojamento: '2026-02-07', qtd_alojada: 20000, qtd_atual: 19500,
  idade_dias: 28, status: 'ativo', mortalidade_perc: 2.5, ica: 1.68,
  peso_medio: 1.85, created_at: '2026-02-07', updated_at: '2026-03-07',
};

const mockPesagens: Pesagem[] = Array.from({ length: 5 }, (_, i) => ({
  id: i + 1, lote_id: 1, data: `2026-02-${String(7 + i * 7).padStart(2, '0')}`,
  idade_dias: i * 7, amostra: 100, peso_medio: 0.04 + i * 0.45,
  uniformidade: 85 - i * 2, desvio_padrao: 0.02 + i * 0.03,
  peso_benchmark: 0.04 + i * 0.42, created_at: '',
}));

const mockMortalidade: Mortalidade[] = Array.from({ length: 28 }, (_, i) => ({
  id: i + 1, lote_id: 1, data: `2026-02-${String(7 + i).padStart(2, '0')}`,
  idade_dias: i + 1, quantidade: Math.max(0, Math.floor(Math.random() * 25)),
  acumulada: 0, percentual: 0, created_at: '',
})).map((m, _, arr) => {
  const acumulada = arr.slice(0, arr.indexOf(m) + 1).reduce((s, x) => s + x.quantidade, 0);
  return { ...m, acumulada, percentual: (acumulada / 20000) * 100 };
});

const mockRacao: RacaoConsumo[] = Array.from({ length: 4 }, (_, i) => ({
  id: i + 1, lote_id: 1, data: `2026-02-${String(14 + i * 7).padStart(2, '0')}`,
  idade_dias: 7 + i * 7, quantidade_kg: 2000 + i * 3000, tipo_racao: i < 2 ? 'Inicial' : 'Crescimento',
  consumo_ave_g: 100 + i * 50,
}));

const mockAgua: ConsumoAgua[] = Array.from({ length: 28 }, (_, i) => ({
  id: i + 1, lote_id: 1, data: `2026-02-${String(7 + i).padStart(2, '0')}`,
  idade_dias: i + 1, quantidade_litros: 1500 + i * 200 + Math.random() * 500,
  consumo_ave_ml: 80 + i * 10,
}));

const mockVacinacoes = [
  { id: 1, data: '2026-02-07', vacina: 'Marek', via_aplicacao: 'Subcutânea', responsavel: 'Dr. Carlos', observacao: 'No incubatório' },
  { id: 2, data: '2026-02-14', vacina: 'Newcastle + Bronquite', via_aplicacao: 'Ocular', responsavel: 'Dr. Carlos', observacao: '' },
  { id: 3, data: '2026-02-21', vacina: 'Gumboro', via_aplicacao: 'Água de bebida', responsavel: 'Dr. Carlos', observacao: '' },
];

const mockMedicamentos = [
  { id: 1, data_inicio: '2026-02-10', data_fim: '2026-02-14', medicamento: 'Vitaminas AD3E', dosagem: '1ml/L água', motivo: 'Profilático', responsavel: 'Dr. Carlos' },
];

const mockVisitantes = [
  { id: 1, data: '2026-02-20', nome: 'Pedro Alves', empresa: 'Cobb-Vantress', motivo: 'Visita técnica' },
  { id: 2, data: '2026-03-01', nome: 'Ana Souza', empresa: 'Integradora Sul', motivo: 'Auditoria' },
];

const mockFinanceiro = {
  receita_bruta: 125000, custo_total: 98000, lucro_liquido: 27000, custo_por_kg: 2.72,
  custos: [
    { categoria: 'Ração', valor: 65000, percentual: 66.3 },
    { categoria: 'Pintainhos', valor: 16000, percentual: 16.3 },
    { categoria: 'Medicamentos', valor: 5000, percentual: 5.1 },
    { categoria: 'Mão de obra', valor: 8000, percentual: 8.2 },
    { categoria: 'Energia/Gás', valor: 4000, percentual: 4.1 },
  ],
};

const TABS = [
  { id: 'resumo', label: 'Resumo', icon: Bird },
  { id: 'pesagens', label: 'Pesagens', icon: Scale },
  { id: 'mortalidade', label: 'Mortalidade', icon: TrendingDown },
  { id: 'racao', label: 'Ração', icon: Wheat },
  { id: 'agua', label: 'Água', icon: Droplets },
  { id: 'sanidade', label: 'Sanidade', icon: Stethoscope },
  { id: 'financeiro', label: 'Financeiro', icon: DollarSign },
];

const PIE_COLORS = ['#2E7D32', '#4CAF50', '#81C784', '#A5D6A7', '#C8E6C9'];

const formatBRL = (val: number) => val.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

const formatDate = (d: string) => {
  try { return format(parseISO(d), 'dd/MM/yyyy', { locale: ptBR }); }
  catch { return d; }
};

export default function LoteDetalhe() {
  const { id } = useParams<{ id: string }>();
  const [activeTab, setActiveTab] = useState('resumo');

  const { data: lote, isLoading } = useQuery<Lote>({
    queryKey: ['lote', id],
    queryFn: async () => { try { const r = await loteService.obter(Number(id)); return r.data.data || r.data; } catch { return mockLote; } },
  });

  const { data: pesagens } = useQuery<Pesagem[]>({
    queryKey: ['lote', id, 'pesagens'],
    queryFn: async () => { try { const r = await loteService.pesagens(Number(id)); return r.data.data || r.data; } catch { return mockPesagens; } },
    enabled: activeTab === 'resumo' || activeTab === 'pesagens',
  });

  const { data: mortalidade } = useQuery<Mortalidade[]>({
    queryKey: ['lote', id, 'mortalidade'],
    queryFn: async () => { try { const r = await loteService.mortalidade(Number(id)); return r.data.data || r.data; } catch { return mockMortalidade; } },
    enabled: activeTab === 'resumo' || activeTab === 'mortalidade',
  });

  const { data: racao } = useQuery<RacaoConsumo[]>({
    queryKey: ['lote', id, 'racao'],
    queryFn: async () => { try { const r = await loteService.racaoConsumo(Number(id)); return r.data.data || r.data; } catch { return mockRacao; } },
    enabled: activeTab === 'racao',
  });

  const { data: agua } = useQuery<ConsumoAgua[]>({
    queryKey: ['lote', id, 'agua'],
    queryFn: async () => { try { const r = await loteService.agua(Number(id)); return r.data.data || r.data; } catch { return mockAgua; } },
    enabled: activeTab === 'agua',
  });

  if (isLoading) return <LoadingSkeleton type="detail" />;
  const l = lote || mockLote;

  return (
    <div className="space-y-6">
      <Link to="/lotes" className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-primary transition-colors"><ArrowLeft className="w-4 h-4" />Voltar para Lotes</Link>

      <div className="card">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{l.nome}</h1>
            <p className="text-sm text-gray-500">{l.granja_nome} - {l.galpao_nome} | {l.linhagem}</p>
          </div>
          <Badge variant={l.status === 'ativo' ? 'success' : 'neutral'} size="md">{l.status === 'ativo' ? 'Ativo' : 'Finalizado'}</Badge>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-6 gap-4 text-sm">
          <div><span className="text-gray-400 text-xs uppercase">Alojamento</span><p className="font-medium mt-0.5">{formatDate(l.data_alojamento)}</p></div>
          <div><span className="text-gray-400 text-xs uppercase">Idade</span><p className="font-medium mt-0.5">{l.idade_dias} dias</p></div>
          <div><span className="text-gray-400 text-xs uppercase">Alojadas</span><p className="font-medium mt-0.5">{l.qtd_alojada.toLocaleString('pt-BR')}</p></div>
          <div><span className="text-gray-400 text-xs uppercase">Atuais</span><p className="font-medium mt-0.5">{l.qtd_atual.toLocaleString('pt-BR')}</p></div>
          <div><span className="text-gray-400 text-xs uppercase">Mort. %</span><p className="font-medium mt-0.5">{l.mortalidade_perc.toFixed(1).replace('.', ',')}%</p></div>
          <div><span className="text-gray-400 text-xs uppercase">ICA</span><p className="font-medium mt-0.5">{l.ica.toFixed(2).replace('.', ',')}</p></div>
        </div>
      </div>

      <div className="border-b border-gray-200">
        <nav className="flex gap-1 overflow-x-auto">
          {TABS.map((tab) => (
            <button key={tab.id} onClick={() => setActiveTab(tab.id)}
              className={`flex items-center gap-1.5 px-4 py-2.5 text-sm font-medium border-b-2 transition-colors whitespace-nowrap ${activeTab === tab.id ? 'border-primary text-primary' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'}`}>
              <tab.icon className="w-4 h-4" />{tab.label}
            </button>
          ))}
        </nav>
      </div>

      {activeTab === 'resumo' && (
        <div className="space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <StatCard titulo="Peso Médio" valor={l.peso_medio.toFixed(2).replace('.', ',')} icone={Scale} sufixo="kg" />
            <StatCard titulo="ICA" valor={l.ica.toFixed(2).replace('.', ',')} icone={Calculator} />
            <StatCard titulo="Mortalidade" valor={l.mortalidade_perc.toFixed(1).replace('.', ',')} icone={TrendingDown} sufixo="%" />
            <StatCard titulo="Aves Atuais" valor={l.qtd_atual.toLocaleString('pt-BR')} icone={Bird} />
          </div>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="card">
              <h3 className="font-semibold text-gray-900 mb-4">Peso vs Benchmark</h3>
              <ResponsiveContainer width="100%" height={250}>
                <LineChart data={pesagens || mockPesagens}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis dataKey="idade_dias" tick={{ fontSize: 12 }} />
                  <YAxis tick={{ fontSize: 12 }} />
                  <Tooltip formatter={(v) => Number(v).toFixed(2).replace('.', ',') + ' kg'} />
                  <Legend />
                  <Line type="monotone" dataKey="peso_medio" name="Peso Real" stroke="#2E7D32" strokeWidth={2} dot={{ r: 4 }} />
                  <Line type="monotone" dataKey="peso_benchmark" name="Benchmark" stroke="#9E9E9E" strokeDasharray="5 5" strokeWidth={1.5} dot={false} />
                </LineChart>
              </ResponsiveContainer>
            </div>
            <div className="card">
              <h3 className="font-semibold text-gray-900 mb-4">Mortalidade Acumulada</h3>
              <ResponsiveContainer width="100%" height={250}>
                <AreaChart data={mortalidade || mockMortalidade}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis dataKey="idade_dias" tick={{ fontSize: 12 }} />
                  <YAxis tick={{ fontSize: 12 }} />
                  <Tooltip formatter={(v) => Number(v).toFixed(2).replace('.', ',') + '%'} />
                  <Area type="monotone" dataKey="percentual" name="Mort. %" stroke="#D32F2F" fill="#FFCDD2" strokeWidth={2} />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      )}

      {activeTab === 'pesagens' && (
        <div className="card p-0 overflow-hidden">
          <table className="w-full"><thead><tr className="bg-gray-50 border-b">
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Data</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Idade</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Amostra</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Peso Médio</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Uniformidade</th>
            <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Desvio Padrão</th>
          </tr></thead><tbody className="divide-y divide-gray-50">
            {(pesagens || mockPesagens).map((p) => (
              <tr key={p.id} className="hover:bg-gray-50">
                <td className="px-4 py-3 text-sm">{formatDate(p.data)}</td>
                <td className="px-4 py-3 text-sm">{p.idade_dias} dias</td>
                <td className="px-4 py-3 text-sm">{p.amostra}</td>
                <td className="px-4 py-3 text-sm font-medium">{p.peso_medio.toFixed(3).replace('.', ',')} kg</td>
                <td className="px-4 py-3 text-sm">{p.uniformidade.toFixed(1).replace('.', ',')}%</td>
                <td className="px-4 py-3 text-sm">{p.desvio_padrao.toFixed(3).replace('.', ',')}</td>
              </tr>
            ))}
          </tbody></table>
        </div>
      )}

      {activeTab === 'mortalidade' && (
        <div className="space-y-6">
          <div className="card">
            <h3 className="font-semibold text-gray-900 mb-4">Mortalidade Diária</h3>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={mortalidade || mockMortalidade}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="idade_dias" tick={{ fontSize: 11 }} /><YAxis tick={{ fontSize: 11 }} />
                <Tooltip /><Bar dataKey="quantidade" name="Mortes" fill="#EF5350" radius={[2, 2, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
          <div className="card p-0 overflow-x-auto">
            <table className="w-full"><thead><tr className="bg-gray-50 border-b">
              <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Data</th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Dia</th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Mortes</th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Acumulada</th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">%</th>
            </tr></thead><tbody className="divide-y divide-gray-50">
              {(mortalidade || mockMortalidade).slice(-14).map((m) => (
                <tr key={m.id} className="hover:bg-gray-50">
                  <td className="px-4 py-2.5 text-sm">{formatDate(m.data)}</td>
                  <td className="px-4 py-2.5 text-sm">{m.idade_dias}</td>
                  <td className="px-4 py-2.5 text-sm font-medium">{m.quantidade}</td>
                  <td className="px-4 py-2.5 text-sm">{m.acumulada}</td>
                  <td className="px-4 py-2.5 text-sm">{m.percentual.toFixed(2).replace('.', ',')}%</td>
                </tr>
              ))}
            </tbody></table>
          </div>
        </div>
      )}

      {activeTab === 'racao' && (
        <div className="space-y-6">
          <div className="card">
            <h3 className="font-semibold text-gray-900 mb-4">Consumo de Ração por Semana</h3>
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={racao || mockRacao}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="idade_dias" tick={{ fontSize: 12 }} /><YAxis tick={{ fontSize: 12 }} />
                <Tooltip formatter={(v) => `${Number(v).toLocaleString('pt-BR')} kg`} />
                <Legend /><Bar dataKey="quantidade_kg" name="Ração (kg)" fill="#4CAF50" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
          <div className="card p-0 overflow-x-auto">
            <table className="w-full"><thead><tr className="bg-gray-50 border-b">
              <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Data</th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Dia</th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Tipo</th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Qtd (kg)</th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Consumo/Ave (g)</th>
            </tr></thead><tbody className="divide-y divide-gray-50">
              {(racao || mockRacao).map((r) => (
                <tr key={r.id} className="hover:bg-gray-50">
                  <td className="px-4 py-2.5 text-sm">{formatDate(r.data)}</td>
                  <td className="px-4 py-2.5 text-sm">{r.idade_dias}</td>
                  <td className="px-4 py-2.5 text-sm"><Badge variant="info" size="sm">{r.tipo_racao}</Badge></td>
                  <td className="px-4 py-2.5 text-sm font-medium">{r.quantidade_kg.toLocaleString('pt-BR')}</td>
                  <td className="px-4 py-2.5 text-sm">{r.consumo_ave_g}</td>
                </tr>
              ))}
            </tbody></table>
          </div>
        </div>
      )}

      {activeTab === 'agua' && (
        <div className="card">
          <h3 className="font-semibold text-gray-900 mb-4">Consumo Diário de Água</h3>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={agua || mockAgua}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis dataKey="idade_dias" tick={{ fontSize: 12 }} /><YAxis tick={{ fontSize: 12 }} />
              <Tooltip formatter={(v) => `${Math.round(Number(v)).toLocaleString('pt-BR')} L`} />
              <Legend /><Area type="monotone" dataKey="quantidade_litros" name="Litros" stroke="#1976D2" fill="#BBDEFB" strokeWidth={2} />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      )}

      {activeTab === 'sanidade' && (
        <div className="space-y-6">
          <div className="card p-0 overflow-hidden">
            <div className="px-6 py-3 bg-gray-50 border-b"><h3 className="font-semibold text-gray-900">Vacinações</h3></div>
            <table className="w-full"><thead><tr className="border-b">
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Data</th>
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Vacina</th>
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Via</th>
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Responsável</th>
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Obs</th>
            </tr></thead><tbody className="divide-y divide-gray-50">
              {mockVacinacoes.map((v) => (
                <tr key={v.id} className="hover:bg-gray-50">
                  <td className="px-4 py-2.5 text-sm">{formatDate(v.data)}</td>
                  <td className="px-4 py-2.5 text-sm font-medium">{v.vacina}</td>
                  <td className="px-4 py-2.5 text-sm">{v.via_aplicacao}</td>
                  <td className="px-4 py-2.5 text-sm">{v.responsavel}</td>
                  <td className="px-4 py-2.5 text-sm text-gray-500">{v.observacao || '-'}</td>
                </tr>
              ))}
            </tbody></table>
          </div>

          <div className="card p-0 overflow-hidden">
            <div className="px-6 py-3 bg-gray-50 border-b"><h3 className="font-semibold text-gray-900">Medicamentos</h3></div>
            <table className="w-full"><thead><tr className="border-b">
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Período</th>
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Medicamento</th>
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Dosagem</th>
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Motivo</th>
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Responsável</th>
            </tr></thead><tbody className="divide-y divide-gray-50">
              {mockMedicamentos.map((m) => (
                <tr key={m.id} className="hover:bg-gray-50">
                  <td className="px-4 py-2.5 text-sm">{formatDate(m.data_inicio)} a {formatDate(m.data_fim)}</td>
                  <td className="px-4 py-2.5 text-sm font-medium">{m.medicamento}</td>
                  <td className="px-4 py-2.5 text-sm">{m.dosagem}</td>
                  <td className="px-4 py-2.5 text-sm">{m.motivo}</td>
                  <td className="px-4 py-2.5 text-sm">{m.responsavel}</td>
                </tr>
              ))}
            </tbody></table>
          </div>

          <div className="card p-0 overflow-hidden">
            <div className="px-6 py-3 bg-gray-50 border-b"><h3 className="font-semibold text-gray-900">Visitantes</h3></div>
            <table className="w-full"><thead><tr className="border-b">
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Data</th>
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Nome</th>
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Empresa</th>
              <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Motivo</th>
            </tr></thead><tbody className="divide-y divide-gray-50">
              {mockVisitantes.map((v) => (
                <tr key={v.id} className="hover:bg-gray-50">
                  <td className="px-4 py-2.5 text-sm">{formatDate(v.data)}</td>
                  <td className="px-4 py-2.5 text-sm font-medium">{v.nome}</td>
                  <td className="px-4 py-2.5 text-sm">{v.empresa}</td>
                  <td className="px-4 py-2.5 text-sm">{v.motivo}</td>
                </tr>
              ))}
            </tbody></table>
          </div>
        </div>
      )}

      {activeTab === 'financeiro' && (
        <div className="space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="card"><p className="text-xs text-gray-400 uppercase">Receita Bruta</p><p className="text-xl font-bold text-green-700 mt-1">{formatBRL(mockFinanceiro.receita_bruta)}</p></div>
            <div className="card"><p className="text-xs text-gray-400 uppercase">Custo Total</p><p className="text-xl font-bold text-red-700 mt-1">{formatBRL(mockFinanceiro.custo_total)}</p></div>
            <div className="card"><p className="text-xs text-gray-400 uppercase">Lucro Líquido</p><p className="text-xl font-bold text-primary mt-1">{formatBRL(mockFinanceiro.lucro_liquido)}</p></div>
            <div className="card"><p className="text-xs text-gray-400 uppercase">Custo/kg</p><p className="text-xl font-bold text-gray-900 mt-1">{formatBRL(mockFinanceiro.custo_por_kg)}</p></div>
          </div>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="card">
              <h3 className="font-semibold text-gray-900 mb-4">Distribuição de Custos</h3>
              <ResponsiveContainer width="100%" height={280}>
                <PieChart>
                  <Pie data={mockFinanceiro.custos} dataKey="valor" nameKey="categoria" cx="50%" cy="50%" outerRadius={100}
                    label={({ name, percent }) => `${name} (${((percent ?? 0) * 100).toFixed(0)}%)`}>
                    {mockFinanceiro.custos.map((_, i) => (<Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />))}
                  </Pie>
                  <Tooltip formatter={(v) => formatBRL(Number(v))} />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="card p-0 overflow-hidden">
              <div className="px-6 py-3 bg-gray-50 border-b"><h3 className="font-semibold text-gray-900">Detalhamento</h3></div>
              <table className="w-full"><thead><tr className="border-b">
                <th className="px-4 py-2.5 text-left text-xs font-semibold text-gray-500 uppercase">Categoria</th>
                <th className="px-4 py-2.5 text-right text-xs font-semibold text-gray-500 uppercase">Valor</th>
                <th className="px-4 py-2.5 text-right text-xs font-semibold text-gray-500 uppercase">%</th>
              </tr></thead><tbody className="divide-y divide-gray-50">
                {mockFinanceiro.custos.map((c) => (
                  <tr key={c.categoria} className="hover:bg-gray-50">
                    <td className="px-4 py-2.5 text-sm font-medium">{c.categoria}</td>
                    <td className="px-4 py-2.5 text-sm text-right">{formatBRL(c.valor)}</td>
                    <td className="px-4 py-2.5 text-sm text-right text-gray-500">{c.percentual.toFixed(1).replace('.', ',')}%</td>
                  </tr>
                ))}
              </tbody></table>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
