import type { ChallengeType, DifficultyLevel } from '../types';
import { Badge } from './common/Badge';
import { PageTitle } from './common/PageTitle';
import { DIFFICULTY_LABELS, MODE_LABELS } from '../utils/resultAnalysis';

interface Props {
  mode: ChallengeType;
  difficulty: DifficultyLevel | null;
}

export const ResultHeader = ({ mode, difficulty }: Props) => (
  <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 pb-6 border-b border-border">
    <div className="space-y-2">
      <Badge variant="default" size="sm" dot>
        Évaluation terminée
      </Badge>
      <PageTitle size="hero-compact">Bilan de votre évaluation</PageTitle>
      <p className="text-base text-ink-secondary">
        Votre niveau, vos forces et votre prochain axe de travail — puis le détail complet de vos
        réponses.
      </p>
    </div>

    <div className="flex items-center gap-2">
      <Badge variant="default" size="md">{MODE_LABELS[mode] ?? mode}</Badge>
      {difficulty && (
        <Badge variant="navy" size="md">{DIFFICULTY_LABELS[difficulty] ?? difficulty}</Badge>
      )}
    </div>
  </div>
);
