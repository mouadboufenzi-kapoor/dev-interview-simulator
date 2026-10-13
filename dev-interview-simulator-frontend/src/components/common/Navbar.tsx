import React, { useState, useRef, useEffect } from 'react';
import { LogoMark } from './LogoMark';
import { ThemeToggle } from './ThemeToggle';
import { Badge } from './Badge';
import { Button } from './Button';
import { X } from 'lucide-react';
import type { ChallengeType, DifficultyLevel } from '../../types';
import { UserAccessModal, type AuthUser } from '../UserAccessModal';
import { NavbarExplorerMenu } from './NavbarExplorerMenu';
import { NavbarUserMenu } from './NavbarUserMenu';
import { NavbarQuitModal } from './NavbarQuitModal';

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
      {/* Navbar Contraste : fond --color-nav, bordure basse --bw, texte --color-text.
          Pas de blur ni de transparence (flat, spec §7). */}
      <header className="sticky top-0 z-30 w-full border-b-2 border-border bg-nav">
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
              className="flex items-center gap-2 text-left focus:outline-none cursor-pointer focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-nav"
              title="Accueil InterviewLab"
            >
              <LogoMark size={30} />
              {/* Wordmark : Interview (texte) + Lab (accent) — spec §8. */}
              <span className="text-sm sm:text-base font-bold tracking-tight text-text whitespace-nowrap">
                Interview<span style={{ color: 'var(--color-wordmark-accent)' }}>Lab</span>
              </span>
            </button>
          </div>

          {/* Center Context (When Quiz in progress) — compact on mobile */}
          {currentScreen === 'QUIZ' && mode && (
            <div className="flex items-center gap-1.5 sm:gap-2 min-w-0">
              <span className="hidden sm:inline text-xs font-semibold text-text whitespace-nowrap">
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
                {/* Dark mode toggle */}
                <ThemeToggle />

                {/* Secondary Menu "Plus" */}
                <NavbarExplorerMenu
                  open={showPlusMenu}
                  onToggle={() => setShowPlusMenu(!showPlusMenu)}
                  menuRef={plusMenuRef}
                />

                {/* Profile indicator */}
                <NavbarUserMenu
                  user={user}
                  showUserMenu={showUserMenu}
                  onToggle={() => setShowUserMenu(v => !v)}
                  onClose={() => setShowUserMenu(false)}
                  requestAccess={() => setShowAccessModal(true)}
                  menuRef={userMenuRef}
                  onOpenDashboard={onOpenDashboard}
                  onOpenAdmin={onOpenAdmin}
                  onLogout={onLogout}
                />
              </div>
            )}
          </div>
        </div>
      </header>

      {/* Confirmation Modal to Quit Quiz */}
      {showQuitModal && (
        <NavbarQuitModal
          onCancel={() => setShowQuitModal(false)}
          onConfirm={handleConfirmQuit}
        />
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
