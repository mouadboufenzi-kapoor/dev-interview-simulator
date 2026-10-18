import type { RefObject } from 'react';
import { ChevronDown, User, LogOut } from 'lucide-react';
import type { AuthUser } from '../UserAccessModal';

interface Props {
  user?: AuthUser | null;
  showUserMenu: boolean;
  onToggle: () => void;
  onClose: () => void;
  /** Ouvre la modale de connexion quand aucun utilisateur. */
  requestAccess: () => void;
  menuRef: RefObject<HTMLDivElement | null>;
  onOpenDashboard?: () => void;
  onOpenSettings?: () => void;
  onOpenAdmin?: () => void;
  onLogout?: () => void;
}

export const NavbarUserMenu = ({
  user,
  showUserMenu,
  onToggle,
  onClose,
  requestAccess,
  menuRef,
  onOpenDashboard,
  onOpenSettings,
  onOpenAdmin,
  onLogout,
}: Props) => (
  <div className="relative sm:pl-2 sm:border-l border-nav-border" ref={menuRef}>
    <button
      type="button"
      onClick={() => {
        if (user) {
          onToggle();
        } else {
          requestAccess();
        }
      }}
      className="flex items-center gap-2 text-xs font-sans text-nav-muted transition hover:text-nav-ink-hover cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
      aria-label={user ? 'Ouvrir le menu utilisateur' : 'Ouvrir la connexion'}
    >
      <div className="flex h-7 w-7 items-center justify-center rounded-full bg-avatar-bg text-avatar-text">
        <User className="w-3.5 h-3.5" />
      </div>
      <span className="hidden md:inline font-medium text-nav-text">
        {user?.username || 'Invité'}
      </span>
      <ChevronDown className="h-3.5 w-3.5 text-nav-muted" />
    </button>

    {user && showUserMenu && (
      <div className="absolute right-0 mt-2 w-52 rounded-2xl border-[0.5px] border-card-border bg-surface p-2 shadow-xl z-40">
        {user.role === 'ADMIN' && (
          <button
            type="button"
            onClick={() => {
              onClose();
              onOpenAdmin?.();
            }}
            className="w-full rounded-xl px-3 py-2.5 text-left text-xs font-semibold text-ink transition hover:bg-canvas-subtle"
          >
            Administration
          </button>
        )}
        <button
          type="button"
          onClick={() => {
            onClose();
            onOpenDashboard?.();
          }}
          className="w-full rounded-xl px-3 py-2.5 text-left text-xs font-semibold text-ink transition hover:bg-canvas-subtle"
        >
          Mon tableau de bord
        </button>
        <button
          type="button"
          onClick={() => {
            onClose();
            onOpenSettings?.();
          }}
          className="w-full rounded-xl px-3 py-2.5 text-left text-xs font-semibold text-ink transition hover:bg-canvas-subtle"
        >
          Profil
        </button>
        <button
          type="button"
          onClick={() => {
            onClose();
            onLogout?.();
          }}
          className="flex w-full items-center gap-2 rounded-xl px-3 py-2.5 text-left text-xs text-crimson-700 transition hover:bg-crimson-50"
        >
          <LogOut className="h-3.5 w-3.5" />
          Se déconnecter
        </button>
      </div>
    )}
  </div>
);
