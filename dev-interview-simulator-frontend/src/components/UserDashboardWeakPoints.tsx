import { useState } from 'react';
import { ChevronDown, ChevronUp, TrendingDown } from 'lucide-react';
import { Button } from './common/Button';
import { Pagination } from './common/Pagination';
import { panelCard } from '../styles/ui';
import type { UserStats } from '../api/userStatsApi';

const MIN_ANSWERS_FOR_RELIABLE_RATE = 3;
const VISIBLE_COUNT = 5;

interface Props {
  weakPoints: UserStats['weakPoints'];
  onRevise?: (filters: { categoryIds?: number[]; skillIds?: number[] }) => void;
  isMobile: boolean;
}

export const UserDashboardWeakPoints = ({ weakPoints, onRevise, isMobile }: Props) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [page, setPage] = useState(0);
  const technicalPoints = weakPoints.filter((point) => point.source === 'CATEGORY');
  const pageCount = Math.max(1, Math.ceil(technicalPoints.length / VISIBLE_COUNT));
  const currentPage = Math.min(page, pageCount - 1);
  const visibleWeakPoints = isMobile
    ? (isExpanded ? technicalPoints : technicalPoints.slice(0, VISIBLE_COUNT))
    : technicalPoints.slice(currentPage * VISIBLE_COUNT, (currentPage + 1) * VISIBLE_COUNT);

  return (
  <section className={`${panelCard} flex h-full flex-col p-5 sm:p-6`}>
    <div className="flex items-center justify-between gap-4">
      <div>
        <h2 className="font-serif text-lg font-bold text-ink sm:text-xl">À travailler</h2>
        <p className="mt-1 text-xs text-ink-muted">Vos axes techniques à renforcer</p>
      </div>
      <TrendingDown className="h-5 w-5 text-crimson-700" />
    </div>
    {technicalPoints.length === 0 ? (
      <div className="mt-5 rounded-xl border border-dashed border-border bg-surface-elevated p-5 text-sm leading-relaxed text-ink-muted">
        Aucun axe technique identifié pour l’instant : continuez votre entraînement pour
        voir apparaître ici les compétences à renforcer.
      </div>
    ) : (
      <div className="mt-3 divide-y divide-border-subtle">
        {visibleWeakPoints.map((category, index) => (
          <div
            key={`${category.source}-${category.id}`}
            className={`flex items-center justify-between gap-3 py-3 ${index === 0 ? 'border-t border-border-subtle' : ''}`}
          >
            <div className="min-w-0">
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
                onClick={() => onRevise({ categoryIds: [category.id] })}
                className="flex-shrink-0"
              >
                Réviser
              </Button>
            )}
          </div>
        ))}
      </div>
    )}
    {isMobile && technicalPoints.length > VISIBLE_COUNT && (
      <button
        type="button"
        onClick={() => setIsExpanded(!isExpanded)}
        className="mt-4 inline-flex items-center gap-1.5 text-xs font-semibold text-navy-900 transition hover:text-crimson-700 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas rounded-md"
      >
        {isExpanded ? <>Réduire <ChevronUp className="h-3.5 w-3.5" /></> : <>Voir tout ({technicalPoints.length}) <ChevronDown className="h-3.5 w-3.5" /></>}
      </button>
    )}
    {!isMobile && (
      <Pagination page={currentPage} pageCount={pageCount} onPageChange={setPage} className="mt-auto pt-4" />
    )}
  </section>
  );
};
