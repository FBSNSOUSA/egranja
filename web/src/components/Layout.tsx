import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Header from './Header';
import type { Usuario } from '../types';

interface LayoutProps {
  usuario: Usuario | null;
  onLogout: () => void;
}

export default function Layout({ usuario, onLogout }: LayoutProps) {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  return (
    <div className="min-h-screen bg-bg">
      <Sidebar
        usuario={usuario}
        onLogout={onLogout}
        collapsed={sidebarCollapsed}
        onToggle={() => setSidebarCollapsed(!sidebarCollapsed)}
      />

      <div
        className={`transition-all duration-300 ${
          sidebarCollapsed ? 'ml-16' : 'ml-60'
        }`}
      >
        <Header usuario={usuario} onLogout={onLogout} />

        <main className="p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
