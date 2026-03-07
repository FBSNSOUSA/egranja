import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { Plus, Warehouse, MapPin } from 'lucide-react';
import { granjaService } from '../services/api';
import DataTable from '../components/DataTable';
import type { Column } from '../components/DataTable';
import Modal from '../components/Modal';
import LoadingSkeleton from '../components/LoadingSkeleton';
import Badge from '../components/Badge';
import type { Granja, GranjaForm } from '../types';

const mockGranjas: Granja[] = [
  { id: 1, nome: 'Granja São José', endereco: 'Rod. MG-050, Km 12', cidade: 'Divinópolis', estado: 'MG', latitude: -20.1389, longitude: -44.8841, produtor_id: 1, produtor_nome: 'João Silva', total_galpoes: 4, lotes_ativos: 3, created_at: '2025-06-01', updated_at: '2025-06-01' },
  { id: 2, nome: 'Granja Boa Vista', endereco: 'Estrada Rural, s/n', cidade: 'Itaúna', estado: 'MG', latitude: -20.0744, longitude: -44.5762, produtor_id: 2, produtor_nome: 'Maria Oliveira', total_galpoes: 3, lotes_ativos: 2, created_at: '2025-07-15', updated_at: '2025-07-15' },
  { id: 3, nome: 'Granja Nova Esperança', endereco: 'Fazenda Córrego Fundo', cidade: 'Carmo do Cajuru', estado: 'MG', latitude: -20.1911, longitude: -44.7689, produtor_id: 3, produtor_nome: 'Carlos Santos', total_galpoes: 6, lotes_ativos: 5, created_at: '2025-08-20', updated_at: '2025-08-20' },
  { id: 4, nome: 'Granja Santa Clara', endereco: 'BR-262, Km 480', cidade: 'Nova Serrana', estado: 'MG', produtor_id: 4, produtor_nome: 'Ana Costa', total_galpoes: 2, lotes_ativos: 1, created_at: '2025-09-10', updated_at: '2025-09-10' },
];

export default function Granjas() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [modalOpen, setModalOpen] = useState(false);
  const [form, setForm] = useState<GranjaForm>({ nome: '', endereco: '', cidade: '', estado: 'MG', produtor_id: 0 });

  const { data: granjas, isLoading } = useQuery<Granja[]>({
    queryKey: ['granjas'],
    queryFn: async () => {
      try { const res = await granjaService.listar(); return res.data.data || res.data; }
      catch { return mockGranjas; }
    },
  });

  const criarMutation = useMutation({
    mutationFn: (data: GranjaForm) => granjaService.criar(data as unknown as Record<string, unknown>),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['granjas'] }); setModalOpen(false); resetForm(); },
  });

  const resetForm = () => setForm({ nome: '', endereco: '', cidade: '', estado: 'MG', produtor_id: 0 });

  const columns: Column<Granja>[] = [
    { key: 'nome', header: 'Nome', render: (g) => (<div className="flex items-center gap-2"><Warehouse className="w-4 h-4 text-primary" /><span className="font-medium text-gray-900">{g.nome}</span></div>) },
    { key: 'endereco', header: 'Endereço', render: (g) => (<div className="flex items-center gap-1 text-gray-600"><MapPin className="w-3.5 h-3.5" />{g.endereco}, {g.cidade}/{g.estado}</div>) },
    { key: 'produtor_nome', header: 'Produtor' },
    { key: 'total_galpoes', header: 'Galpões', render: (g) => <span className="font-medium">{g.total_galpoes}</span> },
    { key: 'lotes_ativos', header: 'Lotes Ativos', render: (g) => <Badge variant={g.lotes_ativos > 0 ? 'success' : 'neutral'}>{g.lotes_ativos}</Badge> },
  ];

  if (isLoading) return (<div className="space-y-6"><LoadingSkeleton type="table" count={5} /></div>);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Granjas</h1>
          <p className="text-sm text-gray-500 mt-1">{(granjas || []).length} granjas cadastradas</p>
        </div>
        <button onClick={() => setModalOpen(true)} className="btn-primary flex items-center gap-2"><Plus className="w-4 h-4" />Nova Granja</button>
      </div>

      <DataTable columns={columns} data={granjas || mockGranjas} onRowClick={(g) => navigate(`/granjas/${g.id}`)} searchPlaceholder="Buscar granjas..." />

      <Modal isOpen={modalOpen} onClose={() => { setModalOpen(false); resetForm(); }} title="Nova Granja"
        footer={<><button className="btn-secondary" onClick={() => { setModalOpen(false); resetForm(); }}>Cancelar</button><button className="btn-primary" onClick={() => criarMutation.mutate(form)} disabled={!form.nome || !form.endereco}>Salvar</button></>}>
        <div className="space-y-4">
          <div><label className="label-field">Nome da Granja</label><input type="text" className="input-field" value={form.nome} onChange={(e) => setForm({ ...form, nome: e.target.value })} placeholder="Ex: Granja São José" /></div>
          <div><label className="label-field">Endereço</label><input type="text" className="input-field" value={form.endereco} onChange={(e) => setForm({ ...form, endereco: e.target.value })} placeholder="Ex: Rod. MG-050, Km 12" /></div>
          <div className="grid grid-cols-2 gap-4">
            <div><label className="label-field">Cidade</label><input type="text" className="input-field" value={form.cidade} onChange={(e) => setForm({ ...form, cidade: e.target.value })} placeholder="Divinópolis" /></div>
            <div><label className="label-field">Estado</label><input type="text" className="input-field" value={form.estado} onChange={(e) => setForm({ ...form, estado: e.target.value })} placeholder="MG" maxLength={2} /></div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div><label className="label-field">Latitude</label><input type="number" step="any" className="input-field" value={form.latitude || ''} onChange={(e) => setForm({ ...form, latitude: Number(e.target.value) })} placeholder="-20.1389" /></div>
            <div><label className="label-field">Longitude</label><input type="number" step="any" className="input-field" value={form.longitude || ''} onChange={(e) => setForm({ ...form, longitude: Number(e.target.value) })} placeholder="-44.8841" /></div>
          </div>
        </div>
      </Modal>
    </div>
  );
}
