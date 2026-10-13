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

// Version compacte : une seule ligne de 3 KPIs (grid-cols-3 dès mobile),
// numéraux réduits, badge tendance dans le titre — pas de grande carte vide.
// Une valeur absente s'affiche « — » : aucune métrique inventée.
const Kpi = ({ value, label }: { value: string; label: string }) => (
  <div className="min-w-0">
    <p className="font-serif text-2xl font-bold leading-none text-navy-900 sm:text-3xl">{value}</p>
    <p className="mt-1.5 text-[11px] leading-tight text-ink-muted">{label}</p>
  </div>
);

export const UserDashboardProgress = ({ stats, loading, error }: Props) => (
  <div className={`${panelCard} p-5 sm:p-6`}>
    <div className="flex items-center justify-between gap-4">
      <div className="flex items-center gap-2.5">
        <h2 className="font-serif text-lg font-bold text-ink sm:text-xl">Votre progression</h2>
        <BarChart3 className="hidden h-4 w-4 text-crimson-700 sm:block" />
      </div>
      {stats && !loading && !error && (
        <TrendBadge trend={stats.trend} recentRate={stats.recentSuccessRate} />
      )}
    </div>

    {loading ? (
      <div className="mt-4 rounded-xl border border-dashed border-border bg-surface-elevated p-4 text-sm text-ink-muted">
        Chargement de votre progression...
      </div>
    ) : error ? (
      <div className="mt-4 rounded-xl border border-dashed border-border bg-surface-elevated p-4 text-sm text-ink-muted">
        La progression n'est pas disponible pour le moment.
      </div>
    ) : !stats || stats.totalAnswers === 0 ? (
      <div className="mt-4 rounded-xl border border-dashed border-border bg-surface-elevated p-4 text-sm leading-relaxed text-ink-muted">
        Aucune réponse enregistrée pour l'instant. Lancez une simulation pour démarrer votre suivi.
      </div>
    ) : (
      <div className="mt-4 grid grid-cols-3 gap-3 sm:gap-8">
        <Kpi
          value={stats.averageSuccessRate != null ? `${Math.round(stats.averageSuccessRate)}%` : '—'}
          label="Score moyen"
        />
        <Kpi
          value={String(stats.completedSimulations)}
          label={`Terminée${stats.completedSimulations > 1 ? 's' : ''}`}
        />
        <Kpi
          value={stats.bestSuccessRate != null ? `${Math.round(stats.bestSuccessRate)}%` : '—'}
          label="Meilleur score"
        />
      </div>
    )}
  </div>
);
