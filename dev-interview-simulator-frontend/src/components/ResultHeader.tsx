import type { ChallengeType, DifficultyLevel } from '../types';
import { Badge } from './common/Badge';
import { PageTitle } from './common/PageTitle';
import { DIFFICULTY_LABELS, MODE_LABELS } from '../utils/resultAnalysis';

interface Props {
  mode: ChallengeType;
  difficulty: DifficultyLevel | null;
}

export const ResultHeader = ({ mode, difficulty }: Props) => (
  <div className="flex items-center justify-between gap-3">
    <PageTitle
      size="hero-compact"
      className="min-w-0 [font-size:26px] sm:[font-size:2.25rem] lg:[font-size:3rem]"
    >
      Votre bilan
    </PageTitle>

    <div className="flex flex-shrink-0 items-center gap-2">
      <Badge variant="default" size="md">{MODE_LABELS[mode] ?? mode}</Badge>
      {difficulty && (
        <Badge variant="navy" size="md">{DIFFICULTY_LABELS[difficulty] ?? difficulty}</Badge>
      )}
    </div>
  </div>
);
