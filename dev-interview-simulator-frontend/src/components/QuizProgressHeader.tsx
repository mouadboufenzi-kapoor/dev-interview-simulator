import type { SimulationChallengeResponse } from '../types';
import { Badge } from './common/Badge';
import { Clock, Award } from 'lucide-react';

interface Props {
  challenge: SimulationChallengeResponse;
  currentIndex: number;
  totalChallenges: number;
  secondsRemaining: number;
  isTimeWarning: boolean;
  score: number;
  timerPaused: boolean;
}

const formatTime = (totalSeconds: number) => {
  const mins = Math.floor(totalSeconds / 60);
  const secs = totalSeconds % 60;
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
};

export const QuizProgressHeader = ({
  challenge,
  currentIndex,
  totalChallenges,
  secondsRemaining,
  isTimeWarning,
  score,
  timerPaused,
}: Props) => {
  const progressPercent = Math.round(((currentIndex + 1) / totalChallenges) * 100);

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap items-center justify-between gap-2 sm:gap-3 text-xs">
        {/* flex-wrap + gap-y : sur mobile étroit, le badge long (ex. « Raisonnement
            séquentiel ») passe sous le compteur au lieu de déborder du viewport. */}
        <div className="flex flex-wrap items-center gap-x-2 gap-y-1">
          <span className="font-mono uppercase tracking-wider text-ink-muted font-semibold whitespace-nowrap">
            {challenge.type === 'ARCHITECTURE'
              ? `ÉTAPE ${(challenge.stepOrder ?? currentIndex + 1).toString().padStart(2, '0')} / ${(challenge.totalSteps ?? totalChallenges).toString().padStart(2, '0')}`
              : `QUESTION ${(currentIndex + 1).toString().padStart(2, '0')} / ${totalChallenges.toString().padStart(2, '0')}`}
          </span>
          <span className="text-border-strong hidden xs:inline">•</span>
          <Badge variant="navy" size="sm">
            {challenge.type === 'CODE_REVIEW'
              ? 'Code Review'
              : challenge.type === 'ARCHITECTURE'
              ? 'Architecture Système'
              : challenge.type === 'SEQUENTIAL_REASONING'
              ? 'Raisonnement séquentiel'
              : 'QCM de situation'}
          </Badge>
        </div>

        {/* Timer & Live Score — minuteur en Space Mono (spec §6) */}
        <div className="flex items-center gap-3">
          <div
            role="timer"
            aria-live={isTimeWarning ? 'assertive' : 'off'}
            aria-label={timerPaused ? `Temps écoulé, ${formatTime(secondsRemaining)}` : `Temps restant ${formatTime(secondsRemaining)}`}
            className={`flex items-center gap-1.5 font-mono text-xs uppercase tracking-[0.06em] px-2.5 py-1 rounded border-2 ${
              isTimeWarning
                ? 'border-danger-border bg-danger-soft text-danger animate-pulse'
                : 'border-border bg-card text-text'
            }`}
          >
            <Clock className={`w-3.5 h-3.5 ${isTimeWarning ? 'text-danger' : 'text-text'}`} />
            <span>{formatTime(secondsRemaining)}</span>
          </div>

          <div className="flex items-center gap-1.5 font-mono text-xs uppercase tracking-[0.06em] bg-card px-2.5 py-1 rounded border-2 border-border text-accent font-bold">
            <Award className="w-3.5 h-3.5 text-accent" />
            <span>{score} pts</span>
          </div>
        </div>
      </div>

      {/* Barre de progression Contraste (spec §15) : hauteur 12px, bordure
          --bw, remplissage --color-brand. */}
      <div className="w-full h-3 border-2 border-border rounded bg-card overflow-hidden">
        <div
          className="h-full bg-brand transition-all duration-300 ease-out"
          style={{ width: `${progressPercent}%` }}
        />
      </div>
    </div>
  );
};
