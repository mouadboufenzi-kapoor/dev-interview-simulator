import type { SimulationChallengeResponse } from '../types';
import { Badge } from './common/Badge';
import { Clock, Award } from 'lucide-react';

interface Props {
  challenge: SimulationChallengeResponse;
  currentIndex: number;
  totalChallenges: number;
  secondsElapsed: number;
  score: number;
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
  secondsElapsed,
  score,
}: Props) => {
  const progressPercent = Math.round(((currentIndex + 1) / totalChallenges) * 100);

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap items-center justify-between gap-3 text-xs">
        <div className="flex items-center gap-2">
          <span className="font-mono uppercase tracking-wider text-ink-muted font-semibold">
            {challenge.type === 'ARCHITECTURE'
              ? `ÉTAPE ${(challenge.stepOrder ?? currentIndex + 1).toString().padStart(2, '0')} / ${(challenge.totalSteps ?? totalChallenges).toString().padStart(2, '0')}`
              : `QUESTION ${(currentIndex + 1).toString().padStart(2, '0')} / ${totalChallenges.toString().padStart(2, '0')}`}
          </span>
          <span className="text-border-strong">•</span>
          <Badge variant="navy" size="sm">
            {challenge.type === 'CODE_REVIEW'
              ? 'Code Review'
              : challenge.type === 'ARCHITECTURE'
              ? 'Architecture Système'
              : 'QCM de situation'}
          </Badge>
        </div>

        {/* Timer & Live Score */}
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1.5 font-mono text-xs bg-surface px-2.5 py-1 rounded-md border border-border text-navy-900 shadow-card">
            <Clock className="w-3.5 h-3.5 text-navy-900" />
            <span>{formatTime(secondsElapsed)}</span>
          </div>

          <div className="flex items-center gap-1.5 font-mono text-xs bg-surface px-2.5 py-1 rounded-md border border-border text-crimson-700 font-semibold shadow-card">
            <Award className="w-3.5 h-3.5 text-crimson-700" />
            <span>{score} pts</span>
          </div>
        </div>
      </div>

      {/* Minimal Progress Bar in Accent Rosewood (crimson-700) */}
      <div className="w-full h-1 bg-border rounded-full overflow-hidden">
        <div
          className="h-full bg-crimson-700 transition-all duration-300 ease-out"
          style={{ width: `${progressPercent}%` }}
        />
      </div>
    </div>
  );
};
