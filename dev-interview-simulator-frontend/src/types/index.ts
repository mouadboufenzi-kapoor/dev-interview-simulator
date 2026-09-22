export type ChallengeType = 'SITUATIONAL_QCM' | 'CODE_REVIEW' | 'ARCHITECTURE';
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
}

export interface StartSimulationRequest {
  mode: ChallengeType;
  difficulty?: DifficultyLevel;
  categoryIds?: number[];
  skillIds?: number[];
}

export interface SubmitAnswerRequest {
  simulationChallengeId: number;
  selectedOptionId: number;
  responseTimeMs?: number;
}

export interface SubmitAnswerResponse {
  answerId: number;
  isCorrect: boolean;
  scoreAwarded: number;
  totalSimulationScore: number;
  explanation: string;
  correctOptionId: number;
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

export interface QuestionSummary {
  challengeId: number;
  title: string;
  context: string;
  question: string;
  userSelectedOptionContent: string;
  correctOptionContent: string;
  isCorrect: boolean;
  explanation: string;
  pointsEarned: number;
  timeSpentMs: number;
}

export interface SimulationResultDTO {
  simulationId: number;
  totalScore: number;
  maxPossibleScore: number;
  successPercentage: number;
  totalTimeSpentSeconds: number;
  totalQuestions: number;
  correctAnswersCount: number;
  questions: QuestionSummary[];
}