import { useState, useEffect } from 'react';
import { statsApi } from '../api/adminApi';
import type { AdminStats } from '../api/adminApi';
import { panel, tableHead, emptyState } from '../styles/ui';

export const AdminStatsPanel = () => {
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

  const cards = [
    { label: 'Contenus', value: stats.totalChallenges, hint: `${stats.challengesDraft} brouillons · ${stats.challengesValidated} validés · ${stats.challengesArchived} archivés` },
    { label: 'Profils', value: stats.totalProfiles, hint: `${stats.activeProfiles} actifs` },
    { label: 'Scénarios', value: stats.totalScenarios, hint: `${stats.activeScenarios} actifs` },
    { label: 'Simulations', value: stats.totalSimulations, hint: `${stats.completedSimulations} terminées · ${stats.inProgressSimulations} en cours` }
  ];

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {cards.map(card => (
          <div
            key={card.label}
            className="bg-surface rounded-2xl border-[0.5px] border-card-border shadow-panel p-5 space-y-1"
          >
            <p className="text-xs uppercase tracking-wider text-ink-muted font-semibold">{card.label}</p>
            <p className="font-serif text-3xl font-bold text-navy-900">{card.value}</p>
            <p className="text-xs text-ink-secondary">{card.hint}</p>
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
