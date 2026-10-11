import { useState, useEffect } from 'react';
import { statsApi } from '../api/adminApi';
import type { AdminStats } from '../api/adminApi';

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
      <div className="bg-white rounded-2xl border border-[#E8E2D8] px-6 py-8 text-center text-sm text-[#797E88]">
        Impossible de charger les statistiques.
      </div>
    );
  }

  if (!stats) {
    return (
      <div className="bg-white rounded-2xl border border-[#E8E2D8] px-6 py-8 text-center text-sm text-[#797E88]">
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
            className="bg-white rounded-2xl border border-[#E8E2D8] shadow-[0_2px_10px_rgba(18,60,105,0.05)] p-5 space-y-1"
          >
            <p className="text-xs uppercase tracking-wider text-[#797E88] font-semibold">{card.label}</p>
            <p className="font-serif text-3xl font-bold text-[#123C69]">{card.value}</p>
            <p className="text-xs text-[#484F59]">{card.hint}</p>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-2xl border border-[#E8E2D8] shadow-[0_2px_10px_rgba(18,60,105,0.05)] overflow-hidden">
        <div className="px-6 py-4 border-b border-[#F2EDE6]">
          <h3 className="font-serif font-bold text-lg text-[#123C69]">Contenus par type</h3>
        </div>
        <table className="w-full text-sm text-left">
          <thead className="text-xs text-[#797E88] uppercase bg-[#FAF9F7] border-b border-[#F2EDE6]">
            <tr>
              <th className="px-6 py-3 font-medium">Type</th>
              <th className="px-6 py-3 font-medium text-right">Nombre</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#F2EDE6]">
            {Object.entries(stats.challengesByType).map(([type, count]) => (
              <tr key={type} className="hover:bg-[#FCFBF9] transition">
                <td className="px-6 py-3 text-[#102136]">{type}</td>
                <td className="px-6 py-3 text-right font-mono font-semibold text-[#123C69]">{count}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
