import { UserRound } from 'lucide-react';
import type { DifficultyLevel } from '../types';
import type { AuthUser } from './UserAccessModal';
import { LevelRankTag } from './LevelRankTag';

interface Props {
  user: AuthUser;
  level: DifficultyLevel | null;
}

// Bloc d'accueil orienté progression : salutation + profil actif.
// Email / rôle volontairement absents : le dashboard est un espace de
// progression, pas une fiche technique du compte (visibles ailleurs).
// Un seul profil actif aujourd'hui ; le bloc reste compatible avec un
// futur multi-profil (il ne s'agira que d'afficher un sélecteur ici).
export const UserDashboardProfile = ({ user, level }: Props) => (
  <div className="flex items-center gap-3.5">
    <div className="flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl bg-navy-100 text-navy-900">
      <UserRound className="h-5 w-5" />
    </div>
    <div className="flex min-w-0 flex-1 flex-wrap items-center justify-between gap-x-3 gap-y-2">
      <div className="min-w-[140px] flex-1">
        <p className="text-sm text-ink-secondary sm:text-base">
          Bonjour, {user.username}
        </p>
        <p className="truncate font-serif text-xl font-bold text-navy-900 sm:text-2xl">
          {user.profile || 'Profil non défini'}
        </p>
      </div>
      {level && <LevelRankTag level={level} />}
    </div>
  </div>
);
