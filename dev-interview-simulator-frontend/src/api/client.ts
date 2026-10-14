import axios from 'axios';
import { clearStoredAuth } from './authStorage';

// URL de l'API : surchargeable par VITE_API_URL (prod). Le chemin /api est
// toujours requis — le backend mappe toutes les routes sous /api/**.
const rawApiUrl = import.meta.env.VITE_API_URL ?? 'http://localhost:8080/api';

export const apiClient = axios.create({
  baseURL: rawApiUrl.replace(/\/$/, ''),
  headers: {
    'Content-Type': 'application/json',
  },
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('jwt_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401 || error.response?.status === 403) {
      clearStoredAuth();
    }
    return Promise.reject(error);
  }
);
