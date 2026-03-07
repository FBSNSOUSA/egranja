import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  FileBarChart, FileText, BarChart3, Download, Loader2, Table,
} from 'lucide-react';
import { loteService, relatorioService } from '../services/api';
import type { Lote } from '../types';

const mockLotes: Lote[] = [
  { id: 1, nome: 'Lote 01', granja_id: 1, granja_nome: 'Granja São José', galpao_id: 1, galpao_nome: 'Galpão 1', linhagem: 'Cobb 500', data_alojamento: '2026-02-07', qtd_alojada: 20000, qtd_atual: 19500, idade_dias: 28, status: 'ativo', mortalidade_perc: 2.5, ica: 1.68, peso_medio: 1.85, created_at: '', updated_at: '' },
  { id: 5, nome: 'Lote 05', granja_id: 3, granja_nome: 'Granja Nova Esperança', galpao_id: 8, galpao_nome: 'Galpão 2', linhagem: 'Ross 308', data_alojamento: '2025-12-15', data_saida: '2026-02-05', qtd_alojada: 22000, qtd_atual: 20900, idade_dias: 52, status: 'finalizado', mortalidade_perc: 5.0, ica: 1.78, peso_medio: 3.12, created_at: '', updated_at: '' },
];

interface RelatorioCard {
  id: string;
  titulo: string;
  descricao: string;
  icone: typeof FileText;
  cor: string;
}

const relatorios: RelatorioCard[] = [
  { id: 'fechamento', titulo: 'Fechamento de Lote', descricao: 'Relatório completo com todos os indicadores do lote finalizado', icone: FileText, cor: 'bg-green-50 text-green-600' },
  { id: 'comparativo', titulo: 'Comparativo de Lotes', descricao: 'Compare indicadores entre múltiplos lotes lado a lado', icone: BarChart3, cor: 'bg-blue-50 text-blue-600' },
  { id: 'exportar', titulo: 'Exportar Dados (CSV)', descricao: 'Exporte dados brutos de pesagens, mortalidade e consumos', icone: Table, cor: 'bg-purple-50 text-purple-600' },
];

export default function Relatorios() {
  const [selectedReport, setSelectedReport] = useState<string | null>(null);
  const [selectedLote, setSelectedLote] = useState<number | null>(null);
  const [selectedLotes, setSelectedLotes] = useState<number[]>([]);
  const [formato, setFormato] = useState<'pdf' | 'csv'>('pdf');
  const [exportTipo, setExportTipo] = useState<string>('pesagens');
  const [loading, setLoading] = useState(false);

  const { data: lotes } = useQuery<Lote[]>({
    queryKey: ['lotes-relatorio'],
    queryFn: async () => {
      try { const res = await loteService.listar(); return res.data.data || res.data; }
      catch { return mockLotes; }
    },
  });

  const handleDownload = async () => {
    setLoading(true);
    try {
      let response;
      let filename = '';
      if (selectedReport === 'fechamento' && selectedLote) {
        response = await relatorioService.fechamento(selectedLote, formato);
        filename = `fechamento_lote_${selectedLote}.${formato}`;
      } else if (selectedReport === 'comparativo' && selectedLotes.length > 0) {
        response = await relatorioService.comparativo(selectedLotes, formato);
        filename = `comparativo_lotes.${formato}`;
      } else if (selectedReport === 'exportar') {
        response = await relatorioService.exportarCSV(exportTipo);
        filename = `exportacao_${exportTipo}.csv`;
      }
      if (response) {
        const url = window.URL.createObjectURL(new Blob([response.data]));
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        a.click();
        window.URL.revokeObjectURL(url);
      }
    } catch {
      alert('Erro ao gerar relatório. O backend ainda não está configurado para esta funcionalidade.');
    } finally { setLoading(false); }
  };

  const toggleLote = (id: number) => setSelectedLotes((prev) => prev.includes(id) ? prev.filter((l) => l !== id) : [...prev, id]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Relatórios</h1>
        <p className="text-sm text-gray-500 mt-1">Gere relatórios de fechamento, comparativos e exportações</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {relatorios.map((rel) => (
          <button key={rel.id} onClick={() => setSelectedReport(rel.id)}
            className={`card text-left hover:shadow-md transition-all ${selectedReport === rel.id ? 'ring-2 ring-primary' : ''}`}>
            <div className={`w-10 h-10 rounded-lg flex items-center justify-center mb-3 ${rel.cor}`}><rel.icone className="w-5 h-5" /></div>
            <h3 className="font-semibold text-gray-900">{rel.titulo}</h3>
            <p className="text-sm text-gray-500 mt-1">{rel.descricao}</p>
          </button>
        ))}
      </div>

      {selectedReport && (
        <div className="card">
          <div className="flex items-center gap-2 mb-4"><FileBarChart className="w-5 h-5 text-primary" /><h3 className="font-semibold text-gray-900">{relatorios.find((r) => r.id === selectedReport)?.titulo}</h3></div>
          <div className="space-y-4 max-w-md">
            {selectedReport === 'fechamento' && (<>
              <div><label className="label-field">Selecione o Lote</label><select className="input-field" value={selectedLote || ''} onChange={(e) => setSelectedLote(Number(e.target.value))}><option value="">Selecione...</option>{(lotes || mockLotes).map((l) => (<option key={l.id} value={l.id}>{l.nome} - {l.granja_nome} ({l.status})</option>))}</select></div>
              <div><label className="label-field">Formato</label><div className="flex gap-3">{(['pdf', 'csv'] as const).map((f) => (<button key={f} onClick={() => setFormato(f)} className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${formato === f ? 'bg-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>{f.toUpperCase()}</button>))}</div></div>
            </>)}
            {selectedReport === 'comparativo' && (<>
              <div><label className="label-field">Selecione os Lotes (mínimo 2)</label><div className="space-y-2 max-h-48 overflow-y-auto border border-gray-200 rounded-lg p-2">{(lotes || mockLotes).map((l) => (<label key={l.id} className="flex items-center gap-2 p-2 rounded hover:bg-gray-50 cursor-pointer"><input type="checkbox" checked={selectedLotes.includes(l.id)} onChange={() => toggleLote(l.id)} className="rounded text-primary focus:ring-primary" /><span className="text-sm">{l.nome} - {l.granja_nome}</span></label>))}</div></div>
              <div><label className="label-field">Formato</label><div className="flex gap-3">{(['pdf', 'csv'] as const).map((f) => (<button key={f} onClick={() => setFormato(f)} className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${formato === f ? 'bg-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>{f.toUpperCase()}</button>))}</div></div>
            </>)}
            {selectedReport === 'exportar' && (<div><label className="label-field">Tipo de dados</label><select className="input-field" value={exportTipo} onChange={(e) => setExportTipo(e.target.value)}><option value="pesagens">Pesagens</option><option value="mortalidade">Mortalidade</option><option value="racao">Consumo de Ração</option><option value="agua">Consumo de Água</option><option value="vacinacoes">Vacinações</option></select></div>)}
            <button onClick={handleDownload} disabled={loading || (selectedReport === 'fechamento' && !selectedLote) || (selectedReport === 'comparativo' && selectedLotes.length < 2)} className="btn-primary flex items-center gap-2">
              {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Download className="w-4 h-4" />}Gerar Relatório
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
