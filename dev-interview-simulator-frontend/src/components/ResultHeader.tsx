import type { ChallengeType, DifficultyLevel } from '../types';
import { Badge } from './common/Badge';
import { BackButton } from './common/BackButton';
import { PageTitle } from './common/PageTitle';
import { DIFFICULTY_LABELS, MODE_LABELS } from '../utils/resultAnalysis';

interface Props {
  mode: ChallengeType;
  difficulty: DifficultyLevel | null;
  onBack?: () => void;
}

export const ResultHeader = ({ mode, difficulty, onBack }: Props) => (
  <div className="flex flex-wrap items-center justify-between gap-2">
    <div className="flex min-w-0 items-center gap-1.5">
      {onBack && <BackButton onClick={onBack} />}
      <PageTitle
        size="hero-compact"
        className="min-w-0 [font-size:26px] sm:[font-size:2.25rem] lg:[font-size:3rem]"
      >
        Votre bilan
      </PageTitle>
    </div>

    <div className="flex flex-wrap items-center gap-1">
      <Badge variant="default" size="sm">
        <span className="text-[10px]">{MODE_LABELS[mode] ?? mode}</span>
      </Badge>
      {difficulty && (
        <Badge variant="navy" size="sm">
          <span className="text-[10px]">{DIFFICULTY_LABELS[difficulty] ?? difficulty}</span>
        </Badge>
      )}
    </div>
  </div>
);
