import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Users, Filter } from 'lucide-react';
import { produtorService } from '../services/api';
import DataTable from '../components/DataTable';
import type { Column } from '../components/DataTable';
import Badge from '../components/Badge';
import LoadingSkeleton from '../components/LoadingSkeleton';
import type { Usuario } from '../types';
import { format, parseISO } from 'date-fns';
import { ptBR } from 'date-fns/locale';

type UsuarioComExtra = Usuario & { granjas?: number; lotes_ativos?: number };

const mockProdutores: UsuarioComExtra[] = [
  { id: 1, nome: 'João Silva', login: 'joao', tipo: 'produtor', email: 'joao@email.com', telefone: '(37) 99999-1111', ativo: true, ultimo_acesso: '2026-03-07T08:30:00', created_at: '2025-01-15', updated_at: '2026-03-07', granjas: 2, lotes_ativos: 3 },
  { id: 2, nome: 'Maria Oliveira', login: 'maria', tipo: 'produtor', email: 'maria@email.com', telefone: '(37) 99999-2222', ativo: true, ultimo_acesso: '2026-03-06T15:20:00', created_at: '2025-02-20', updated_at: '2026-03-06', granjas: 1, lotes_ativos: 2 },
  { id: 3, nome: 'Carlos Santos', login: 'carlos', tipo: 'produtor', email: 'carlos@email.com', ativo: true, ultimo_acesso: '2026-03-05T10:00:00', created_at: '2025-03-10', updated_at: '2026-03-05', granjas: 1, lotes_ativos: 5 },
  { id: 4, nome: 'Dr. Ana Costa', login: 'ana.tecnica', tipo: 'tecnico', email: 'ana@integradora.com', ativo: true, ultimo_acesso: '2026-03-07T12:00:00', created_at: '2025-01-01', updated_at: '2026-03-07', granjas: 0, lotes_ativos: 0 },
  { id: 5, nome: 'Pedro Ferreira', login: 'pedro.tecnico', tipo: 'tecnico', email: 'pedro@integradora.com', ativo: true, ultimo_acesso: '2026-03-04T09:45:00', created_at: '2025-04-01', updated_at: '2026-03-04', granjas: 0, lotes_ativos: 0 },
  { id: 6, nome: 'Luciana Mendes', login: 'luciana', tipo: 'produtor', email: 'luciana@email.com', ativo: false, ultimo_acesso: '2026-01-15T14:00:00', created_at: '2025-05-01', updated_at: '2026-01-15', granjas: 1, lotes_ativos: 0 },
];

export default function Produtores() {
  const [filtroTipo, setFiltroTipo] = useState<string>('todos');

  const { data: usuarios, isLoading } = useQuery<UsuarioComExtra[]>({
    queryKey: ['produtores'],
    queryFn: async () => {
      try { const res = await produtorService.listar({ tipos: 'produtor,tecnico' }); return res.data.data || res.data; }
      catch { return mockProdutores; }
    },
  });

  const tipoLabel: Record<string, string> = { admin: 'Administrador', integradora: 'Integradora', tecnico: 'Técnico', produtor: 'Produtor' };

  const dados = (usuarios || mockProdutores).filter((u) => filtroTipo === 'todos' || u.tipo === filtroTipo);

  const columns: Column<UsuarioComExtra>[] = [
    { key: 'nome', header: 'Nome', render: (u) => (
      <div className="flex items-center gap-3">
        <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center flex-shrink-0"><span className="text-white text-xs font-semibold">{u.nome.charAt(0)}</span></div>
        <div><p className="font-medium text-gray-900">{u.nome}</p><p className="text-xs text-gray-500">{u.email}</p></div>
      </div>
    )},
    { key: 'tipo', header: 'Tipo', render: (u) => <Badge variant={u.tipo === 'tecnico' ? 'info' : 'success'} size="sm">{tipoLabel[u.tipo]}</Badge> },
    { key: 'granjas', header: 'Granjas', render: (u) => String(u.granjas ?? '-') },
    { key: 'lotes_ativos', header: 'Lotes Ativos', render: (u) => String(u.lotes_ativos ?? '-') },
    { key: 'ultimo_acesso', header: 'Último Acesso', render: (u) => {
      try { return format(parseISO(u.ultimo_acesso || ''), "dd/MM/yyyy HH:mm", { locale: ptBR }); }
      catch { return '-'; }
    }},
    { key: 'ativo', header: 'Status', render: (u) => <Badge variant={u.ativo ? 'success' : 'neutral'} size="sm">{u.ativo ? 'Ativo' : 'Inativo'}</Badge> },
  ];

  if (isLoading) return <LoadingSkeleton type="table" count={6} />;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Produtores e Técnicos</h1>
          <p className="text-sm text-gray-500 mt-1">{dados.length} usuários encontrados</p>
        </div>
        <div className="p-2.5 bg-green-50 rounded-xl"><Users className="w-6 h-6 text-primary" /></div>
      </div>
      <div className="flex items-center gap-3">
        <Filter className="w-4 h-4 text-gray-400" />
        {['todos', 'produtor', 'tecnico'].map((tipo) => (
          <button key={tipo} onClick={() => setFiltroTipo(tipo)}
            className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${filtroTipo === tipo ? 'bg-primary text-white' : 'bg-white text-gray-600 border border-gray-200 hover:bg-gray-50'}`}>
            {tipo === 'todos' ? 'Todos' : tipoLabel[tipo] + 's'}
          </button>
        ))}
      </div>
      <DataTable columns={columns} data={dados} searchPlaceholder="Buscar por nome, email..." />
    </div>
  );
}
