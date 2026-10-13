import type { SubmitAnswerResponse } from '../types';
import { Badge } from './common/Badge';
import { ShieldAlert } from 'lucide-react';

interface Props {
  feedback: SubmitAnswerResponse;
}

// État après validation — hiérarchie volontairement courte :
//   1. Résultat (badge + points)
//   2. Explication (contenu principal, texte plein sans carte imbriquée)
//   3. Info secondaire Architecture (repère système / compromis) en retrait
//   4. Détail des anomalies (Code Review uniquement)
// La correction détaillée (options, ordre des étapes) vit dans les listes
// d'options/étapes au-dessus — pas de doublon ici.
export const QuizFeedbackPanel = ({ feedback }: Props) => {
  // Raisonnement séquentiel : les corrections par étape sont affichées
  // directement dans QuizSequenceList (positions vert/rouge).
  const isSequential = !!feedback.expectedOrder && feedback.expectedOrder.length > 0;

  // Code Review uniquement : les explications d'options ne sont pas du détail
  // utile pour un QCM classique (l'option correcte est déjà surlignée).
  const anomalyCorrections = feedback.corrections.filter((c) => c.explanation);
  const showAnomalies = !isSequential && anomalyCorrections.length > 0;

  const hasSecondary = !!(feedback.revealedInformation || feedback.tradeoff);

  return (
    <div className="rounded-2xl border-[0.5px] border-card-border bg-canvas-subtle p-5 sm:p-6 space-y-4 shadow-panel animate-in fade-in duration-200">
      {/* 1. Résultat */}
      <div className="flex flex-wrap items-center justify-between gap-2">
        <Badge variant={feedback.isCorrect ? 'success' : 'danger'} size="md" dot>
          {feedback.isCorrect ? 'Réponse validée' : 'Réponse incorrecte'}
        </Badge>
        <span className="font-mono text-xs text-crimson-700 font-semibold">
          +{feedback.scoreAwarded} point(s)
        </span>
      </div>

      {/* 2. Explication — contenu principal, sans carte imbriquée */}
      {feedback.explanation && (
        <p className="text-sm text-ink leading-relaxed font-sans break-words">
          {feedback.explanation}
        </p>
      )}

      {/* 3. Info secondaire (Architecture) — en retrait, une seule carte discrète */}
      {hasSecondary && (
        <div className="space-y-2 pt-1">
          {feedback.revealedInformation && (
            <p className="text-xs text-ink-secondary leading-relaxed border-l-2 border-navy-200 pl-3 break-words">
              <span className="font-semibold text-navy-900">Repère système — </span>
              {feedback.revealedInformation}
            </p>
          )}
          {feedback.tradeoff && (
            <p className="text-xs text-ink-secondary leading-relaxed border-l-2 border-warning-border pl-3 break-words">
              <span className="font-semibold text-warning">Compromis — </span>
              {feedback.tradeoff}
            </p>
          )}
        </div>
      )}

      {/* 4. Détail des anomalies (Code Review) */}
      {showAnomalies && (
        <div className="pt-2 space-y-2 border-t border-border-subtle">
          <div className="text-xs font-sans uppercase tracking-wider text-ink-secondary font-semibold flex items-center gap-1.5">
            <ShieldAlert className="w-3.5 h-3.5 text-crimson-700" />
            Détail des anomalies
          </div>
          <div className="space-y-2">
            {anomalyCorrections.map((correction) => (
              <div
                key={correction.optionId}
                className="p-3.5 rounded-xl bg-surface border border-border text-xs text-ink-secondary leading-relaxed space-y-1"
              >
                <div className="flex items-center gap-2">
                  {correction.severity && (
                    <Badge variant="crimson" size="sm">
                      {correction.severity}
                    </Badge>
                  )}
                  <span className="font-semibold text-ink min-w-0 break-words">
                    {correction.content}
                  </span>
                </div>
                <p className="text-ink-secondary pt-0.5 break-words">
                  {correction.explanation}
                </p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
