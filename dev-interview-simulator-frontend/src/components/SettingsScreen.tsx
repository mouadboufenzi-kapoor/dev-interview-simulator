import { Mail, Briefcase, ShieldCheck } from 'lucide-react';
import type { AuthUser } from './UserAccessModal';
import { PageTitle } from './common/PageTitle';
import { AppAppearance } from './AppAppearance';

interface Props {
  user: AuthUser;
}

/** Avatar : initiales (pas d'upload d'image dans l'app — rester simple). */
const initialsOf = (username: string) =>
  username
    .trim()
    .split(/\s+/)
    .map((word) => word[0])
    .slice(0, 2)
    .join('')
    .toUpperCase();

const ROLE_LABELS: Record<string, string> = {
  ADMIN: 'Administrateur',
};

// Page Paramètres — profil du compte + apparence, côte à côte sur desktop,
// empilés en mobile-first. Le bloc Apparence est le même composant que par le
// passé (il vient du dashboard, comportement identique).
export const SettingsScreen = ({ user }: Props) => (
  <div className="w-full max-w-5xl mx-auto space-y-6 py-8 sm:py-12">
    <div className="space-y-2 border-b border-border pb-6">
      <PageTitle size="hero-compact">Paramètres</PageTitle>
      <p className="text-base text-ink-secondary">
        Votre profil et l'apparence de l'application.
      </p>
    </div>

    <div className="grid gap-5 lg:grid-cols-2 lg:items-start lg:gap-6">
      {/* Profil */}
      <section className="bg-card rounded border-2 border-border shadow-card p-5 sm:p-6 space-y-5">
        <div className="space-y-1">
          <h2 className="font-serif text-lg sm:text-xl font-bold text-text">Profil</h2>
          <p className="text-xs text-muted">Vos informations de compte.</p>
        </div>

        <div className="flex items-center gap-4">
          <div className="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-full bg-navy-100 font-serif text-lg font-bold text-navy-900">
            {initialsOf(user.username)}
          </div>
          <div className="min-w-0">
            <p className="truncate font-serif text-xl font-bold text-ink">{user.username}</p>
            {user.profile && (
              <p className="truncate text-sm text-ink-secondary">{user.profile}</p>
            )}
          </div>
        </div>

        <dl className="space-y-3.5 border-t border-border pt-4">
          <div className="flex items-start gap-3">
            <Mail className="mt-0.5 h-4 w-4 flex-shrink-0 text-ink-muted" />
            <div className="min-w-0">
              <dt className="text-[10px] font-semibold uppercase tracking-wider text-ink-muted">
                Email
              </dt>
              <dd className="truncate text-sm text-ink">{user.email}</dd>
            </div>
          </div>

          <div className="flex items-start gap-3">
            <Briefcase className="mt-0.5 h-4 w-4 flex-shrink-0 text-ink-muted" />
            <div className="min-w-0">
              <dt className="text-[10px] font-semibold uppercase tracking-wider text-ink-muted">
                Profil actif
              </dt>
              <dd className="truncate text-sm text-ink">{user.profile || 'Non défini'}</dd>
            </div>
          </div>

          {user.role === 'ADMIN' && (
            <div className="flex items-start gap-3">
              <ShieldCheck className="mt-0.5 h-4 w-4 flex-shrink-0 text-ink-muted" />
              <div className="min-w-0">
                <dt className="text-[10px] font-semibold uppercase tracking-wider text-ink-muted">
                  Rôle
                </dt>
                <dd className="truncate text-sm text-ink">
                  {ROLE_LABELS[user.role] ?? user.role}
                </dd>
              </div>
            </div>
          )}
        </dl>
      </section>

      {/* Apparence : palette + mode — déplacée telle quelle du dashboard */}
      <AppAppearance />
    </div>
  </div>
);
