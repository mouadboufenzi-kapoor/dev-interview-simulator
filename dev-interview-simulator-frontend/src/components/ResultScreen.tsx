import type { SimulationResultDTO, StartSimulationRequest } from '../types';
import { Button } from './common/Button';
import { Award, RotateCcw, Target } from 'lucide-react';
import { ResultHeader } from './ResultHeader';
import { ResultEvaluation } from './ResultEvaluation';
import { ResultCompetencies } from './ResultCompetencies';
import { ResultPriority } from './ResultPriority';
import { ResultQuestions } from './ResultQuestions';
import { analyzeResult, groupSkillTagsByCategory } from '../utils/resultAnalysis';
import { trackEvent } from '../api/events';

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
}: Props) => {
  const categoryResults = summary.categoryResults ?? (
    summary.competencySource === 'CATEGORY' ? summary.competencyResults ?? [] : []
  );
  const categoryAnalysis = analyzeResult(categoryResults);
  const technicalWeaknesses = analyzeResult(
    summary.weakCategoryResults ?? categoryAnalysis.weaknesses
  ).weaknesses;
  const skillTagsByCategory = groupSkillTagsByCategory(summary.questions);
  // En Architecture, les filtres skill/catégorie sont ignorés par la requête côté backend :
  // afficher un bouton « ciblé » serait mensonger → diagnostic affiché sans CTA
  // (décision validée).
  const showTargetedCta = summary.mode !== 'ARCHITECTURE';

  return (
    <div className="max-w-4xl mx-auto space-y-6 sm:space-y-8 py-1 sm:py-2">
      <ResultHeader mode={summary.mode} difficulty={summary.difficulty} />

      <ResultEvaluation
        summary={summary}
        isGuest={isGuest}
        isPlacement={isPlacement}
        onCreateAccount={onCreateAccount}
        onContinuePlacement={onContinuePlacement}
      />

      {isGuest && (
        <section className="space-y-3">
          {[
            'Points faibles / axes à travailler',
            'Plan de progression',
            'Détail et corrections des questions',
          ].map((title) => (
            <div key={title} className="rounded border-2 border-border bg-card p-5">
              <p className="font-semibold text-sm text-text">{title}</p>
              <p className="mt-1 text-xs text-ink-secondary">
                Aperçu disponible avec un compte gratuit.
              </p>
              <Button
                type="button"
                variant="outline"
                size="md"
                className="mt-4"
                onClick={() => {
                  trackEvent('result_locked_clicked', { simulationId: summary.simulationId });
                  onCreateAccount();
                }}
              >
                Déverrouiller
              </Button>
            </div>
          ))}
        </section>
      )}

      {!isGuest && technicalWeaknesses.length > 0 && (
        <ResultPriority
          technicalWeaknesses={technicalWeaknesses}
          tagsByCategory={skillTagsByCategory}
          summary={summary}
          loading={loading}
          onStart={onStart}
          showCta={showTargetedCta}
        />
      )}

      {!isGuest && categoryAnalysis.strengths.length > 0 && (
        <ResultCompetencies
          title="Domaines maîtrisés"
          subtitle="Technologies et domaines évalués"
          icon={<Award className="w-4 h-4" />}
          iconChipClassName="bg-success-soft border-success-border text-success"
          tone="success"
          items={categoryAnalysis.strengths}
          tagsByCompetency={skillTagsByCategory}
        />
      )}
      {!isGuest && categoryAnalysis.toConsolidate.length > 0 && (
        <ResultCompetencies
          title="Domaines à consolider"
          subtitle="Technologies et domaines évalués"
          icon={<Target className="w-4 h-4" />}
          iconChipClassName="bg-warning-soft border-warning-border text-navy-900"
          tone="navy"
          items={categoryAnalysis.toConsolidate}
          tagsByCompetency={skillTagsByCategory}
        />
      )}

      {!isGuest && <ResultQuestions summary={summary} />}

      {/* Restart CTA */}
      <div className="pt-8 border-t border-border flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="text-sm text-ink-secondary text-center sm:text-left">
          Prêt à tester une nouvelle compétence ou un autre niveau ?
        </div>

        <Button
          onClick={onRestart}
          variant="primary"
          size="lg"
          leftIcon={<RotateCcw className="w-4 h-4" />}
          className="w-full sm:w-auto px-8"
        >
          Lancer une nouvelle session
        </Button>
      </div>
    </div>
  );
};
