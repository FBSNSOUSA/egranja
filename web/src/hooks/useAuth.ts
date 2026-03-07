import { useState, useCallback, useEffect } from 'react';
import type { Usuario } from '../types';
import { authService } from '../services/api';

export function useAuth() {
  const [usuario, setUsuario] = useState<Usuario | null>(() => {
    const stored = localStorage.getItem('egranja_usuario');
    return stored ? JSON.parse(stored) : null;
  });
  const [isAuthenticated, setIsAuthenticated] = useState(() => {
    return !!localStorage.getItem('egranja_token');
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const token = localStorage.getItem('egranja_token');
    const stored = localStorage.getItem('egranja_usuario');
    setIsAuthenticated(!!token);
    setUsuario(stored ? JSON.parse(stored) : null);
  }, []);

  const login = useCallback(async (loginInput: string, senha: string) => {
    setLoading(true);
    setError(null);
    try {
      const { data } = await authService.login(loginInput, senha);
      const response = data.data || data;
      localStorage.setItem('egranja_token', response.token);
      localStorage.setItem('egranja_refresh_token', response.refresh_token);
      localStorage.setItem('egranja_usuario', JSON.stringify(response.usuario));
      setUsuario(response.usuario);
      setIsAuthenticated(true);
      return true;
    } catch (err: unknown) {
      const axiosError = err as { response?: { data?: { message?: string } } };
      setError(axiosError.response?.data?.message || 'Erro ao realizar login');
      return false;
    } finally {
      setLoading(false);
    }
  }, []);

  const logout = useCallback(() => {
    authService.logout();
    setUsuario(null);
    setIsAuthenticated(false);
  }, []);

  return { usuario, isAuthenticated, loading, error, login, logout };
}
