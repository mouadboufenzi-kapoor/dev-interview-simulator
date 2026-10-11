import { useEffect, useState } from 'react';
import {
  ArrowRight,
  BarChart3,
  CalendarDays,
  Minus,
  TrendingDown,
  TrendingUp,
  UserRound,
} from 'lucide-react';
import { Button } from './common/Button';
import type { AuthUser } from './UserAccessModal';
import { userStatsApi } from '../api/userStatsApi';
import type { UserStats } from '../api/userStatsApi';

interface Props {
  user: AuthUser;
  onStartSimulation: () => void;
  onRevise?: (categoryIds: number[]) => void;
  onOpenResult?: (simulationId: number) => void;
}

const formatDate = (iso?: string) => {
  if (!iso) return '—';
  try {
    return new Date(iso).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' });
  } catch {
    return '—';
  }
};

const TrendBadge = ({ trend, recentRate }: { trend?: string | null; recentRate?: number | null }) => {
  if (!trend || recentRate == null) return null;
  const config = {
    UP: { icon: TrendingUp, label: 'En progression', className: 'text-[#2E7D32] bg-[#E8F5E9]' },
    DOWN: { icon: TrendingDown, label: 'En baisse', className: 'text-[#9C2727] bg-[#FDF2F2]' },
    STABLE: { icon: Minus, label: 'Stable', className: 'text-[#484F59] bg-[#FAF9F7]' },
  }[trend as 'UP' | 'DOWN' | 'STABLE'];
  if (!config) return null;
  const Icon = config.icon;
  return (
    <span className={`inline-flex items-center gap-1 px-2 py-1 rounded-lg text-xs font-semibold ${config.className}`}>
      <Icon className="w-3.5 h-3.5" /> {config.label} · {Math.round(recentRate)}%
    </span>
  );
};

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
          <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[#797E88]">
            Tableau de bord
          </p>
          <h1 className="mt-2 font-serif text-4xl font-semibold tracking-tight text-[#123C69]">
            Bonjour, {user.username}
          </h1>
          <p className="mt-2 max-w-lg text-sm leading-relaxed text-[#484F59]">
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
        <div className="rounded-2xl border border-[#E8E2D8] bg-white p-6 shadow-[0_2px_10px_rgba(18,60,105,0.05)]">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#E6EFF8] text-[#123C69]">
              <UserRound className="h-5 w-5" />
            </div>
            <div>
              <h2 className="font-serif text-xl font-bold text-[#102136]">Profil</h2>
              <p className="text-xs text-[#797E88]">Votre espace de préparation</p>
            </div>
          </div>
          <dl className="mt-7 space-y-4 text-sm">
            <div className="flex items-center justify-between gap-4 border-b border-[#F2EDE6] pb-3">
              <dt className="text-[#797E88]">Username</dt>
              <dd className="font-semibold text-[#102136]">{user.username}</dd>
            </div>
            <div className="flex items-center justify-between gap-4 border-b border-[#F2EDE6] pb-3">
              <dt className="text-[#797E88]">Email</dt>
              <dd className="max-w-[60%] truncate font-semibold text-[#102136]">{user.email}</dd>
            </div>
            <div className="flex items-center justify-between gap-4 border-b border-[#F2EDE6] pb-3">
              <dt className="text-[#797E88]">Rôle</dt>
              <dd className="font-semibold text-[#102136]">{user.role || 'USER'}</dd>
            </div>
            <div className="flex items-center justify-between gap-4">
              <dt className="text-[#797E88]">Profil actuel</dt>
              <dd className="font-semibold text-[#123C69]">{user.profile || 'Non défini'}</dd>
            </div>
          </dl>
        </div>

        <div className="rounded-2xl border border-[#E8E2D8] bg-white p-6 shadow-[0_2px_10px_rgba(18,60,105,0.05)]">
          <div className="flex items-center justify-between gap-4">
            <div>
              <h2 className="font-serif text-xl font-bold text-[#102136]">Progression / compétences</h2>
              <p className="mt-1 text-xs text-[#797E88]">Une vue synthétique de vos entraînements</p>
            </div>
            <BarChart3 className="h-5 w-5 text-[#AC3B61]" />
          </div>

          {loading ? (
            <div className="mt-6 rounded-xl border border-dashed border-[#E8E2D8] bg-[#FCFBF9] p-5 text-sm text-[#797E88]">
              Chargement de votre progression...
            </div>
          ) : error ? (
            <div className="mt-6 rounded-xl border border-dashed border-[#E8E2D8] bg-[#FCFBF9] p-5 text-sm text-[#797E88]">
              La progression n'est pas disponible pour le moment.
            </div>
          ) : !stats || stats.totalAnswers === 0 ? (
            <div className="mt-6 rounded-xl border border-dashed border-[#E8E2D8] bg-[#FCFBF9] p-5 text-sm leading-relaxed text-[#797E88]">
              Aucune réponse enregistrée pour l'instant. Lancez une simulation pour démarrer votre suivi.
            </div>
          ) : (
            <>
              <div className="mt-6 flex flex-wrap items-end gap-4">
                <div>
                  <p className="font-serif text-4xl font-bold text-[#123C69]">
                    {Math.round(stats.globalSuccessRate ?? 0)}%
                  </p>
                  <p className="text-xs text-[#797E88]">
                    Réussite globale · {stats.correctAnswers}/{stats.totalAnswers} réponses
                  </p>
                </div>
                <div className="pb-1">
                  <TrendBadge trend={stats.trend} recentRate={stats.recentSuccessRate} />
                  <p className="text-xs text-[#797E88] mt-1">
                    {stats.totalSimulations} simulation{stats.totalSimulations > 1 ? 's' : ''} ·{' '}
                    {stats.completedSimulations} terminée{stats.completedSimulations > 1 ? 's' : ''}
                  </p>
                </div>
              </div>

              {stats.byCategory.length > 0 && (
                <div className="mt-6 space-y-3">
                  <p className="text-xs font-semibold uppercase tracking-wider text-[#797E88]">
                    Par technologie
                  </p>
                  {stats.byCategory.slice(0, 6).map(category => (
                    <div key={category.id}>
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-[#102136] font-medium">{category.name}</span>
                        <span className="text-xs text-[#797E88] font-mono">
                          {category.correct}/{category.answered} · {Math.round(category.successRate)}%
                        </span>
                      </div>
                      <div className="mt-1 h-1.5 w-full rounded-full bg-[#E6EFF8] overflow-hidden">
                        <div
                          className={`h-full rounded-full transition-all ${category.successRate < 50 ? 'bg-[#AC3B61]' : 'bg-[#123C69]'}`}
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
      </section>

      {stats && !loading && !error && stats.totalAnswers > 0 && (
        <section className="rounded-2xl border border-[#E8E2D8] bg-white p-6 shadow-[0_2px_10px_rgba(18,60,105,0.05)]">
          <div className="flex items-center justify-between gap-4">
            <div>
              <h2 className="font-serif text-xl font-bold text-[#102136]">Points faibles</h2>
              <p className="mt-1 text-xs text-[#797E88]">
                Les compétences à retravailler en priorité selon vos réponses
              </p>
            </div>
            <TrendingDown className="h-5 w-5 text-[#AC3B61]" />
          </div>
          {stats.weakPoints.length === 0 ? (
            <div className="mt-5 rounded-xl border border-dashed border-[#E8E2D8] bg-[#FCFBF9] p-5 text-sm leading-relaxed text-[#797E88]">
              Aucun point faible identifié pour l'instant : toutes vos compétences pratiquées
              sont actuellement à 100 %. Continuez ainsi, ou élargissez votre entraînement à
              d'autres technologies.
            </div>
          ) : (
            <div className="mt-5 grid gap-4 sm:grid-cols-3">
              {stats.weakPoints.map(category => (
                <div
                  key={category.id}
                  className="rounded-xl border border-[#E8E2D8] bg-[#FCFBF9] p-4 space-y-2"
                >
                  <p className="font-semibold text-[#102136] text-sm">{category.name}</p>
                  <p className="text-xs text-[#797E88]">
                    {category.correct}/{category.answered} correctes ·{' '}
                    <span className={category.successRate < 50 ? 'text-[#AC3B61] font-semibold' : 'text-[#123C69] font-semibold'}>
                      {Math.round(category.successRate)}%
                    </span>
                  </p>
                  {onRevise && (
                    <Button
                      type="button"
                      variant="secondary"
                      size="sm"
                      onClick={() => onRevise([category.id])}
                    >
                      Réviser
                    </Button>
                  )}
                </div>
              ))}
            </div>
          )}
        </section>
      )}

      <section className="rounded-2xl border border-[#E8E2D8] bg-white p-6 shadow-[0_2px_10px_rgba(18,60,105,0.05)]">
        <div className="flex items-center justify-between gap-4">
          <div>
            <h2 className="font-serif text-xl font-bold text-[#102136]">Mes simulations</h2>
            <p className="mt-1 text-xs text-[#797E88]">Vos dernières sessions d'entraînement</p>
          </div>
          <CalendarDays className="h-5 w-5 text-[#123C69]" />
        </div>

        {loading ? (
          <div className="mt-5 rounded-xl border border-dashed border-[#E8E2D8] bg-[#FCFBF9] p-5 text-sm text-[#797E88]">
            Chargement...
          </div>
        ) : !stats || stats.simulations.totalElements === 0 ? (
          <div className="mt-5 rounded-xl border border-dashed border-[#E8E2D8] bg-[#FCFBF9] p-5 text-sm leading-relaxed text-[#797E88]">
            Aucune session enregistrée. Vos simulations terminées apparaîtront ici.
          </div>
        ) : (
          <>
            <div className="mt-5 divide-y divide-[#F2EDE6]">
              {stats.simulations.content.map(simulation => {
                const successRate = simulation.totalQuestions > 0
                  ? Math.round((simulation.correctAnswers / simulation.totalQuestions) * 100)
                  : 0;
                return (
                  <button
                    key={simulation.id}
                    type="button"
                    onClick={() => onOpenResult?.(simulation.id)}
                    className="w-full text-left py-3 flex flex-col sm:flex-row sm:items-center gap-1.5 sm:gap-4 hover:bg-[#FCFBF9] transition cursor-pointer"
                  >
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="font-mono text-xs text-[#797E88]">{formatDate(simulation.startedAt)}</span>
                      <span className="font-semibold text-[#102136] text-sm">{simulation.mode || 'Simulation'}</span>
                      {simulation.difficulty && (
                        <span className="text-xs text-[#797E88]">{simulation.difficulty}</span>
                      )}
                    </div>
                    <div className="sm:ml-auto flex items-center gap-3">
                      <span className="text-xs text-[#797E88] font-mono">
                        {simulation.correctAnswers}/{simulation.totalQuestions} bonnes réponses
                      </span>
                      <span
                        className={`px-2 py-1 rounded-lg text-xs font-mono font-semibold ${
                          successRate < 50
                            ? 'bg-[#FDF2F2] text-[#9C2727]'
                            : 'bg-[#E6EFF8] text-[#123C69]'
                        }`}
                      >
                        {successRate}%
                      </span>
                      <span className="font-mono font-semibold text-[#123C69]">{simulation.totalScore} pts</span>
                    </div>
                  </button>
                );
              })}
            </div>

            {stats.simulations.totalPages > 1 && (
              <div className="mt-4 flex flex-wrap items-center justify-between gap-3 text-xs text-[#484F59]">
                <span>
                  {stats.simulations.page * stats.simulations.size + 1}–
                  {Math.min(
                    (stats.simulations.page + 1) * stats.simulations.size,
                    stats.simulations.totalElements
                  )}{' '}
                  sur {stats.simulations.totalElements}
                </span>
                <div className="flex gap-2">
                  <button
                    onClick={() => setSimPage(p => Math.max(0, p - 1))}
                    disabled={stats.simulations.page === 0}
                    className="px-4 py-2 min-h-[40px] rounded-lg border border-[#E8E2D8] bg-white hover:bg-[#FAF9F7] disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer"
                  >
                    Précédent
                  </button>
                  <button
                    onClick={() => setSimPage(p => Math.min(stats.simulations.totalPages - 1, p + 1))}
                    disabled={stats.simulations.page >= stats.simulations.totalPages - 1}
                    className="px-4 py-2 min-h-[40px] rounded-lg border border-[#E8E2D8] bg-white hover:bg-[#FAF9F7] disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer"
                  >
                    Suivant
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </section>
    </div>
  );
};
