import { useEffect, useState } from 'react';
import type {
  Category,
  ChallengeType,
  DifficultyLevel,
  Skill,
  StartSimulationRequest,
} from '../types';
import { simulationApi } from '../api/simulationApi';
import { SetupProfileStep } from './SetupProfileStep';
import { SetupConfigStep } from './SetupConfigStep';

interface Props {
  onStart: (request: StartSimulationRequest) => void;
  loading: boolean;
  activeMode?: ChallengeType;
  initialCategoryIds?: number[];
  initialSkillIds?: number[];
  skipProfileSelection?: boolean;
}

export const SetupScreen = ({
  onStart,
  loading,
  activeMode,
  initialCategoryIds,
  initialSkillIds,
  skipProfileSelection = false,
}: Props) => {
  const [selectedProfile, setSelectedProfile] = useState<string | null>(null);
  const [showConfiguration, setShowConfiguration] = useState(skipProfileSelection);
  const [selectedMode, setSelectedMode] = useState<ChallengeType>(
    activeMode || 'SITUATIONAL_QCM'
  );
  const [selectedDifficulty, setSelectedDifficulty] = useState<DifficultyLevel>('JUNIOR');
  const [questionCount, setQuestionCount] = useState(5);
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
      questionCount: selectedMode === 'ARCHITECTURE' ? questionCount : undefined,
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

  // Clic sur une carte profil → navigation immédiate vers la configuration.
  const handleProfileSelect = (profileId: string) => {
    setSelectedProfile(profileId);
    setShowConfiguration(true);
  };

  if (!showConfiguration) {
    return (
      <SetupProfileStep
        key="profiles"
        selectedProfile={selectedProfile}
        onSelect={handleProfileSelect}
      />
    );
  }

  return (
    <SetupConfigStep
      key="config"
      onBack={() => setShowConfiguration(false)}
      loading={loading}
      onSubmit={handleSubmit}
      selectedMode={selectedMode}
      onSelectMode={setSelectedMode}
      selectedDifficulty={selectedDifficulty}
      onSelectDifficulty={setSelectedDifficulty}
      questionCount={questionCount}
      onQuestionCountChange={setQuestionCount}
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
