import type { SimulationResultDTO, StartSimulationRequest } from '../types';
import { Button } from './common/Button';
import { Award, RotateCcw } from 'lucide-react';
import { ResultHeader } from './ResultHeader';
import { ResultEvaluation } from './ResultEvaluation';
import { ResultCompetencies } from './ResultCompetencies';
import { ResultPriority } from './ResultPriority';
import { ResultQuestions } from './ResultQuestions';
import { analyzeResult, groupSkillTagsByCategory } from '../utils/resultAnalysis';
import { trackEvent } from '../api/events';
import { useEffect, useRef } from 'react';

interface Props {
  summary: SimulationResultDTO;
  onRestart: () => void;
  /** Démarrage direct d'une simulation ciblée (réutilise handleStartSimulation de App). */
  onStart: (request: StartSimulationRequest) => void;
  loading: boolean;
  isGuest: boolean;
  guestSimulationCount: number;
  onCreateAccount: () => void;
  isPlacement: boolean;
  onContinuePlacement: () => void;
  onBack: () => void;
}

export const ResultScreen = ({
  summary,
  onRestart,
  onStart,
  loading,
  isGuest,
  onCreateAccount,
  isPlacement,
  onContinuePlacement,
  onBack,
}: Props) => {
  const guestCtaRef = useRef<HTMLElement>(null);
  const guestCtaViewedRef = useRef(false);

  useEffect(() => {
    if (!isGuest || !guestCtaRef.current || typeof IntersectionObserver === 'undefined') return;
    const observer = new IntersectionObserver((entries) => {
      if (guestCtaViewedRef.current || !entries.some((entry) => entry.isIntersecting)) return;
      guestCtaViewedRef.current = true;
      trackEvent('guest_cta_viewed', { simulationId: summary.simulationId });
      observer.disconnect();
    }, { threshold: 0.5 });
    observer.observe(guestCtaRef.current);
    return () => observer.disconnect();
  }, [isGuest, summary.simulationId]);

  const categoryResults = summary.categoryResults ?? (
    summary.competencySource === 'CATEGORY' ? summary.competencyResults ?? [] : []
  );
  const categoryAnalysis = analyzeResult(categoryResults);
  const technicalWeaknesses = analyzeResult(
    summary.weakCategoryResults ?? categoryAnalysis.weaknesses
  ).weaknesses;
  const skillTagsByCategory = groupSkillTagsByCategory(summary.questions);
  // Priorité : tous les domaines sous 100 %, du plus fragile au plus solide
  // (à égalité, le plus de mauvaises réponses d'abord).
  const priorityAxes = [
    ...categoryAnalysis.weaknesses,
    ...categoryAnalysis.toConsolidate,
  ].sort(
    (a, b) => a.pct - b.pct || (b.total - b.correct) - (a.total - a.correct)
  );
  const priorityList = priorityAxes.length > 0 ? priorityAxes : technicalWeaknesses;
  // En Architecture, les filtres skill/catégorie sont ignorés par la requête côté backend :
  // un bouton « ciblé » serait mensonger → relance générique du mode en cours.
  const showTargetedCta = summary.mode !== 'ARCHITECTURE';
  const showGenericCta = summary.mode === 'ARCHITECTURE';
  const showPriority = priorityList.length > 0;
  const showStrengths = categoryAnalysis.strengths.length > 0;

  return (    <div className="max-w-4xl mx-auto py-1 sm:py-2 space-y-4 sm:space-y-0 sm:grid sm:grid-cols-2 sm:gap-6">
      <div className="sm:col-span-2">
        <ResultHeader
          mode={summary.mode}
          difficulty={summary.difficulty}
          onBack={onBack}
        />
      </div>

      <div className="grid sm:col-span-2">
        <ResultEvaluation
          summary={summary}
          isGuest={isGuest}
          isPlacement={isPlacement}
          onContinuePlacement={onContinuePlacement}
        />
      </div>

      {showPriority && (
        <div className={`grid ${showStrengths ? '' : 'sm:col-span-2'}`}>
          <ResultPriority
            technicalWeaknesses={priorityList}
            tagsByCategory={skillTagsByCategory}
            summary={summary}
            loading={loading}
            onStart={onStart}
            showCta={showTargetedCta}
            genericCta={showGenericCta}
          />
        </div>
      )}

      {showStrengths && (
        <div className={`grid ${showPriority ? '' : 'sm:col-span-2'}`}>
          <ResultCompetencies
            title="Domaines maîtrisés"
            subtitle="Technologies et domaines évalués"
            icon={<Award className="w-4 h-4" />}
            iconChipClassName="bg-success-soft border-success-border text-success"
            tone="success"
            items={categoryAnalysis.strengths}
            tagsByCompetency={skillTagsByCategory}
          />
        </div>
      )}

      <div className="grid sm:col-span-2">
        <ResultQuestions
          summary={summary}
          isGuest={isGuest}
          onCreateAccount={onCreateAccount}
        />
      </div>

      {/* Restart CTA */}
      <div className="grid justify-center sm:col-span-2">
        <Button
          onClick={onRestart}
          variant="primary"
          size="lg"
          leftIcon={<RotateCcw className="w-4 h-4" />}
          className="w-full sm:w-80"
        >
          Lancer une nouvelle session
        </Button>
      </div>
    </div>
  );
};
