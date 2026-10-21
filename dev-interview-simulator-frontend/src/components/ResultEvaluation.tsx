import type { SimulationResultDTO } from '../types';
import { Badge } from './common/Badge';
import { CheckCircle2, Clock, Gauge } from 'lucide-react';
import { getAssessment } from '../utils/resultAnalysis';

interface Props {
  summary: SimulationResultDTO;
}

const formatTime = (seconds: number) => {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return mins > 0 ? `${mins}m ${secs.toString().padStart(2, '0')}s` : `${secs}s`;
};

export const ResultEvaluation = ({ summary }: Props) => {
  const assessment = getAssessment(summary.successPercentage);

  const questionsWithRecordedTime = summary.questions.filter(question => question.timeSpentMs != null).length;
  const avgTimePerQuestion = questionsWithRecordedTime > 0
    ? Math.round(summary.totalTimeSpentSeconds / questionsWithRecordedTime)
    : 0;

  return (
    <section className="bg-surface border-[0.5px] border-card-border rounded-2xl p-6 shadow-elevated space-y-5">
      <div className="flex items-center justify-between gap-3">
        <span className="font-sans text-xs uppercase tracking-wider text-ink-muted font-semibold">
          Évaluation globale
        </span>
        <Badge variant={assessment.variant} size="md">
          {assessment.label}
        </Badge>
      </div>

      <div>
        <span className="font-serif text-5xl font-bold text-crimson-700">
          {summary.successPercentage}%
        </span>
        <p className="text-xs text-ink-secondary mt-1.5">
          Bonnes réponses · Score {summary.totalScore} / {summary.maxPossibleScore} points obtenus
        </p>
      </div>

      <p className="text-sm text-ink-secondary leading-relaxed">{assessment.desc}</p>

      <div className="grid grid-cols-3 gap-2 sm:gap-4 pt-4 border-t border-border">
        <div className="space-y-1">
          <div className="flex items-center justify-between gap-1">
            <span className="text-[10px] sm:text-[11px] font-sans uppercase tracking-wider text-ink-muted font-semibold">
              Bonnes réponses
            </span>
            <CheckCircle2 className="w-3.5 h-3.5 text-success flex-shrink-0 hidden sm:block" />
          </div>
          <p className="font-serif text-lg sm:text-xl font-bold text-ink">
            {summary.correctAnswersCount}
            <span className="text-sm font-normal text-ink-muted"> / {summary.totalQuestions}</span>
          </p>
        </div>

        <div className="space-y-1">
          <div className="flex items-center justify-between gap-1">
            <span className="text-[10px] sm:text-[11px] font-sans uppercase tracking-wider text-ink-muted font-semibold">
              Temps total
            </span>
            <Clock className="w-3.5 h-3.5 text-navy-900 flex-shrink-0 hidden sm:block" />
          </div>
          <p className="font-serif text-lg sm:text-xl font-bold text-ink">
            {formatTime(summary.totalTimeSpentSeconds)}
          </p>
        </div>

        <div className="space-y-1">
          <div className="flex items-center justify-between gap-1">
            <span className="text-[10px] sm:text-[11px] font-sans uppercase tracking-wider text-ink-muted font-semibold">
              Rythme moyen
            </span>
            <Gauge className="w-3.5 h-3.5 text-navy-900 flex-shrink-0 hidden sm:block" />
          </div>
          <p className="font-serif text-lg sm:text-xl font-bold text-ink">{avgTimePerQuestion}s</p>
          <p className="text-[9px] font-sans text-ink-muted">par question</p>
        </div>
      </div>
    </section>
  );
};
