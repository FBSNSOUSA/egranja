import { useQuery } from '@tanstack/react-query';
import { CloudSun, Thermometer, Droplets, Wind, CloudRain } from 'lucide-react';
import { dashboardService } from '../services/api';
import LoadingSkeleton from '../components/LoadingSkeleton';
import type { PrevisaoTempo as PrevisaoTempoType } from '../types';
import { format, parseISO } from 'date-fns';
import { ptBR } from 'date-fns/locale';

const mockPrevisao: PrevisaoTempoType[] = [
  { data: '2026-03-07', temperatura_min: 18, temperatura_max: 29, umidade: 65, condicao: 'Parcialmente nublado', icone: 'cloud-sun', vento_kmh: 12, precipitacao_mm: 0 },
  { data: '2026-03-08', temperatura_min: 20, temperatura_max: 32, umidade: 70, condicao: 'Chuva leve', icone: 'cloud-rain', vento_kmh: 18, precipitacao_mm: 8 },
  { data: '2026-03-09', temperatura_min: 17, temperatura_max: 26, umidade: 55, condicao: 'Ensolarado', icone: 'sun', vento_kmh: 8, precipitacao_mm: 0 },
  { data: '2026-03-10', temperatura_min: 19, temperatura_max: 28, umidade: 60, condicao: 'Nublado', icone: 'cloud', vento_kmh: 15, precipitacao_mm: 2 },
  { data: '2026-03-11', temperatura_min: 21, temperatura_max: 33, umidade: 72, condicao: 'Chuva forte', icone: 'cloud-rain', vento_kmh: 25, precipitacao_mm: 20 },
  { data: '2026-03-12', temperatura_min: 16, temperatura_max: 24, umidade: 50, condicao: 'Ensolarado', icone: 'sun', vento_kmh: 10, precipitacao_mm: 0 },
  { data: '2026-03-13', temperatura_min: 18, temperatura_max: 27, umidade: 58, condicao: 'Parcialmente nublado', icone: 'cloud-sun', vento_kmh: 14, precipitacao_mm: 0 },
];

export default function PrevisaoTempo() {
  const { data: previsao, isLoading } = useQuery<PrevisaoTempoType[]>({
    queryKey: ['previsao-tempo'],
    queryFn: async () => {
      try { const res = await dashboardService.getPrevisaoTempo(); return res.data.data || res.data; }
      catch { return mockPrevisao; }
    },
  });

  const dados = previsao || mockPrevisao;

  const getTempBg = (max: number) => {
    if (max >= 33) return 'from-red-100 to-red-50';
    if (max >= 30) return 'from-amber-100 to-amber-50';
    return 'from-blue-50 to-green-50';
  };

  if (isLoading) return <LoadingSkeleton type="cards" count={7} />;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Previsão do Tempo</h1>
        <p className="text-sm text-gray-500 mt-1">Previsão para os próximos 7 dias na região das granjas</p>
      </div>

      {dados.some((d) => d.temperatura_max >= 32) && (
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 flex items-start gap-3">
          <Thermometer className="w-5 h-5 text-amber-600 mt-0.5" />
          <div>
            <p className="text-sm font-medium text-amber-800">Alerta de calor</p>
            <p className="text-xs text-amber-600 mt-0.5">Temperaturas acima de 32°C previstas. Reforce a ventilação e nebulização dos galpões.</p>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {dados.map((dia, idx) => (
          <div key={dia.data} className={`rounded-xl border border-gray-100 p-5 bg-gradient-to-br ${getTempBg(dia.temperatura_max)} ${idx === 0 ? 'ring-2 ring-primary/30' : ''}`}>
            <div className="flex items-center justify-between mb-3">
              <div>
                <p className="text-sm font-semibold text-gray-900 capitalize">{format(parseISO(dia.data), "EEEE", { locale: ptBR })}</p>
                <p className="text-xs text-gray-500">{format(parseISO(dia.data), "dd 'de' MMMM", { locale: ptBR })}</p>
              </div>
              <CloudSun className="w-8 h-8 text-amber-500" />
            </div>
            <div className="flex items-end gap-2 mb-4">
              <span className="text-3xl font-bold text-gray-900">{dia.temperatura_max}°</span>
              <span className="text-lg text-gray-400 mb-0.5">/ {dia.temperatura_min}°</span>
            </div>
            <p className="text-sm text-gray-700 mb-3">{dia.condicao}</p>
            <div className="grid grid-cols-3 gap-2 text-center">
              <div className="bg-white/60 rounded-lg p-2">
                <Droplets className="w-3.5 h-3.5 mx-auto mb-0.5 text-blue-500" /><p className="text-xs font-medium">{dia.umidade}%</p><p className="text-[10px] text-gray-400">Umidade</p>
              </div>
              <div className="bg-white/60 rounded-lg p-2">
                <Wind className="w-3.5 h-3.5 mx-auto mb-0.5 text-gray-500" /><p className="text-xs font-medium">{dia.vento_kmh} km/h</p><p className="text-[10px] text-gray-400">Vento</p>
              </div>
              <div className="bg-white/60 rounded-lg p-2">
                <CloudRain className="w-3.5 h-3.5 mx-auto mb-0.5 text-blue-600" /><p className="text-xs font-medium">{dia.precipitacao_mm}mm</p><p className="text-[10px] text-gray-400">Chuva</p>
              </div>
            </div>
            {idx === 0 && (<div className="mt-3 pt-2 border-t border-gray-200/50"><p className="text-[10px] text-primary font-semibold uppercase">Hoje</p></div>)}
          </div>
        ))}
      </div>
    </div>
  );
}
