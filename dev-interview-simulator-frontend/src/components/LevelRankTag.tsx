import type { ReactNode } from 'react';
import type { DifficultyLevel } from '../types';
import { DIFFICULTY_LABELS } from '../utils/resultAnalysis';

type Rank = 'silver' | 'gold' | 'diamond';

interface Props {
  level: DifficultyLevel;
}

const RANK_BY_LEVEL: Record<DifficultyLevel, Rank> = {
  JUNIOR: 'silver',
  INTERMEDIATE: 'gold',
  ADVANCED: 'diamond',
};

const RANK_ICONS: Record<Rank, ReactNode> = {
  silver: (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="#0a2342"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M12 3l7 3v5c0 5-3 8-7 10-4-2-7-5-7-10V6z" />
    </svg>
  ),
  gold: (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="#0a2342"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M12 3l2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z" />
    </svg>
  ),
  diamond: (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="#0a2342"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M6 4h12l4 5-10 11L2 9z" />
      <path d="M2 9h20M9 4l-2 5 5 11M15 4l2 5-5 11" />
    </svg>
  ),
};

export const LevelRankTag = ({ level }: Props) => {
  const rank = RANK_BY_LEVEL[level];
  const label = DIFFICULTY_LABELS[level];

  return (
    <span
      role="img"
      aria-label={`Niveau : ${label}`}
      className={`level-rank--${rank} relative inline-flex flex-shrink-0 items-center gap-1.5 overflow-hidden whitespace-nowrap rounded-[6px] border-2 border-[#0a2342] px-2.5 py-[5px] font-mono text-xs font-bold uppercase tracking-[0.06em] text-[#0a2342] shadow-[2px_2px_0_#0a2342]`}
    >
      {RANK_ICONS[rank]}
      <span>{label}</span>
    </span>
  );
};
