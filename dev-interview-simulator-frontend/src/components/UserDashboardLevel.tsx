import { panelCard } from '../styles/ui';
import type { UserLevelProgress } from '../types';
import type { UserStats } from '../api/userStatsApi';
import { DIFFICULTY_LABELS } from '../utils/resultAnalysis';
import { Badge } from './common/Badge';

interface Props {
  level: UserLevelProgress | null;
  loading: boolean;
  error: boolean;
  stats: UserStats | null;
  statsLoading: boolean;
  statsError: boolean;
}

const Kpi = ({ value, label }: { value: string; label: string }) => (
  <div className="min-w-0">
    <p className="font-serif text-2xl font-bold leading-none text-navy-900 sm:text-3xl">{value}</p>
    <p className="mt-1.5 text-[11px] leading-tight text-ink-muted">{label}</p>
  </div>
);

const clamped = (value: number) => Math.min(100, Math.max(0, value));

export const UserDashboardLevel = ({ level, loading, error, stats, statsLoading, statsError }: Props) => {
  // En cas d'erreur, la carte n'est pas affichée.
  if (error) return null;

  const currentLabel = level ? DIFFICULTY_LABELS[level.currentLevel] ?? level.currentLevel : 'Junior';
  const nextLabel = level?.nextLevel ? DIFFICULTY_LABELS[level.nextLevel] ?? level.nextLevel : null;

  const goalReached = !!level && level.successRatePercent >= level.requiredSuccessRate;
  const correctAnswers = level ? Math.round((level.successRatePercent * level.answeredCount) / 100) : 0;
  const requiredAnswers = level ? Math.ceil((level.requiredSuccessRate * level.windowSize) / 100) : 0;

  return (
    <div className={`${panelCard} p-4 sm:p-6`}>
      <div className="flex items-center justify-between gap-2 sm:gap-3">
        <h2 className="shrink-0 whitespace-nowrap font-serif text-base font-bold text-ink sm:text-xl">
          Ma progression
        </h2>
        {level && !loading && (
          <Badge variant="navy" size="sm" className="shrink-0 whitespace-nowrap">
            <span className="text-[10px] sm:text-[11px]">
              {nextLabel ? `${currentLabel} → ${nextLabel}` : currentLabel}
            </span>
          </Badge>
        )}
      </div>

      {loading || !level ? (
        <div className="mt-4 rounded-xl border border-dashed border-border bg-surface-elevated p-4 text-sm text-ink-muted">
          Chargement de ta progression...
        </div>
      ) : !nextLabel ? (
        <p className="mt-4 text-sm text-ink-secondary">Niveau {currentLabel} atteint.</p>
      ) : (
        <>
          <div className="mt-4 flex items-end justify-between gap-3">
            <p className="shrink-0 whitespace-nowrap font-serif text-4xl font-bold leading-none text-navy-900 sm:text-5xl">
              {level.successRatePercent} %
            </p>
            <p className="min-w-0 text-right text-[11px] leading-snug text-ink-secondary sm:text-sm">
              de réussite sur tes {level.answeredCount} dernières questions {currentLabel.toLowerCase()}
            </p>
          </div>

          <div className="relative mt-4 pt-1">
            <div className="h-1.5 rounded-full bg-canvas-subtle overflow-hidden">
              <div
                className={`h-full rounded-full transition-all duration-300 ease-out ${goalReached ? 'bg-success' : 'bg-brand'}`}
                style={{ width: `${clamped(level.successRatePercent)}%` }}
              />
            </div>
            <span
              aria-hidden="true"
              className="absolute top-0.5 h-3.5 w-[2px] -translate-x-1/2 rounded-full bg-accent"
              style={{ left: `${clamped(level.requiredSuccessRate)}%` }}
            />
            <div className="relative mt-1.5 h-3.5">
              <span
                className="absolute -translate-x-1/2 font-mono text-[10px] uppercase tracking-[0.06em] text-ink-muted whitespace-nowrap"
                style={{ left: `${clamped(level.requiredSuccessRate)}%` }}
              >
                Objectif {level.requiredSuccessRate} %
              </span>
            </div>
          </div>

          <p className="mt-2 text-[11px] text-ink-secondary sm:text-xs">
            {correctAnswers} bonnes réponses sur {level.answeredCount}. Il t’en faut {requiredAnswers} pour passer{' '}
            {nextLabel}.
          </p>
        </>
      )}

      <div className="mt-4 border-t border-border-subtle pt-3 sm:mt-5">
        {statsLoading ? (
          <p className="text-sm text-ink-muted">Chargement de ta progression...</p>
        ) : statsError ? (
          <p className="text-sm text-ink-muted">La progression n’est pas disponible pour le moment.</p>
        ) : !stats || stats.totalAnswers === 0 ? (
          <p className="text-sm text-ink-muted">Aucune réponse enregistrée pour l’instant. Lance une simulation pour démarrer ton suivi.</p>
        ) : (
          <div className="grid grid-cols-3 gap-3 sm:gap-8">
            <Kpi value={String(stats.completedSimulations)} label="Simulations" />
            <Kpi
              value={stats.averageSuccessRate != null ? `${Math.round(stats.averageSuccessRate)}%` : '—'}
              label="Score moyen"
            />
            <Kpi
              value={stats.bestSuccessRate != null ? `${Math.round(stats.bestSuccessRate)}%` : '—'}
              label="Meilleur score"
            />
          </div>
        )}
      </div>
    </div>
  );
};
