import type { FormEvent } from 'react';
import type { Category, ChallengeType, DifficultyLevel, Skill } from '../types';
import { Button } from './common/Button';
import { PageTitle } from './common/PageTitle';
import { SetupModeCards } from './SetupModeCards';
import { SetupTopics } from './SetupTopics';
import { ArrowRight } from 'lucide-react';
import { trackEvent } from '../api/events';

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
  loading: boolean;
  onSubmit: (e: FormEvent) => void;
  selectedMode: ChallengeType;
  onSelectMode: (mode: ChallengeType) => void;
  selectedDifficulty: DifficultyLevel;
  onSelectDifficulty: (difficulty: DifficultyLevel) => void;
  topics: TopicsProps;
}

const DIFFICULTIES: { id: DifficultyLevel; label: string }[] = [
  { id: 'JUNIOR', label: 'Junior' },
  { id: 'INTERMEDIATE', label: 'Confirmé' },
  { id: 'ADVANCED', label: 'Senior' },
];

const MODE_LABELS: Record<ChallengeType, string> = {
  SITUATIONAL_QCM: 'QCM',
  CODE_REVIEW: 'Code review',
  ARCHITECTURE: 'Mises en situation',
  SEQUENTIAL_REASONING: 'Raisonnement séquentiel',
  PROBLEM_SOLVING: 'Résolution',
};

const PERSONALIZED_QUESTION_COUNT = 10;

export const SetupConfigStep = ({
  loading,
  onSubmit,
  selectedMode,
  onSelectMode,
  selectedDifficulty,
  onSelectDifficulty,
  topics,
}: Props) => {
  const selectedTechnologyNames = [
    ...topics.categories
      .filter((category) => topics.selectedCategoryIds.includes(category.id))
      .map((category) => category.name),
  ];
  const technologySummary = selectedTechnologyNames.length > 0
    ? selectedTechnologyNames.join(', ')
    : 'Toutes technologies';
  const difficultyLabel =
    DIFFICULTIES.find((difficulty) => difficulty.id === selectedDifficulty)?.label
    ?? 'Junior';

  return (
    <div className="screen-transition w-full px-4 py-4 sm:px-6 sm:py-5">
      <div className="mx-auto w-full max-w-[640px]">
        <PageTitle size="hero-compact" className="whitespace-nowrap text-center text-[23px] sm:text-4xl lg:text-5xl">
          Configure ton entraînement
        </PageTitle>

        <form onSubmit={onSubmit} className="mt-5 pb-24 sm:pb-0">
          <section className="rounded border-2 border-border bg-card p-5 text-left shadow-card space-y-5 sm:space-y-5">
            <h2 className="text-xs font-semibold uppercase tracking-wider text-muted">
              Niveau visé
            </h2>
            <div role="group" aria-label="Niveau visé" className="mt-2 grid grid-cols-3 gap-2">
              {DIFFICULTIES.map((difficulty) => (
                <button
                  key={difficulty.id}
                  type="button"
                  onClick={() => {
                    trackEvent('config_level_selected', { difficulty: difficulty.id });
                    onSelectDifficulty(difficulty.id);
                  }}
                  aria-pressed={selectedDifficulty === difficulty.id}
                  className={`min-h-11 rounded border-2 px-2 text-sm font-semibold ${
                    selectedDifficulty === difficulty.id
                      ? 'border-border bg-brand text-cta-text shadow-[2px_2px_0_var(--color-shadow)]'
                      : 'border-border bg-card text-text'
                  }`}
                >
                  {difficulty.label}
                </button>
              ))}
            </div>

            <h2 className="text-xs font-semibold uppercase tracking-wider text-muted">
              Challenge
            </h2>
            <div>
              <SetupModeCards
                selectedMode={selectedMode}
                onSelect={(mode) => {
                  trackEvent('config_mode_selected', { mode });
                  onSelectMode(mode);
                }}
              />
            </div>

            <div>
              <SetupTopics {...topics} />
            </div>

            <p className="border-t border-border pt-3 text-xs text-muted">
              {PERSONALIZED_QUESTION_COUNT} questions · {MODE_LABELS[selectedMode]} · {difficultyLabel} · {technologySummary}
            </p>
          </section>

          <div className="fixed bottom-0 left-0 right-0 z-20 border-t-2 border-border bg-surface px-4 py-3 sm:static sm:mt-5 sm:border-0 sm:bg-transparent sm:p-0">
            <Button
              type="submit"
              variant="primary"
              size="lg"
              loading={loading}
              rightIcon={<ArrowRight className="h-4 w-4" />}
              fullWidth
              className="sm:w-[320px]"
            >
              Commencer
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};
