import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Warehouse,
  Layers,
  Users,
  Cpu,
  CloudSun,
  FileBarChart,
  Settings,
  LogOut,
  ChevronLeft,
  ChevronRight,
  Egg,
} from 'lucide-react';
import type { Usuario } from '../types';

interface SidebarProps {
  usuario: Usuario | null;
  onLogout: () => void;
  collapsed: boolean;
  onToggle: () => void;
  alertCount?: number;
}

const menuItems = [
  { to: '/', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/granjas', icon: Warehouse, label: 'Granjas' },
  { to: '/lotes', icon: Layers, label: 'Lotes' },
  { to: '/produtores', icon: Users, label: 'Produtores' },
  { to: '/iot', icon: Cpu, label: 'Sensores IoT' },
  { to: '/previsao', icon: CloudSun, label: 'Previsão do Tempo' },
  { to: '/relatorios', icon: FileBarChart, label: 'Relatórios' },
  { to: '/config', icon: Settings, label: 'Configurações' },
];

export default function Sidebar({
  usuario,
  onLogout,
  collapsed,
  onToggle,
  alertCount = 0,
}: SidebarProps) {
  const tipoLabel: Record<string, string> = {
    admin: 'Administrador',
    integradora: 'Integradora',
    tecnico: 'Técnico',
    produtor: 'Produtor',
  };

  return (
    <aside
      className={`fixed left-0 top-0 h-screen bg-white border-r border-gray-200 flex flex-col z-40 transition-all duration-300 ${
        collapsed ? 'w-16' : 'w-60'
      }`}
    >
      {/* Logo */}
      <div className="flex items-center gap-3 px-4 py-5 border-b border-gray-100">
        <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center flex-shrink-0">
          <Egg className="w-5 h-5 text-white" />
        </div>
        {!collapsed && (
          <span className="text-xl font-bold text-primary">eGranja</span>
        )}
      </div>

      {/* Toggle */}
      <button
        onClick={onToggle}
        className="absolute -right-3 top-7 w-6 h-6 bg-white border border-gray-200 rounded-full flex items-center justify-center hover:bg-gray-50 shadow-sm"
      >
        {collapsed ? (
          <ChevronRight className="w-3 h-3 text-gray-500" />
        ) : (
          <ChevronLeft className="w-3 h-3 text-gray-500" />
        )}
      </button>

      {/* Menu */}
      <nav className="flex-1 py-4 px-2 space-y-1 overflow-y-auto">
        {menuItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === '/'}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors duration-150 group relative ${
                isActive
                  ? 'bg-green-50 text-primary'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`
            }
          >
            {({ isActive }) => (
              <>
                {isActive && (
                  <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-primary rounded-r-full" />
                )}
                <item.icon className={`w-5 h-5 flex-shrink-0 ${isActive ? 'text-primary' : 'text-gray-400 group-hover:text-gray-600'}`} />
                {!collapsed && <span>{item.label}</span>}
                {!collapsed && item.label === 'Sensores IoT' && alertCount > 0 && (
                  <span className="ml-auto bg-red-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full min-w-[20px] text-center">
                    {alertCount}
                  </span>
                )}
              </>
            )}
          </NavLink>
        ))}
      </nav>

      {/* User */}
      <div className="border-t border-gray-100 p-3">
        {!collapsed ? (
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 bg-primary rounded-full flex items-center justify-center flex-shrink-0">
              <span className="text-white text-sm font-semibold">
                {usuario?.nome?.charAt(0).toUpperCase() || 'U'}
              </span>
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-gray-900 truncate">
                {usuario?.nome || 'Usuário'}
              </p>
              <p className="text-xs text-gray-500 truncate">
                {tipoLabel[usuario?.tipo || 'admin']}
              </p>
            </div>
            <button
              onClick={onLogout}
              className="p-1.5 rounded-lg hover:bg-red-50 text-gray-400 hover:text-red-600 transition-colors"
              title="Sair"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        ) : (
          <button
            onClick={onLogout}
            className="w-full p-2 rounded-lg hover:bg-red-50 text-gray-400 hover:text-red-600 transition-colors flex items-center justify-center"
            title="Sair"
          >
            <LogOut className="w-5 h-5" />
          </button>
        )}
      </div>
    </aside>
  );
}
