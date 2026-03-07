import axios from 'axios';
import type { AxiosError, InternalAxiosRequestConfig } from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || '/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor de request — adiciona JWT
api.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const token = localStorage.getItem('egranja_token');
  if (token && config.headers) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Interceptor de response — refresh token automático
let isRefreshing = false;
let failedQueue: Array<{
  resolve: (token: string) => void;
  reject: (error: AxiosError) => void;
}> = [];

const processQueue = (error: AxiosError | null, token: string | null = null) => {
  failedQueue.forEach((prom) => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve(token!);
    }
  });
  failedQueue = [];
};

api.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

    if (error.response?.status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({
            resolve: (token: string) => {
              if (originalRequest.headers) {
                originalRequest.headers.Authorization = `Bearer ${token}`;
              }
              resolve(api(originalRequest));
            },
            reject,
          });
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      const refreshToken = localStorage.getItem('egranja_refresh_token');
      if (!refreshToken) {
        localStorage.removeItem('egranja_token');
        localStorage.removeItem('egranja_refresh_token');
        localStorage.removeItem('egranja_usuario');
        window.location.href = '/login';
        return Promise.reject(error);
      }

      try {
        const { data } = await axios.post(
          `${import.meta.env.VITE_API_URL || '/api/v1'}/auth/refresh`,
          { refresh_token: refreshToken }
        );

        const newToken = data.token;
        localStorage.setItem('egranja_token', newToken);
        if (data.refresh_token) {
          localStorage.setItem('egranja_refresh_token', data.refresh_token);
        }

        processQueue(null, newToken);

        if (originalRequest.headers) {
          originalRequest.headers.Authorization = `Bearer ${newToken}`;
        }
        return api(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError as AxiosError, null);
        localStorage.removeItem('egranja_token');
        localStorage.removeItem('egranja_refresh_token');
        localStorage.removeItem('egranja_usuario');
        window.location.href = '/login';
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  }
);

export default api;

// ==================== Auth ====================
export const authService = {
  login: (login: string, senha: string) =>
    api.post('/auth/login', { login, senha }),
  logout: () => {
    localStorage.removeItem('egranja_token');
    localStorage.removeItem('egranja_refresh_token');
    localStorage.removeItem('egranja_usuario');
    window.location.href = '/login';
  },
};

// ==================== Dashboard ====================
export const dashboardService = {
  getIndicadores: () => api.get('/dashboard/indicadores'),
  getICAHistorico: () => api.get('/dashboard/ica-historico'),
  getPesoLotes: () => api.get('/dashboard/peso-lotes'),
  getAlertas: () => api.get('/dashboard/alertas'),
  getPrevisaoTempo: () => api.get('/dashboard/previsao-tempo'),
};

// ==================== Granjas ====================
export const granjaService = {
  listar: (params?: Record<string, unknown>) => api.get('/granjas', { params }),
  obter: (id: number) => api.get(`/granjas/${id}`),
  criar: (data: Record<string, unknown>) => api.post('/granjas', data),
  atualizar: (id: number, data: Record<string, unknown>) => api.put(`/granjas/${id}`, data),
  excluir: (id: number) => api.delete(`/granjas/${id}`),
  galpoes: (granjaId: number) => api.get(`/granjas/${granjaId}/galpoes`),
};

// ==================== Lotes ====================
export const loteService = {
  listar: (params?: Record<string, unknown>) => api.get('/lotes', { params }),
  obter: (id: number) => api.get(`/lotes/${id}`),
  criar: (data: Record<string, unknown>) => api.post('/lotes', data),
  atualizar: (id: number, data: Record<string, unknown>) => api.put(`/lotes/${id}`, data),
  pesagens: (loteId: number) => api.get(`/lotes/${loteId}/pesagens`),
  mortalidade: (loteId: number) => api.get(`/lotes/${loteId}/mortalidade`),
  racaoRecebimentos: (loteId: number) => api.get(`/lotes/${loteId}/racao/recebimentos`),
  racaoConsumo: (loteId: number) => api.get(`/lotes/${loteId}/racao/consumo`),
  agua: (loteId: number) => api.get(`/lotes/${loteId}/agua`),
  vacinacoes: (loteId: number) => api.get(`/lotes/${loteId}/vacinacoes`),
  medicamentos: (loteId: number) => api.get(`/lotes/${loteId}/medicamentos`),
  visitantes: (loteId: number) => api.get(`/lotes/${loteId}/visitantes`),
  financeiro: (loteId: number) => api.get(`/lotes/${loteId}/financeiro`),
};

// ==================== Produtores ====================
export const produtorService = {
  listar: (params?: Record<string, unknown>) => api.get('/usuarios', { params }),
  obter: (id: number) => api.get(`/usuarios/${id}`),
};

// ==================== IoT ====================
export const iotService = {
  galpoes: () => api.get('/iot/galpoes'),
  sensores: (galpaoId: number) => api.get(`/iot/galpoes/${galpaoId}/sensores`),
  leituras: (sensorId: number, params?: Record<string, unknown>) =>
    api.get(`/iot/sensores/${sensorId}/leituras`, { params }),
};

// ==================== Relatórios ====================
export const relatorioService = {
  fechamento: (loteId: number, formato: string) =>
    api.get(`/relatorios/fechamento/${loteId}`, {
      params: { formato },
      responseType: 'blob',
    }),
  comparativo: (loteIds: number[], formato: string) =>
    api.post(
      '/relatorios/comparativo',
      { lote_ids: loteIds, formato },
      { responseType: 'blob' }
    ),
  exportarCSV: (tipo: string, params?: Record<string, unknown>) =>
    api.get(`/relatorios/exportar/${tipo}`, {
      params,
      responseType: 'blob',
    }),
};

// ==================== Configurações ====================
export const configService = {
  getPerfil: () => api.get('/usuarios/perfil'),
  atualizarPerfil: (data: Record<string, unknown>) => api.put('/usuarios/perfil', data),
  alterarSenha: (senhaAtual: string, novaSenha: string) =>
    api.put('/usuarios/senha', { senha_atual: senhaAtual, nova_senha: novaSenha }),
};
