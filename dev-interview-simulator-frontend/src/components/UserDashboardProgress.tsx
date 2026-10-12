import { BarChart3, Minus, TrendingDown, TrendingUp } from 'lucide-react';
import { panelCard } from '../styles/ui';
import type { UserStats } from '../api/userStatsApi';

interface Props {
  stats: UserStats | null;
  loading: boolean;
  error: boolean;
}

const TrendBadge = ({ trend, recentRate }: { trend?: string | null; recentRate?: number | null }) => {
  if (!trend || recentRate == null) return null;
  const config = {
    UP: { icon: TrendingUp, label: 'En progression', className: 'text-success-strong bg-success-surface' },
    DOWN: { icon: TrendingDown, label: 'En baisse', className: 'text-danger bg-danger-soft' },
    STABLE: { icon: Minus, label: 'Stable', className: 'text-ink-secondary bg-canvas-subtle' },
  }[trend as 'UP' | 'DOWN' | 'STABLE'];
  if (!config) return null;
  const Icon = config.icon;
  return (
    <span className={`inline-flex items-center gap-1 px-2 py-1 rounded-lg text-xs font-semibold ${config.className}`}>
      <Icon className="w-3.5 h-3.5" /> {config.label} · {Math.round(recentRate)}%
    </span>
  );
};

export const UserDashboardProgress = ({ stats, loading, error }: Props) => (
  <div className={`${panelCard} p-6`}>
    <div className="flex items-center justify-between gap-4">
      <div>
        <h2 className="font-serif text-xl font-bold text-ink">Progression / compétences</h2>
        <p className="mt-1 text-xs text-ink-muted">Une vue synthétique de vos entraînements</p>
      </div>
      <BarChart3 className="h-5 w-5 text-crimson-700" />
    </div>

    {loading ? (
      <div className="mt-6 rounded-xl border border-dashed border-border bg-surface-elevated p-5 text-sm text-ink-muted">
        Chargement de votre progression...
      </div>
    ) : error ? (
      <div className="mt-6 rounded-xl border border-dashed border-border bg-surface-elevated p-5 text-sm text-ink-muted">
        La progression n'est pas disponible pour le moment.
      </div>
    ) : !stats || stats.totalAnswers === 0 ? (
      <div className="mt-6 rounded-xl border border-dashed border-border bg-surface-elevated p-5 text-sm leading-relaxed text-ink-muted">
        Aucune réponse enregistrée pour l'instant. Lancez une simulation pour démarrer votre suivi.
      </div>
    ) : (
      <>
        <div className="mt-6 flex flex-wrap items-end gap-4">
          <div>
            <p className="font-serif text-4xl font-bold text-navy-900">
              {Math.round(stats.globalSuccessRate ?? 0)}%
            </p>
            <p className="text-xs text-ink-muted">
              Réussite globale · {stats.correctAnswers}/{stats.totalAnswers} réponses
            </p>
          </div>
          <div className="pb-1">
            <TrendBadge trend={stats.trend} recentRate={stats.recentSuccessRate} />
            <p className="text-xs text-ink-muted mt-1">
              {stats.totalSimulations} simulation{stats.totalSimulations > 1 ? 's' : ''} ·{' '}
              {stats.completedSimulations} terminée{stats.completedSimulations > 1 ? 's' : ''}
            </p>
          </div>
        </div>

        {stats.byCategory.length > 0 && (
          <div className="mt-6 space-y-3">
            <p className="text-xs font-semibold uppercase tracking-wider text-ink-muted">
              Par technologie
            </p>
            {stats.byCategory.slice(0, 6).map(category => (
              <div key={category.id}>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-ink font-medium">{category.name}</span>
                  <span className="text-xs text-ink-muted font-mono">
                    {category.correct}/{category.answered} · {Math.round(category.successRate)}%
                  </span>
                </div>
                <div className="mt-1 h-1.5 w-full rounded-full bg-navy-100 overflow-hidden">
                  <div
                    className={`h-full rounded-full transition-all ${category.successRate < 50 ? 'bg-crimson-700' : 'bg-navy-900'}`}
                    style={{ width: `${Math.max(3, category.successRate)}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        )}
      </>
    )}
  </div>
);
