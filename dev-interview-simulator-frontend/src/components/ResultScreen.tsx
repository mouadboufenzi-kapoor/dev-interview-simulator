import type { SimulationResultDTO, StartSimulationRequest } from '../types';
import { Button } from './common/Button';
import { Award, RotateCcw, Target } from 'lucide-react';
import { ResultHeader } from './ResultHeader';
import { ResultEvaluation } from './ResultEvaluation';
import { ResultCompetencies } from './ResultCompetencies';
import { ResultPriority } from './ResultPriority';
import { ResultGuestCta } from './ResultGuestCta';
import { ResultQuestions } from './ResultQuestions';
import { analyzeResult } from '../utils/resultAnalysis';

interface Props {
  summary: SimulationResultDTO;
  onRestart: () => void;
  /** Démarrage direct d'une simulation ciblée (réutilise handleStartSimulation de App). */
  onStart: (request: StartSimulationRequest) => void;
  loading: boolean;
  isGuest: boolean;
  guestSimulationCount: number;
  onCreateAccount: () => void;
}

export const ResultScreen = ({
  summary,
  onRestart,
  onStart,
  loading,
  isGuest,
  guestSimulationCount,
  onCreateAccount,
}: Props) => {
  const categoryResults = summary.categoryResults ?? (
    summary.competencySource === 'CATEGORY' ? summary.competencyResults ?? [] : []
  );
  const skillResults = summary.skillResults ?? (
    summary.competencySource === 'SKILL' ? summary.competencyResults ?? [] : []
  );
  const categoryAnalysis = analyzeResult(categoryResults);
  const skillAnalysis = analyzeResult(skillResults);
  const weakestCategories = analyzeResult(summary.weakCategoryResults ?? categoryAnalysis.weaknesses).weaknesses;
  const weakestSkills = analyzeResult(summary.weakSkillResults ?? skillAnalysis.weaknesses).weaknesses;
  const weaknesses = [
    ...weakestCategories.map((item) => ({ ...item, source: 'CATEGORY' as const })),
    ...weakestSkills.map((item) => ({ ...item, source: 'SKILL' as const })),
  ].sort((a, b) => a.pct - b.pct || a.total - b.total);
  const weakest = weaknesses[0] ?? null;
  // En Architecture, les filtres skill/catégorie sont ignorés par la requête côté backend :
  // afficher un bouton « ciblé » serait mensonger → diagnostic affiché sans CTA
  // (décision validée).
  const showTargetedCta = summary.mode !== 'ARCHITECTURE';

  return (
    <div className="max-w-4xl mx-auto space-y-6 sm:space-y-8 py-4 sm:py-6">
      <ResultHeader mode={summary.mode} difficulty={summary.difficulty} />

      {/* Évaluation globale + Votre priorité côte à côte (desktop) —
          empilement naturel en mobile-first via grid-cols-1.
          Sans point faible, l'évaluation garde toute la largeur. */}
      <div
        className={
          weakest
            ? 'grid grid-cols-1 md:grid-cols-2 gap-6 items-stretch'
            : 'grid grid-cols-1 gap-6'
        }
      >
        <ResultEvaluation summary={summary} />

        {weakest && (
          <ResultPriority
            weaknesses={weaknesses}
            summary={summary}
            loading={loading}
            onStart={onStart}
            showCta={showTargetedCta}
          />
        )}
      </div>

      {/* Les domaines techniques et compétences transversales restent séparés. */}
      {categoryAnalysis.strengths.length > 0 && (
        <ResultCompetencies
          title="Domaines maîtrisés"
          subtitle="Technologies et domaines évalués"
          icon={<Award className="w-4 h-4" />}
          iconChipClassName="bg-success-soft border-success-border text-success"
          tone="success"
          items={categoryAnalysis.strengths}
        />
      )}
      {skillAnalysis.strengths.length > 0 && (
        <ResultCompetencies
          title="Compétences transversales maîtrisées"
          subtitle="Méthodes et pratiques évaluées"
          icon={<Award className="w-4 h-4" />}
          iconChipClassName="bg-success-soft border-success-border text-success"
          tone="success"
          items={skillAnalysis.strengths}
        />
      )}

      {categoryAnalysis.toConsolidate.length > 0 && (
        <ResultCompetencies
          title="Domaines à consolider"
          subtitle="Technologies et domaines évalués"
          icon={<Target className="w-4 h-4" />}
          iconChipClassName="bg-warning-soft border-warning-border text-navy-900"
          tone="navy"
          items={categoryAnalysis.toConsolidate}
        />
      )}
      {skillAnalysis.toConsolidate.length > 0 && (
        <ResultCompetencies
          title="Compétences transversales à consolider"
          subtitle="Méthodes et pratiques évaluées"
          icon={<Target className="w-4 h-4" />}
          iconChipClassName="bg-warning-soft border-warning-border text-navy-900"
          tone="navy"
          items={skillAnalysis.toConsolidate}
        />
      )}

      <ResultQuestions summary={summary} />

      {/* CTA invité — après le détail des questions (hiérarchie : diagnostic →
          preuve → conversion), montre la valeur du compte sans bloquer */}
      {isGuest && (
        <ResultGuestCta count={guestSimulationCount} onCreateAccount={onCreateAccount} />
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
