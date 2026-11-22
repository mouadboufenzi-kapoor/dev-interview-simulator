import type { EstimatedLevel } from '../utils/levelEstimation';
import { toGaugeLevel } from '../utils/levelGauge';

interface Props {
  level: EstimatedLevel;
}

export const LevelGauge = ({ level }: Props) => {
  const { position, label } = toGaugeLevel(level);

  return (
    <div className="mt-3 md:mt-0">
      <div className="flex items-center justify-between gap-3">
        <p className="font-mono text-xs font-bold uppercase tracking-[0.08em] text-brand">
          Niveau estimé
        </p>
        <span className="font-sans text-[12px] font-bold text-accent-text">{label}</span>
      </div>

      <div className="relative mt-2" role="img" aria-label={`Niveau estimé : ${label}`}>
        <div className="h-3 overflow-hidden rounded-full border-2 border-[#0a2342]">
          <div className="flex h-full">
            <div className="h-full w-1/3 bg-[#d9e2f1]" />
            <div className="h-full w-1/3 bg-[#9db1d1]" />
            <div className="h-full w-1/3 bg-brand" />
          </div>
        </div>
        <span
          aria-hidden="true"
          className="absolute top-1/2 h-[22px] w-[10px] -translate-x-1/2 -translate-y-1/2 rounded-[4px] border-2 border-[#0a2342] bg-accent"
          style={{ left: `${position}%` }}
        />
      </div>

      <div className="mt-1 flex justify-between gap-1 font-mono text-[10px] uppercase tracking-[0.08em] text-ink-secondary">
        <span>Junior</span>
        <span>Confirmé</span>
        <span>Senior</span>
      </div>
    </div>
  );
};
