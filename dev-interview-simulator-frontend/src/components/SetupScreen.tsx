import { useEffect, useState } from 'react';
import type {
  Category,
  ChallengeType,
  DifficultyLevel,
  Skill,
  StartSimulationRequest,
} from '../types';
import { simulationApi } from '../api/simulationApi';
import { Button } from './common/Button';
import {
  HelpCircle,
  Code2,
  Layers,
  ArrowRight,
  Check,
  BriefcaseBusiness,
  Cloud,
  ClipboardCheck,
  ShieldCheck,
  Database,
  KanbanSquare,
  ArrowLeft,
  Loader2,
} from 'lucide-react';

interface Props {
  onStart: (request: StartSimulationRequest) => void;
  loading: boolean;
  activeMode?: ChallengeType;
}

interface ModeCardConfig {
  id: ChallengeType;
  title: string;
  description: string;
  icon: typeof HelpCircle;
}

interface ProfileCardConfig {
  id: string;
  title: string;
  description: string;
  icon: typeof BriefcaseBusiness;
}

const PROFILES: ProfileCardConfig[] = [
  {
    id: 'developer',
    title: 'Développeur',
    description: 'Code, conception et résolution de problèmes techniques.',
    icon: BriefcaseBusiness,
  },
  {
    id: 'devops-cloud',
    title: 'DevOps / Cloud',
    description: 'Infrastructure, déploiement et fiabilité des services.',
    icon: Cloud,
  },
  {
    id: 'qa-testing',
    title: 'QA / Testing',
    description: 'Qualité logicielle, automatisation et stratégies de test.',
    icon: ClipboardCheck,
  },
  {
    id: 'cybersecurity',
    title: 'Cybersécurité',
    description: 'Sécurité applicative, risques et protection des systèmes.',
    icon: ShieldCheck,
  },
  {
    id: 'data',
    title: 'Data',
    description: 'Données, analyse et mise en place de solutions pertinentes.',
    icon: Database,
  },
  {
    id: 'it-project-manager',
    title: 'Chef de projet IT',
    description: 'Pilotage, coordination et livraison de projets numériques.',
    icon: KanbanSquare,
  },
];

const MODES: ModeCardConfig[] = [
  {
    id: 'SITUATIONAL_QCM',
    title: 'QCM',
    description: 'Testez vos connaissances et vos réflexes d’ingénieur.',
    icon: HelpCircle,
  },
  {
    id: 'CODE_REVIEW',
    title: 'Code Review',
    description: 'Analysez du code source comme en entretien technique.',
    icon: Code2,
  },
  {
    id: 'ARCHITECTURE',
    title: 'Architecture',
    description: 'Résolvez des problèmes de conception de systèmes.',
    icon: Layers,
  },
];

const DIFFICULTIES: { id: DifficultyLevel; label: string }[] = [
  { id: 'JUNIOR', label: 'Junior' },
  { id: 'INTERMEDIATE', label: 'Intermédiaire' },
  { id: 'ADVANCED', label: 'Senior' },
];

