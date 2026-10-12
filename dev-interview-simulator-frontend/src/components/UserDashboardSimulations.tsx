import { CalendarDays } from 'lucide-react';
import { panelCard } from '../styles/ui';
import { formatDate as formatIsoDate } from '../utils/format';
import type { UserStats } from '../api/userStatsApi';

interface Props {
  stats: UserStats | null;
  loading: boolean;
  onOpenResult?: (simulationId: number) => void;
  page: number;
  onPageChange: (page: number) => void;
}

const formatDate = (iso?: string) => {
  if (!iso) return '—';
  try {
    return formatIsoDate(iso);
  } catch {
    return '—';
  }
};

export const UserDashboardSimulations = ({ stats, loading, onOpenResult, page, onPageChange }: Props) => (
  <section className={`${panelCard} p-6`}>
    <div className="flex items-center justify-between gap-4">
      <div>
        <h2 className="font-serif text-xl font-bold text-ink">Mes simulations</h2>
        <p className="mt-1 text-xs text-ink-muted">Vos dernières sessions d'entraînement</p>
      </div>
      <CalendarDays className="h-5 w-5 text-navy-900" />
    </div>

    {loading ? (
      <div className="mt-5 rounded-xl border border-dashed border-border bg-surface-elevated p-5 text-sm text-ink-muted">
        Chargement...
      </div>
    ) : !stats || stats.simulations.totalElements === 0 ? (
      <div className="mt-5 rounded-xl border border-dashed border-border bg-surface-elevated p-5 text-sm leading-relaxed text-ink-muted">
        Aucune session enregistrée. Vos simulations terminées apparaîtront ici.
      </div>
    ) : (
      <>
        <div className="mt-5 divide-y divide-border-subtle">
          {stats.simulations.content.map(simulation => {
            const successRate = simulation.totalQuestions > 0
              ? Math.round((simulation.correctAnswers / simulation.totalQuestions) * 100)
              : 0;
            return (
              <button
                key={simulation.id}
                type="button"
                onClick={() => onOpenResult?.(simulation.id)}
                className="w-full text-left py-3 flex flex-col sm:flex-row sm:items-center gap-1.5 sm:gap-4 hover:bg-surface-elevated transition cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
              >
                <div className="flex items-center gap-2 flex-wrap">
                  <span className="font-mono text-xs text-ink-muted">{formatDate(simulation.startedAt)}</span>
                  <span className="font-semibold text-ink text-sm">{simulation.mode || 'Simulation'}</span>
                  {simulation.difficulty && (
                    <span className="text-xs text-ink-muted">{simulation.difficulty}</span>
                  )}
                </div>
                <div className="sm:ml-auto flex items-center gap-3">
                  <span className="text-xs text-ink-muted font-mono">
                    {simulation.correctAnswers}/{simulation.totalQuestions} bonnes réponses
                  </span>
                  <span
                    className={`px-2 py-1 rounded-lg text-xs font-mono font-semibold ${
                      successRate < 50
                        ? 'bg-danger-soft text-danger'
                        : 'bg-navy-100 text-navy-900'
                    }`}
                  >
                    {successRate}%
                  </span>
                  <span className="font-mono font-semibold text-navy-900">{simulation.totalScore} pts</span>
                </div>
              </button>
            );
          })}
        </div>

        {stats.simulations.totalPages > 1 && (
          <div className="mt-4 flex flex-wrap items-center justify-between gap-3 text-xs text-ink-secondary">
            <span>
              {stats.simulations.page * stats.simulations.size + 1}–
              {Math.min(
                (stats.simulations.page + 1) * stats.simulations.size,
                stats.simulations.totalElements
              )}{' '}
              sur {stats.simulations.totalElements}
            </span>
            <div className="flex gap-2">
              <button
                onClick={() => onPageChange(Math.max(0, page - 1))}
                disabled={stats.simulations.page === 0}
                className="px-4 py-2 min-h-[40px] rounded-lg border border-border bg-surface hover:bg-canvas-subtle disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
              >
                Précédent
              </button>
              <button
                onClick={() => onPageChange(Math.min(stats.simulations.totalPages - 1, page + 1))}
                disabled={stats.simulations.page >= stats.simulations.totalPages - 1}
                className="px-4 py-2 min-h-[40px] rounded-lg border border-border bg-surface hover:bg-canvas-subtle disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
              >
                Suivant
              </button>
            </div>
          </div>
        )}
      </>
    )}
  </section>
);
