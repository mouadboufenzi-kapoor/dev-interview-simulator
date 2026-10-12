import { UserRound } from 'lucide-react';
import { panelCard } from '../styles/ui';
import type { AuthUser } from './UserAccessModal';

interface Props {
  user: AuthUser;
}

export const UserDashboardProfile = ({ user }: Props) => (
  <div className={`${panelCard} p-6`}>
    <div className="flex items-center gap-3">
      <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-navy-100 text-navy-900">
        <UserRound className="h-5 w-5" />
      </div>
      <div>
        <h2 className="font-serif text-xl font-bold text-ink">Profil</h2>
        <p className="text-xs text-ink-muted">Votre espace de préparation</p>
      </div>
    </div>
    <dl className="mt-7 space-y-4 text-sm">
      <div className="flex items-center justify-between gap-4 border-b border-border-subtle pb-3">
        <dt className="text-ink-muted">Username</dt>
        <dd className="font-semibold text-ink">{user.username}</dd>
      </div>
      <div className="flex items-center justify-between gap-4 border-b border-border-subtle pb-3">
        <dt className="text-ink-muted">Email</dt>
        <dd className="max-w-[60%] truncate font-semibold text-ink">{user.email}</dd>
      </div>
      <div className="flex items-center justify-between gap-4 border-b border-border-subtle pb-3">
        <dt className="text-ink-muted">Rôle</dt>
        <dd className="font-semibold text-ink">{user.role || 'USER'}</dd>
      </div>
      <div className="flex items-center justify-between gap-4">
        <dt className="text-ink-muted">Profil actuel</dt>
        <dd className="font-semibold text-navy-900">{user.profile || 'Non défini'}</dd>
      </div>
    </dl>
  </div>
);
