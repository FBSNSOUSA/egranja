/**
 * Store de autenticacao (Zustand).
 *
 * Gerencia o estado global de autenticacao do usuario:
 * - Dados do usuario logado
 * - Status de autenticacao
 * - Loading states
 * - Acoes de login, logout e refresh
 */

import { create } from 'zustand';
import {
  login as authLogin,
  logout as authLogout,
  isAuthenticated as checkAuthenticated,
  getUserFromToken,
  User,
} from '@services/auth';
import { apiGet } from '@services/api';

// ==========================================
// TIPOS
// ==========================================

export interface AuthState {
  /** Dados do usuario logado */
  user: User | null;

  /** Indica se o usuario esta autenticado */
  isAuthenticated: boolean;

  /** Indica se esta verificando autenticacao ou fazendo login */
  isLoading: boolean;

  /** Mensagem de erro do ultimo login */
  errorMessage: string | null;

  /**
   * Realiza login do usuario.
   * Salva tokens e atualiza estado global.
   */
  login: (username: string, password: string) => Promise<void>;

  /**
   * Realiza logout do usuario.
   * Limpa tokens e estado global.
   */
  logout: () => Promise<void>;

  /**
   * Verifica autenticacao e recarrega dados do usuario.
   * Chamado na inicializacao do app para auto-login.
   */
  refreshUser: () => Promise<void>;

  /** Limpa mensagem de erro */
  clearError: () => void;
}

// ==========================================
// STORE
// ==========================================

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  isLoading: true, // Inicia como true para verificacao inicial
  errorMessage: null,

  login: async (username: string, password: string) => {
    // Validacao de campos vazios
    if (!username.trim()) {
      set({ errorMessage: 'Informe o login.' });
      return;
    }
    if (!password.trim()) {
      set({ errorMessage: 'Informe a senha.' });
      return;
    }

    set({ isLoading: true, errorMessage: null });

    try {
      const user = await authLogin(username, password);
      set({
        user,
        isAuthenticated: true,
        isLoading: false,
        errorMessage: null,
      });
    } catch (error) {
      const message = error instanceof Error
        ? error.message
        : 'Usuario ou senha incorretos.';

      set({
        user: null,
        isAuthenticated: false,
        isLoading: false,
        errorMessage: message,
      });
    }
  },

  logout: async () => {
    set({ isLoading: true });

    try {
      await authLogout();
    } catch (error) {
      console.error('[AuthStore] Erro no logout:', error);
    } finally {
      set({
        user: null,
        isAuthenticated: false,
        isLoading: false,
        errorMessage: null,
      });
    }
  },

  refreshUser: async () => {
    set({ isLoading: true });

    try {
      // Verificar se ha token valido salvo
      const authenticated = await checkAuthenticated();

      if (!authenticated) {
        set({
          user: null,
          isAuthenticated: false,
          isLoading: false,
        });
        return;
      }

      // Tentar buscar dados completos do usuario via API
      try {
        const response = await apiGet<User>('/auth/me');
        set({
          user: response.data,
          isAuthenticated: true,
          isLoading: false,
        });
      } catch (apiError) {
        // Se API falhar (offline), usar dados do token
        const tokenUser = await getUserFromToken();
        if (tokenUser) {
          set({
            user: {
              id: tokenUser.id || '',
              login: '',
              nome: '',
              tipo: tokenUser.tipo || 'produtor',
              ativo: true,
            },
            isAuthenticated: true,
            isLoading: false,
          });
        } else {
          set({
            user: null,
            isAuthenticated: false,
            isLoading: false,
          });
        }
      }
    } catch (error) {
      console.error('[AuthStore] Erro ao verificar autenticacao:', error);
      set({
        user: null,
        isAuthenticated: false,
        isLoading: false,
      });
    }
  },

  clearError: () => {
    set({ errorMessage: null });
  },
}));

export default useAuthStore;
