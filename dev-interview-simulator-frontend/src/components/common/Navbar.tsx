import React, { useState, useRef, useEffect } from 'react';
import { Logo } from './Logo';
import { PageTitle } from './PageTitle';
import { Badge } from './Badge';
import { Button } from './Button';
import {
  X,
  AlertTriangle,
  ChevronDown,
  Radio,
  Trophy,
  TrendingUp,
  User,
  LogOut,
} from 'lucide-react';
import type { ChallengeType, DifficultyLevel } from '../../types';
import { UserAccessModal, type AuthUser } from '../UserAccessModal';

interface NavbarProps {
  currentScreen: 'SETUP' | 'QUIZ' | 'RESULT' | 'DASHBOARD' | 'ADMIN';
  mode?: ChallengeType;
  difficulty?: DifficultyLevel;
  onQuit?: () => void;
  onSelectMode?: (mode: ChallengeType) => void;
  user?: AuthUser | null;
  onAuthenticated?: (user: AuthUser) => void;
  onLogout?: () => void;
  onOpenDashboard?: () => void;
  onOpenAdmin?: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({
  currentScreen,
  mode,
  difficulty,
  onQuit,
  user,
  onAuthenticated,
  onLogout,
  onOpenDashboard,
  onOpenAdmin,
}) => {
  const [showQuitModal, setShowQuitModal] = useState(false);
  const [showPlusMenu, setShowPlusMenu] = useState(false);
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [showAccessModal, setShowAccessModal] = useState(false);
  const plusMenuRef = useRef<HTMLDivElement>(null);
  const userMenuRef = useRef<HTMLDivElement>(null);

  // Close dropdown on click outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        plusMenuRef.current &&
        !plusMenuRef.current.contains(event.target as Node)
      ) {
        setShowPlusMenu(false);
      }
      if (
        userMenuRef.current &&
        !userMenuRef.current.contains(event.target as Node)
      ) {
        setShowUserMenu(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const getModeLabel = (m?: ChallengeType) => {
    switch (m) {
      case 'CODE_REVIEW':
        return 'Code Review';
      case 'ARCHITECTURE':
        return 'Architecture';
      case 'PROBLEM_SOLVING':
        return 'Problem Solving';
      default:
        return 'QCM';
    }
  };

  const handleConfirmQuit = () => {
    setShowQuitModal(false);
    onQuit?.();
  };

  return (
    <>
      <header className="sticky top-0 z-30 w-full border-b border-border bg-sand-100/75 backdrop-blur-md">
        <div className="max-w-6xl mx-auto px-3 sm:px-6 h-14 sm:h-16 flex items-center justify-between gap-2 sm:gap-6">
          {/* Left: Brand */}
          <div className="flex items-center gap-6">
            <button
              onClick={() => {
                if (currentScreen === 'QUIZ') {
                  setShowQuitModal(true);
                } else if (onQuit) {
                  onQuit();
                }
              }}
              className="text-left focus:outline-none cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white"
              title="Accueil Dev Interview Simulator"
            >
              <Logo size="sm" showSubtitle={false} />
            </button>

          </div>

          {/* Center Context (When Quiz in progress) — compact on mobile */}
          {currentScreen === 'QUIZ' && mode && (
            <div className="flex items-center gap-1.5 sm:gap-2 min-w-0">
              <span className="hidden sm:inline text-xs font-semibold text-navy-900 whitespace-nowrap">
                {getModeLabel(mode)}
              </span>
              {difficulty && (
                <Badge variant="default" size="sm">
                  {difficulty}
                </Badge>
              )}
            </div>
          )}

          {/* Right: Actions / Secondary features */}
          <div className="flex items-center gap-3">
            {currentScreen === 'QUIZ' && onQuit ? (
              <Button
                variant="outline"
                size="sm"
                onClick={() => setShowQuitModal(true)}
                leftIcon={<X className="w-3.5 h-3.5 text-crimson-700" />}
                className="text-xs text-crimson-700 hover:border-crimson-700"
              >
                <span>Quitter</span>
              </Button>
            ) : (
              <div className="flex items-center gap-1.5 sm:gap-2">
                {/* Secondary Menu "Plus" */}
                <div className="relative" ref={plusMenuRef}>
                  <button
                    type="button"
                    onClick={() => setShowPlusMenu(!showPlusMenu)}
                    className="flex items-center gap-1 text-xs font-sans text-ink-warm hover:text-navy-900 px-2 sm:px-2.5 py-1.5 rounded-lg hover:bg-canvas-subtle transition cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white"
                  >
                    <span className="hidden sm:inline">Explorer</span>
                    <ChevronDown className="w-3.5 h-3.5" />
                  </button>

                  {/* Dropdown Menu for Future Features */}
                  {showPlusMenu && (
                    <div className="absolute right-0 mt-2 w-64 bg-surface border border-border rounded-2xl p-2 shadow-xl animate-in fade-in slide-in-from-top-1 duration-150 z-40 space-y-1">
                      <div className="px-3 py-2 border-b border-border-subtle">
                        <span className="text-[10px] font-mono uppercase tracking-wider text-ink-muted font-semibold">
                          Modules à venir
                        </span>
                      </div>

                      <div className="p-2.5 rounded-xl hover:bg-canvas-subtle transition flex items-center justify-between cursor-default">
                        <div className="flex items-center gap-2.5 text-xs text-ink">
                          <Radio className="w-4 h-4 text-navy-900" />
                          <div>
                            <p className="font-semibold">Veille technique</p>
                            <p className="text-[10px] text-ink-muted">Radar & actualités dev</p>
                          </div>
                        </div>
                        <Badge variant="default" size="sm">
                          Bientôt
                        </Badge>
                      </div>

                      <div className="p-2.5 rounded-xl hover:bg-canvas-subtle transition flex items-center justify-between cursor-default">
                        <div className="flex items-center gap-2.5 text-xs text-ink">
                          <Trophy className="w-4 h-4 text-crimson-700" />
                          <div>
                            <p className="font-semibold">Classement</p>
                            <p className="text-[10px] text-ink-muted">Top scores de la promo</p>
                          </div>
                        </div>
                        <Badge variant="default" size="sm">
                          Bientôt
                        </Badge>
                      </div>

                      <div className="p-2.5 rounded-xl hover:bg-canvas-subtle transition flex items-center justify-between cursor-default">
                        <div className="flex items-center gap-2.5 text-xs text-ink">
                          <TrendingUp className="w-4 h-4 text-warning-accent" />
                          <div>
                            <p className="font-semibold">Progression</p>
                            <p className="text-[10px] text-ink-muted">Historique & analytics</p>
                          </div>
                        </div>
                        <Badge variant="default" size="sm">
                          Bientôt
                        </Badge>
                      </div>
                    </div>
                  )}
                </div>

                {/* Profile indicator */}
                <div className="relative sm:pl-2 sm:border-l border-border" ref={userMenuRef}>
                  <button
                    type="button"
                    onClick={() => {
                      if (user) {
                        setShowUserMenu(!showUserMenu);
                      } else {
                        setShowAccessModal(true);
                      }
                    }}
                    className="flex items-center gap-2 text-xs font-sans text-ink-warm transition hover:text-navy-900 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white"
                    aria-label={user ? 'Ouvrir le menu utilisateur' : 'Ouvrir la connexion'}
                  >
                    <div className="flex h-7 w-7 items-center justify-center rounded-full bg-navy-100 text-navy-900">
                      <User className="w-3.5 h-3.5" />
                    </div>
                    <span className="hidden md:inline font-medium text-ink">
                      {user?.username || 'Invité'}
                    </span>
                    <ChevronDown className="h-3.5 w-3.5 text-ink-muted" />
                  </button>

                  {user && showUserMenu && (
                    <div className="absolute right-0 mt-2 w-52 rounded-2xl border border-border bg-surface p-2 shadow-xl z-40">
                      {user.role === 'ADMIN' && (
                        <button
                          type="button"
                          onClick={() => {
                            setShowUserMenu(false);
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
                          setShowUserMenu(false);
                          onOpenDashboard?.();
                        }}
                        className="w-full rounded-xl px-3 py-2.5 text-left text-xs font-semibold text-ink transition hover:bg-canvas-subtle"
                      >
                        Mon tableau de bord
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          setShowUserMenu(false);
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
              </div>
            )}
          </div>
        </div>
      </header>

      {/* Confirmation Modal to Quit Quiz */}
      {showQuitModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="w-full max-w-md bg-surface border border-border rounded-2xl p-6 shadow-2xl space-y-4">
            <div className="flex items-start gap-3.5">
              <div className="p-2.5 rounded-xl bg-danger-soft border border-danger-border text-danger flex-shrink-0">
                <AlertTriangle className="w-5 h-5" />
              </div>
              <div>
                <PageTitle as="h3" size="xs" tone="ink">
                  Quitter la session en cours ?
                </PageTitle>
                <p className="text-sm text-ink-secondary mt-1 leading-relaxed">
                  Votre progression actuelle et les réponses non soumises seront perdues. Souhaitez-vous vraiment revenir au choix des entraînements ?
                </p>
              </div>
            </div>

            <div className="flex items-center justify-end gap-3 pt-3">
              <Button
                variant="secondary"
                size="sm"
                onClick={() => setShowQuitModal(false)}
              >
                Continuer la session
              </Button>
              <Button
                variant="danger"
                size="sm"
                onClick={handleConfirmQuit}
              >
                Oui, quitter
              </Button>
            </div>
          </div>
        </div>
      )}

      {showAccessModal && onAuthenticated && (
        <UserAccessModal
          onClose={() => setShowAccessModal(false)}
          onAuthenticated={(authenticatedUser) => {
            setShowAccessModal(false);
            onAuthenticated(authenticatedUser);
          }}
        />
      )}
    </>
  );
};
