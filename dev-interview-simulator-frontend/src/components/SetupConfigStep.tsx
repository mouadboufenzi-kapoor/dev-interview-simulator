import type { FormEvent } from 'react';
import { useRef } from 'react';
import type { Category, ChallengeType, DifficultyLevel, Skill } from '../types';
import { Button } from './common/Button';
import { BackButton } from './common/BackButton';
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
  onBack: () => void;
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
  onBack,
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

  const submitRef = useRef<HTMLDivElement>(null);

  const scrollToSubmitIfNeeded = () => {
    window.requestAnimationFrame(() => {
      const target = submitRef.current;
      if (!target) return;
      const rect = target.getBoundingClientRect();
      if (rect.top >= 0 && rect.bottom <= window.innerHeight) return;
      target.scrollIntoView({
        behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches
          ? 'auto'
          : 'smooth',
        block: 'nearest',
      });
    });
  };

  return (
    <div className="screen-transition w-full px-4 py-3 sm:px-6 sm:py-5">
      <div className="mx-auto w-full max-w-[640px]">
        <div className="flex items-center gap-2 lg:gap-3">
          <BackButton onClick={onBack} />
          <PageTitle size="hero-compact" className="min-w-0 flex-1 text-center text-[20px] sm:text-[24px] lg:text-[30px]">
            Configure ton entraînement
          </PageTitle>
        </div>

        <form onSubmit={onSubmit} className="mt-3 sm:mt-5">
          <section className="rounded border-2 border-border bg-card p-4 text-left shadow-[4px_4px_0_var(--color-accent)] sm:p-5">
            <h2 className="text-[11px] font-semibold uppercase tracking-wider text-muted sm:text-xs">
              Niveau visé
            </h2>
            <div role="group" aria-label="Niveau visé" className="mt-1.5 grid grid-cols-3 gap-2 sm:mt-5">
              {DIFFICULTIES.map((difficulty) => (
                <button
                  key={difficulty.id}
                  type="button"
                  onClick={() => {
                    trackEvent('config_level_selected', { difficulty: difficulty.id });
                    onSelectDifficulty(difficulty.id);
                  }}
                  aria-pressed={selectedDifficulty === difficulty.id}
                  className={`min-h-10 rounded border-2 px-2 text-sm font-semibold sm:min-h-11 ${
                    selectedDifficulty === difficulty.id
                      ? 'border-border bg-brand text-cta-text shadow-[2px_2px_0_var(--color-accent)]'
                      : 'border-border bg-card text-text'
                  }`}
                >
                  {difficulty.label}
                </button>
              ))}
            </div>

            <h2 className="mt-3 text-[11px] font-semibold uppercase tracking-wider text-muted sm:mt-5 sm:text-xs">
              Challenge
            </h2>
            <div className="mt-1.5 sm:mt-5">
              <SetupModeCards
                selectedMode={selectedMode}
                onSelect={(mode) => {
                  trackEvent('config_mode_selected', { mode });
                  onSelectMode(mode);
                }}
              />
            </div>

            <div className="mt-3 sm:mt-5">
              <SetupTopics {...topics} onExpand={scrollToSubmitIfNeeded} />
            </div>

            <p className="mt-3 border-t border-border pt-3 text-xs text-muted sm:mt-5">
              {PERSONALIZED_QUESTION_COUNT} questions · {MODE_LABELS[selectedMode]} · {difficultyLabel} · {technologySummary}
            </p>
            <div ref={submitRef} className="mt-3 flex justify-center sm:mt-5">
              <Button
                type="submit"
                variant="primary"
                size="md"
                loading={loading}
                rightIcon={<ArrowRight className="h-4 w-4" />}
                fullWidth
                className="sm:w-[320px]"
              >
                Commencer
              </Button>
            </div>
          </section>
        </form>
      </div>
    </div>
  );
};
