/**
 * Servico de autenticacao do eGranja.
 *
 * Gerencia login, logout, refresh de tokens e armazenamento seguro
 * usando react-native-keychain (Keychain iOS / Keystore Android).
 *
 * Fluxo JWT:
 * - Access token: valido por 24h, enviado em toda request
 * - Refresh token: valido por 30 dias, usado para renovar access token
 * - Tokens armazenados de forma segura no dispositivo
 */

import axios from 'axios';
import * as Keychain from 'react-native-keychain';

// ==========================================
// CONFIGURACAO
// ==========================================

/** URL base da API - mesma config de api.ts (emulador: http://10.0.2.2:8080/api/v1) */
const API_BASE_URL =
  process.env.EXPO_PUBLIC_API_BASE_URL ||
  process.env.API_BASE_URL ||
  'https://api.egranja.com.br/api/v1';

/** Chaves para armazenamento seguro no Keychain */
const KEYCHAIN_SERVICE_ACCESS = 'egranja_access_token';
const KEYCHAIN_SERVICE_REFRESH = 'egranja_refresh_token';

// ==========================================
// TIPOS
// ==========================================

/** Dados do usuario retornados pelo login */
export interface User {
  id: string;
  login: string;
  nome: string;
  tipo: 'produtor' | 'tecnico';
  ativo: boolean;
}

/** Resposta do endpoint de login */
export interface LoginResponse {
  user: User;
  access_token: string;
  refresh_token: string;
}

/** Resposta do endpoint de refresh */
export interface RefreshResponse {
  access_token: string;
}

/** Payload decodificado do JWT (campos relevantes) */
interface JWTPayload {
  sub: string;    // ID do usuario
  exp: number;    // Timestamp de expiracao
  iat: number;    // Timestamp de emissao
  tipo: string;   // Tipo do usuario (produtor/tecnico)
}

// ==========================================
// FUNCOES DE ARMAZENAMENTO SEGURO
// ==========================================

/**
 * Salva os tokens de autenticacao no armazenamento seguro do dispositivo.
 * Access token e refresh token sao armazenados separadamente.
 */
async function saveTokens(accessToken: string, refreshToken: string): Promise<void> {
  try {
    // Salvar access token
    await Keychain.setGenericPassword('access_token', accessToken, {
      service: KEYCHAIN_SERVICE_ACCESS,
      accessible: Keychain.ACCESSIBLE.AFTER_FIRST_UNLOCK,
    });

    // Salvar refresh token
    await Keychain.setGenericPassword('refresh_token', refreshToken, {
      service: KEYCHAIN_SERVICE_REFRESH,
      accessible: Keychain.ACCESSIBLE.AFTER_FIRST_UNLOCK,
    });
  } catch (error) {
    console.error('[Auth] Erro ao salvar tokens:', error);
    throw new Error('Falha ao salvar credenciais de autenticacao.');
  }
}

/**
 * Remove todos os tokens do armazenamento seguro.
 */
async function clearTokens(): Promise<void> {
  try {
    await Keychain.resetGenericPassword({ service: KEYCHAIN_SERVICE_ACCESS });
    await Keychain.resetGenericPassword({ service: KEYCHAIN_SERVICE_REFRESH });
  } catch (error) {
    console.error('[Auth] Erro ao limpar tokens:', error);
  }
}

// ==========================================
// FUNCOES PUBLICAS
// ==========================================

/**
 * Recupera o access token armazenado no dispositivo.
 * Retorna null se nao houver token salvo.
 */
export async function getToken(): Promise<string | null> {
  try {
    const credentials = await Keychain.getGenericPassword({
      service: KEYCHAIN_SERVICE_ACCESS,
    });
    if (credentials) {
      return credentials.password;
    }
    return null;
  } catch (error) {
    console.error('[Auth] Erro ao recuperar access token:', error);
    return null;
  }
}

/**
 * Recupera o refresh token armazenado no dispositivo.
 * Retorna null se nao houver token salvo.
 */
async function getRefreshToken(): Promise<string | null> {
  try {
    const credentials = await Keychain.getGenericPassword({
      service: KEYCHAIN_SERVICE_REFRESH,
    });
    if (credentials) {
      return credentials.password;
    }
    return null;
  } catch (error) {
    console.error('[Auth] Erro ao recuperar refresh token:', error);
    return null;
  }
}

/**
 * Decodifica o payload de um JWT sem verificar assinatura.
 * Usado apenas para leitura local (expiracao, tipo, etc).
 * A validacao real acontece no servidor.
 */
function decodeJWT(token: string): JWTPayload | null {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;

    const payload = parts[1];
    // Decodificar base64url para string JSON
    const decoded = atob(payload.replace(/-/g, '+').replace(/_/g, '/'));
    return JSON.parse(decoded) as JWTPayload;
  } catch (error) {
    console.error('[Auth] Erro ao decodificar JWT:', error);
    return null;
  }
}

/**
 * Verifica se o token esta expirado.
 * Considera expirado se faltam menos de 60 segundos para expirar.
 */
function isTokenExpired(token: string): boolean {
  const payload = decodeJWT(token);
  if (!payload) return true;

  const now = Math.floor(Date.now() / 1000);
  const marginSeconds = 60; // Margem de 60 segundos
  return payload.exp <= now + marginSeconds;
}

