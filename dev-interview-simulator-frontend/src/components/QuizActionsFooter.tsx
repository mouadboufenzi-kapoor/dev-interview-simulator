import type { SubmitAnswerResponse } from '../types';
import { Button } from './common/Button';
import { ArrowRight } from 'lucide-react';

interface Props {
  feedback: SubmitAnswerResponse | null;
  selectedCount: number;
  submitting: boolean;
  isLastQuestion: boolean;
  onSubmit: () => void;
  onNext: () => void;
}

export const QuizActionsFooter = ({
  feedback,
  selectedCount,
  submitting,
  isLastQuestion,
  onSubmit,
  onNext,
}: Props) => (
  <div className="pt-4 border-t border-border flex items-center justify-between gap-4">
    <div className="text-xs text-ink-muted font-sans hidden sm:block">
      {!feedback ? (
        <span>{selectedCount} option(s) sélectionnée(s)</span>
      ) : (
        <span>Score de session : {feedback.totalSimulationScore} points</span>
      )}
    </div>

    <div className="ml-auto">
      {!feedback ? (
        <Button
          variant="primary"
          size="md"
          onClick={onSubmit}
          disabled={selectedCount === 0 || submitting}
          loading={submitting}
          rightIcon={<ArrowRight className="w-4 h-4" />}
          className="px-6 font-semibold"
        >
          Valider ma réponse
        </Button>
      ) : (
        <Button
          variant="primary"
          size="md"
          onClick={onNext}
          rightIcon={<ArrowRight className="w-4 h-4" />}
          className="px-6 font-semibold"
        >
          {isLastQuestion ? 'Consulter le bilan' : 'Question suivante'}
        </Button>
      )}
    </div>
  </div>
);
