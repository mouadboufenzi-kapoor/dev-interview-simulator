import type { SubmitAnswerResponse } from '../types';
import { Badge } from './common/Badge';
import { Sparkles, Layers, Scale, ShieldAlert } from 'lucide-react';

interface Props {
  feedback: SubmitAnswerResponse;
}

export const QuizFeedbackPanel = ({ feedback }: Props) => (
  <div className="rounded-2xl border-[0.5px] border-card-border bg-canvas-subtle p-5 sm:p-7 space-y-4 shadow-panel animate-in fade-in duration-200">
    {/* Header */}
    <div className="flex flex-wrap items-center justify-between gap-3 pb-3 border-b border-border">
      <div className="flex items-center gap-2">
        <span className="font-mono text-xs uppercase tracking-wider text-ink-muted">
          Évaluation :
        </span>
        <Badge
          variant={feedback.isCorrect ? 'success' : 'danger'}
          size="md"
          dot
        >
          {feedback.isCorrect ? 'Réponse validée' : 'Réponse incorrecte'}
        </Badge>
      </div>

      <div className="font-mono text-xs text-crimson-700 font-semibold">
        +{feedback.scoreAwarded} point(s) attribué(s)
      </div>
    </div>

    {/* Explanation */}
    {feedback.explanation && (
      <div className="space-y-1.5">
        <div className="text-xs font-sans text-navy-900 font-semibold uppercase tracking-wider flex items-center gap-1.5">
          <Sparkles className="w-3.5 h-3.5 text-crimson-700" />
          Explication de l'évaluateur
        </div>
        <p className="text-sm text-ink leading-relaxed font-sans bg-surface p-4 rounded-xl border border-border">
          {feedback.explanation}
        </p>
      </div>
    )}

    {/* Architecture: Revealed Information */}
    {feedback.revealedInformation && (
      <div className="rounded-xl border border-navy-200 bg-navy-50 p-4 space-y-1">
        <div className="flex items-center gap-1.5 text-xs font-sans uppercase tracking-wider text-navy-900 font-semibold">
          <Layers className="w-3.5 h-3.5 text-navy-900" />
          Information révélée sur le système
        </div>
        <p className="text-xs sm:text-sm text-ink leading-relaxed">
          {feedback.revealedInformation}
        </p>
      </div>
    )}

    {/* Architecture: Trade-off */}
    {feedback.tradeoff && (
      <div className="rounded-xl border border-warning-border bg-warning-soft p-4 space-y-1">
        <div className="flex items-center gap-1.5 text-xs font-sans uppercase tracking-wider text-warning font-semibold">
          <Scale className="w-3.5 h-3.5 text-warning" />
          Arbitrage & Compromis architectural (Trade-off)
        </div>
        <p className="text-xs sm:text-sm text-ink leading-relaxed">
          {feedback.tradeoff}
        </p>
      </div>
    )}

    {/* Code Review: Detailed per-issue corrections */}
    {feedback.corrections.some((c) => c.explanation) && (
      <div className="pt-2 space-y-2">
        <div className="text-xs font-sans uppercase tracking-wider text-ink-secondary font-semibold flex items-center gap-1.5">
          <ShieldAlert className="w-3.5 h-3.5 text-crimson-700" />
          Détail des anomalies
        </div>
        <div className="space-y-2">
          {feedback.corrections
            .filter((c) => c.explanation)
            .map((correction) => (
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
                  <span className="font-semibold text-ink">
                    {correction.content}
                  </span>
                </div>
                <p className="text-ink-secondary pt-0.5">
                  {correction.explanation}
                </p>
              </div>
            ))}
        </div>
      </div>
    )}
  </div>
);
