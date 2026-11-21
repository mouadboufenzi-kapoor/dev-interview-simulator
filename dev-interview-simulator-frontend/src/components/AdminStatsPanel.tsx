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

  const share = (count: number) => stats.totalSimulations === 0
    ? '—'
    : `${((count / stats.totalSimulations) * 100).toFixed(1)} %`;

  const simulationRows = [
    {
      label: 'Terminées',
      value: nf.format(stats.completedSimulations),
      detail: `${share(stats.completedSimulations)} des simulations`
    },
    {
      label: 'En cours',
      value: nf.format(stats.inProgressSimulations),
      detail: `${share(stats.inProgressSimulations)} des simulations`
    },
    {
      label: 'Abandonnées',
      value: nf.format(stats.abandonedSimulations),
      detail: `${share(stats.abandonedSimulations)} des simulations`
    },
    {
      label: 'Taux de finalisation',
      value: stats.completionRate === null ? '—' : `${stats.completionRate} %`,
      detail: 'terminées / lancées'
    },
    {
      label: 'Simulations / utilisateur actif',
      value: stats.averageSimulationsPerActiveUser === null
        ? '—'
        : stats.averageSimulationsPerActiveUser.toFixed(1),
      detail: 'comptes inscrits ayant lancé au moins une simulation'
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

      <div className={panel}>
        <div className="px-6 py-4 border-b border-border-subtle">
          <h3 className="font-serif font-bold text-lg text-navy-900">Simulations</h3>
          <p className="text-xs text-ink-secondary">
            {nf.format(stats.totalSimulations)} simulations lancées au total
          </p>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-left">
            <thead className={tableHead}>
              <tr>
                <th className="px-6 py-3 font-medium">Indicateur</th>
                <th className="px-6 py-3 font-medium text-right">Valeur</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border-subtle">
              {simulationRows.map(row => (
                <tr key={row.label} className="hover:bg-surface-elevated transition">
                  <td className="px-6 py-4 font-medium text-ink">
                    {row.label}
                    <span className="ml-1 text-xs font-normal text-ink-secondary">({row.detail})</span>
                  </td>
                  <td className="px-6 py-4 text-right font-serif text-2xl font-bold text-navy-900">{row.value}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
