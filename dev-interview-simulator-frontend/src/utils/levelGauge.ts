import type { EstimatedLevel } from './levelEstimation';
import { AT_LEVEL_RATE, STRONG_RATE } from './levelEstimation';

export type GaugeZone = 'junior' | 'confirmed' | 'senior';

export interface GaugeLevel {
  position: number;
  label: string;
}

const LEVEL_POSITIONS: readonly number[] = [10, 25, 45, 62, 85];

const ZONE_LABELS: Record<GaugeZone, string> = {
  junior: 'Junior',
  confirmed: 'Confirmé',
  senior: 'Senior',
};

const zoneOf = (position: number): GaugeZone =>
  position <= 33 ? 'junior' : position <= 66 ? 'confirmed' : 'senior';

export const maxLevelIndexForRate = (rate: number): number => {
  if (rate >= STRONG_RATE) return 4;
  return rate >= AT_LEVEL_RATE ? 3 : 1;
};

export const toGaugeLevel = (level: EstimatedLevel): GaugeLevel => {
  const raw = LEVEL_POSITIONS[level.index] ?? 10;
  const position = Math.min(97, Math.max(3, raw));

  return { position, label: ZONE_LABELS[zoneOf(position)] };
};
