import { apiClient } from './client';
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