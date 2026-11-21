import { useRef } from 'react';
import type { FormEvent, RefObject } from 'react';
import type { Category, ChallengeType, DifficultyLevel, Skill } from '../types';
import { Button } from './common/Button';
import { PageTitle } from './common/PageTitle';
import { SetupModeCards } from './SetupModeCards';
import { SetupTopics } from './SetupTopics';
import { trackEvent } from '../api/events';
import { ArrowRight } from 'lucide-react';

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
  { id: 'INTERMEDIATE', label: 'Intermédiaire' },
  { id: 'ADVANCED', label: 'Senior' },
];

const MOBILE_MAX_WIDTH_QUERY = '(max-width: 767px)';
export const SetupConfigStep = ({
  loading,
  onSubmit,
  selectedMode,
  onSelectMode,
  selectedDifficulty,
  onSelectDifficulty,
  topics,
}: Props) => {
  const levelSectionRef = useRef<HTMLDivElement>(null);
  const startButtonRef = useRef<HTMLDivElement>(null);

  const scrollOnMobile = (target: RefObject<HTMLDivElement | null>) => {
    if (window.matchMedia(MOBILE_MAX_WIDTH_QUERY).matches) {
      target.current?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  };

  const handleSelectMode = (mode: ChallengeType) => {
    trackEvent('config_mode_selected', { mode });
    onSelectMode(mode);
    scrollOnMobile(levelSectionRef);
  };

  const handleSelectDifficulty = (difficulty: DifficultyLevel) => {
    trackEvent('config_level_selected', { difficulty });
    onSelectDifficulty(difficulty);
    scrollOnMobile(startButtonRef);
  };

  // Suppression des auto-scrolls dans cet écran
  // Garde les comportements du quiz

  return (
    <div className="screen-transition w-full flex flex-col items-center py-4 sm:py-6 px-4">
      <div className="w-full max-w-3xl mx-auto space-y-12 sm:space-y-14 text-center">
        <button
          type="button"
          onClick={() => trackEvent('config_level_selected', { mode: selectedMode })}
          className="mx-auto flex items-center gap-2 text-xs font-medium text-muted hover:text-text transition-colors cursor-pointer focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg"
        >
          Trouve votre niveau
        </button>

        <button
          type="button"
          onClick={() => trackEvent('config_personalize_opened', {})}
          className="mt-2 text-sm text-link underline cursor-pointer"
        >
          Personnaliser
        </button>

        <PageTitle size="hero-compact">
          Configurez votre session
        </PageTitle>

        <form onSubmit={onSubmit} className="space-y-10 sm:space-y-12">
          <section aria-labelledby="simulation-mode-heading" className="space-y-4">
            <h2 id="simulation-mode-heading" className="text-sm font-semibold text-text">
              Format de simulation
            </h2>
            <SetupModeCards selectedMode={selectedMode} onSelect={handleSelectMode} />
          </section>

          <div className="flex flex-col items-center justify-between gap-6 pt-2">
            <div
              ref={levelSectionRef}
              className="flex flex-wrap items-center justify-center gap-2 text-xs font-sans"
            >
              <span id="difficulty-heading" className="text-muted font-mono uppercase tracking-[0.06em] mr-2">Niveau visé :</span>
              <div role="group" aria-labelledby="difficulty-heading" className="inline-flex gap-2">
                {DIFFICULTIES.map((diff) => {
                  const isDiffSelected = selectedDifficulty === diff.id;
                  return (
                    <button
                      key={diff.id}
                      type="button"
                      onClick={() => handleSelectDifficulty(diff.id)}
                      aria-pressed={isDiffSelected}
                      className={`px-3.5 py-2 min-h-11 rounded border-2 text-xs font-semibold transition-all cursor-pointer focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg ${
                        isDiffSelected
                          ? 'bg-brand text-cta-text border-border shadow-[2px_2px_0_var(--color-shadow)]'
                          : 'bg-card text-text border-border hover:border-brand'
                      }`}
                    >
                      {diff.label}
                    </button>
                  );
                })}
              </div>
            </div>
            {selectedMode !== 'ARCHITECTURE' && <SetupTopics {...topics} />}

            <div ref={startButtonRef} className="pt-2">
              <Button
                type="submit"
                variant="primary"
                size="lg"
                loading={loading}
                rightIcon={<ArrowRight className="w-4 h-4" />}
                className="px-9 py-3 text-base font-semibold tracking-wide"
              >
                Lancer ma simulation
              </Button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};

