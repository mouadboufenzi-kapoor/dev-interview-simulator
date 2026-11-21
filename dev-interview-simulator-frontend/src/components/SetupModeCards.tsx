import type { ChallengeType } from '../types';

interface ModeCardConfig {
  id: ChallengeType;
  title: string;
  description: string;
}

const MODES: ModeCardConfig[] = [
  {
    id: 'SITUATIONAL_QCM',
    title: 'QCM',
    description: 'Questions à choix',
  },
  {
    id: 'CODE_REVIEW',
    title: 'Code Review',
    description: 'Repérer les défauts',
  },
  {
    id: 'ARCHITECTURE',
    title: 'Mises en situation',
    description: 'Cas réels',
  },
  {
    id: 'SEQUENTIAL_REASONING',
    title: 'Raisonnement séquentiel',
    description: 'Étapes dans l’ordre',
  },
];

interface Props {
  selectedMode: ChallengeType;
  onSelect: (mode: ChallengeType) => void;
}

export const SetupModeCards = ({ selectedMode, onSelect }: Props) => (
  <div className="grid grid-cols-2 gap-2 text-left sm:gap-3">
    {MODES.map((mode) => {
      const isSelected = selectedMode === mode.id;
      const Icon = mode.icon;

      return (
        <button
          key={mode.id}
          type="button"
          onClick={() => onSelect(mode.id)}
          aria-pressed={isSelected}
          className={`group relative w-full rounded border-2 p-3 text-left transition-all duration-150 cursor-pointer focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg flex flex-col justify-between select-none min-h-[72px] sm:p-4 ${
            isSelected
              ? 'bg-selected border-border shadow-elevated'
              : 'bg-card border-border hover:border-brand hover:shadow-card'
          }`}
        >
          <div className="space-y-1">
              <h3 className="font-serif text-[15px] font-bold text-text sm:text-lg">
                {mode.title}
              </h3>
              <p className="text-[13px] text-muted leading-tight sm:text-xs sm:leading-relaxed">
                {mode.description}
              </p>
          </div>
        </button>
      );
    })}
  </div>
);
