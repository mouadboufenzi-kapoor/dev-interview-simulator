import { apiClient } from './client';

export interface Profile {
  id: number;
  name: string;
  description: string;
  allowedTypes?: string[];
}

export const profileApi = {
  getProfiles: async (): Promise<Profile[]> => {
    const response = await apiClient.get<Profile[]>('/profiles');
    return response.data;
  },
};
