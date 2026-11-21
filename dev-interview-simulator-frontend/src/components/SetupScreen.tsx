import { useEffect, useState } from 'react';
import type {
  Category,
  ChallengeType,
  DifficultyLevel,
  Skill,
  StartSimulationRequest,
} from '../types';
import { simulationApi } from '../api/simulationApi';
import { trackEvent } from '../api/events';
import { SetupProfileStep } from './SetupProfileStep';
import { SetupConfigStep } from './SetupConfigStep';

interface Props {
  onStart: (request: StartSimulationRequest) => void;
  loading: boolean;
  activeMode?: ChallengeType;
  initialCategoryIds?: number[];
  initialSkillIds?: number[];
  skipProfileSelection?: boolean;
  initialDifficulty?: DifficultyLevel;
}
export const SetupScreen = ({
  onStart,
  loading,
  activeMode,
  initialCategoryIds,
  initialSkillIds,
  initialDifficulty,
}: Props) => {
  const [showConfiguration, setShowConfiguration] = useState(
    Boolean(initialDifficulty)
  );
  const [selectedMode, setSelectedMode] = useState<ChallengeType>(
    activeMode || 'SITUATIONAL_QCM'
  );
  const [selectedDifficulty, setSelectedDifficulty] = useState<DifficultyLevel>(
    initialDifficulty ?? 'JUNIOR'
  );
  const [categories, setCategories] = useState<Category[]>([]);
  const [skills, setSkills] = useState<Skill[]>([]);
  const [selectedCategoryIds, setSelectedCategoryIds] = useState<number[]>(initialCategoryIds ?? []);
  const [selectedSkillIds, setSelectedSkillIds] = useState<number[]>(initialSkillIds ?? []);
  const [isLoadingTopics, setIsLoadingTopics] = useState(false);
  const [topicsError, setTopicsError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    const loadTopics = async () => {
      setIsLoadingTopics(true);
      setTopicsError(null);

      try {
        const [categoryData, skillData] = await Promise.all([
          simulationApi.getCategories(),
          simulationApi.getSkills(),
        ]);

        if (isMounted) {
          setCategories(categoryData);
          setSkills(skillData);
        }
      } catch (error) {
        console.error(error);
        if (isMounted) {
          setTopicsError('Les technologies et sujets ne sont pas disponibles pour le moment.');
        }
      } finally {
        if (isMounted) {
          setIsLoadingTopics(false);
        }
      }
    };

    loadTopics();

    return () => {
      isMounted = false;
    };
  }, []);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onStart({
      mode: selectedMode,
      difficulty: selectedDifficulty,
      categoryIds: selectedCategoryIds.length > 0 ? selectedCategoryIds : undefined,
      skillIds: selectedSkillIds.length > 0 ? selectedSkillIds : undefined,
    });
  };

  const toggleCategory = (categoryId: number) => {
    setSelectedCategoryIds((current) =>
      current.includes(categoryId)
        ? current.filter((id) => id !== categoryId)
        : [...current, categoryId]
    );
  };

  const toggleSkill = (skillId: number) => {
    setSelectedSkillIds((current) =>
      current.includes(skillId)
        ? current.filter((id) => id !== skillId)
        : [...current, skillId]
    );
  };

  const clearTopics = () => {
    setSelectedCategoryIds([]);
    setSelectedSkillIds([]);
  };

  // Même mécanisme que App.tsx : sur mobile, un défilement lancé avant le  // remplacement de l'écran est parfois abandonné par le navigateur — on le  // rejoue juste après le rendu, en défilement instantané.  const scrollToTopAfterRender = () => {
    window.requestAnimationFrame(() => {
      window.scrollTo({ top: 0, behavior: 'auto' });
    });
  };

  // Clic sur une carte profil (ou son bouton « Commencer ») → navigation  // immédiate vers la configuration, en haut de la page.  

  if (!showConfiguration) {
    return (
      <SetupProfileStep
        key="profiles"
        onPlacement={() => onStart({
          mode: 'SITUATIONAL_QCM',
          difficulty: 'JUNIOR',
          placement: true,
        })}
        onPersonalize={() => {
          trackEvent('config_personalize_opened', {});
          setShowConfiguration(true);
          scrollToTopAfterRender();
        }}
      />
    );
  }

  // Si placement=true, on va directement en configuration sans afficher
  // le profil si skipProfileSelection est vrai, ou on saute directement
  // vers la config. Sinon comportement normal.  

  return (
    <SetupConfigStep
      key="config"
      loading={loading}
      onSubmit={handleSubmit}
      selectedMode={selectedMode}
      onSelectMode={setSelectedMode}
      selectedDifficulty={selectedDifficulty}
      onSelectDifficulty={setSelectedDifficulty}
      topics={{
        categories,
        skills,
        selectedCategoryIds,
        selectedSkillIds,
        onToggleCategory: toggleCategory,
        onToggleSkill: toggleSkill,
        onClear: clearTopics,
        loading: isLoadingTopics,
        error: topicsError,
      }}
    />
  );
};

