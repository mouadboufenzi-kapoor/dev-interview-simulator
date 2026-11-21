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
import { useEffect, useRef } from 'react';
import { PageTitle } from './common/PageTitle';

interface Props {
  summary: SimulationResultDTO;
  onRestart: () => void;
  /** Démarrage direct d'une simulation ciblée (réutilise handleStartSimulation de App). */
  onStart: (request: StartSimulationRequest) => void;
  loading: boolean;
  isGuest: boolean;
  guestSimulationCount: number;
  onCreateAccount: () => void;
  onGoogleAccount: () => void;
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
  onGoogleAccount,
  isPlacement,
  onContinuePlacement,
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
        onContinuePlacement={onContinuePlacement}
      />

      {isGuest && (
        <div className="space-y-4">
          <section className="rounded-2xl border-[0.5px] border-card-border bg-surface p-5 shadow-card sm:p-6">
            <PageTitle as="h2" size="sm">Points faibles / axes à travailler</PageTitle>
            {technicalWeaknesses.length > 0 ? (
              <>
                <p className="mt-3 text-sm font-semibold text-crimson-700">
                  {technicalWeaknesses[0].name}
                </p>
                {technicalWeaknesses.length > 1 && (
                  <ul className="mt-3 space-y-2" aria-label="Axes supplémentaires verrouillés">
                    {technicalWeaknesses.slice(1).map((_, index) => (
                      <li key={index} className="rounded border border-border bg-card px-3 py-2">
                        <span className="block max-w-28 blur-sm select-none text-sm text-muted" aria-hidden="true">
                          Autre axe
                        </span>
                      </li>
                    ))}
                  </ul>
                )}
              </>
            ) : (
              <p className="mt-3 text-sm text-ink-secondary">
                Aucun axe prioritaire identifié.
              </p>
            )}
          </section>

          <section className="rounded-2xl border-[0.5px] border-card-border bg-surface p-5 shadow-card sm:p-6">
            <PageTitle as="h2" size="sm">Plan de progression</PageTitle>
            <ol className="mt-3 space-y-2">
              <li className="text-sm text-text">
                {technicalWeaknesses[0]
                  ? `Revoir les fondamentaux : ${technicalWeaknesses[0].name}`
                  : 'Revoir les fondamentaux du niveau'}
              </li>
              {Array.from({ length: 3 }).map((_, index) => (
                <li key={index} className="rounded border border-border bg-card px-3 py-2">
                  <span className="block max-w-32 blur-sm select-none text-sm text-muted" aria-hidden="true">
                    Étape suivante
                  </span>
                </li>
              ))}
            </ol>
          </section>
        </div>
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

      <ResultQuestions summary={summary} isGuest={isGuest} />

      {isGuest && (
        <section
          ref={guestCtaRef}
          className="rounded-2xl border-[0.5px] border-card-border bg-surface p-5 shadow-card sm:p-6"
        >
          <p className="text-sm font-semibold text-text">
            Crée un compte gratuit pour sauvegarder ce résultat et retrouver tous tes points faibles
          </p>
          <div className="mt-4 flex flex-col gap-3 sm:flex-row sm:items-center">
            <Button
              type="button"
              variant="outline"
              size="lg"
              fullWidth
              onClick={() => {
                trackEvent('guest_cta_clicked', { simulationId: summary.simulationId });
                onGoogleAccount();
              }}
              className="sm:flex-1"
            >
              Continuer avec Google
            </Button>
            <Button
              type="button"
              variant="primary"
              size="lg"
              fullWidth
              onClick={() => {
                trackEvent('guest_cta_clicked', { simulationId: summary.simulationId });
                onCreateAccount();
              }}
              className="sm:flex-1"
            >
              Créer mon compte
            </Button>
          </div>
        </section>
      )}

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
