import { TrendingDown } from 'lucide-react';
import { Button } from './common/Button';
import { panelCard } from '../styles/ui';
import type { UserStats } from '../api/userStatsApi';

interface Props {
  weakPoints: UserStats['weakPoints'];
  onRevise?: (categoryIds: number[]) => void;
}

// Points faibles : lignes compactes empilées (mobile d'abord), bouton
// « Réviser » qui lance directement une simulation ciblée sur la
// compétence — le démarrage est géré par App (même moteur que le Setup).
export const UserDashboardWeakPoints = ({ weakPoints, onRevise }: Props) => (
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
        {weakPoints.map((category) => (
          <div
            key={category.id}
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
                onClick={() => onRevise([category.id])}
                className="flex-shrink-0"
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
