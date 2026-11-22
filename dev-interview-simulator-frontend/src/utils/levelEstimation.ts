export interface LevelEvidence {
  difficulty?: string | null;
  answered: number;
  correct: number;
}

export interface EstimatedLevel {
  index: number;
  label: string;
  provisional: boolean;
}

const LEVEL_LABELS = ['Débutant', 'Junior', 'Junior – Intermédiaire', 'Intermédiaire', 'Senior'];

const DIFFICULTY_BASE_LEVEL: Record<string, number> = {
  JUNIOR: 1,
  INTERMEDIATE: 3,
  ADVANCED: 4,
};

export const STRONG_RATE = 80;
export const AT_LEVEL_RATE = 65;
const CONFIRMED_MIN_SIMULATIONS = 3;

const LEVEL_PHRASES = [
  ['Tout commence quelque part.', 'Premier commit, premiers réflexes.'],
  ['Les bases sont là, place à la pratique.', 'Fondamentaux solides : on monte.'],
  ['Le compilateur commence à vous respecter.', 'Le cap du junior est passé.'],
  ['Les bugs impossibles arrivent bientôt.', 'On vous confie les cas tordus.'],
  ['Même les bugs ont peur de vous.', 'Il ne reste qu’à choisir vos combats.'],
];

const successRate = (evidence: LevelEvidence) =>
  evidence.answered > 0 ? (evidence.correct * 100) / evidence.answered : 0;

const levelModifier = (evidence: LevelEvidence) => {
  const rate = successRate(evidence);
  if (rate >= STRONG_RATE) return 1;
  return rate >= AT_LEVEL_RATE ? 0 : -1;
};

const baseLevelOf = (evidence: LevelEvidence) =>
  evidence.difficulty ? DIFFICULTY_BASE_LEVEL[evidence.difficulty] : undefined;

const baseLevelFromRate = (evidence: LevelEvidence) => {
  const rate = successRate(evidence);
  if (rate >= 80) return 4; // ADVANCED
  if (rate >= 65) return 3; // INTERMEDIATE
  return 1; // JUNIOR
};

export const estimateLevel = (
  evidence: LevelEvidence[],
  completedSimulations: number
): EstimatedLevel | null => {
  const hasDifficulty = evidence.some((entry) => entry.difficulty != null);
  const usable = evidence.filter((entry) => entry.answered > 0 && (hasDifficulty ? baseLevelOf(entry) !== undefined : true));
  if (usable.length === 0) return null;

  const totalAnswered = usable.reduce((total, entry) => total + entry.answered, 0);
  const weightedScore = usable.reduce(
    (total, entry) => total + entry.answered * (hasDifficulty ? (baseLevelOf(entry) as number) + levelModifier(entry) : baseLevelFromRate(entry)),
    0
  );
  const rawIndex = Math.round(weightedScore / totalAnswered);
  const provisional = completedSimulations < CONFIRMED_MIN_SIMULATIONS;
  let highestPractised: number;
  if (hasDifficulty) {
    highestPractised = Math.max(...usable.map((entry) => baseLevelOf(entry) as number));
  } else {
    highestPractised = 4; // Pas de précédent connu, on part du plus haut
  }
  const cappedIndex = provisional ? Math.min(rawIndex, highestPractised) : rawIndex;
  const index = Math.min(Math.max(cappedIndex, 0), LEVEL_LABELS.length - 1);

  return { index, label: LEVEL_LABELS[index], provisional };
};

export const levelPhrase = (index: number, seed: number) => {
  const phrases = LEVEL_PHRASES[index] ?? LEVEL_PHRASES[0];
  const safeSeed = Math.abs(Math.trunc(seed));
  return phrases[safeSeed % phrases.length];
};
