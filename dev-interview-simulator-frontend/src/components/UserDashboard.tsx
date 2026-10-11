import { ArrowRight, BarChart3, CalendarDays, UserRound } from 'lucide-react';
import { Button } from './common/Button';
import type { AuthUser } from './UserAccessModal';

interface Props {
  user: AuthUser;
  onStartSimulation: () => void;
}

export const UserDashboard = ({ user, onStartSimulation }: Props) => {
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
          <div className="mt-6 rounded-xl border border-dashed border-[#E8E2D8] bg-[#FCFBF9] p-5 text-sm leading-relaxed text-[#797E88]">
            Les statistiques de progression seront affichées lorsque l’API de suivi
            utilisateur sera disponible.
          </div>
        </div>
      </section>

      <section className="rounded-2xl border border-[#E8E2D8] bg-white p-6 shadow-[0_2px_10px_rgba(18,60,105,0.05)]">
        <div className="flex items-center justify-between gap-4">
          <div>
            <h2 className="font-serif text-xl font-bold text-[#102136]">Mes simulations</h2>
            <p className="mt-1 text-xs text-[#797E88]">Vos dernières sessions d'entraînement</p>
          </div>
          <CalendarDays className="h-5 w-5 text-[#123C69]" />
        </div>
        <div className="mt-5 rounded-xl border border-dashed border-[#E8E2D8] bg-[#FCFBF9] p-5 text-sm leading-relaxed text-[#797E88]">
          Aucune session liée à ce compte n’est disponible pour le moment.
        </div>
      </section>
    </div>
  );
};
