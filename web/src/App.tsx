import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useAuth } from './hooks/useAuth';
import Layout from './components/Layout';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Granjas from './pages/Granjas';
import GranjaDetalhe from './pages/GranjaDetalhe';
import Lotes from './pages/Lotes';
import LoteDetalhe from './pages/LoteDetalhe';
import Produtores from './pages/Produtores';
import IoTSensores from './pages/IoTSensores';
import PrevisaoTempo from './pages/PrevisaoTempo';
import Relatorios from './pages/Relatorios';
import Configuracoes from './pages/Configuracoes';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutos
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated } = useAuth();
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
}

function AppRoutes() {
  const { usuario, isAuthenticated, loading, error, login, logout } = useAuth();

  if (!isAuthenticated) {
    return (
      <Routes>
        <Route path="/login" element={<Login onLogin={login} error={error} loading={loading} />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    );
  }

  return (
    <Routes>
      <Route path="/login" element={<Navigate to="/" replace />} />
      <Route
        element={
          <ProtectedRoute>
            <Layout usuario={usuario} onLogout={logout} />
          </ProtectedRoute>
        }
      >
        <Route path="/" element={<Dashboard />} />
        <Route path="/granjas" element={<Granjas />} />
        <Route path="/granjas/:id" element={<GranjaDetalhe />} />
        <Route path="/lotes" element={<Lotes />} />
        <Route path="/lotes/:id" element={<LoteDetalhe />} />
        <Route path="/produtores" element={<Produtores />} />
        <Route path="/iot" element={<IoTSensores />} />
        <Route path="/previsao" element={<PrevisaoTempo />} />
        <Route path="/relatorios" element={<Relatorios />} />
        <Route path="/config" element={<Configuracoes usuario={usuario} />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <AppRoutes />
      </BrowserRouter>
    </QueryClientProvider>
  );
}
