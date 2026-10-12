import { useEffect, useState } from 'react';
import { ArrowRight } from 'lucide-react';
import { Button } from './common/Button';
import { PageTitle } from './common/PageTitle';
import type { AuthUser } from './UserAccessModal';
import { userStatsApi } from '../api/userStatsApi';
import type { UserStats } from '../api/userStatsApi';
import { UserDashboardProfile } from './UserDashboardProfile';
import { UserDashboardProgress } from './UserDashboardProgress';
import { UserDashboardWeakPoints } from './UserDashboardWeakPoints';
import { UserDashboardSimulations } from './UserDashboardSimulations';

interface Props {
  user: AuthUser;
  onStartSimulation: () => void;
  onRevise?: (categoryIds: number[]) => void;
  onOpenResult?: (simulationId: number) => void;
}

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
    <div className="w-full max-w-5xl mx-auto space-y-8 py-8 sm:py-12">
      <div className="flex flex-col items-start justify-between gap-5 sm:flex-row sm:items-end">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.18em] text-ink-muted">
            Tableau de bord
          </p>
          <PageTitle size="xl" className="mt-2">
            Bonjour, {user.username}
          </PageTitle>
          <p className="mt-2 max-w-lg text-sm leading-relaxed text-ink-secondary">
            Retrouvez votre progression et reprenez votre préparation là où vous l'avez laissée.
          </p>
        </div>
        <Button
          type="button"
          variant="primary"
          onClick={onStartSimulation}
          rightIcon={<ArrowRight className="h-4 w-4" />}
        >
          Nouvelle simulation
        </Button>
      </div>

      <section className="grid gap-5 lg:grid-cols-[0.8fr_1.2fr]">
        <UserDashboardProfile user={user} />
        <UserDashboardProgress stats={stats} loading={loading} error={error} />
      </section>

      {stats && !loading && !error && stats.totalAnswers > 0 && (
        <UserDashboardWeakPoints weakPoints={stats.weakPoints} onRevise={onRevise} />
      )}

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
