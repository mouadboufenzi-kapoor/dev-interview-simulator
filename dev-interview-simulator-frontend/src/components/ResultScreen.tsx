import type { SimulationResultDTO, StartSimulationRequest } from '../types';
import { Button } from './common/Button';
import { Award, RotateCcw } from 'lucide-react';
import { ResultHeader } from './ResultHeader';
import { ResultEvaluation } from './ResultEvaluation';
import { ResultCompetencies } from './ResultCompetencies';
import { ResultPriority } from './ResultPriority';
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
  const { strengths, weaknesses, weakest } = analyzeResult(
    summary.competencyResults ?? []
  );

  // En Architecture, les filtres skill/catégorie sont ignorés par la requête côté backend :
  // afficher un bouton « ciblé » serait mensonger → diagnostic affiché sans CTA
  // (décision validée).
  const showTargetedCta = summary.mode !== 'ARCHITECTURE';

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
            loading={loading}
            onStart={handleTargetedTraining}
            showCta={showTargetedCta}
          />
        )}
      </div>

      {/* Points forts */}
      {strengths.length > 0 && (
        <ResultCompetencies
          title="Points forts"
          icon={<Award className="w-4 h-4" />}
          iconChipClassName="bg-success-soft border-success-border text-success"
          tone="success"
          items={strengths}
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
