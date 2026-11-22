const STORAGE_KEY = 'placement_seen_challenge_ids';

const readIds = (): number[] => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    const parsed: unknown = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed)
      ? [...new Set(parsed.filter((value): value is number =>
          typeof value === 'number' && Number.isInteger(value) && value > 0))]
      : [];
  } catch {
    return [];
  }
};

export const readPlacementSeenChallengeIds = (): number[] => readIds();

export const savePlacementSeenChallengeIds = (challengeIds: number[]): void => {
  const next = [...new Set([...readIds(), ...challengeIds])]
    .filter((id) => Number.isInteger(id) && id > 0);
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(next.slice(-100)));
  } catch {
    // Le placement reste fonctionnel si le stockage local est indisponible.
  }
};
