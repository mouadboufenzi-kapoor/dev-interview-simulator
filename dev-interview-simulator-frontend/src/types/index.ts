export type ChallengeType =
  | 'SITUATIONAL_QCM'
  | 'PROBLEM_SOLVING'
  | 'CODE_REVIEW'
  | 'ARCHITECTURE'
  | 'SEQUENTIAL_REASONING';
export type SelectionType = 'SINGLE_CHOICE' | 'MULTIPLE_CHOICE';
export type DifficultyLevel = 'JUNIOR' | 'INTERMEDIATE' | 'ADVANCED';
export type SimulationStatus = 'IN_PROGRESS' | 'COMPLETED' | 'ABANDONED';

export interface Category {
  id: number;
  name: string;
  description: string;
}

export interface Skill {
  id: number;
  name: string;
  description: string;
}

export interface OptionResponse {
  id: number;
  content: string;
  displayOrder: number;
}

export interface SimulationChallengeResponse {
  simulationChallengeId: number;
  displayOrder: number;
  challengeId: number;
  title: string;
  context: string;
  question: string;
  type: ChallengeType;
  selectionType: SelectionType;
  codeSnippet: string | null;
  codeLanguage: string | null;
  scenarioTitle: string | null;
  scenarioDescription: string | null;
  stepOrder: number | null;
  totalSteps: number | null;
  revealedInformation: string | null;
  tradeoff: string | null;
  estimatedTimeSeconds: number | null;
  options: OptionResponse[];
}

export interface SimulationResponse {
  id: number;
  mode: ChallengeType;
  difficulty: DifficultyLevel;
  status: SimulationStatus;
  totalScore: number;
  startedAt: string;
  challenges: SimulationChallengeResponse[];
  guestAccessToken?: string | null;
}

export interface StartSimulationRequest {
  mode: ChallengeType;
  difficulty?: DifficultyLevel;
  profileId?: number;
  categoryIds?: number[];
  skillIds?: number[];
  excludeChallengeIds?: number[];
  questionCount?: number;
}

export interface SubmitAnswerRequest {
  simulationChallengeId: number;
  selectedOptionIds: number[];
  responseTimeMs?: number;
}

export interface ChallengeCorrection {
  optionId: number;
  content: string;
  isCorrect: boolean;
  wasSelected: boolean;
  severity: string | null;
  explanation: string | null;
}

export interface SubmitAnswerResponse {
  answerId: number;
  isCorrect: boolean;
  scoreAwarded: number;
  totalSimulationScore: number;
  explanation: string | null;
  correctOptionId: number | null;
  revealedInformation: string | null;
  tradeoff: string | null;
  corrections: ChallengeCorrection[];
  /** Raisonnement séquentiel uniquement : ids des étapes dans l'ordre attendu. */
  expectedOrder?: number[] | null;
}

export interface SimulationSummaryResponse {
  simulationId: number;
  status: SimulationStatus;
  totalScore: number;
  totalQuestions: number;
  correctAnswers: number;
  startedAt: string;
  completedAt: string;
}

export type QuestionStatus = 'ANSWERED' | 'TIMED_OUT' | 'UNANSWERED';

export interface QuestionSummary {
  challengeId: number;
  title: string;
  context: string;
  question: string;
  userSelectedOptionContent: string | null;
  correctOptionContent: string | null;
  isCorrect: boolean;
  /** Optional for compatibility with historical result payloads. */
  status?: QuestionStatus;
  explanation: string | null;
  pointsEarned: number;
  timeSpentMs: number | null;
  categories?: string[];
  skills?: string[];
}

export type CompetencySource = 'SKILL' | 'CATEGORY';

export interface CompetencyResult {
  id: number;
  name: string;
  correct: number;
  total: number;
}

export interface SimulationResultDTO {
  simulationId: number;
  totalScore: number;
  maxPossibleScore: number;
  successPercentage: number;
  totalTimeSpentSeconds: number;
  totalQuestions: number;
  correctAnswersCount: number;
  mode: ChallengeType;
  difficulty: DifficultyLevel | null;
  profileId: number | null;
  competencySource: CompetencySource;
  /** Historique groupé conservé pour compatibilité avec les anciennes sessions. */
  competencyResults: CompetencyResult[];
  /** Axes techniques sous le seuil de faiblesse, sans les maîtrises à 100 %. */
  weakCategoryResults?: CompetencyResult[];
  /** Skills transversaux sous le seuil de faiblesse, sans les maîtrises à 100 %. */
  weakSkillResults?: CompetencyResult[];
  /** Résultats par domaine technique, par exemple Java ou Spring Boot. */
  categoryResults?: CompetencyResult[];
  /** Résultats par compétence transversale, par exemple Debugging. */
  skillResults?: CompetencyResult[];
  questions: QuestionSummary[];
}