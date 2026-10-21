import { useState } from 'react';
import { ChevronDown, ChevronUp, TrendingDown } from 'lucide-react';
import { Button } from './common/Button';
import { panelCard } from '../styles/ui';
import type { UserStats } from '../api/userStatsApi';

interface Props {
  weakPoints: UserStats['weakPoints'];
  onRevise?: (filters: { categoryIds?: number[]; skillIds?: number[] }) => void;
}

// Points faibles : lignes compactes empilées (mobile d'abord), bouton
// « Réviser » qui lance directement une simulation ciblée sur la
// compétence — le démarrage est géré par App (même moteur que le Setup).
export const UserDashboardWeakPoints = ({ weakPoints, onRevise }: Props) => {
  const [expanded, setExpanded] = useState(false);
  const visibleWeakPoints = expanded ? weakPoints : weakPoints.slice(0, 4);

  return (
  <section className={`${panelCard} p-5 sm:p-6`}>
    <div className="flex items-center justify-between gap-4">
      <div>
        <h2 className="font-serif text-lg font-bold text-ink sm:text-xl">À travailler en priorité</h2>
        <p className="mt-1 text-xs text-ink-muted">
          Les compétences à retravailler selon vos réponses
        </p>
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
      <div className="mt-3 divide-y divide-border-subtle">
        {visibleWeakPoints.map((category) => (
          <div
            key={`${category.source}-${category.id}`}
            className="flex items-center justify-between gap-3 py-3.5"
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
    {weakPoints.length > 4 && (
      <button
        type="button"
        onClick={() => setExpanded((current) => !current)}
        className="mt-4 inline-flex items-center gap-1.5 text-xs font-semibold text-navy-900 transition hover:text-crimson-700 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas rounded-md"
      >
        {expanded ? (
          <>Réduire <ChevronUp className="h-3.5 w-3.5" /></>
        ) : (
          <>Voir tous les axes ({weakPoints.length}) <ChevronDown className="h-3.5 w-3.5" /></>
        )}
      </button>
    )}
  </section>
  );
};
