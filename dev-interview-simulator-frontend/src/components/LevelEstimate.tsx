import type { EstimatedLevel } from '../utils/levelEstimation';

interface Props {
  level: EstimatedLevel;
  phrase?: string;
  note?: string;
}

export const LevelEstimate = ({ level, phrase, note }: Props) => (
  <div className="min-w-0">
    <div className="flex flex-wrap items-center gap-x-2 gap-y-1">
      <span className="font-mono text-[10px] font-semibold uppercase tracking-wider text-ink-muted">
        Niveau estimé
      </span>
      <span className="rounded-lg bg-navy-100 px-2 py-0.5 font-serif text-sm font-bold text-navy-900">
        {level.label}
      </span>
      {note && <span className="text-[10px] leading-tight text-ink-muted">{note}</span>}
    </div>

    {phrase && (
      <p className="mt-1.5 break-words text-xs leading-snug text-ink-secondary">{phrase}</p>
    )}
  </div>
);
