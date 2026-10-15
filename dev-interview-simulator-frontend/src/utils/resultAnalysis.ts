import type {
  ChallengeType,
  CompetencyResult,
  DifficultyLevel,
  SimulationResultDTO,
  StartSimulationRequest,
} from '../types';

/** Libellés d'affichage des modes et difficultés (en-tête du bilan). */
export const MODE_LABELS: Record<ChallengeType, string> = {
  SITUATIONAL_QCM: 'QCM',
  CODE_REVIEW: 'Code Review',
  ARCHITECTURE: 'Architecture',
  PROBLEM_SOLVING: 'Problem Solving',
  SEQUENTIAL_REASONING: 'Raisonnement séquentiel',
};

export const DIFFICULTY_LABELS: Record<DifficultyLevel, string> = {
  JUNIOR: 'Junior',
  INTERMEDIATE: 'Intermédiaire',
  ADVANCED: 'Senior',
};

type AssessmentVariant = 'success' | 'navy' | 'crimson';

export interface Assessment {
  label: string;
  desc: string;
  variant: AssessmentVariant;
}

/** Diagnostic : paliers lisibles sur le taux de réussite existant (aucun nouveau scoring). */
export const getAssessment = (percent: number): Assessment => {
  if (percent >= 90) {
    return {
      label: 'Excellent',
      desc: 'Maîtrise remarquable : les réponses sont justes et les arbitrages techniques solides. Visez maintenant un niveau supérieur ou un autre domaine.',
      variant: 'success',
    };
  }
  if (percent >= 80) {
    return {
      label: 'Très solide',
      desc: 'Très bonne maîtrise du sujet. Quelques points de vigilance isolés avant d’aborder des cas plus complexes.',
      variant: 'success',
    };
  }
  if (percent >= 65) {
    return {
      label: 'Solide',
      desc: 'Bases fiables et raisonnement correct. Consolidez les axes identifiés ci-dessous pour viser l’excellence.',
      variant: 'navy',
    };
  }
  if (percent >= 50) {
    return {
      label: 'En progression',
      desc: 'Les fondamentaux sont là mais des écarts subsistent. Un travail ciblé sur vos points faibles fera vite monter le niveau.',
      variant: 'navy',
    };
  }
  return {
    label: 'À renforcer',
    desc: 'Des lacunes sur plusieurs sujets de cette simulation. Reprenez les bases par les axes proposés ci-dessous, une simulation après l’autre.',
    variant: 'crimson',
  };
};

/**
 * Seuil de « vraie faiblesse » : un axe n'est présenté en priorité que s'il
 * descend sous ce taux (aligné sur le palier « Solide » de getAssessment).
 * Une compétence à 80 % n'est donc jamais déclarée priorité principale
 * simplement parce qu'elle était sélectionnée à la configuration.
 */
export const PRIORITY_THRESHOLD = 65;

export interface AnalyzedCompetency extends CompetencyResult {
  pct: number;
}

export interface ResultAnalysis {
  competencies: AnalyzedCompetency[];
  strengths: AnalyzedCompetency[];
  weaknesses: AnalyzedCompetency[];
  weakest: AnalyzedCompetency | null;
}

/**
 * Découpe les compétences du bilan :
 * - weaknesses (priorités) : uniquement les axes SOUS le seuil de vraie
 *   faiblesse (PRIORITY_THRESHOLD), triés du plus fragile au moins fragile —
 *   une performance correcte n'est jamais présentée comme une faiblesse ;
 * - strengths : compétences à 100 %, max 3.
 * Les axes intermédiaires (seuil ≤ pct < 100 %) n'apparaissent dans aucune
 * des deux listes : ni force, ni faiblesse (moins de bruit, pas de mensonge).
 */
export const analyzeResult = (results: CompetencyResult[]): ResultAnalysis => {
  const competencies = results.map((c) => ({
    ...c,
    pct: c.total > 0 ? Math.round((c.correct / c.total) * 100) : 0,
  }));

  const weaknesses = [...competencies]
    .filter((c) => c.pct < PRIORITY_THRESHOLD)
    .sort((a, b) => a.pct - b.pct || a.total - b.total);
  const strengths = [...competencies]
    .filter((c) => c.pct === 100)
    .sort((a, b) => b.total - a.total)
    .slice(0, 3);

  return {
    competencies,
    strengths,
    weaknesses,
    weakest: weaknesses[0] ?? null,
  };
};

/**
 * Requête d'entraînement ciblé : réutilise le mécanisme existant de création de
 * simulation (même mode / difficulté / profil), en ciblant le skill ou la
 * catégorie de l'objectif et en excluant les questions déjà répondues.
 */
export const buildTargetedRequest = (
  summary: SimulationResultDTO,
  target: CompetencyResult,
  answeredChallengeIds: number[]
): StartSimulationRequest => ({
  mode: summary.mode,
  difficulty: summary.difficulty ?? undefined,
  profileId: summary.profileId ?? undefined,
  ...(summary.competencySource === 'SKILL'
    ? { skillIds: [target.id] }
    : { categoryIds: [target.id] }),
  excludeChallengeIds: answeredChallengeIds,
});
