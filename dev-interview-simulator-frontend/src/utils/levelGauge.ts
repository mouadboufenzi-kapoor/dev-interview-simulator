import type { EstimatedLevel } from './levelEstimation';

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

export const toGaugeLevel = (level: EstimatedLevel): GaugeLevel => {
  const raw = LEVEL_POSITIONS[level.index] ?? 10;
  const position = Math.min(97, Math.max(3, raw));

  return { position, label: ZONE_LABELS[zoneOf(position)] };
};
