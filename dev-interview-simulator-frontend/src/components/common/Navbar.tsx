import React, { useState, useRef, useEffect } from 'react';
import { Logo } from './Logo';
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
} from 'lucide-react';
import type { ChallengeType, DifficultyLevel } from '../../types';

interface NavbarProps {
  currentScreen: 'SETUP' | 'QUIZ' | 'RESULT';
  mode?: ChallengeType;
  difficulty?: DifficultyLevel;
  onQuit?: () => void;
  onSelectMode?: (mode: ChallengeType) => void;
}

export const Navbar: React.FC<NavbarProps> = ({
  currentScreen,
  mode,
  difficulty,
  onQuit,
}) => {
  const [showQuitModal, setShowQuitModal] = useState(false);
  const [showPlusMenu, setShowPlusMenu] = useState(false);
  const plusMenuRef = useRef<HTMLDivElement>(null);

  // Close dropdown on click outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        plusMenuRef.current &&
        !plusMenuRef.current.contains(event.target as Node)
      ) {
        setShowPlusMenu(false);
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
      <header className="sticky top-0 z-30 w-full border-b border-[#DDD5D8] bg-[#EEE2DC]/75 backdrop-blur-md">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between gap-6">
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
              className="text-left focus:outline-none cursor-pointer"
              title="Accueil Dev Interview Simulator"
            >
              <Logo size="sm" showSubtitle={false} />
            </button>

          </div>

          {/* Center Context (When Quiz in progress) */}
          {currentScreen === 'QUIZ' && mode && (
            <div className="flex items-center gap-2">
              <Badge variant="navy" size="sm" dot>
                Session active
              </Badge>
              <span className="text-[#BAB2B5] text-xs">/</span>
              <span className="text-xs font-semibold text-[#123C69]">
                {getModeLabel(mode)}
              </span>
              {difficulty && (
                <>
                  <span className="text-[#BAB2B5] text-xs">/</span>
                  <Badge variant="default" size="sm">
                    {difficulty}
                  </Badge>
                </>
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
                leftIcon={<X className="w-3.5 h-3.5 text-[#AC3B61]" />}
                className="text-xs text-[#AC3B61] hover:border-[#AC3B61]"
              >
                <span>Quitter</span>
              </Button>
            ) : (
              <div className="flex items-center gap-2">
                {/* Secondary Menu "Plus" */}
                <div className="relative" ref={plusMenuRef}>
                  <button
                    type="button"
                    onClick={() => setShowPlusMenu(!showPlusMenu)}
                    className="flex items-center gap-1 text-xs font-sans text-[#5C554E] hover:text-[#123C69] px-2.5 py-1.5 rounded-lg hover:bg-[#FAF9F7] transition cursor-pointer"
                  >
                    <span>Explorer</span>
                    <ChevronDown className="w-3.5 h-3.5" />
                  </button>

                  {/* Dropdown Menu for Future Features */}
                  {showPlusMenu && (
                    <div className="absolute right-0 mt-2 w-64 bg-white border border-[#E8E2D8] rounded-2xl p-2 shadow-xl animate-in fade-in slide-in-from-top-1 duration-150 z-40 space-y-1">
                      <div className="px-3 py-2 border-b border-[#F2EDE6]">
                        <span className="text-[10px] font-mono uppercase tracking-wider text-[#797E88] font-semibold">
                          Modules à venir
                        </span>
                      </div>

                      <div className="p-2.5 rounded-xl hover:bg-[#FAF9F7] transition flex items-center justify-between cursor-default">
                        <div className="flex items-center gap-2.5 text-xs text-[#102136]">
                          <Radio className="w-4 h-4 text-[#123C69]" />
                          <div>
                            <p className="font-semibold">Veille technique</p>
                            <p className="text-[10px] text-[#797E88]">Radar & actualités dev</p>
                          </div>
                        </div>
                        <Badge variant="default" size="sm">
                          Bientôt
                        </Badge>
                      </div>

                      <div className="p-2.5 rounded-xl hover:bg-[#FAF9F7] transition flex items-center justify-between cursor-default">
                        <div className="flex items-center gap-2.5 text-xs text-[#102136]">
                          <Trophy className="w-4 h-4 text-[#AC3B61]" />
                          <div>
                            <p className="font-semibold">Classement</p>
                            <p className="text-[10px] text-[#797E88]">Top scores de la promo</p>
                          </div>
                        </div>
                        <Badge variant="default" size="sm">
                          Bientôt
                        </Badge>
                      </div>

                      <div className="p-2.5 rounded-xl hover:bg-[#FAF9F7] transition flex items-center justify-between cursor-default">
                        <div className="flex items-center gap-2.5 text-xs text-[#102136]">
                          <TrendingUp className="w-4 h-4 text-[#C89D58]" />
                          <div>
                            <p className="font-semibold">Progression</p>
                            <p className="text-[10px] text-[#797E88]">Historique & analytics</p>
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
                <div className="hidden sm:flex items-center gap-2 text-xs font-sans text-[#5C554E] pl-2 border-l border-[#E8E2D8]">
                  <div className="w-7 h-7 rounded-full bg-[#E6EFF8] text-[#123C69] flex items-center justify-center">
                    <User className="w-3.5 h-3.5" />
                  </div>
                  <span className="font-medium text-[#102136]">Invité</span>
                </div>
              </div>
            )}
          </div>
        </div>
      </header>

      {/* Confirmation Modal to Quit Quiz */}
      {showQuitModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="w-full max-w-md bg-white border border-[#E8E2D8] rounded-2xl p-6 shadow-2xl space-y-4">
            <div className="flex items-start gap-3.5">
              <div className="p-2.5 rounded-xl bg-[#FDF2F2] border border-[#F3BEBE] text-[#9C2727] flex-shrink-0">
                <AlertTriangle className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-base font-serif font-bold text-[#102136]">
                  Quitter la session en cours ?
                </h3>
                <p className="text-sm text-[#484F59] mt-1 leading-relaxed">
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
    </>
  );
};
