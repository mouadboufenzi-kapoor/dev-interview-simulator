import { apiClient } from './client';

export interface UserStatEntry {
  id: number;
  name: string;
  answered: number;
  correct: number;
  successRate: number;
}

export interface UserWeakPointEntry extends UserStatEntry {
  source: 'CATEGORY' | 'SKILL';
}

export interface UserTypeStat {
  type: string;
  answered: number;
  correct: number;
  successRate: number;
}

export interface UserRecentSimulation {
  id: number;
  mode?: string;
  difficulty?: string;
  totalQuestions: number;
  correctAnswers: number;
  totalScore: number;
  status?: string;
  startedAt?: string;
}

export interface PagedSimulations {
  content: UserRecentSimulation[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
}

export interface UserStats {
  totalSimulations: number;
  completedSimulations: number;
  totalAnswers: number;
  correctAnswers: number;
  globalSuccessRate?: number | null;
  recentSuccessRate?: number | null;
  previousSuccessRate?: number | null;
  trend?: string | null;
  averageSuccessRate?: number | null;
  bestSuccessRate?: number | null;
  byCategory: UserStatEntry[];
  bySkill?: UserStatEntry[];
  byType: UserTypeStat[];
  weakPoints: UserWeakPointEntry[];
  simulations: PagedSimulations;
}

export const userStatsApi = {
  getStats: async (page = 0): Promise<UserStats> => {
    const { data } = await apiClient.get<UserStats>('/user/stats', { params: { page } });
    return data;
  },
};
