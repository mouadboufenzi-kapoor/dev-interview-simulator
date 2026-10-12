import type { FormEvent } from 'react';
import type { Category, ChallengeType, DifficultyLevel, Skill } from '../types';
import { Button } from './common/Button';
import { PageTitle } from './common/PageTitle';
import { SetupModeCards } from './SetupModeCards';
import { SetupTopics } from './SetupTopics';
import { ArrowLeft, ArrowRight } from 'lucide-react';

interface TopicsProps {
  categories: Category[];
  skills: Skill[];
  selectedCategoryIds: number[];
  selectedSkillIds: number[];
  onToggleCategory: (id: number) => void;
  onToggleSkill: (id: number) => void;
  onClear: () => void;
  loading: boolean;
  error: string | null;
}

interface Props {
  selectedProfileLabel?: string;
  onBack: () => void;
  loading: boolean;
  onSubmit: (e: FormEvent) => void;
  selectedMode: ChallengeType;
  onSelectMode: (mode: ChallengeType) => void;
  selectedDifficulty: DifficultyLevel;
  onSelectDifficulty: (difficulty: DifficultyLevel) => void;
  questionCount: number;
  onQuestionCountChange: (count: number) => void;
  topics: TopicsProps;
}

const DIFFICULTIES: { id: DifficultyLevel; label: string }[] = [
  { id: 'JUNIOR', label: 'Junior' },
  { id: 'INTERMEDIATE', label: 'Intermédiaire' },
  { id: 'ADVANCED', label: 'Senior' },
];

export const SetupConfigStep = ({
  selectedProfileLabel,
  onBack,
  loading,
  onSubmit,
  selectedMode,
  onSelectMode,
  selectedDifficulty,
  onSelectDifficulty,
  questionCount,
  onQuestionCountChange,
  topics,
}: Props) => (
  <div className="screen-transition w-full min-h-[calc(80vh-80px)] flex flex-col items-center justify-center py-10 sm:py-16 px-4">
    <div className="w-full max-w-3xl mx-auto space-y-12 sm:space-y-14 text-center">
      <button
        type="button"
        onClick={onBack}
        className="mx-auto flex items-center gap-2 text-xs font-medium text-ink-muted hover:text-navy-900 transition-colors cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
      >
        <ArrowLeft className="w-3.5 h-3.5" />
        Changer de profil
      </button>

      {/* Brand & Main Headline */}
      <div className="space-y-4">
        <p className="font-sans text-xs uppercase tracking-[0.2em] text-ink-muted font-semibold">
          Dev Interview Simulator
        </p>
        <PageTitle size="hero-compact">
          Préparez votre prochain <br className="hidden sm:inline" />
          entretien technique.
        </PageTitle>
        <p className="text-sm sm:text-base text-ink-secondary font-sans max-w-md mx-auto leading-relaxed">
          {selectedProfileLabel
            ? `Configurez votre entraînement ${selectedProfileLabel.toLowerCase()} en conditions réelles.`
            : "Choisissez un mode d'évaluation pour vous entraîner en conditions réelles."}
        </p>
      </div>

      <form onSubmit={onSubmit} className="space-y-10 sm:space-y-12">
        <SetupModeCards selectedMode={selectedMode} onSelect={onSelectMode} />

        {/* Minimalist Configuration Bar (Level + Options) */}
        <div className="flex flex-col items-center justify-center gap-6 pt-2">
          <div className="flex flex-wrap items-center justify-center gap-2 text-xs font-sans">
            <span className="text-ink-muted font-medium mr-2">Niveau attendu :</span>
            <div className="inline-flex p-1 rounded-xl bg-surface border border-border shadow-card">
              {DIFFICULTIES.map((diff) => {
                const isDiffSelected = selectedDifficulty === diff.id;
                return (
                  <button
                    key={diff.id}
                    type="button"
                    onClick={() => onSelectDifficulty(diff.id)}
                    className={`px-3.5 py-1.5 rounded-lg text-xs font-medium transition-all cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${
                      isDiffSelected
                        ? 'bg-navy-900 dark:bg-navy-800 text-white shadow-sm'
                        : 'text-ink-secondary hover:text-ink hover:bg-canvas-subtle'
                    }`}
                  >
                    {diff.label}
                  </button>
                );
              })}
            </div>
          </div>

          <SetupTopics {...topics} />

          {/* Architecture step options (discreetly visible if ARCHITECTURE) */}
          {selectedMode === 'ARCHITECTURE' && (
            <div className="inline-flex items-center gap-3 text-xs font-sans text-ink-warm bg-surface border border-border px-4 py-2 rounded-xl">
              <span>Scénario :</span>
              <div className="flex items-center gap-1">
                {[3, 4, 5].map((count) => (
                  <button
                    key={count}
                    type="button"
                    onClick={() => onQuestionCountChange(count)}
                    className={`w-6 h-6 rounded text-xs font-mono font-semibold transition-colors cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${
                      questionCount === count
                        ? 'bg-navy-900 dark:bg-navy-800 text-white'
                        : 'text-ink-warm hover:bg-canvas-subtle'
                    }`}
                  >
                    {count}
                  </button>
                ))}
                <span className="text-[11px] text-ink-muted ml-1">étapes</span>
              </div>
            </div>
          )}

          {/* Prominent Action Button (Rosewood Accent: crimson-700) */}
          <div className="pt-2">
            <Button
              type="submit"
              variant="primary"
              size="lg"
              loading={loading}
              rightIcon={<ArrowRight className="w-4 h-4" />}
              className="px-9 py-3 text-base font-semibold tracking-wide"
            >
              Commencer l'entraînement
            </Button>
          </div>
        </div>
      </form>
    </div>
  </div>
);
