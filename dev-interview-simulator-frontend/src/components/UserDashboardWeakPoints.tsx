import { useEffect, useRef, useState } from 'react';
import { ChevronDown, Code2, TrendingDown, Wrench, X } from 'lucide-react';
import { Button } from './common/Button';
import { panelCard } from '../styles/ui';
import type { UserStats } from '../api/userStatsApi';

const MIN_ANSWERS_FOR_RELIABLE_RATE = 3;

interface Props {
  weakPoints: UserStats['weakPoints'];
  onRevise?: (filters: { categoryIds?: number[]; skillIds?: number[] }) => void;
}

export const UserDashboardWeakPoints = ({ weakPoints, onRevise }: Props) => {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const dialogRef = useRef<HTMLDivElement>(null);
  const technicalPoints = weakPoints.filter((point) => point.source === 'CATEGORY');
  const transversalPoints = weakPoints.filter((point) => point.source === 'SKILL');
  const visibleWeakPoints = technicalPoints.slice(0, 5);
  const hiddenCount = Math.max(0, weakPoints.length - visibleWeakPoints.length);

  useEffect(() => {
    if (!isDialogOpen) return;

    const previousFocus = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    const closeOnEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setIsDialogOpen(false);
    };
    document.addEventListener('keydown', closeOnEscape);
    dialogRef.current?.focus();

    return () => {
      document.removeEventListener('keydown', closeOnEscape);
      previousFocus?.focus();
    };
  }, [isDialogOpen]);

  return (
  <section className={`${panelCard} p-5 sm:p-6`}>
    <div className="flex items-center justify-between gap-4">
      <div>
        <h2 className="font-serif text-lg font-bold text-ink sm:text-xl">À travailler</h2>
        <p className="mt-1 text-xs text-ink-muted">Vos axes techniques à renforcer</p>
      </div>
      <TrendingDown className="h-5 w-5 text-crimson-700" />
    </div>
    {weakPoints.length === 0 ? (
      <div className="mt-5 rounded-xl border border-dashed border-border bg-surface-elevated p-5 text-sm leading-relaxed text-ink-muted">
        Aucun point faible identifié pour l'instant : toutes vos compétences pratiquées
        sont actuellement à 100 %. Continuez ainsi, ou élargissez votre entraînement à
        d'autres technologies.
      </div>
    ) : (
      <>
      {visibleWeakPoints.length === 0 ? (
        <p className="mt-4 text-sm text-ink-muted">Aucun axe technique identifié pour l’instant.</p>
      ) : (
      <div className="mt-3 divide-y divide-border-subtle">
        {visibleWeakPoints.map((category, index) => (
          <div
            key={`${category.source}-${category.id}`}
            className={`flex items-center justify-between gap-3 py-3 ${index === 0 || visibleWeakPoints[index - 1]?.source !== category.source ? 'border-t border-border-subtle' : ''}`}
          >
            <div className="min-w-0">
              {index === 0 && (
                <span className="mb-1.5 inline-flex items-center gap-1 rounded-sm border-2 border-navy-200 bg-navy-100 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-navy-900 shadow-[2px_2px_0_var(--color-shadow)]">
                  <Code2 className="h-3 w-3" aria-hidden="true" />
                  Technique · {technicalPoints.length}
                </span>
              )}
              <p className="truncate text-sm font-semibold text-ink">{category.name}</p>
              <p className="mt-0.5 text-xs text-ink-muted">
                <span
                  className={
                    category.successRate < 50
                      ? 'font-semibold text-crimson-700'
                      : 'font-semibold text-navy-900'
                  }
                >
                  {Math.round(category.successRate)}%
                </span>{' '}
                · {category.correct}/{category.answered} correctes
              </p>
              {category.answered < MIN_ANSWERS_FOR_RELIABLE_RATE && (
                <span className="mt-1 inline-flex rounded-full border border-border-subtle bg-surface-elevated px-2 py-0.5 text-[10px] font-medium text-ink-muted">
                  À confirmer
                </span>
              )}
            </div>
            {onRevise && (
              <Button
                type="button"
                variant="secondary"
                size="sm"
                onClick={() => onRevise(category.source === 'SKILL'
                  ? { skillIds: [category.id] }
                  : { categoryIds: [category.id] })}
                className="flex-shrink-0"
              >
                Réviser
              </Button>
            )}
          </div>
        ))}
      </div>
      )}
      </>
    )}
    {hiddenCount > 0 && (
      <button
        type="button"
        onClick={() => setIsDialogOpen(true)}
        className="mt-4 inline-flex items-center gap-1.5 text-xs font-semibold text-navy-900 transition hover:text-crimson-700 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas rounded-md"
      >
        <ChevronDown className="h-3.5 w-3.5" />
        {technicalPoints.length > visibleWeakPoints.length
          ? `Voir les ${hiddenCount} autres axes`
          : `Voir les compétences transversales (${transversalPoints.length})`}
      </button>
    )}
    {isDialogOpen && (
      <div
        className="fixed inset-0 z-50 flex items-end justify-center bg-ink/25 p-0 backdrop-blur-[2px] sm:items-center sm:p-4"
        onMouseDown={(event) => {
          if (event.target === event.currentTarget) setIsDialogOpen(false);
        }}
      >
        <div
          ref={dialogRef}
          role="dialog"
          aria-modal="true"
          aria-labelledby="weak-points-dialog-title"
          tabIndex={-1}
          className="flex max-h-[85vh] w-full max-w-lg flex-col rounded-t-2xl border-2 border-card-border bg-surface p-5 shadow-modal outline-none sm:rounded-2xl sm:p-6"
        >
          <div className="flex items-start justify-between gap-4 border-b border-border-subtle pb-4">
            <div>
              <h3 id="weak-points-dialog-title" className="font-serif text-lg font-bold text-ink">
                Tous vos axes à travailler
              </h3>
              <p className="mt-1 text-xs text-ink-muted">{weakPoints.length} axes · par famille</p>
            </div>
            <button
              type="button"
              onClick={() => setIsDialogOpen(false)}
              aria-label="Fermer la liste des axes"
              className="rounded-sm border-2 border-border bg-surface p-1.5 text-ink-muted shadow-[2px_2px_0_var(--color-shadow)] transition hover:text-navy-900 focus-visible:ring-2 focus-visible:ring-navy-900"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
          <div className="min-h-0 flex-1 space-y-4 overflow-y-auto overscroll-contain pt-3">
            {[
              { label: 'Technique', source: 'CATEGORY' as const, points: technicalPoints },
              { label: 'Transversal', source: 'SKILL' as const, points: transversalPoints },
            ].map(({ label, source, points }) => points.length > 0 && (
              <section key={source} aria-label={`Axes ${label.toLowerCase()}`}>
                <span
                  className={`mb-1.5 inline-flex items-center gap-1 rounded-sm border-2 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide shadow-[2px_2px_0_var(--color-shadow)] ${
                    source === 'CATEGORY'
                      ? 'border-navy-200 bg-navy-100 text-navy-900'
                      : 'border-crimson-200 bg-crimson-100 text-crimson-700'
                  }`}
                >
                  {source === 'CATEGORY' ? <Code2 className="h-3 w-3" aria-hidden="true" /> : <Wrench className="h-3 w-3" aria-hidden="true" />}
                  {label} · {points.length}
                </span>
                <div className="divide-y divide-border-subtle">
                  {points.map((point) => (
                    <div key={`${point.source}-${point.id}`} className="flex items-center justify-between gap-3 py-3">
                      <div className="min-w-0">
                        <p className="truncate text-sm font-semibold text-ink">{point.name}</p>
                        <p className="mt-0.5 text-xs text-ink-muted">
                          <span className={point.successRate < 50 ? 'font-semibold text-crimson-700' : 'font-semibold text-navy-900'}>
                            {Math.round(point.successRate)}%
                          </span>{' '}· {point.correct}/{point.answered} correctes
                        </p>
                        {point.answered < MIN_ANSWERS_FOR_RELIABLE_RATE && (
                          <span className="mt-1 inline-flex rounded-full border border-border-subtle bg-surface-elevated px-2 py-0.5 text-[10px] font-medium text-ink-muted">
                            À confirmer
                          </span>
                        )}
                      </div>
                      {onRevise && (
                        <Button
                          type="button"
                          variant="secondary"
                          size="sm"
                          onClick={() => {
                            setIsDialogOpen(false);
                            onRevise(source === 'SKILL' ? { skillIds: [point.id] } : { categoryIds: [point.id] });
                          }}
                          className="flex-shrink-0"
                        >
                          Réviser
                        </Button>
                      )}
                    </div>
                  ))}
                </div>
              </section>
            ))}
          </div>
        </div>
      </div>
    )}
  </section>
  );
};
