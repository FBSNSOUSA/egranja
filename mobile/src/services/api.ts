/**
 * Cliente HTTP (Axios) para comunicacao com a API eGranja.
 *
 * Funcionalidades:
 * - Base URL configuravel via variavel de ambiente
 * - Interceptor de request: adiciona JWT no header Authorization
 * - Interceptor de response: refresh automatico quando recebe 401
 * - Tratamento de erro de rede (salva operacao offline)
 * - Tipos de resposta padronizados (SuccessResponse, ErrorResponse)
 */

import axios, {
  AxiosInstance,
  AxiosError,
  InternalAxiosRequestConfig,
  AxiosResponse,
} from 'axios';
import { getToken, refreshToken } from './auth';
import { useSyncStore } from '@stores/syncStore';

// ==========================================
// CONFIGURACAO
// ==========================================

/** URL base da API - configuravel via EXPO_PUBLIC_API_BASE_URL ou API_BASE_URL (emulador: http://10.0.2.2:8080/api/v1) */
const API_BASE_URL =
  process.env.EXPO_PUBLIC_API_BASE_URL ||
  process.env.API_BASE_URL ||
  'https://api.egranja.com.br/api/v1';

/** Timeout padrao para requisicoes (ms) */
const REQUEST_TIMEOUT = 30000;

// ==========================================
// TIPOS DE RESPOSTA DA API
// ==========================================

/** Metadados de paginacao */
export interface PaginationMeta {
  page: number;
  per_page: number;
  total: number;
  total_pages: number;
}

/** Resposta de sucesso padrao da API */
export interface SuccessResponse<T> {
  success: true;
  data: T;
  meta?: PaginationMeta;
}

/** Detalhes de erro de validacao */
export interface ErrorDetail {
  field: string;
  message: string;
}

/** Corpo de erro da API */
export interface ApiError {
  code: string;
  message: string;
  details?: ErrorDetail[];
}

/** Resposta de erro padrao da API */
export interface ErrorResponse {
  success: false;
  error: ApiError;
}

/** Tipo uniao para qualquer resposta da API */
export type ApiResponse<T> = SuccessResponse<T> | ErrorResponse;

/** Operacao pendente para sincronizacao offline */
export interface PendingOperation {
  id: string;
  method: 'POST' | 'PATCH' | 'PUT' | 'DELETE';
  url: string;
  data?: unknown;
  createdAt: string;
}

// ==========================================
// CRIACAO DA INSTANCIA AXIOS
// ==========================================

const api: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: REQUEST_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// ==========================================
// INTERCEPTOR DE REQUEST
// Adiciona o JWT no header Authorization de toda requisicao
// ==========================================

api.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    try {
      const token = await getToken();
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    } catch (error) {
      // Se falhar ao recuperar token, continua sem ele
      // O servidor retornara 401 e o interceptor de response tratara
      console.warn('[API] Falha ao recuperar token para request:', error);
    }
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  },
);

// ==========================================
// INTERCEPTOR DE RESPONSE
// Trata 401 com refresh automatico e erros de rede
// ==========================================

/** Flag para evitar loop infinito de refresh */
let isRefreshing = false;

/** Fila de requests que aguardam o refresh do token */
let failedQueue: Array<{
  resolve: (value: unknown) => void;
  reject: (reason: unknown) => void;
}> = [];

/**
 * Processa a fila de requests pendentes apos refresh do token.
 * Se o refresh foi bem-sucedido, reenvia as requests com o novo token.
 * Se falhou, rejeita todas as requests pendentes.
 */
function processQueue(error: AxiosError | null, token: string | null = null): void {
  failedQueue.forEach((promise) => {
    if (error) {
      promise.reject(error);
    } else {
      promise.resolve(token);
    }
  });
  failedQueue = [];
}

