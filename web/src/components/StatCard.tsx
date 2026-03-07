import type { LucideIcon } from 'lucide-react';
import { TrendingUp, TrendingDown } from 'lucide-react';

interface StatCardProps {
  titulo: string;
  valor: string | number;
  icone: LucideIcon;
  variacao?: number;
  cor?: string;
  sufixo?: string;
}

export default function StatCard({
  titulo,
  valor,
  icone: Icon,
  variacao,
  cor = 'text-primary',
  sufixo,
}: StatCardProps) {
  const variacaoPositiva = variacao !== undefined && variacao >= 0;

  return (
    <div className="card hover:shadow-md transition-shadow duration-200">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm font-medium text-gray-500 uppercase tracking-wide">
            {titulo}
          </p>
          <p className="mt-2 text-3xl font-bold text-gray-900">
            {valor}
            {sufixo && (
              <span className="text-lg font-normal text-gray-500 ml-1">
                {sufixo}
              </span>
            )}
          </p>
          {variacao !== undefined && (
            <div className="mt-2 flex items-center gap-1">
              {variacaoPositiva ? (
                <TrendingUp className="w-4 h-4 text-green-600" />
              ) : (
                <TrendingDown className="w-4 h-4 text-red-600" />
              )}
              <span
                className={`text-sm font-medium ${
                  variacaoPositiva ? 'text-green-600' : 'text-red-600'
                }`}
              >
                {variacaoPositiva ? '+' : ''}
                {variacao.toFixed(1)}%
              </span>
              <span className="text-sm text-gray-400 ml-1">vs mês anterior</span>
            </div>
          )}
        </div>
        <div className={`p-3 rounded-xl bg-green-50 ${cor}`}>
          <Icon className="w-6 h-6" />
        </div>
      </div>
    </div>
  );
}
