import { useState } from 'react';
import { CalendarDays, ChevronRight } from 'lucide-react';
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

const VISIBLE_COUNT = 3;

const MODE_LABELS: Record<string, string> = {
  SITUATIONAL_QCM: 'QCM',
  CODE_REVIEW: 'Code Review',
  ARCHITECTURE: 'Architecture',
  PROBLEM_SOLVING: 'Problem Solving',
};

const STATUS_LABELS: Record<string, string> = {
  COMPLETED: 'Terminée',
  IN_PROGRESS: 'En cours',
  ABANDONED: 'Abandonnée',
};

const formatDate = (iso?: string) => {
  if (!iso) return '—';
  try {
    return formatIsoDate(iso);
  } catch {
    return '—';
  }
};

// Mes dernières simulations : 3 dernières sessions en lignes compactes
// (mobile d'abord) avec statut réel ; « Voir toutes » déplie l'historique
// paginé existant (même mécanisme serveur, aucun nouvel endpoint).
export const UserDashboardSimulations = ({ stats, loading, onOpenResult, page, onPageChange }: Props) => {
  const [expanded, setExpanded] = useState(false);
  const simulations = stats?.simulations;
  const rows = simulations && expanded ? simulations.content : (simulations?.content.slice(0, VISIBLE_COUNT) ?? []);

  return (
    <section className={`${panelCard} p-5 sm:p-6`}>
      <div className="flex items-center justify-between gap-4">
        <div>
          <h2 className="font-serif text-lg font-bold text-ink sm:text-xl">Mes dernières simulations</h2>
          <p className="mt-1 text-xs text-ink-muted">Vos sessions d'entraînement récentes</p>
        </div>
        <CalendarDays className="h-5 w-5 text-navy-900" />
      </div>

      {loading ? (
        <div className="mt-5 rounded-xl border border-dashed border-border bg-surface-elevated p-5 text-sm text-ink-muted">
          Chargement...
        </div>
      ) : !simulations || simulations.totalElements === 0 ? (
        <div className="mt-5 rounded-xl border border-dashed border-border bg-surface-elevated p-5 text-sm leading-relaxed text-ink-muted">
          Aucune session enregistrée. Vos simulations apparaîtront ici.
        </div>
      ) : (
        <>
          <div className="mt-3 divide-y divide-border-subtle">
            {rows.map((simulation) => {
              const successRate =
                simulation.totalQuestions > 0
                  ? Math.round((simulation.correctAnswers / simulation.totalQuestions) * 100)
                  : 0;
              const modeLabel = simulation.mode
                ? MODE_LABELS[simulation.mode] || simulation.mode
                : 'Simulation';
              const statusLabel = simulation.status
                ? STATUS_LABELS[simulation.status] || simulation.status
                : null;
              return (
                <button
                  key={simulation.id}
                  type="button"
                  onClick={() => onOpenResult?.(simulation.id)}
                  className="-mx-2 w-full rounded-lg px-2 py-3.5 flex items-center justify-between gap-3 text-left hover:bg-surface-elevated transition cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas sm:gap-4"
                >
                  {/* Desktop : colonnes alignées (date · sujet · résultat · action) ;
                      mobile : lignes compactes (date masquée). */}
                  <span className="hidden w-24 flex-shrink-0 font-mono text-xs text-ink-muted sm:block">
                    {formatDate(simulation.startedAt)}
                  </span>
                  <div className="min-w-0 flex-1 sm:flex sm:items-baseline sm:justify-between sm:gap-4">
                    <p className="truncate text-sm font-semibold text-ink sm:w-5/12">
                      {modeLabel}
                      {simulation.difficulty && (
                        <span className="ml-2 text-xs font-normal text-ink-muted">
                          {simulation.difficulty}
                        </span>
                      )}
                    </p>
                    <p className="mt-0.5 text-xs text-ink-muted sm:mt-0 sm:w-5/12">
                      {successRate}%{statusLabel ? ` · ${statusLabel}` : ''}
                    </p>
                  </div>
                  <span className="flex flex-shrink-0 items-center gap-1 text-xs font-semibold text-navy-900">
                    Voir le bilan
                    <ChevronRight className="h-3.5 w-3.5" />
                  </span>
                </button>
              );
            })}
          </div>

          {!expanded && simulations.totalElements > VISIBLE_COUNT && (
            <button
              type="button"
              onClick={() => setExpanded(true)}
              className="mt-4 inline-flex items-center gap-1.5 text-xs font-semibold text-navy-900 transition hover:text-crimson-700 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas rounded-md"
            >
              Voir toutes les simulations ({simulations.totalElements}) →
            </button>
          )}

          {expanded && (
            <div className="mt-4 flex flex-wrap items-center justify-between gap-3 text-xs text-ink-secondary">
              <span>
                {simulations.totalPages > 1 ? (
                  <>
                    {simulations.page * simulations.size + 1}–
                    {Math.min(
                      (simulations.page + 1) * simulations.size,
                      simulations.totalElements
                    )}{' '}
                    sur {simulations.totalElements}
                  </>
                ) : (
                  <>
                    {simulations.totalElements} simulation
                    {simulations.totalElements > 1 ? 's' : ''}
                  </>
                )}
              </span>
              <div className="flex gap-2">
                {simulations.totalPages > 1 && (
                  <>
                    <button
                      type="button"
                      onClick={() => onPageChange(Math.max(0, page - 1))}
                      disabled={simulations.page === 0}
                      className="px-4 py-2 min-h-[40px] rounded-lg border border-border bg-surface hover:bg-canvas-subtle disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
                    >
                      Précédent
                    </button>
                    <button
                      type="button"
                      onClick={() => onPageChange(Math.min(simulations.totalPages - 1, page + 1))}
                      disabled={simulations.page >= simulations.totalPages - 1}
                      className="px-4 py-2 min-h-[40px] rounded-lg border border-border bg-surface hover:bg-canvas-subtle disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
                    >
                      Suivant
                    </button>
                  </>
                )}
                <button
                  type="button"
                  onClick={() => setExpanded(false)}
                  className="px-4 py-2 min-h-[40px] rounded-lg border border-border bg-surface hover:bg-canvas-subtle cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
                >
                  Réduire
                </button>
              </div>
            </div>
          )}
        </>
      )}
    </section>
  );
};
