import type { ChallengeType } from '../types';
import { HelpCircle, Code2, Layers, Check } from 'lucide-react';

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
    title: 'Architecture',
    description: 'Résolvez des problèmes de conception de systèmes.',
    icon: Layers,
  },
];

interface Props {
  selectedMode: ChallengeType;
  onSelect: (mode: ChallengeType) => void;
}

export const SetupModeCards = ({ selectedMode, onSelect }: Props) => (
  <div className="grid grid-cols-1 md:grid-cols-3 gap-4 sm:gap-5 text-left">
    {MODES.map((mode) => {
      const isSelected = selectedMode === mode.id;
      const Icon = mode.icon;

      return (
        <div
          key={mode.id}
          onClick={() => onSelect(mode.id)}
          className={`group relative rounded-2xl border-[0.5px] p-6 transition-all duration-200 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas flex flex-col justify-between select-none ${
            isSelected
              ? 'bg-surface border-navy-900 shadow-elevated ring-1 ring-navy-900'
              : 'bg-surface border-card-border hover:border-border-strong hover:shadow-panel'
          }`}
        >
          <div className="space-y-4">
            {/* Header with minimal monochrome icon */}
            <div className="flex items-center justify-between">
              <div
                className={`w-9 h-9 rounded-xl flex items-center justify-center border transition-colors ${
                  isSelected
                    ? 'bg-navy-100 border-navy-200 text-navy-900'
                    : 'bg-canvas-subtle border-border text-ink-muted group-hover:text-navy-900'
                }`}
              >
                <Icon className="w-4 h-4 stroke-[2]" />
              </div>

              <div
                className={`w-4 h-4 rounded-full border flex items-center justify-center transition-all ${
                  isSelected
                    ? 'border-navy-900 bg-navy-900 dark:bg-navy-800 text-white'
                    : 'border-border bg-surface'
                }`}
              >
                {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
              </div>
            </div>

            <div className="space-y-1.5">
              <h3
                className={`font-serif text-xl font-bold transition-colors ${
                  isSelected ? 'text-navy-900' : 'text-ink'
                }`}
              >
                {mode.title}
              </h3>
              <p className="text-xs text-ink-warm leading-relaxed">
                {mode.description}
              </p>
            </div>
          </div>
        </div>
      );
    })}
  </div>
);
