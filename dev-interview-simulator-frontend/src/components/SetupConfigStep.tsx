import { useRef } from 'react';
import type { FormEvent, RefObject } from 'react';
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
  onBack: () => void;
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
  onBack,
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
    onSelectMode(mode);
    scrollOnMobile(levelSectionRef);
  };

  const handleSelectDifficulty = (difficulty: DifficultyLevel) => {
    onSelectDifficulty(difficulty);
    scrollOnMobile(startButtonRef);
  };

  return (
    <div className="screen-transition w-full min-h-[calc(80vh-80px)] flex flex-col items-center justify-center py-10 sm:py-16 px-4">
      <div className="w-full max-w-3xl mx-auto space-y-12 sm:space-y-14 text-center">
        <button
          type="button"
          onClick={onBack}
          className="mx-auto flex items-center gap-2 text-xs font-medium text-muted hover:text-text transition-colors cursor-pointer focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg"
        >
          <ArrowLeft className="w-3.5 h-3.5" />
          Changer de profil
        </button>

        {/* Brand & Main Headline */}
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

          {/* Minimalist Configuration Bar (Level + Options) */}
          <div className="flex flex-col items-center justify-between gap-6 pt-2">
            <div
              ref={levelSectionRef}
              className="scroll-mt-14 sm:scroll-mt-16 flex flex-wrap items-center justify-center gap-2 text-xs font-sans"
            >
              <span id="difficulty-heading" className="text-muted font-mono uppercase tracking-[0.06em] mr-2">Niveau visé :</span>
              {/* Sélecteur de niveau Contraste (spec §11) : boutons bordés,
                  gap 8px, actif = fond brand + texte cta-text + ombre 2px. */}
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
            {/* Technologies / sujets : masquées en Architecture — le backend choisit
                un scénario au hasard et ignore ces filtres (findScenarioChallenges) :
                les afficher serait trompeur. QCM, Code Review et Raisonnement
                séquentiel, eux, filtrent réellement le contenu. */}
            {selectedMode !== 'ARCHITECTURE' && <SetupTopics {...topics} />}

            {/* Prominent Action Button (Rosewood Accent: crimson-700) */}
            <div ref={startButtonRef} className="scroll-mt-14 sm:scroll-mt-16 pt-2">
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
