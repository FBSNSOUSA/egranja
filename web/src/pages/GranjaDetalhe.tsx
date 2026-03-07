import { useParams, Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { ArrowLeft, Warehouse, MapPin, User, Ruler } from 'lucide-react';
import { granjaService } from '../services/api';
import Badge from '../components/Badge';
import LoadingSkeleton from '../components/LoadingSkeleton';
import type { Granja, Galpao } from '../types';

const mockGranja: Granja = {
  id: 1, nome: 'Granja São José', endereco: 'Rod. MG-050, Km 12',
  cidade: 'Divinópolis', estado: 'MG', latitude: -20.1389, longitude: -44.8841,
  produtor_id: 1, produtor_nome: 'João Silva', total_galpoes: 4, lotes_ativos: 3,
  created_at: '2025-06-01', updated_at: '2025-06-01',
};

const mockGalpoes: Galpao[] = [
  { id: 1, granja_id: 1, nome: 'Galpão 1', comprimento: 120, largura: 14, orientacao: 'Leste-Oeste', capacidade: 20000, lote_ativo: { id: 1, nome: 'Lote 01', linhagem: 'Cobb 500', idade_dias: 28, qtd_atual: 19500, status: 'ativo' }, created_at: '2025-06-01' },
  { id: 2, granja_id: 1, nome: 'Galpão 2', comprimento: 120, largura: 14, orientacao: 'Leste-Oeste', capacidade: 20000, lote_ativo: { id: 2, nome: 'Lote 02', linhagem: 'Ross 308', idade_dias: 14, qtd_atual: 19800, status: 'ativo' }, created_at: '2025-06-01' },
  { id: 3, granja_id: 1, nome: 'Galpão 3', comprimento: 100, largura: 12, orientacao: 'Norte-Sul', capacidade: 15000, lote_ativo: { id: 4, nome: 'Lote 04', linhagem: 'Cobb 500', idade_dias: 35, qtd_atual: 14200, status: 'ativo' }, created_at: '2025-07-01' },
  { id: 4, granja_id: 1, nome: 'Galpão 4', comprimento: 100, largura: 12, orientacao: 'Norte-Sul', capacidade: 15000, created_at: '2025-07-01' },
];

export default function GranjaDetalhe() {
  const { id } = useParams<{ id: string }>();

  const { data: granja, isLoading: loadingGranja } = useQuery<Granja>({
    queryKey: ['granja', id],
    queryFn: async () => {
      try { const res = await granjaService.obter(Number(id)); return res.data.data || res.data; }
      catch { return mockGranja; }
    },
  });

  const { data: galpoes, isLoading: loadingGalpoes } = useQuery<Galpao[]>({
    queryKey: ['granja', id, 'galpoes'],
    queryFn: async () => {
      try { const res = await granjaService.galpoes(Number(id)); return res.data.data || res.data; }
      catch { return mockGalpoes; }
    },
  });

  if (loadingGranja) return <LoadingSkeleton type="detail" />;
  const g = granja || mockGranja;

  return (
    <div className="space-y-6">
      <Link to="/granjas" className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-primary transition-colors">
        <ArrowLeft className="w-4 h-4" />Voltar para Granjas
      </Link>

      <div className="card">
        <div className="flex items-start justify-between">
          <div>
            <div className="flex items-center gap-3 mb-4">
              <div className="p-2.5 bg-green-50 rounded-xl"><Warehouse className="w-6 h-6 text-primary" /></div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">{g.nome}</h1>
                <div className="flex items-center gap-1 text-sm text-gray-500 mt-0.5"><MapPin className="w-3.5 h-3.5" />{g.endereco}, {g.cidade}/{g.estado}</div>
              </div>
            </div>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-6">
              <div><p className="text-xs font-medium text-gray-400 uppercase">Produtor</p><p className="mt-1 text-sm font-medium text-gray-900 flex items-center gap-1"><User className="w-3.5 h-3.5 text-gray-400" />{g.produtor_nome}</p></div>
              <div><p className="text-xs font-medium text-gray-400 uppercase">Galpões</p><p className="mt-1 text-sm font-medium text-gray-900">{g.total_galpoes}</p></div>
              <div><p className="text-xs font-medium text-gray-400 uppercase">Lotes Ativos</p><p className="mt-1 text-sm font-medium text-gray-900">{g.lotes_ativos}</p></div>
              <div><p className="text-xs font-medium text-gray-400 uppercase">Coordenadas</p><p className="mt-1 text-sm text-gray-600">{g.latitude ? `${g.latitude}, ${g.longitude}` : 'Não informado'}</p></div>
            </div>
          </div>
        </div>
      </div>

      <div>
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Galpões ({(galpoes || []).length})</h2>
        {loadingGalpoes ? <LoadingSkeleton type="cards" count={4} /> : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {(galpoes || mockGalpoes).map((galpao) => (
              <div key={galpao.id} className="card hover:shadow-md transition-shadow cursor-pointer">
                <div className="flex items-center justify-between mb-3">
                  <h3 className="font-semibold text-gray-900">{galpao.nome}</h3>
                  {galpao.lote_ativo ? <Badge variant="success">Ocupado</Badge> : <Badge variant="neutral">Livre</Badge>}
                </div>
                <div className="space-y-2 text-sm">
                  <div className="flex items-center gap-2 text-gray-600"><Ruler className="w-3.5 h-3.5 text-gray-400" />{galpao.comprimento}m x {galpao.largura}m</div>
                  <div className="flex items-center gap-2 text-gray-600"><span className="text-gray-400 text-xs">Orientação:</span>{galpao.orientacao}</div>
                  <div className="flex items-center gap-2 text-gray-600"><span className="text-gray-400 text-xs">Capacidade:</span>{galpao.capacidade.toLocaleString('pt-BR')} aves</div>
                </div>
                {galpao.lote_ativo && (
                  <div className="mt-3 pt-3 border-t border-gray-100">
                    <Link to={`/lotes/${galpao.lote_ativo.id}`} className="text-sm text-primary hover:underline font-medium">{galpao.lote_ativo.nome}</Link>
                    <p className="text-xs text-gray-500 mt-0.5">{galpao.lote_ativo.linhagem} &bull; {galpao.lote_ativo.idade_dias} dias &bull; {galpao.lote_ativo.qtd_atual.toLocaleString('pt-BR')} aves</p>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="card">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Localização</h2>
        <div className="h-64 bg-gray-100 rounded-lg flex items-center justify-center border-2 border-dashed border-gray-300">
          <div className="text-center text-gray-400">
            <MapPin className="w-8 h-8 mx-auto mb-2" />
            <p className="text-sm">Mapa será integrado em versão futura</p>
            {g.latitude && <p className="text-xs mt-1">{g.latitude}, {g.longitude}</p>}
          </div>
        </div>
      </div>
    </div>
  );
}
