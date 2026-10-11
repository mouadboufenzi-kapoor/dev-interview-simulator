import { apiClient } from './client';
import { clearStoredAuth } from './authStorage';

export interface LoginRequest {
  usernameOrEmail: string;
  password: string;
}

export interface RegisterRequest {
  username: string;
  email: string;
  password: string;
}

export interface AuthResponse {
  token: string;
  userId: number;
  username: string;
  email: string;
  role: string;
}

const persistAuth = (authResponse: AuthResponse) => {
  localStorage.setItem('jwt_token', authResponse.token);
  localStorage.setItem('user', JSON.stringify(authResponse));
};

const normalizeAuthResponse = (response: unknown): AuthResponse => {
  if (!response || typeof response !== 'object') {
    throw new Error('Réponse d’authentification invalide.');
  }

  const data = response as Record<string, unknown>;
  const token = typeof data.token === 'string' ? data.token.trim() : '';
  const username = typeof data.username === 'string' ? data.username.trim() : '';
  const email = typeof data.email === 'string' ? data.email.trim() : '';
  const role = typeof data.role === 'string' ? data.role.trim() : '';
  const rawUserId = data.userId ?? data.id;
  const userId = typeof rawUserId === 'number'
    ? rawUserId
    : typeof rawUserId === 'string' && rawUserId.trim() !== ''
      ? Number(rawUserId)
      : NaN;

  if (!token || !username || !email || !role) {
    throw new Error('Réponse d’authentification invalide.');
  }

  return {
    token,
    userId: Number.isFinite(userId) && userId > 0 ? userId : 0,
    username,
    email,
    role,
  };
};

export const authApi = {
  login: async (request: LoginRequest): Promise<AuthResponse> => {
    clearStoredAuth();
    const response = await apiClient.post<AuthResponse>('/auth/login', request);
    let authResponse: AuthResponse;
    try {
      authResponse = normalizeAuthResponse(response.data);
    } catch (error) {
      clearStoredAuth();
      throw error;
    }
    persistAuth(authResponse);
    return authResponse;
  },
  
  register: async (request: RegisterRequest): Promise<AuthResponse> => {
    clearStoredAuth();
    const response = await apiClient.post<AuthResponse>('/auth/register', request);
    let authResponse: AuthResponse;
    try {
      authResponse = normalizeAuthResponse(response.data);
    } catch (error) {
      clearStoredAuth();
      throw error;
    }
    persistAuth(authResponse);
    return authResponse;
  },
  
  logout: () => {
    clearStoredAuth();
  }
};
