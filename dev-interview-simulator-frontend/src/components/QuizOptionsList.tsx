import type { SimulationChallengeResponse, SubmitAnswerResponse } from '../types';
import { CheckCircle2, XCircle } from 'lucide-react';

interface Props {
  challenge: SimulationChallengeResponse;
  selectedOptionIds: number[];
  feedback: SubmitAnswerResponse | null;
  onSelect: (optionId: number) => void;
}

const getOptionLetter = (idx: number) => {
  return String.fromCharCode(65 + idx);
};

export const QuizOptionsList = ({ challenge, selectedOptionIds, feedback, onSelect }: Props) => (
  <div className="space-y-3 pt-2">
    {challenge.options.map((option, idx) => {
      const isSelected = selectedOptionIds.includes(option.id);
      const correction = feedback?.corrections.find(
        (item) => item.optionId === option.id
      );

      // Dynamic styling
      let cardStyle =
        'border-border bg-surface hover:border-border-strong hover:bg-canvas-subtle text-ink shadow-card';
      let indicatorStyle =
        'border-border bg-canvas-subtle text-ink-secondary';

      if (feedback) {
        if (correction?.isCorrect && correction.wasSelected) {
          // Correct & Selected
          cardStyle =
            'border-success-border bg-success-soft text-success ring-1 ring-success-border';
          indicatorStyle =
            'border-success bg-success text-white font-bold';
        } else if (correction?.isCorrect) {
          // Correct but missed
          cardStyle =
            'border-success-border bg-success-soft/50 text-success';
          indicatorStyle =
            'border-success-border bg-surface text-success';
        } else if (correction?.wasSelected) {
          // Incorrectly chosen
          cardStyle =
            'border-danger-border bg-danger-soft text-danger ring-1 ring-danger-border';
          indicatorStyle =
            'border-danger bg-danger text-white font-bold';
        } else {
          // Unselected incorrect
          cardStyle =
            'border-border bg-surface opacity-50 text-ink-muted';
        }
      } else if (isSelected) {
        // User selected -> Rosewood / Crimson active state (crimson-700)
        cardStyle =
          'border-crimson-700 bg-crimson-100 text-ink ring-1 ring-crimson-700 shadow-[0_2px_6px_rgba(172,59,97,0.06)]';
        indicatorStyle =
          'border-crimson-700 bg-crimson-700 dark:border-crimson-900 dark:bg-crimson-900 text-white font-bold';
      }

      return (
        <div
          key={option.id}
          onClick={() => onSelect(option.id)}
          className={`relative flex items-start gap-4 p-4 sm:p-5 rounded-xl border transition-all duration-150 select-none ${
            feedback ? 'cursor-default' : 'cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas active:scale-[0.998]'
          } ${cardStyle}`}
        >
          {/* Index / Checkbox indicator */}
          <div
            className={`w-6 h-6 rounded-md border flex items-center justify-center text-xs font-mono flex-shrink-0 mt-0.5 transition-colors ${indicatorStyle}`}
          >
            {feedback ? (
              correction?.isCorrect ? (
                <CheckCircle2 className="w-4 h-4 stroke-[2.5]" />
              ) : correction?.wasSelected ? (
                <XCircle className="w-4 h-4 stroke-[2.5]" />
              ) : (
                getOptionLetter(idx)
              )
            ) : isSelected ? (
              <CheckCircle2 className="w-4 h-4 stroke-[2.5]" />
            ) : (
              getOptionLetter(idx)
            )}
          </div>

          {/* Option text */}
          <div className="flex-1 text-sm sm:text-base leading-relaxed font-sans">
            {option.content}
          </div>
        </div>
      );
    })}
  </div>
);
