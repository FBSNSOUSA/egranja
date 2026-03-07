import { useState, useRef, useEffect } from 'react';
import { useLocation, Link } from 'react-router-dom';
import { Bell, Search, ChevronRight, User, LogOut, Settings } from 'lucide-react';
import type { Usuario, Alerta } from '../types';

interface HeaderProps {
  usuario: Usuario | null;
  onLogout: () => void;
  alertas?: Alerta[];
}

const routeLabels: Record<string, string> = {
  '': 'Dashboard',
  granjas: 'Granjas',
  lotes: 'Lotes',
  produtores: 'Produtores',
  iot: 'Sensores IoT',
  previsao: 'Previsão do Tempo',
  relatorios: 'Relatórios',
  config: 'Configurações',
};

export default function Header({ usuario, onLogout, alertas = [] }: HeaderProps) {
  const location = useLocation();
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);
  const [searchValue, setSearchValue] = useState('');
  const userMenuRef = useRef<HTMLDivElement>(null);
  const notifRef = useRef<HTMLDivElement>(null);

  const unreadCount = alertas.filter((a) => !a.lida).length;

  // Breadcrumb
  const pathParts = location.pathname.split('/').filter(Boolean);
  const breadcrumbs = [
    { label: 'Início', to: '/' },
    ...pathParts.map((part, idx) => {
      const to = '/' + pathParts.slice(0, idx + 1).join('/');
      const label = routeLabels[part] || (isNaN(Number(part)) ? part : `#${part}`);
      return { label, to };
    }),
  ];

  // Fechar dropdowns ao clicar fora
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (userMenuRef.current && !userMenuRef.current.contains(e.target as Node)) {
        setShowUserMenu(false);
      }
      if (notifRef.current && !notifRef.current.contains(e.target as Node)) {
        setShowNotifications(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-6 sticky top-0 z-30">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-1 text-sm">
        {breadcrumbs.map((crumb, idx) => (
          <span key={crumb.to} className="flex items-center gap-1">
            {idx > 0 && <ChevronRight className="w-3.5 h-3.5 text-gray-300" />}
            {idx === breadcrumbs.length - 1 ? (
              <span className="font-medium text-gray-900">{crumb.label}</span>
            ) : (
              <Link
                to={crumb.to}
                className="text-gray-500 hover:text-primary transition-colors"
              >
                {crumb.label}
              </Link>
            )}
          </span>
        ))}
      </nav>

      {/* Direita */}
      <div className="flex items-center gap-3">
        {/* Busca */}
        <div className="relative hidden md:block">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            value={searchValue}
            onChange={(e) => setSearchValue(e.target.value)}
            placeholder="Buscar granjas, lotes..."
            className="pl-10 pr-4 py-2 bg-gray-50 border-0 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:bg-white w-64 transition-all"
          />
        </div>

        {/* Notificações */}
        <div className="relative" ref={notifRef}>
          <button
            onClick={() => {
              setShowNotifications(!showNotifications);
              setShowUserMenu(false);
            }}
            className="relative p-2 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <Bell className="w-5 h-5 text-gray-500" />
            {unreadCount > 0 && (
              <span className="absolute top-1 right-1 w-4 h-4 bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center">
                {unreadCount > 9 ? '9+' : unreadCount}
              </span>
            )}
          </button>

          {showNotifications && (
            <div className="absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-lg border border-gray-100 overflow-hidden">
              <div className="px-4 py-3 border-b border-gray-100">
                <h3 className="font-semibold text-gray-900 text-sm">Notificações</h3>
              </div>
              <div className="max-h-80 overflow-y-auto">
                {alertas.length === 0 ? (
                  <p className="px-4 py-8 text-center text-sm text-gray-400">
                    Nenhuma notificação
                  </p>
                ) : (
                  alertas.slice(0, 10).map((alerta) => (
                    <div
                      key={alerta.id}
                      className={`px-4 py-3 border-b border-gray-50 hover:bg-gray-50 ${
                        !alerta.lida ? 'bg-green-50/50' : ''
                      }`}
                    >
                      <p className="text-sm text-gray-800">{alerta.mensagem}</p>
                      <p className="text-xs text-gray-400 mt-1">
                        {alerta.lote_nome && `${alerta.lote_nome} - `}
                        {alerta.data}
                      </p>
                    </div>
                  ))
                )}
              </div>
            </div>
          )}
        </div>

        {/* User menu */}
        <div className="relative" ref={userMenuRef}>
          <button
            onClick={() => {
              setShowUserMenu(!showUserMenu);
              setShowNotifications(false);
            }}
            className="flex items-center gap-2 p-1.5 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center">
              <span className="text-white text-sm font-semibold">
                {usuario?.nome?.charAt(0).toUpperCase() || 'U'}
              </span>
            </div>
            <span className="hidden md:block text-sm font-medium text-gray-700">
              {usuario?.nome?.split(' ')[0] || 'Usuário'}
            </span>
          </button>

          {showUserMenu && (
            <div className="absolute right-0 mt-2 w-48 bg-white rounded-xl shadow-lg border border-gray-100 overflow-hidden">
              <div className="px-4 py-3 border-b border-gray-100">
                <p className="text-sm font-medium text-gray-900">{usuario?.nome}</p>
                <p className="text-xs text-gray-500">{usuario?.email || usuario?.login}</p>
              </div>
              <div className="py-1">
                <Link
                  to="/config"
                  onClick={() => setShowUserMenu(false)}
                  className="flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
                >
                  <User className="w-4 h-4" />
                  Meu Perfil
                </Link>
                <Link
                  to="/config"
                  onClick={() => setShowUserMenu(false)}
                  className="flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
                >
                  <Settings className="w-4 h-4" />
                  Configurações
                </Link>
                <button
                  onClick={onLogout}
                  className="flex items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-red-50 w-full"
                >
                  <LogOut className="w-4 h-4" />
                  Sair
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
