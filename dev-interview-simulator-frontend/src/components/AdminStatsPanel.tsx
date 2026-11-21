import { useState, useEffect } from 'react';
import { statsApi } from '../api/adminApi';
import type { AdminStats } from '../api/adminApi';
import { panel, tableHead, emptyState } from '../styles/ui';

const nf = new Intl.NumberFormat('fr-FR');

interface StatCardProps {
  label: string;
  value: number;
  hint: string;
  onClick?: () => void;
}

const StatCard = ({ label, value, hint, onClick }: StatCardProps) => {
  const className =
    'bg-surface rounded-2xl border-[0.5px] border-card-border shadow-panel p-5 space-y-1 text-left w-full';
  const content = (
    <>
      <p className="text-xs uppercase tracking-wider text-ink-muted font-semibold">{label}</p>
      <p className="font-serif text-3xl font-bold text-navy-900">{nf.format(value)}</p>
      <p className="text-xs text-ink-secondary">{hint}</p>
    </>
  );

  if (!onClick) {
    return <div className={className}>{content}</div>;
  }

  return (
    <button
      type="button"
      onClick={onClick}
      className={`${className} cursor-pointer transition hover:bg-surface-elevated focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2`}
    >
      {content}
    </button>
  );
};

interface Props {
  onOpenUsers: () => void;
}

export const AdminStatsPanel = ({ onOpenUsers }: Props) => {
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    statsApi.getStats()
      .then(setStats)
      .catch(() => setError(true));
  }, []);

  if (error) {
    return (
      <div className={`bg-surface rounded-2xl border-[0.5px] border-card-border ${emptyState}`}>
        Impossible de charger les statistiques.
      </div>
    );
  }

  if (!stats) {
    return (
      <div className={`bg-surface rounded-2xl border-[0.5px] border-card-border ${emptyState}`}>
        Chargement...
      </div>
    );
  }

  const cards: StatCardProps[] = [
    {
      label: 'Contenus',
      value: stats.totalChallenges,
      hint: `${stats.challengesDraft} brouillons · ${stats.challengesValidated} validés · ${stats.challengesArchived} archivés`
    },
    {
      label: 'Profils',
      value: stats.totalProfiles,
      hint: `${stats.activeProfiles} actifs`
    },
    {
      label: 'Utilisateurs',
      value: stats.totalUsers,
      hint: `${stats.newUsersLast7Days} sur 7 j · ${stats.newUsersLast30Days} sur 30 j`,
      onClick: onOpenUsers
    },
    {
      label: 'Simulations',
      value: stats.totalSimulations,
      hint: `${stats.completedSimulations} terminées · ${stats.inProgressSimulations} en cours`
    }
  ];

  const simulationMetrics = [
    { label: 'Terminées', value: nf.format(stats.completedSimulations) },
    { label: 'En cours', value: nf.format(stats.inProgressSimulations) },
    { label: 'Abandonnées', value: nf.format(stats.abandonedSimulations) },
    {
      label: 'Taux de finalisation',
      value: stats.completionRate === null ? '—' : `${stats.completionRate} %`
    },
    {
      label: 'Simulations / utilisateur actif',
      value: stats.averageSimulationsPerActiveUser === null
        ? '—'
        : stats.averageSimulationsPerActiveUser.toFixed(1)
    }
  ];

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {cards.map(card => (
          <StatCard
            key={card.label}
            label={card.label}
            value={card.value}
            hint={card.hint}
            onClick={card.onClick}
          />
        ))}
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
        {simulationMetrics.map(metric => (
          <div
            key={metric.label}
            className="bg-surface rounded-xl border border-card-border px-4 py-3 space-y-1"
          >
            <p className="text-[11px] uppercase tracking-wider text-ink-muted font-semibold">
              {metric.label}
            </p>
            <p className="font-serif text-xl font-bold text-navy-900">{metric.value}</p>
          </div>
        ))}
      </div>

      <div className={panel}>
        <div className="px-6 py-4 border-b border-border-subtle">
          <h3 className="font-serif font-bold text-lg text-navy-900">Contenus par type</h3>
        </div>
        <table className="w-full text-sm text-left">
          <thead className={tableHead}>
            <tr>
              <th className="px-6 py-3 font-medium">Type</th>
              <th className="px-6 py-3 font-medium text-right">Nombre</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border-subtle">
            {Object.entries(stats.challengesByType).map(([type, count]) => (
              <tr key={type} className="hover:bg-surface-elevated transition">
                <td className="px-6 py-3 text-ink">{type}</td>
                <td className="px-6 py-3 text-right font-mono font-semibold text-navy-900">{count}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
