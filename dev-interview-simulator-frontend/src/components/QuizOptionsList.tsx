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

// QCM Contraste : avant validation, cartes standard (bordure 2px, ombre
// décalée). Sélection = fond --color-selected, la bordure ne change PAS de
// couleur (spec §10). Après validation : success/error tokens + indicateurs
// icônes (spec §12 — jamais la couleur seule).
export const QuizOptionsList = ({ challenge, selectedOptionIds, feedback, onSelect }: Props) => (
  <div className="space-y-3 pt-2">
    {challenge.options.map((option, idx) => {
      const isSelected = selectedOptionIds.includes(option.id);
      const correction = feedback?.corrections.find(
        (item) => item.optionId === option.id
      );

      // États Contraste (tokens, jamais de hex en dur)
      let cardStyle =
        'border-border bg-card hover:border-brand text-text shadow-card';
      let indicatorStyle =
        'border-border bg-bg text-muted';

      if (feedback) {
        if (correction?.isCorrect && correction.wasSelected) {
          // Correcte & sélectionnée
          cardStyle =
            'border-success bg-success-bg text-text shadow-card';
          indicatorStyle =
            'border-success bg-success text-card font-bold';
        } else if (correction?.isCorrect) {
          // Correcte mais manquée
          cardStyle =
            'border-success bg-success-bg text-text';
          indicatorStyle =
            'border-success bg-card text-success';
        } else if (correction?.wasSelected) {
          // Incorrecte choisie
          cardStyle =
            'border-error bg-error-bg text-text shadow-card';
          indicatorStyle =
            'border-error bg-error text-card font-bold';
        } else {
          // Incorrecte non choisie
          cardStyle =
            'border-border bg-card opacity-60 text-muted';
        }
      } else if (isSelected) {
        // Sélection : fond selected, bordure identique (inchangée — spec §10)
        cardStyle =
          'border-border bg-selected text-text shadow-elevated';
        indicatorStyle =
          'border-border bg-text text-card font-bold';
      }

      return (
        <div
          key={option.id}
          onClick={() => onSelect(option.id)}
          className={`relative flex items-start gap-4 p-4 sm:p-5 rounded border-2 transition-all duration-150 select-none min-h-11 ${
            feedback
              ? 'cursor-default'
              : 'cursor-pointer active:scale-[0.995]'
          } ${cardStyle}`}
        >
          {/* Index / Checkbox indicator */}
          <div
            className={`w-6 h-6 rounded-sm border-2 flex items-center justify-center text-xs font-mono flex-shrink-0 mt-0.5 transition-colors ${indicatorStyle}`}
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
          <div className="flex-1 min-w-0 text-sm sm:text-base leading-relaxed font-sans break-words">
            {option.content}
          </div>
        </div>
      );
    })}
  </div>
);
