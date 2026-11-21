import type { SimulationResponse } from '../types';

const STORAGE_KEY = 'guest_simulations';
const MAX_AGE_MS = 30 * 24 * 60 * 60 * 1000;

export interface StoredGuestSimulation {
  simulationId: number;
  guestAccessToken: string;
  createdAt: string;
}

const isStoredGuestSimulation = (value: unknown): value is StoredGuestSimulation => {
  if (!value || typeof value !== 'object') return false;
  const entry = value as Record<string, unknown>;
  return typeof entry.simulationId === 'number'
    && Number.isFinite(entry.simulationId)
    && typeof entry.guestAccessToken === 'string'
    && entry.guestAccessToken.trim() !== ''
    && typeof entry.createdAt === 'string';
};

const readEntries = (): StoredGuestSimulation[] => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed: unknown = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed.filter(isStoredGuestSimulation) : [];
  } catch (error) {
    console.error('Lecture des simulations invité impossible', error);
    return [];
  }
};

const isRecent = (entry: StoredGuestSimulation): boolean => {
  const createdAt = Date.parse(entry.createdAt);
  return Number.isFinite(createdAt) && Date.now() - createdAt <= MAX_AGE_MS;
};

const writeEntries = (entries: StoredGuestSimulation[]): void => {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
  } catch (error) {
    console.error('Écriture des simulations invité impossible', error);
  }
};

export const pruneGuestSimulations = (): StoredGuestSimulation[] => {
  const recent = readEntries().filter(isRecent);
  writeEntries(recent);
  return recent;
};

export const saveGuestSimulation = (simulation: SimulationResponse): void => {
  const { guestAccessToken } = simulation;
  if (!guestAccessToken) return;
  const entries = pruneGuestSimulations().filter(
    (entry) => entry.simulationId !== simulation.id
      && entry.guestAccessToken !== guestAccessToken
  );
  entries.push({
    simulationId: simulation.id,
    guestAccessToken,
    createdAt: new Date().toISOString(),
  });
  writeEntries(entries);
};

export const readGuestSimulationTokens = (): string[] =>
  pruneGuestSimulations().map((entry) => entry.guestAccessToken);

export const clearGuestSimulations = (): void => {
  try {
    localStorage.removeItem(STORAGE_KEY);
  } catch (error) {
    console.error('Suppression des simulations invité impossible', error);
  }
};
