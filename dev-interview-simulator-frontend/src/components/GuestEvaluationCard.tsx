import type { SimulationResultDTO } from '../types';
import { ArrowRight } from 'lucide-react';
import { Button } from './common/Button';
import { LevelGauge } from './LevelGauge';
import { estimateLevel } from '../utils/levelEstimation';
import { panelCard } from '../styles/ui';
import { trackEvent } from '../api/events';

interface Props {
  summary: SimulationResultDTO;
  durationLabel: string | null;
  isPlacement: boolean;
  onContinuePlacement: () => void;
}

export const GuestEvaluationCard = ({
  summary,
  durationLabel,
  isPlacement,
  onContinuePlacement,
}: Props) => {
  const level = estimateLevel(
    [
      {
        difficulty: summary.difficulty,
        answered: summary.totalQuestions,
        correct: summary.correctAnswersCount,
      },
    ],
    1
  );
  const correctLabel = summary.correctAnswersCount > 1 ? 'bonnes réponses' : 'bonne réponse';
  const targetLevel = level
    ? level.index <= 1
      ? 'Junior'
      : level.index <= 3
        ? 'Intermédiaire'
        : 'Avancé'
    : '';

  return (
    <section
      className={`${panelCard} rounded-[10px] border-[#0a2342] p-3.5 shadow-none md:p-5 ${
        level ? 'md:grid md:grid-cols-2 md:items-start md:gap-6' : ''
      }`}
    >
      <div>
        <div className="flex items-start justify-between gap-3">
          <span className="font-mono text-[13px] font-bold uppercase tracking-[0.08em] text-brand">
            Évaluation
          </span>
          <span className="rounded-[6px] border-2 border-[#0a2342] bg-[#fde3dc] px-2 py-0.5 font-mono text-[11px] uppercase tracking-[0.06em] text-[#0a2342] leading-none">
            En progression
          </span>
        </div>

        <div className="mt-2 flex flex-col gap-1.5 md:flex-row md:items-end md:justify-between md:gap-5">
          <p className="font-serif text-[40px] font-bold leading-none text-brand md:text-[56px]">
            {Math.round(summary.successPercentage)}&nbsp;%
          </p>
          <div className="text-[12px] text-ink-secondary md:text-right md:text-sm">
            <p>
              {summary.correctAnswersCount} {correctLabel} sur {summary.totalQuestions}
            </p>
            {durationLabel && <p className="mt-1">{durationLabel}</p>}
          </div>
        </div>
      </div>

      {level && (
        <div className="md:flex md:flex-col md:border-l-2 md:border-border md:pl-6">
          <LevelGauge level={level} />

          {level.provisional && (
            <p className="mt-2.5 text-[12px] text-ink-secondary md:text-sm">
              Première estimation, à confirmer.
            </p>
          )}

          {isPlacement && (
            <Button
              type="button"
              variant="primary"
              size="lg"
              fullWidth
              className="mt-3 md:w-auto md:self-end"
              rightIcon={<ArrowRight className="h-4 w-4" />}
              onClick={() => {
                trackEvent('placement_continue_clicked', {
                  simulationId: summary.simulationId,
                  metadata: { level: level.label },
                });
                onContinuePlacement();
              }}
            >
              Tester le niveau {targetLevel}
            </Button>
          )}
        </div>
      )}
    </section>
  );
};
