import { useState } from 'react';
import { Cpu, ChevronDown, ChevronUp } from 'lucide-react';
import { panelCard } from '../styles/ui';
import type { UserStats } from '../api/userStatsApi';

interface Props {
  byCategory: UserStats['byCategory'];
}

const VISIBLE_COUNT = 5;

// Compétences les plus maîtrisées (taux décroissant) : 5 maximum sur le
// dashboard pour rester lisible sur mobile. Le reste se déplie sur place —
// les données sont déjà toutes présentes dans la réponse /user/stats,
// aucun nouvel endpoint ni carousel horizontal.
export const UserDashboardSkills = ({ byCategory }: Props) => {
  const [expanded, setExpanded] = useState(false);

  const sorted = [...byCategory].sort((a, b) => {
    const byRate = b.successRate - a.successRate;
    return byRate !== 0 ? byRate : b.answered - a.answered;
  });
  const visible = expanded ? sorted : sorted.slice(0, VISIBLE_COUNT);

  return (
    <section className={`${panelCard} p-5 sm:p-6`}>
      <div className="flex items-center justify-between gap-4">
        <div>
          <h2 className="font-serif text-lg font-bold text-ink sm:text-xl">Compétences</h2>
          <p className="mt-1 text-xs text-ink-muted">Vos taux de réussite par technologie</p>
        </div>
        <Cpu className="h-5 w-5 text-navy-900" />
      </div>

      <div className="mt-5 space-y-4">
        {visible.map((category) => (
          <div key={category.id}>
            <div className="flex items-center justify-between gap-3 text-sm">
              <span className="min-w-0 truncate font-medium text-ink">{category.name}</span>
              <span className="flex-shrink-0 text-xs font-mono text-ink-muted">
                {Math.round(category.successRate)}%
              </span>
            </div>
            <div className="mt-1.5 h-1.5 w-full overflow-hidden rounded-full bg-navy-100">
              <div
                className={`h-full rounded-full transition-all ${
                  category.successRate < 50 ? 'bg-crimson-700' : 'bg-navy-900'
                }`}
                style={{ width: `${Math.max(3, category.successRate)}%` }}
              />
            </div>
          </div>
        ))}
      </div>

      {sorted.length > VISIBLE_COUNT && (
        <button
          type="button"
          onClick={() => setExpanded((current) => !current)}
          className="mt-5 inline-flex items-center gap-1.5 text-xs font-semibold text-navy-900 transition hover:text-crimson-700 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas rounded-md"
        >
          {expanded ? (
            <>
              Réplier <ChevronUp className="h-3.5 w-3.5" />
            </>
          ) : (
            <>
              Voir toutes les compétences ({sorted.length}) <ChevronDown className="h-3.5 w-3.5" />
            </>
          )}
        </button>
      )}
    </section>
  );
};
