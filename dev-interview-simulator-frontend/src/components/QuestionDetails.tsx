import type { QuestionSummary } from '../types';
import { CheckCircle2, XCircle, Sparkles } from 'lucide-react';

interface Props {
  question: QuestionSummary;
}

export const QuestionDetails = ({ question: q }: Props) => (
  <div className="p-5 sm:p-7 bg-canvas-subtle border-t border-border text-sm space-y-4 animate-in fade-in duration-150">
    {/* Context if available */}
    {q.context && (
      <div className="p-4 rounded-xl bg-surface border border-border text-xs text-ink-secondary italic font-serif text-sm">
        <div className="font-sans not-italic uppercase tracking-wider text-ink-muted text-[10px] mb-1 font-semibold">
          Mise en situation
        </div>
        {q.context}
      </div>
    )}

    {/* Question Prompt */}
    <div>
      <span className="text-[10px] font-mono uppercase tracking-wider text-crimson-700 font-semibold block mb-1">
        Question posée
      </span>
      <p className="font-serif text-base font-semibold text-ink">{q.question}</p>
    </div>

    {/* User Answer */}
    <div className="space-y-1">
      <span className="text-[10px] font-mono uppercase tracking-wider text-ink-muted block">
        Votre réponse soumise :
      </span>
      <div
        className={`p-3.5 rounded-xl border text-sm flex items-start gap-2.5 ${
          q.isCorrect
            ? 'bg-success-soft border-success-border text-success'
            : 'bg-danger-soft border-danger-border text-danger'
        }`}
      >
        {q.isCorrect ? (
          <CheckCircle2 className="w-4 h-4 text-success flex-shrink-0 mt-0.5" />
        ) : (
          <XCircle className="w-4 h-4 text-danger flex-shrink-0 mt-0.5" />
        )}
        <span>{q.userSelectedOptionContent || '(Aucune réponse enregistrée)'}</span>
      </div>
    </div>

    {/* Expected Answer (if incorrect) */}
    {!q.isCorrect && q.correctOptionContent && (
      <div className="space-y-1">
        <span className="text-[10px] font-mono uppercase tracking-wider text-ink-muted block">
          Bonne réponse attendue :
        </span>
        <div className="p-3.5 rounded-xl bg-success-soft border border-success-border text-success text-sm flex items-start gap-2.5">
          <CheckCircle2 className="w-4 h-4 text-success flex-shrink-0 mt-0.5" />
          <span>{q.correctOptionContent}</span>
        </div>
      </div>
    )}

    {/* Evaluator Explanation */}
    <div className="bg-surface border border-border p-4 rounded-xl space-y-1.5 shadow-card">
      <div className="flex items-center gap-1.5 text-xs font-sans uppercase tracking-wider text-navy-900 font-semibold">
        <Sparkles className="w-3.5 h-3.5 text-crimson-700" />
        <span>Explication technique de l'évaluateur</span>
      </div>
      <p className="text-xs sm:text-sm text-ink leading-relaxed font-sans">
        {q.explanation || 'Aucune explication renseignée pour cette question.'}
      </p>
    </div>

    {/* Question Metadata Footer */}
    <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs font-mono text-ink-muted pt-1">
      <span>Points obtenus : +{q.pointsEarned}</span>
      <span>•</span>
      <span>
        Temps de réponse : {q.timeSpentMs != null ? `${Math.round(q.timeSpentMs / 1000)}s` : 'Non renseigné'}
      </span>
    </div>
  </div>
);
