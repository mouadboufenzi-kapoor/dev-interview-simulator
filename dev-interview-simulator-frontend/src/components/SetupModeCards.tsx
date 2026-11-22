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

      return (
        <button
          key={mode.id}
          type="button"
          onClick={() => onSelect(mode.id)}
          aria-pressed={isSelected}
          className={`group relative flex min-h-[84px] w-full cursor-pointer select-none flex-col justify-between rounded border-2 px-3 py-3.5 text-left transition-all duration-150 focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg sm:min-h-[104px] sm:p-5 ${
            isSelected
              ? 'border-accent bg-card shadow-[3px_3px_0_var(--color-accent)]'
              : 'border-border bg-card hover:border-brand hover:shadow-card'
          }`}
        >
          <div className="space-y-1">
              <h3 className="font-serif text-[16px] font-bold leading-tight text-text sm:text-xl">
                {mode.title}
              </h3>
              <p className="text-[13px] text-muted leading-tight sm:text-sm sm:leading-relaxed">
                {mode.description}
              </p>
          </div>
        </button>
      );
    })}
  </div>
);
