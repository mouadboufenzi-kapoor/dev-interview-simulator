import { apiBaseUrl, apiClient } from './client';
import type {
  Category,
  Skill,
  SimulationResponse,
  StartSimulationRequest,
  SubmitAnswerRequest,
  SubmitAnswerResponse,
  SimulationResultDTO,
  SimulationSummaryResponse,
} from '../types';

const postOnUnload = (path: string, guestAccessToken?: string | null): void => {
  const url = `${apiBaseUrl}${path}`;
  if (guestAccessToken) {
    if (typeof navigator.sendBeacon !== 'function') return;
    navigator.sendBeacon(url, new URLSearchParams({ guestAccessToken }));
    return;
  }
  const authToken = localStorage.getItem('jwt_token');
  if (!authToken) return;
  void fetch(url, {
    method: 'POST',
    keepalive: true,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${authToken}`,
    },
    body: JSON.stringify({}),
  }).catch((error) => {
    console.error('Envoi de la requête de sortie impossible', error);
  });
};

export const simulationApi = {
  // Récupérer la liste des catégories
  getCategories: async (): Promise<Category[]> => {
    const response = await apiClient.get<Category[]>('/categories');
    return response.data;
  },

  // Récupérer la liste des compétences
  getSkills: async (): Promise<Skill[]> => {
    const response = await apiClient.get<Skill[]>('/skills');
    return response.data;
  },

  // Démarrer une nouvelle simulation
  startSimulation: async (request: StartSimulationRequest): Promise<SimulationResponse> => {
    const response = await apiClient.post<SimulationResponse>('/simulations', request);
    return response.data;
  },

  claimSimulations: async (tokens: string[]): Promise<number> => {
    if (tokens.length === 0) return 0;
    const response = await apiClient.post<{ claimed: number }>('/simulations/claim', { tokens });
    return response.data.claimed;
  },

  abandonSimulationOnUnload: (simulationId: number, guestAccessToken?: string | null): void => {
    postOnUnload(`/simulations/${simulationId}/abandon`, guestAccessToken);
  },

  markSimulationSeenOnUnload: (simulationId: number, guestAccessToken?: string | null): void => {
    postOnUnload(`/simulations/${simulationId}/seen`, guestAccessToken);
  },

  // Soumettre une réponse à une question
  submitAnswer: async (
    simulationId: number,
    request: SubmitAnswerRequest,
    guestAccessToken?: string | null
  ): Promise<SubmitAnswerResponse> => {
    const response = await apiClient.post<SubmitAnswerResponse>(
      `/simulations/${simulationId}/answers`,
      request,
      guestAccessToken ? { headers: { 'X-Guest-Access-Token': guestAccessToken } } : undefined
    );
    return response.data;
  },

    getSimulationResult: async (
      simulationId: number,
      guestAccessToken?: string | null
    ): Promise<SimulationResultDTO> => {
        const response = await apiClient.get<SimulationResultDTO>(
          `/simulations/${simulationId}/result`,
          guestAccessToken ? { headers: { 'X-Guest-Access-Token': guestAccessToken } } : undefined
        );
        return response.data;
  },

  // Clore une session (statut COMPLETED) — indispensable pour que les
  // compteurs « simulations terminées » du dashboard soient cohérents.
  completeSimulation: async (
    simulationId: number,
    guestAccessToken?: string | null
  ): Promise<SimulationSummaryResponse> => {
    const response = await apiClient.post<SimulationSummaryResponse>(
      `/simulations/${simulationId}/complete`,
      undefined,
      guestAccessToken ? { headers: { 'X-Guest-Access-Token': guestAccessToken } } : undefined
    );
    return response.data;
  },

  // Marquer une session quittée en cours de route comme ABANDONNÉE.
  abandonSimulation: async (
    simulationId: number,
    guestAccessToken?: string | null
  ): Promise<SimulationSummaryResponse> => {
    const response = await apiClient.post<SimulationSummaryResponse>(
      `/simulations/${simulationId}/abandon`,
      undefined,
      guestAccessToken ? { headers: { 'X-Guest-Access-Token': guestAccessToken } } : undefined
    );
    return response.data;
  },
};