export const SetupScreen = ({ onStart, loading, activeMode }: Props) => {
  const [selectedProfile, setSelectedProfile] = useState<string | null>(null);
  const [showConfiguration, setShowConfiguration] = useState(false);
  const [selectedMode, setSelectedMode] = useState<ChallengeType>(
    activeMode || 'SITUATIONAL_QCM'
  );
  const [selectedDifficulty, setSelectedDifficulty] = useState<DifficultyLevel>('JUNIOR');
  const [questionCount, setQuestionCount] = useState(5);
  const [categories, setCategories] = useState<Category[]>([]);
  const [skills, setSkills] = useState<Skill[]>([]);
  const [selectedCategoryIds, setSelectedCategoryIds] = useState<number[]>([]);
  const [selectedSkillIds, setSelectedSkillIds] = useState<number[]>([]);
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

  const selectedProfileLabel = PROFILES.find(
    (profile) => profile.id === selectedProfile
  )?.title;

  if (!showConfiguration) {
    return (
      <div className="relative w-full min-h-[calc(80vh-80px)] flex flex-col items-center justify-center py-10 sm:py-16 px-4">
        <div className="w-full max-w-4xl mx-auto space-y-10 sm:space-y-12 text-center">
          <div className="space-y-4">
            <p className="font-sans text-xs uppercase tracking-[0.2em] text-[#797E88] font-semibold">
              Dev Interview Simulator
            </p>
            <h1 className="font-serif text-3xl sm:text-5xl lg:text-6xl font-semibold text-[#123C69] tracking-tight leading-[1.12]">
              Vous êtes quel profil ?
            </h1>
            <p className="text-sm sm:text-base text-[#484F59] font-sans max-w-lg mx-auto leading-relaxed">
              Choisissez votre domaine pour commencer une simulation adaptée à
              votre parcours.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5 text-left">
            {PROFILES.map((profile) => {
              const isSelected = selectedProfile === profile.id;
              const Icon = profile.icon;

              return (
                <button
                  key={profile.id}
                  type="button"
                  onClick={() => setSelectedProfile(profile.id)}
                  aria-pressed={isSelected}
                  className={`group relative min-h-36 rounded-2xl border p-5 text-left transition-all duration-200 cursor-pointer ${
                    isSelected
                      ? 'bg-white border-[#123C69] shadow-[0_4px_20px_rgba(18,60,105,0.08)] ring-1 ring-[#123C69]'
                      : 'bg-white/90 border-[#E8E2D8] hover:border-[#BAB2B5] hover:shadow-[0_2px_10px_rgba(18,60,105,0.03)]'
                  }`}
                >
                  <div className="flex items-start justify-between gap-4">
                    <div
                      className={`w-9 h-9 rounded-xl flex items-center justify-center border transition-colors ${
                        isSelected
                          ? 'bg-[#E6EFF8] border-[#B8D3EC] text-[#123C69]'
                          : 'bg-[#FAF9F7] border-[#E8E2D8] text-[#797E88] group-hover:text-[#123C69]'
                      }`}
                    >
                      <Icon className="w-4 h-4 stroke-[2]" />
                    </div>
                    <div
                      className={`w-4 h-4 rounded-full border flex items-center justify-center transition-all ${
                        isSelected
                          ? 'border-[#123C69] bg-[#123C69] text-white'
                          : 'border-[#DDD5D8] bg-white'
                      }`}
                    >
                      {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                    </div>
                  </div>

                  <div className="space-y-1.5 mt-6">
                    <h2
                      className={`font-serif text-xl font-bold transition-colors ${
                        isSelected ? 'text-[#123C69]' : 'text-[#102136]'
                      }`}
                    >
                      {profile.title}
                    </h2>
                    <p className="text-xs text-[#5C554E] leading-relaxed">
                      {profile.description}
                    </p>
                  </div>
                </button>
              );
            })}
          </div>

          <div className="min-h-12 flex items-center justify-center">
            {selectedProfile && (
              <Button
                type="button"
                variant="primary"
                size="lg"
                onClick={() => setShowConfiguration(true)}
                rightIcon={<ArrowRight className="w-4 h-4" />}
                className="px-8 py-3 text-base font-semibold tracking-wide"
              >
                Continuer avec {selectedProfileLabel}
              </Button>
            )}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="w-full min-h-[calc(80vh-80px)] flex flex-col items-center justify-center py-10 sm:py-16 px-4">
      <div className="w-full max-w-3xl mx-auto space-y-12 sm:space-y-14 text-center">
        <button
          type="button"
          onClick={() => setShowConfiguration(false)}
          className="mx-auto flex items-center gap-2 text-xs font-medium text-[#797E88] hover:text-[#123C69] transition-colors cursor-pointer"
        >
          <ArrowLeft className="w-3.5 h-3.5" />
          Changer de profil
        </button>

        {/* Brand & Main Headline */}
        <div className="space-y-4">
          <p className="font-sans text-xs uppercase tracking-[0.2em] text-[#797E88] font-semibold">
            Dev Interview Simulator
          </p>
          <h1 className="font-serif text-3xl sm:text-5xl lg:text-6xl font-semibold text-[#123C69] tracking-tight leading-[1.12]">
            Préparez votre prochain <br className="hidden sm:inline" />
            entretien technique.
          </h1>
          <p className="text-sm sm:text-base text-[#484F59] font-sans max-w-md mx-auto leading-relaxed">
            {selectedProfileLabel
              ? `Configurez votre entraînement ${selectedProfileLabel.toLowerCase()} en conditions réelles.`
              : "Choisissez un mode d'évaluation pour vous entraîner en conditions réelles."}
          </p>
        </div>

        {/* Mode Cards Grid (3 cards centered, airy) */}
        <form onSubmit={handleSubmit} className="space-y-10 sm:space-y-12">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 sm:gap-5 text-left">
            {MODES.map((mode) => {
              const isSelected = selectedMode === mode.id;
              const Icon = mode.icon;

              return (
                <div
                  key={mode.id}
                  onClick={() => setSelectedMode(mode.id)}
                  className={`group relative rounded-2xl border p-6 transition-all duration-200 cursor-pointer flex flex-col justify-between select-none ${
                    isSelected
                      ? 'bg-white border-[#123C69] shadow-[0_4px_20px_rgba(18,60,105,0.08)] ring-1 ring-[#123C69]'
                      : 'bg-white border-[#E8E2D8] hover:border-[#BAB2B5] hover:shadow-[0_2px_10px_rgba(18,60,105,0.03)]'
                  }`}
                >
                  <div className="space-y-4">
                    {/* Header with minimal monochrome icon */}
                    <div className="flex items-center justify-between">
                      <div
                        className={`w-9 h-9 rounded-xl flex items-center justify-center border transition-colors ${
                          isSelected
                            ? 'bg-[#E6EFF8] border-[#B8D3EC] text-[#123C69]'
                            : 'bg-[#FAF9F7] border-[#E8E2D8] text-[#797E88] group-hover:text-[#123C69]'
                        }`}
                      >
                        <Icon className="w-4 h-4 stroke-[2]" />
                      </div>

                      <div
                        className={`w-4 h-4 rounded-full border flex items-center justify-center transition-all ${
                          isSelected
                            ? 'border-[#123C69] bg-[#123C69] text-white'
                            : 'border-[#DDD5D8] bg-white'
                        }`}
                      >
                        {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                      </div>
                    </div>

                    <div className="space-y-1.5">
                      <h3
                        className={`font-serif text-xl font-bold transition-colors ${
                          isSelected ? 'text-[#123C69]' : 'text-[#102136]'
                        }`}
                      >
                        {mode.title}
                      </h3>
                      <p className="text-xs text-[#5C554E] leading-relaxed">
                        {mode.description}
                      </p>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Minimalist Configuration Bar (Level + Options) */}
          <div className="flex flex-col items-center justify-center gap-6 pt-2">
            <div className="flex flex-wrap items-center justify-center gap-2 text-xs font-sans">
              <span className="text-[#797E88] font-medium mr-2">Niveau attendu :</span>
              <div className="inline-flex p-1 rounded-xl bg-white border border-[#E8E2D8] shadow-[0_1px_2px_rgba(18,60,105,0.02)]">
                {DIFFICULTIES.map((diff) => {
                  const isDiffSelected = selectedDifficulty === diff.id;
                  return (
                    <button
                      key={diff.id}
                      type="button"
                      onClick={() => setSelectedDifficulty(diff.id)}
                      className={`px-3.5 py-1.5 rounded-lg text-xs font-medium transition-all cursor-pointer ${
                        isDiffSelected
                          ? 'bg-[#123C69] text-white shadow-sm'
                          : 'text-[#484F59] hover:text-[#102136] hover:bg-[#FAF9F7]'
                      }`}
                    >
                      {diff.label}
                    </button>
                  );
                })}
              </div>
            </div>

            <div className="w-full max-w-2xl rounded-2xl border border-[#E8E2D8] bg-[#FCFBF9] px-4 py-4 text-left sm:px-5">
              <div className="flex flex-col gap-1 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <h2 className="text-sm font-semibold text-[#102136]">
                    Technologies / sujets <span className="font-normal text-[#797E88]">— optionnel</span>
                  </h2>
                  <p className="mt-1 text-xs text-[#797E88]">
                    Affinez les questions proposées, ou continuez sans filtre.
                  </p>
                </div>
                {(selectedCategoryIds.length > 0 || selectedSkillIds.length > 0) && (
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedCategoryIds([]);
                      setSelectedSkillIds([]);
                    }}
                    className="self-start text-xs font-medium text-[#AC3B61] transition hover:text-[#8C294A] sm:self-auto"
                  >
                    Tout désélectionner
                  </button>
                )}
              </div>

              {isLoadingTopics ? (
                <div className="mt-4 flex items-center gap-2 text-xs text-[#797E88]">
                  <Loader2 className="h-3.5 w-3.5 animate-spin" />
                  Chargement des technologies…
                </div>
              ) : topicsError ? (
                <p className="mt-4 text-xs text-[#AC3B61]">{topicsError}</p>
              ) : (
                <div className="mt-4 flex flex-wrap gap-2">
                  {categories.map((category) => {
                    const isSelected = selectedCategoryIds.includes(category.id);
                    return (
                      <button
                        key={`category-${category.id}`}
                        type="button"
                        onClick={() => toggleCategory(category.id)}
                        aria-pressed={isSelected}
                        className={`rounded-lg border px-3 py-1.5 text-xs transition ${
                          isSelected
                            ? 'border-[#123C69] bg-[#E6EFF8] font-semibold text-[#123C69]'
                            : 'border-[#E8E2D8] bg-white text-[#484F59] hover:border-[#BAB2B5] hover:text-[#123C69]'
                        }`}
                      >
                        {category.name}
                      </button>
                    );
                  })}
                  {skills.map((skill) => {
                    const isSelected = selectedSkillIds.includes(skill.id);
                    return (
                      <button
                        key={`skill-${skill.id}`}
                        type="button"
                        onClick={() => toggleSkill(skill.id)}
                        aria-pressed={isSelected}
                        className={`rounded-lg border px-3 py-1.5 text-xs transition ${
                          isSelected
                            ? 'border-[#123C69] bg-[#E6EFF8] font-semibold text-[#123C69]'
                            : 'border-[#E8E2D8] bg-white text-[#484F59] hover:border-[#BAB2B5] hover:text-[#123C69]'
                        }`}
                      >
                        {skill.name}
                      </button>
                    );
                  })}
                  {categories.length === 0 && skills.length === 0 && (
                    <p className="text-xs text-[#797E88]">
                      Aucun sujet disponible pour cette configuration.
                    </p>
                  )}
                </div>
              )}
            </div>

            {/* Architecture step options (discreetly visible if ARCHITECTURE) */}
            {selectedMode === 'ARCHITECTURE' && (
              <div className="inline-flex items-center gap-3 text-xs font-sans text-[#5C554E] bg-white border border-[#E8E2D8] px-4 py-2 rounded-xl">
                <span>Scénario Food Delivery :</span>
                <div className="flex items-center gap-1">
                  {[3, 4, 5].map((count) => (
                    <button
                      key={count}
                      type="button"
                      onClick={() => setQuestionCount(count)}
                      className={`w-6 h-6 rounded text-xs font-mono font-semibold transition-colors cursor-pointer ${
                        questionCount === count
                          ? 'bg-[#123C69] text-white'
                          : 'text-[#5C554E] hover:bg-[#FAF9F7]'
                      }`}
                    >
                      {count}
                    </button>
                  ))}
                  <span className="text-[11px] text-[#797E88] ml-1">étapes</span>
                </div>
              </div>
            )}

            {/* Prominent Action Button (Rosewood Accent #AC3B61) */}
            <div className="pt-2">
              <Button
                type="submit"
                variant="primary"
                size="lg"
                loading={loading}
                rightIcon={<ArrowRight className="w-4 h-4" />}
                className="px-9 py-3 text-base font-semibold tracking-wide"
              >
                Commencer l'entraînement
              </Button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};