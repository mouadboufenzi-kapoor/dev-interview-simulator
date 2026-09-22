import { apiClient } from './client';
import type {
  Category,
  Skill,
  SimulationResponse,
  StartSimulationRequest,
  SubmitAnswerRequest,
  SubmitAnswerResponse,
  SimulationResultDTO,
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
    request: SubmitAnswerRequest
  ): Promise<SubmitAnswerResponse> => {
    const response = await apiClient.post<SubmitAnswerResponse>(
      `/simulations/${simulationId}/answers`,
      request
    );
    return response.data;
  },

    getSimulationResult: async (simulationId: number): Promise<SimulationResultDTO> => {
        const response = await apiClient.get<SimulationResultDTO>(`/simulations/${simulationId}/result`);
        return response.data;
  },
};