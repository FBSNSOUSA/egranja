interface BadgeProps {
  children: React.ReactNode;
  variant?: 'success' | 'warning' | 'danger' | 'info' | 'neutral';
  size?: 'sm' | 'md';
}

const variantClasses = {
  success: 'bg-green-100 text-green-800',
  warning: 'bg-amber-100 text-amber-800',
  danger: 'bg-red-100 text-red-800',
  info: 'bg-blue-100 text-blue-800',
  neutral: 'bg-gray-100 text-gray-700',
};

const sizeClasses = {
  sm: 'px-2 py-0.5 text-xs',
  md: 'px-2.5 py-1 text-xs',
};

export default function Badge({
  children,
  variant = 'neutral',
  size = 'md',
}: BadgeProps) {
  return (
    <span
      className={`inline-flex items-center font-semibold rounded-full ${variantClasses[variant]} ${sizeClasses[size]}`}
    >
      {children}
    </span>
  );
}

// Helpers para mapear severidade/status para variant
export function severidadeVariant(
  severidade: string
): 'success' | 'warning' | 'danger' | 'info' | 'neutral' {
  switch (severidade) {
    case 'critica':
      return 'danger';
    case 'alta':
      return 'warning';
    case 'media':
      return 'info';
    case 'baixa':
      return 'success';
    default:
      return 'neutral';
  }
}

export function statusVariant(
  status: string
): 'success' | 'warning' | 'danger' | 'info' | 'neutral' {
  switch (status) {
    case 'ativo':
    case 'online':
    case 'normal':
      return 'success';
    case 'finalizado':
    case 'offline':
      return 'neutral';
    case 'alerta':
      return 'warning';
    case 'critico':
      return 'danger';
    default:
      return 'neutral';
  }
}
