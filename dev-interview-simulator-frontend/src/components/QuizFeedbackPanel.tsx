import type { SubmitAnswerResponse } from '../types';
import { Badge } from './common/Badge';

interface Props {
  feedback: SubmitAnswerResponse;
}

// État après validation — hiérarchie volontairement courte :
//   1. Résultat (badge + points)
//   2. Explication (contenu principal, texte plein sans carte imbriquée)
//   3. Info secondaire Architecture (repère système / compromis) en retrait
// La correction détaillée (options, ordre des étapes) vit dans les listes
// d'options/étapes au-dessus — pas de doublon ici. Le « Détail des anomalies »
// par option a été retiré de l'affichage principal : trop lourd après chaque
// question (les données restent dans le DTO, jamais supprimées côté backend).
export const QuizFeedbackPanel = ({ feedback }: Props) => {
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
        <div className="space-y-2">
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
    </div>
  );
};
