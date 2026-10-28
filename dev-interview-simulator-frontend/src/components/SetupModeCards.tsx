import type { ChallengeType } from '../types';
import { HelpCircle, Code2, Layers, ListOrdered } from 'lucide-react';

interface ModeCardConfig {
  id: ChallengeType;
  title: string;
  description: string;
  icon: typeof HelpCircle;
}

const MODES: ModeCardConfig[] = [
  {
    id: 'SITUATIONAL_QCM',
    title: 'QCM',
    description: 'Testez vos connaissances et vos réflexes d’ingénieur.',
    icon: HelpCircle,
  },
  {
    id: 'CODE_REVIEW',
    title: 'Code Review',
    description: 'Analysez du code source comme en entretien technique.',
    icon: Code2,
  },
  {
    id: 'ARCHITECTURE',
    title: 'Mise en situation',
    description: 'Résolvez des problèmes de conception de systèmes.',
    icon: Layers,
  },
  {
    id: 'SEQUENTIAL_REASONING',
    title: 'Raisonnement',
    description: "Remettez des étapes dans l'ordre logique (debug, test, pipeline...).",
    icon: ListOrdered,
  },
];

interface Props {
  selectedMode: ChallengeType;
  onSelect: (mode: ChallengeType) => void;
}

export const SetupModeCards = ({ selectedMode, onSelect }: Props) => (
  <div className="grid grid-cols-1 gap-2.5 text-left md:grid-cols-2 md:gap-3 lg:grid-cols-4 lg:gap-4">
    {MODES.map((mode, index) => {
      const isSelected = selectedMode === mode.id;
      const Icon = mode.icon;

      return (
        <button
          key={mode.id}
          type="button"
          onClick={() => onSelect(mode.id)}
          aria-pressed={isSelected}
          className={`group relative w-full rounded border-2 p-4 text-left transition-all duration-150 cursor-pointer focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg flex flex-col justify-between select-none min-h-11 ${
            isSelected
              ? 'bg-selected border-border shadow-elevated'
              : 'bg-card border-border hover:border-brand hover:shadow-card'
          }`}
        >
          <div className="space-y-3">
            {/* Icône monochrome + numéro de carte (mono, spec §10) */}
            <div className="flex items-center justify-between">
              <div
                className={`w-9 h-9 rounded flex items-center justify-center border-2 transition-colors ${
                  isSelected
                    ? 'bg-card border-border text-text'
                    : 'bg-bg border-border text-muted group-hover:text-text'
                }`}
              >
                <Icon className="w-4 h-4 stroke-[2]" />
              </div>

              <span className="font-mono text-[11px] uppercase tracking-[0.06em] text-muted">
                {String(index + 1).padStart(2, '0')}
              </span>
            </div>

            <div className="space-y-1">
              <h3 className="font-serif text-lg font-bold text-text">
                {mode.title}
              </h3>
              <p className="text-xs text-muted leading-relaxed">
                {mode.description}
              </p>
            </div>
          </div>
        </button>
      );
    })}
  </div>
);