api.interceptors.response.use(
  // Resposta bem-sucedida: retorna normalmente
  (response: AxiosResponse) => {
    return response;
  },

  // Tratamento de erros
  async (error: AxiosError<ErrorResponse>) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & {
      _retry?: boolean;
    };

    // --- Erro de rede (sem conexao / timeout) ---
    if (!error.response) {
      console.warn('[API] Erro de rede detectado. Salvando operacao offline.');

      // Salvar operacao para sincronizacao posterior (apenas mutacoes)
      if (
        originalRequest &&
        originalRequest.method &&
        ['post', 'patch', 'put', 'delete'].includes(originalRequest.method.toLowerCase())
      ) {
        const pendingOp: PendingOperation = {
          id: `${Date.now()}_${Math.random().toString(36).substring(2, 9)}`,
          method: originalRequest.method.toUpperCase() as PendingOperation['method'],
          url: originalRequest.url || '',
          data: originalRequest.data ? JSON.parse(originalRequest.data as string) : undefined,
          createdAt: new Date().toISOString(),
        };

        // Adicionar a fila de operacoes pendentes no store
        useSyncStore.getState().addPendingOp(pendingOp);
      }

      return Promise.reject({
        success: false,
        error: {
          code: 'NETWORK_ERROR',
          message: 'Sem conexao com a internet. Os dados serao sincronizados quando a conexao for restaurada.',
        },
      } as ErrorResponse);
    }

    // --- Erro 401 (Unauthorized): tentar refresh do token ---
    if (error.response.status === 401 && !originalRequest._retry) {
      // Se ja esta fazendo refresh, coloca na fila
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        })
          .then((token) => {
            if (originalRequest.headers) {
              originalRequest.headers.Authorization = `Bearer ${token}`;
            }
            return api(originalRequest);
          })
          .catch((err) => {
            return Promise.reject(err);
          });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        const newToken = await refreshToken();

        if (newToken) {
          // Refresh bem-sucedido: processar fila e reenviar request original
          processQueue(null, newToken);

          if (originalRequest.headers) {
            originalRequest.headers.Authorization = `Bearer ${newToken}`;
          }

          return api(originalRequest);
        } else {
          // Refresh falhou (refresh token expirado): limpar fila e redirecionar para login
          processQueue(error);
          // O authStore deve ser atualizado para redirecionar ao login
          return Promise.reject({
            success: false,
            error: {
              code: 'SESSION_EXPIRED',
              message: 'Sua sessao expirou. Faca login novamente.',
            },
          } as ErrorResponse);
        }
      } catch (refreshError) {
        processQueue(error);
        return Promise.reject({
          success: false,
          error: {
            code: 'SESSION_EXPIRED',
            message: 'Sua sessao expirou. Faca login novamente.',
          },
        } as ErrorResponse);
      } finally {
        isRefreshing = false;
      }
    }

    // --- Outros erros HTTP: formatar e retornar ---
    const errorResponse: ErrorResponse = error.response.data || {
      success: false,
      error: {
        code: `HTTP_${error.response.status}`,
        message: getDefaultErrorMessage(error.response.status),
      },
    };

    return Promise.reject(errorResponse);
  },
);

// ==========================================
// FUNCOES AUXILIARES
// ==========================================

/**
 * Retorna mensagem de erro padrao baseada no status HTTP.
 */
function getDefaultErrorMessage(status: number): string {
  const messages: Record<number, string> = {
    400: 'Dados invalidos. Verifique os campos e tente novamente.',
    403: 'Voce nao tem permissao para realizar esta acao.',
    404: 'Recurso nao encontrado.',
    409: 'Conflito de dados. Tente novamente.',
    422: 'Dados invalidos. Verifique os campos e tente novamente.',
    429: 'Muitas requisicoes. Aguarde um momento e tente novamente.',
    500: 'Erro interno do servidor. Tente novamente mais tarde.',
    502: 'Servidor indisponivel. Tente novamente mais tarde.',
    503: 'Servico temporariamente indisponivel. Tente novamente mais tarde.',
  };
  return messages[status] || 'Ocorreu um erro inesperado. Tente novamente.';
}

/**
 * Helper tipado para GET requests.
 */
export async function apiGet<T>(
  url: string,
  params?: Record<string, unknown>,
): Promise<SuccessResponse<T>> {
  const response = await api.get<SuccessResponse<T>>(url, { params });
  return response.data;
}

/**
 * Helper tipado para POST requests.
 */
export async function apiPost<T>(
  url: string,
  data?: unknown,
): Promise<SuccessResponse<T>> {
  const response = await api.post<SuccessResponse<T>>(url, data);
  return response.data;
}

/**
 * Helper tipado para PATCH requests.
 */
export async function apiPatch<T>(
  url: string,
  data?: unknown,
): Promise<SuccessResponse<T>> {
  const response = await api.patch<SuccessResponse<T>>(url, data);
  return response.data;
}

/**
 * Helper tipado para DELETE requests.
 */
export async function apiDelete<T>(
  url: string,
): Promise<SuccessResponse<T>> {
  const response = await api.delete<SuccessResponse<T>>(url);
  return response.data;
}

/**
 * Upload de arquivo (foto/audio) com multipart/form-data.
 * Retorna URL do arquivo no servidor.
 */
export async function apiUpload(
  uri: string,
  type: string,
  name: string,
): Promise<SuccessResponse<{ url: string; thumbnail_url?: string }>> {
  const formData = new FormData();
  formData.append('file', {
    uri,
    type,
    name,
  } as unknown as Blob);

  const response = await api.post('/upload', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    timeout: 60000, // Upload pode demorar mais
  });

  return response.data;
}

export default api;
