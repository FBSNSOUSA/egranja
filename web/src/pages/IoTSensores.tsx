import { useQuery } from '@tanstack/react-query';
import {
  Cpu, Thermometer, Droplets, Wind, AlertTriangle, RefreshCw,
} from 'lucide-react';
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from 'recharts';
import { iotService } from '../services/api';
import Badge, { statusVariant } from '../components/Badge';
import LoadingSkeleton from '../components/LoadingSkeleton';
import type { IoTGalpaoResumo, IoTReading } from '../types';

const generateHistorico = (base: number, variance: number, count: number): IoTReading[] =>
  Array.from({ length: count }, (_, i) => ({
    id: i, sensor_id: 1, valor: base + (Math.random() - 0.5) * variance,
    unidade: '', timestamp: new Date(Date.now() - (count - i) * 900000).toISOString(),
  }));

const mockGalpoes: IoTGalpaoResumo[] = [
  { galpao_id: 1, galpao_nome: 'Galpão 1 - Granja São José', granja_nome: 'Granja São José', temperatura: 27.3, umidade: 62, co2: 2800, amonia: 15, status: 'normal', ultima_atualizacao: new Date().toISOString(), historico_temperatura: generateHistorico(27, 4, 24), historico_umidade: generateHistorico(62, 10, 24) },
  { galpao_id: 2, galpao_nome: 'Galpão 2 - Granja São José', granja_nome: 'Granja São José', temperatura: 29.1, umidade: 68, co2: 3200, amonia: 18, status: 'alerta', ultima_atualizacao: new Date().toISOString(), historico_temperatura: generateHistorico(29, 5, 24), historico_umidade: generateHistorico(68, 12, 24) },
  { galpao_id: 3, galpao_nome: 'Galpão 3 - Granja São José', granja_nome: 'Granja São José', temperatura: 33.2, umidade: 75, co2: 4500, amonia: 28, status: 'critico', ultima_atualizacao: new Date().toISOString(), historico_temperatura: generateHistorico(33, 3, 24), historico_umidade: generateHistorico(75, 8, 24) },
  { galpao_id: 5, galpao_nome: 'Galpão 1 - Granja Boa Vista', granja_nome: 'Granja Boa Vista', temperatura: 26.8, umidade: 58, co2: 2100, amonia: 12, status: 'normal', ultima_atualizacao: new Date().toISOString(), historico_temperatura: generateHistorico(27, 3, 24), historico_umidade: generateHistorico(58, 8, 24) },
];

export default function IoTSensores() {
  const { data: galpoes, isLoading, refetch, isFetching } = useQuery<IoTGalpaoResumo[]>({
    queryKey: ['iot', 'galpoes'],
    queryFn: async () => {
      try { const res = await iotService.galpoes(); return res.data.data || res.data; }
      catch { return mockGalpoes; }
    },
    refetchInterval: 30000,
  });

  const dados = galpoes || mockGalpoes;

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'critico': return 'border-red-300 bg-red-50';
      case 'alerta': return 'border-amber-300 bg-amber-50';
      default: return 'border-gray-100 bg-white';
    }
  };

  const getTempColor = (temp?: number) => {
    if (!temp) return 'text-gray-500';
    if (temp > 32) return 'text-red-600';
    if (temp > 30) return 'text-amber-600';
    return 'text-green-600';
  };

  if (isLoading) return (<div className="space-y-6"><LoadingSkeleton type="cards" count={4} /><LoadingSkeleton type="chart" /></div>);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Sensores IoT</h1>
          <p className="text-sm text-gray-500 mt-1">Monitoramento em tempo real dos galpões</p>
        </div>
        <button onClick={() => refetch()} className="btn-secondary flex items-center gap-2" disabled={isFetching}>
          <RefreshCw className={`w-4 h-4 ${isFetching ? 'animate-spin' : ''}`} />Atualizar
        </button>
      </div>

      {dados.some((g) => g.status !== 'normal') && (
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 flex items-start gap-3">
          <AlertTriangle className="w-5 h-5 text-amber-600 mt-0.5" />
          <div>
            <p className="text-sm font-medium text-amber-800">{dados.filter((g) => g.status === 'critico').length} galpão(ões) em estado crítico, {dados.filter((g) => g.status === 'alerta').length} em alerta</p>
            <p className="text-xs text-amber-600 mt-0.5">Verifique os parâmetros ambientais e tome as ações necessárias</p>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {dados.map((galpao) => (
          <div key={galpao.galpao_id} className={`rounded-xl border-2 p-5 transition-shadow hover:shadow-md ${getStatusColor(galpao.status)}`}>
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2"><Cpu className="w-5 h-5 text-primary" /><h3 className="font-semibold text-gray-900">{galpao.galpao_nome}</h3></div>
              <Badge variant={statusVariant(galpao.status)} size="sm">{galpao.status === 'normal' ? 'Normal' : galpao.status === 'alerta' ? 'Alerta' : 'Crítico'}</Badge>
            </div>
            <div className="grid grid-cols-4 gap-3 mb-4">
              <div className="text-center p-2 bg-white/80 rounded-lg">
                <Thermometer className={`w-4 h-4 mx-auto mb-1 ${getTempColor(galpao.temperatura)}`} />
                <p className={`text-lg font-bold ${getTempColor(galpao.temperatura)}`}>{galpao.temperatura?.toFixed(1)}°</p>
                <p className="text-[10px] text-gray-500 uppercase">Temp</p>
              </div>
              <div className="text-center p-2 bg-white/80 rounded-lg">
                <Droplets className="w-4 h-4 mx-auto mb-1 text-blue-500" />
                <p className="text-lg font-bold text-blue-600">{galpao.umidade}%</p>
                <p className="text-[10px] text-gray-500 uppercase">Umid.</p>
              </div>
              <div className="text-center p-2 bg-white/80 rounded-lg">
                <Wind className="w-4 h-4 mx-auto mb-1 text-gray-500" />
                <p className="text-lg font-bold text-gray-700">{galpao.co2}</p>
                <p className="text-[10px] text-gray-500 uppercase">CO2 ppm</p>
              </div>
              <div className="text-center p-2 bg-white/80 rounded-lg">
                <Wind className="w-4 h-4 mx-auto mb-1 text-purple-500" />
                <p className="text-lg font-bold text-purple-600">{galpao.amonia}</p>
                <p className="text-[10px] text-gray-500 uppercase">NH3 ppm</p>
              </div>
            </div>
            <ResponsiveContainer width="100%" height={120}>
              <LineChart data={galpao.historico_temperatura}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" /><XAxis dataKey="timestamp" hide /><YAxis domain={['auto', 'auto']} hide />
                <Tooltip formatter={(v) => `${Number(v).toFixed(1)}°C`} labelFormatter={(l) => { try { return new Date(String(l)).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }); } catch { return String(l); } }} />
                <Legend /><Line type="monotone" dataKey="valor" name="Temperatura" stroke="#EF5350" strokeWidth={1.5} dot={false} />
              </LineChart>
            </ResponsiveContainer>
            <p className="text-[10px] text-gray-400 mt-2 text-right">Últimas 6 horas (atualizado a cada 15 min)</p>
          </div>
        ))}
      </div>
    </div>
  );
}
