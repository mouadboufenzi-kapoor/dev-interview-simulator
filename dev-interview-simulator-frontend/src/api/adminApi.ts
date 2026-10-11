import { apiClient  } from './client'; 
import type { ChallengeType } from '../types';

export interface AdminChallengeOptionRequest {
  id?: number;
  content: string;
  correct: boolean;
  severity?: string;
  explanation?: string;
  displayOrder: number;
}

export interface AdminChallengeRequest {
  title: string;
  type: ChallengeType;
  difficulty: string;
  selectionType: string;
  context?: string;
  question: string;
  codeSnippet?: string;
  codeLanguage?: string;
  revealedInformation?: string;
  tradeoff?: string;
  scenarioId?: number;
  stepOrder?: number;
  explanation?: string;
  estimatedTimeSeconds?: number;
  points: number;
  categoryIds: number[];
  skillIds: number[];
  profileIds: number[];
  options: AdminChallengeOptionRequest[];
}

export interface AdminChallengeResponse {
  id: number;
  title: string;
  type: ChallengeType;
  difficulty: string;
  selectionType: string;
  status: string;
  context?: string;
  question: string;
  codeSnippet?: string;
  codeLanguage?: string;
  revealedInformation?: string;
  tradeoff?: string;
  scenarioId?: number | null;
  stepOrder?: number | null;
  explanation?: string;
  estimatedTimeSeconds?: number;
  points: number;
  categoryIds?: number[];
  skillIds?: number[];
  profileIds?: number[];
  options: AdminChallengeOptionRequest[];
}

export interface AdminScenario {
  id: number;
  title: string;
  description?: string;
  mode: string;
  active: boolean;
  stepCount: number;
}

export interface AdminScenarioStep {
  challengeId: number;
  title: string;
  stepOrder?: number;
}

export const scenarioApi = {
  getScenarios: async (): Promise<AdminScenario[]> => {
    const { data } = await apiClient.get('/admin/scenarios');
    return data;
  },

  getScenarioSteps: async (id: number): Promise<AdminScenarioStep[]> => {
    const { data } = await apiClient.get(`/admin/scenarios/${id}/steps`);
    return data;
  },

  createScenario: async (request: { title: string; description?: string }): Promise<AdminScenario> => {
    const { data } = await apiClient.post('/admin/scenarios', request);
    return data;
  }
};

export interface Page<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
}

export const adminApi = {
  searchChallenges: async (params?: {
    search?: string;
    status?: string;
    type?: string;
    difficulty?: string;
    profileId?: number;
    page?: number;
    size?: number;
  }): Promise<Page<AdminChallengeResponse>> => {
    const { data } = await apiClient.get('/admin/challenges', { params });
    return data;
  },

  getChallenge: async (id: number): Promise<AdminChallengeResponse> => {
    const { data } = await apiClient.get(`/admin/challenges/${id}`);
    return data;
  },

  createChallenge: async (request: AdminChallengeRequest): Promise<AdminChallengeResponse> => {
    const { data } = await apiClient.post('/admin/challenges', request);
    return data;
  },

  updateChallenge: async (id: number, request: AdminChallengeRequest): Promise<AdminChallengeResponse> => {
    const { data } = await apiClient.put(`/admin/challenges/${id}`, request);
    return data;
  },

  changeStatus: async (id: number, status: string): Promise<AdminChallengeResponse> => {
    const { data } = await apiClient.patch(`/admin/challenges/${id}/status`, null, { params: { status } });
    return data;
  }
};
