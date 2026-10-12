import type { SimulationResultDTO, StartSimulationRequest } from '../types';
import { Button } from './common/Button';
import { Award, AlertTriangle, RotateCcw } from 'lucide-react';
import { ResultHeader } from './ResultHeader';
import { ResultEvaluation } from './ResultEvaluation';
import { ResultCompetencies } from './ResultCompetencies';
import { ResultObjective } from './ResultObjective';
import { ResultGuestCta } from './ResultGuestCta';
import { ResultQuestions } from './ResultQuestions';
import { analyzeResult, buildTargetedRequest } from '../utils/resultAnalysis';

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
  const { competencies, strengths, weaknesses, weakest } = analyzeResult(
    summary.competencyResults ?? []
  );

  // En Architecture, les filtres skill/catégorie sont ignorés par la requête côté backend :
  // afficher un bouton « ciblé » serait mensonger → bloc masqué (décision validée).
  const showObjective = weakest != null && summary.mode !== 'ARCHITECTURE';

  const handleTargetedTraining = () => {
    if (!weakest) return;
    const request: StartSimulationRequest = buildTargetedRequest(
      summary,
      weakest,
      summary.questions.map((q) => q.challengeId)
    );
    onStart(request);
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6 sm:space-y-8 py-4 sm:py-6">
      <ResultHeader mode={summary.mode} difficulty={summary.difficulty} />

      <ResultEvaluation summary={summary} />

      {/* Points forts */}
      {strengths.length > 0 && (
        <ResultCompetencies
          title="Points forts"
          icon={<Award className="w-4 h-4" />}
          iconChipClassName="bg-success-soft border-success-border text-success"
          tone="success"
          items={strengths}
          footerNote={
            <>
              Ton point fort sur cette simulation :{' '}
              <span className="font-semibold text-ink">{strengths[0].name}</span> —{' '}
              {strengths[0].pct} % de réussite.
            </>
          }
        />
      )}

      {/* Points à améliorer */}
      {competencies.length > 0 && (
        <ResultCompetencies
          title="À améliorer"
          icon={<AlertTriangle className="w-4 h-4" />}
          iconChipClassName="bg-warning-soft border-warning-border text-warning"
          tone="crimson"
          items={weaknesses}
          emptyMessage="Aucun axe à améliorer identifié : toutes les compétences évaluées sont à 100 % dans cette simulation."
          footerNote="Les explications des questions en échec sont détaillées plus bas — reprenez-les avant de relancer une session ciblée sur ces sujets."
        />
      )}

      {/* Prochain objectif — entraînement ciblé (pas la page de configuration) */}
      {showObjective && weakest && (
        <ResultObjective target={weakest} loading={loading} onStart={handleTargetedTraining} />
      )}

      {/* CTA invité — montre la valeur du compte, sans bloquer */}
      {isGuest && (
        <ResultGuestCta count={guestSimulationCount} onCreateAccount={onCreateAccount} />
      )}

      <ResultQuestions summary={summary} />

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