/**
 * Verifica se o usuario esta autenticado.
 *
 * Retorna true se:
 * - Ha um access token salvo E nao esta expirado, OU
 * - Ha um refresh token salvo E nao esta expirado (pode renovar)
 */
export async function isAuthenticated(): Promise<boolean> {
  try {
    // Verificar access token
    const accessToken = await getToken();
    if (accessToken && !isTokenExpired(accessToken)) {
      return true;
    }

    // Access token expirado/ausente: verificar refresh token
    const refreshTokenValue = await getRefreshToken();
    if (refreshTokenValue && !isTokenExpired(refreshTokenValue)) {
      // Tentar renovar o access token
      const newToken = await refreshToken();
      return newToken !== null;
    }

    return false;
  } catch (error) {
    console.error('[Auth] Erro ao verificar autenticacao:', error);
    return false;
  }
}

/**
 * Realiza login do usuario.
 *
 * Envia credenciais para API, recebe tokens JWT e dados do usuario.
 * Salva tokens de forma segura no dispositivo.
 *
 * @param username - Login do usuario
 * @param password - Senha do usuario
 * @returns Dados do usuario logado
 * @throws Error com mensagem amigavel para o usuario
 */
export async function login(username: string, password: string): Promise<User> {
  try {
    const response = await axios.post<{
      success: boolean;
      data: LoginResponse;
    }>(`${API_BASE_URL}/auth/login`, {
      login: username,
      senha: password,
    }, {
      timeout: 15000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.data.success || !response.data.data) {
      throw new Error('Usuario ou senha incorretos.');
    }

    const { user, access_token, refresh_token } = response.data.data;

    // Salvar tokens de forma segura
    await saveTokens(access_token, refresh_token);

    return user;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      // Erro de rede (sem conexao)
      if (!error.response) {
        throw new Error('Sem conexao com a internet. Verifique sua conexao e tente novamente.');
      }

      // Erro de credenciais (401)
      if (error.response.status === 401) {
        throw new Error('Usuario ou senha incorretos.');
      }

      // Rate limiting (429)
      if (error.response.status === 429) {
        throw new Error('Muitas tentativas de login. Aguarde um momento e tente novamente.');
      }

      // Erro do servidor
      if (error.response.status >= 500) {
        throw new Error('Servidor indisponivel. Tente novamente mais tarde.');
      }
    }

    // Erro generico ou ja tratado
    if (error instanceof Error) {
      throw error;
    }
    throw new Error('Ocorreu um erro inesperado. Tente novamente.');
  }
}

/**
 * Renova o access token usando o refresh token.
 *
 * Chamado automaticamente pelo interceptor do Axios quando recebe 401.
 * Se o refresh token tambem estiver expirado, retorna null (usuario deve fazer login novamente).
 *
 * @returns Novo access token ou null se falhou
 */
export async function refreshToken(): Promise<string | null> {
  try {
    const currentRefreshToken = await getRefreshToken();
    if (!currentRefreshToken) {
      console.warn('[Auth] Nenhum refresh token disponivel.');
      return null;
    }

    // Verificar se refresh token esta expirado antes de chamar API
    if (isTokenExpired(currentRefreshToken)) {
      console.warn('[Auth] Refresh token expirado.');
      await clearTokens();
      return null;
    }

    const response = await axios.post<{
      success: boolean;
      data: RefreshResponse;
    }>(`${API_BASE_URL}/auth/refresh`, {
      refresh_token: currentRefreshToken,
    }, {
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.data.success || !response.data.data) {
      await clearTokens();
      return null;
    }

    const { access_token } = response.data.data;

    // Salvar novo access token (mantem o refresh token atual)
    await Keychain.setGenericPassword('access_token', access_token, {
      service: KEYCHAIN_SERVICE_ACCESS,
      accessible: Keychain.ACCESSIBLE.AFTER_FIRST_UNLOCK,
    });

    return access_token;
  } catch (error) {
    console.error('[Auth] Erro ao renovar token:', error);
    await clearTokens();
    return null;
  }
}

/**
 * Realiza logout do usuario.
 *
 * Remove todos os tokens do armazenamento seguro.
 * Nao chama API (o token simplesmente expira no servidor).
 */
export async function logout(): Promise<void> {
  try {
    await clearTokens();
  } catch (error) {
    console.error('[Auth] Erro ao realizar logout:', error);
    // Mesmo com erro, tenta limpar o que puder
    await clearTokens();
  }
}

/**
 * Extrai dados do usuario a partir do access token salvo.
 * Util para recuperar info do usuario sem chamar API.
 *
 * @returns Dados parciais do usuario ou null se nao autenticado
 */
export async function getUserFromToken(): Promise<Partial<User> | null> {
  try {
    const token = await getToken();
    if (!token) return null;

    const payload = decodeJWT(token);
    if (!payload) return null;

    return {
      id: payload.sub,
      tipo: payload.tipo as User['tipo'],
    };
  } catch (error) {
    console.error('[Auth] Erro ao extrair dados do token:', error);
    return null;
  }
}
