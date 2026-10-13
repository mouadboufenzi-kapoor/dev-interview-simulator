import { useEffect, useState } from 'react';
import { ArrowRight } from 'lucide-react';
import { Button } from './common/Button';
import type { AuthUser } from './UserAccessModal';
import { userStatsApi } from '../api/userStatsApi';
import type { UserStats } from '../api/userStatsApi';
import { UserDashboardProfile } from './UserDashboardProfile';
import { UserDashboardProgress } from './UserDashboardProgress';
import { UserDashboardSkills } from './UserDashboardSkills';
import { UserDashboardWeakPoints } from './UserDashboardWeakPoints';
import { UserDashboardSimulations } from './UserDashboardSimulations';
import { AppAppearance } from './AppAppearance';

interface Props {
  user: AuthUser;
  onStartSimulation: () => void;
  onRevise?: (categoryIds: number[]) => void;
  onOpenResult?: (simulationId: number) => void;
}

// Dashboard utilisateur — ordre mobile-first :
// accueil (profil) → progression → compétences → priorités → dernières simulations.
export const UserDashboard = ({ user, onStartSimulation, onRevise, onOpenResult }: Props) => {
  const [stats, setStats] = useState<UserStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [simPage, setSimPage] = useState(0);

  useEffect(() => {
    let isMounted = true;
    setLoading(true);
    setError(false);
    userStatsApi.getStats(simPage)
      .then(data => {
        if (isMounted) setStats(data);
      })
      .catch(() => {
        if (isMounted) setError(true);
      })
      .finally(() => {
        if (isMounted) setLoading(false);
      });
    return () => {
      isMounted = false;
    };
  }, [simPage]);

  return (
    <div className="w-full max-w-5xl mx-auto space-y-5 py-8 sm:space-y-6 sm:py-12">
      {/* Accueil : profil actif + CTA principal */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <UserDashboardProfile user={user} onChangeProfile={onStartSimulation} />
        <Button
          type="button"
          variant="primary"
          onClick={onStartSimulation}
          rightIcon={<ArrowRight className="h-4 w-4" />}
          className="w-full justify-center sm:w-auto"
        >
          Nouvelle simulation
        </Button>
      </div>

      <UserDashboardProgress stats={stats} loading={loading} error={error} />

      {/* Desktop : Compétences + À travailler côte à côte ; mobile : empilés */}
      <div className="grid gap-5 lg:grid-cols-2 lg:items-start lg:gap-6">
        {stats && !loading && !error && stats.byCategory.length > 0 && (
          <UserDashboardSkills byCategory={stats.byCategory} />
        )}

        {stats && !loading && !error && stats.totalAnswers > 0 && (
          <UserDashboardWeakPoints weakPoints={stats.weakPoints} onRevise={onRevise} />
        )}
      </div>

      <UserDashboardSimulations
        stats={stats}
        loading={loading}
        onOpenResult={onOpenResult}
        page={simPage}
        onPageChange={setSimPage}
      />

      {/* Apparence : sélecteur de thème (palette + mode) — spec §18.
          Changement immédiat, persisté localStorage. */}
      <AppAppearance />
    </div>
  );
};
