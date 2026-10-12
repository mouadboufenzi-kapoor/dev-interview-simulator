import { TrendingDown } from 'lucide-react';
import { Button } from './common/Button';
import { panelCard } from '../styles/ui';
import type { UserStats } from '../api/userStatsApi';

interface Props {
  weakPoints: UserStats['weakPoints'];
  onRevise?: (categoryIds: number[]) => void;
}

export const UserDashboardWeakPoints = ({ weakPoints, onRevise }: Props) => (
  <section className={`${panelCard} p-6`}>
    <div className="flex items-center justify-between gap-4">
      <div>
        <h2 className="font-serif text-xl font-bold text-ink">Points faibles</h2>
        <p className="mt-1 text-xs text-ink-muted">
          Les compétences à retravailler en priorité selon vos réponses
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
      <div className="mt-5 grid gap-4 sm:grid-cols-3">
        {weakPoints.map(category => (
          <div
            key={category.id}
            className="rounded-xl border border-border bg-surface-elevated p-4 space-y-2"
          >
            <p className="font-semibold text-ink text-sm">{category.name}</p>
            <p className="text-xs text-ink-muted">
              {category.correct}/{category.answered} correctes ·{' '}
              <span className={category.successRate < 50 ? 'text-crimson-700 font-semibold' : 'text-navy-900 font-semibold'}>
                {Math.round(category.successRate)}%
              </span>
            </p>
            {onRevise && (
              <Button
                type="button"
                variant="secondary"
                size="sm"
                onClick={() => onRevise([category.id])}
              >
                Réviser
              </Button>
            )}
          </div>
        ))}
      </div>
    )}
  </section>
);
