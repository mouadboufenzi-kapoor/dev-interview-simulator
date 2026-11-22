import { useEffect, useState } from 'react';
import { ArrowRight } from 'lucide-react';
import { Button } from './common/Button';
import type { AuthUser } from './UserAccessModal';
import { userStatsApi } from '../api/userStatsApi';
import type { UserStats } from '../api/userStatsApi';
import type { UserLevelProgress } from '../types';
import { UserDashboardLevel } from './UserDashboardLevel';
import { UserDashboardProfile } from './UserDashboardProfile';
import { UserDashboardSkills } from './UserDashboardSkills';
import { UserDashboardWeakPoints } from './UserDashboardWeakPoints';
import { UserDashboardSimulations } from './UserDashboardSimulations';

const MOBILE_MAX_WIDTH_QUERY = '(max-width: 767px)';

interface Props {
  user: AuthUser;
  onStartSimulation: () => void;
  onRevise?: (filters: { categoryIds?: number[]; skillIds?: number[] }) => void;
  onOpenResult?: (simulationId: number) => void;
}

export const UserDashboard = ({ user, onStartSimulation, onRevise, onOpenResult }: Props) => {
  const [stats, setStats] = useState<UserStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [simPage, setSimPage] = useState(0);
  const [level, setLevel] = useState<UserLevelProgress | null>(null);
  const [levelLoading, setLevelLoading] = useState(true);
  const [levelError, setLevelError] = useState(false);
  const [isMobile, setIsMobile] = useState(() => window.matchMedia(MOBILE_MAX_WIDTH_QUERY).matches);

  useEffect(() => {
    const query = window.matchMedia(MOBILE_MAX_WIDTH_QUERY);
    const handleChange = () => setIsMobile(query.matches);
    query.addEventListener('change', handleChange);
    return () => query.removeEventListener('change', handleChange);
  }, []);

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

  useEffect(() => {
    let isMounted = true;
    setLevelLoading(true);
    setLevelError(false);
    userStatsApi.getLevel()
      .then(data => {
        if (isMounted) setLevel(data);
      })
      .catch(() => {
        if (isMounted) setLevelError(true);
      })
      .finally(() => {
        if (isMounted) setLevelLoading(false);
      });
    return () => {
      isMounted = false;
    };
  }, []);

  return (
    <div className="w-full max-w-5xl mx-auto space-y-5 py-1 sm:space-y-6 sm:py-2">
      {/* Accueil : profil actif + CTA principal */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <UserDashboardProfile user={user} level={level?.currentLevel ?? null} />
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

      <UserDashboardLevel
        level={level}
        loading={levelLoading}
        error={levelError}
        stats={stats}
        statsLoading={loading}
        statsError={error}
      />


      {/* Desktop : Compétences + À travailler côte à côte ; mobile : empilés */}
      <div className="grid gap-5 md:grid-cols-2 md:gap-6">
        {stats && !loading && !error && stats.totalAnswers > 0 && (
          <div className="order-1 md:order-2">
            <UserDashboardWeakPoints weakPoints={stats.weakPoints} onRevise={onRevise} isMobile={isMobile} />
          </div>
        )}

        {stats && !loading && !error && (stats.byCategory.length > 0 || (stats.bySkill?.length ?? 0) > 0) && (
          <div className="order-2 md:order-1">
            <UserDashboardSkills byCategory={stats.byCategory} bySkill={stats.bySkill ?? []} isMobile={isMobile} />
          </div>
        )}
      </div>

      <UserDashboardSimulations
        stats={stats}
        loading={loading}
        onOpenResult={onOpenResult}
        page={simPage}
        onPageChange={setSimPage}
      />
    </div>
  );
};
