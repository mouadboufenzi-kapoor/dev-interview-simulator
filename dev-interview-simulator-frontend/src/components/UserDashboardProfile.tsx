import { UserRound } from 'lucide-react';
import { Button } from './common/Button';
import type { AuthUser } from './UserAccessModal';

interface Props {
  user: AuthUser;
  onChangeProfile: () => void;
}

// Bloc d'accueil orienté progression : salutation + profil actif.
// Email / rôle volontairement absents : le dashboard est un espace de
// progression, pas une fiche technique du compte (visibles ailleurs).
// Un seul profil actif aujourd'hui ; le bloc reste compatible avec un
// futur multi-profil (il ne s'agira que d'afficher un sélecteur ici).
export const UserDashboardProfile = ({ user, onChangeProfile }: Props) => (
  <div className="flex items-center gap-3.5">
    <div className="flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl bg-navy-100 text-navy-900">
      <UserRound className="h-5 w-5" />
    </div>
    <div className="min-w-0">
      <p className="text-lg text-ink-secondary">
        Bonjour, {user.username}
      </p>
      <p className="truncate font-serif text-xl font-bold text-navy-900 sm:text-2xl">
        {user.profile || 'Profil non défini'}
      </p>
    </div>
    <Button
      type="button"
      variant="outline"
      size="sm"
      onClick={onChangeProfile}
      className="ml-auto flex-shrink-0"
    >
      Changer de profil
    </Button>
  </div>
);
