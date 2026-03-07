import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { Plus, Filter } from 'lucide-react';
import { loteService } from '../services/api';
import DataTable from '../components/DataTable';
import type { Column } from '../components/DataTable';
import Badge, { statusVariant } from '../components/Badge';
import LoadingSkeleton from '../components/LoadingSkeleton';
import type { Lote } from '../types';

const mockLotes: Lote[] = [
  { id: 1, nome: 'Lote 01', granja_id: 1, granja_nome: 'Granja São José', galpao_id: 1, galpao_nome: 'Galpão 1', linhagem: 'Cobb 500', data_alojamento: '2026-02-07', qtd_alojada: 20000, qtd_atual: 19500, idade_dias: 28, status: 'ativo', mortalidade_perc: 2.5, ica: 1.68, peso_medio: 1.85, created_at: '2026-02-07', updated_at: '2026-03-07' },
  { id: 2, nome: 'Lote 02', granja_id: 1, granja_nome: 'Granja São José', galpao_id: 2, galpao_nome: 'Galpão 2', linhagem: 'Ross 308', data_alojamento: '2026-02-21', qtd_alojada: 20000, qtd_atual: 19800, idade_dias: 14, status: 'ativo', mortalidade_perc: 1.0, ica: 1.35, peso_medio: 0.48, created_at: '2026-02-21', updated_at: '2026-03-07' },
  { id: 3, nome: 'Lote 03', granja_id: 2, granja_nome: 'Granja Boa Vista', galpao_id: 5, galpao_nome: 'Galpão 1', linhagem: 'Cobb 500', data_alojamento: '2026-02-14', qtd_alojada: 18000, qtd_atual: 17640, idade_dias: 21, status: 'ativo', mortalidade_perc: 2.0, ica: 1.52, peso_medio: 1.12, created_at: '2026-02-14', updated_at: '2026-03-07' },
  { id: 4, nome: 'Lote 04', granja_id: 1, granja_nome: 'Granja São José', galpao_id: 3, galpao_nome: 'Galpão 3', linhagem: 'Cobb 500', data_alojamento: '2026-01-31', qtd_alojada: 15000, qtd_atual: 14200, idade_dias: 35, status: 'ativo', mortalidade_perc: 5.3, ica: 1.82, peso_medio: 2.42, created_at: '2026-01-31', updated_at: '2026-03-07' },
  { id: 5, nome: 'Lote 05', granja_id: 3, granja_nome: 'Granja Nova Esperança', galpao_id: 8, galpao_nome: 'Galpão 2', linhagem: 'Ross 308', data_alojamento: '2025-12-15', data_saida: '2026-02-05', qtd_alojada: 22000, qtd_atual: 20900, idade_dias: 52, status: 'finalizado', mortalidade_perc: 5.0, ica: 1.78, peso_medio: 3.12, created_at: '2025-12-15', updated_at: '2026-02-05' },
  { id: 6, nome: 'Lote 06', granja_id: 2, granja_nome: 'Granja Boa Vista', galpao_id: 6, galpao_nome: 'Galpão 2', linhagem: 'Hubbard', data_alojamento: '2026-03-01', qtd_alojada: 16000, qtd_atual: 15950, idade_dias: 6, status: 'ativo', mortalidade_perc: 0.3, ica: 0.95, peso_medio: 0.18, created_at: '2026-03-01', updated_at: '2026-03-07' },
];

export default function Lotes() {
  const navigate = useNavigate();
  const [filtroStatus, setFiltroStatus] = useState<string>('todos');

  const { data: lotes, isLoading } = useQuery<Lote[]>({
    queryKey: ['lotes'],
    queryFn: async () => {
      try { const res = await loteService.listar(); return res.data.data || res.data; }
      catch { return mockLotes; }
    },
  });

  const dadosFiltrados = (lotes || mockLotes).filter((l) => filtroStatus === 'todos' || l.status === filtroStatus);

  const columns: Column<Lote>[] = [
    { key: 'nome', header: 'Nome', render: (l) => <span className="font-medium text-gray-900">{l.nome}</span> },
    { key: 'granja_nome', header: 'Granja' },
    { key: 'linhagem', header: 'Linhagem' },
    { key: 'idade_dias', header: 'Idade', render: (l) => `${l.idade_dias} dias` },
    { key: 'qtd_atual', header: 'Aves', render: (l) => l.qtd_atual.toLocaleString('pt-BR') },
    { key: 'mortalidade_perc', header: 'Mort. %', render: (l) => {
      const variant = l.mortalidade_perc > 4 ? 'danger' : l.mortalidade_perc > 2 ? 'warning' : 'success';
      return <Badge variant={variant} size="sm">{l.mortalidade_perc.toFixed(1).replace('.', ',')}%</Badge>;
    }},
    { key: 'ica', header: 'ICA', render: (l) => l.ica.toFixed(2).replace('.', ',') },
    { key: 'peso_medio', header: 'Peso (kg)', render: (l) => l.peso_medio.toFixed(2).replace('.', ',') },
    { key: 'status', header: 'Status', render: (l) => <Badge variant={statusVariant(l.status)}>{l.status === 'ativo' ? 'Ativo' : 'Finalizado'}</Badge> },
  ];

  if (isLoading) return <div className="space-y-6"><LoadingSkeleton type="table" count={6} /></div>;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Lotes</h1>
          <p className="text-sm text-gray-500 mt-1">{dadosFiltrados.length} lotes encontrados</p>
        </div>
        <button className="btn-primary flex items-center gap-2"><Plus className="w-4 h-4" />Novo Lote</button>
      </div>

      <div className="flex items-center gap-3">
        <Filter className="w-4 h-4 text-gray-400" />
        <div className="flex gap-2">
          {['todos', 'ativo', 'finalizado'].map((status) => (
            <button key={status} onClick={() => setFiltroStatus(status)}
              className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${filtroStatus === status ? 'bg-primary text-white' : 'bg-white text-gray-600 border border-gray-200 hover:bg-gray-50'}`}>
              {status === 'todos' ? 'Todos' : status === 'ativo' ? 'Ativos' : 'Finalizados'}
            </button>
          ))}
        </div>
      </div>

      <DataTable columns={columns} data={dadosFiltrados} onRowClick={(l) => navigate(`/lotes/${l.id}`)} searchPlaceholder="Buscar lotes..." />
    </div>
  );
}
