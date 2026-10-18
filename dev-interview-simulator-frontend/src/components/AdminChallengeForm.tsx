import { useState, useEffect } from 'react';
import type { AdminChallengeRequest, AdminScenario } from '../api/adminApi';
import { adminApi, scenarioApi } from '../api/adminApi';
import { profileApi } from '../api/profileApi';
import type { Profile } from '../api/profileApi';
import { simulationApi } from '../api/simulationApi';
import type { Category, Skill, ChallengeType } from '../types';
import { Button } from './common/Button';
import { AdminFormHeader } from './AdminFormHeader';
import { AdminChallengeBasics } from './AdminChallengeBasics';
import { AdminTaxonomyFields } from './AdminTaxonomyFields';
import { AdminScenarioSection } from './AdminScenarioSection';
import { AdminOptionsEditor } from './AdminOptionsEditor';

interface Props {
  challengeId?: number;
  defaultScenarioId?: number;
  onBack: () => void;
  onSaved: () => void;
}

const ALL_CHALLENGE_TYPES: ChallengeType[] = ['SITUATIONAL_QCM', 'CODE_REVIEW', 'ARCHITECTURE', 'SEQUENTIAL_REASONING'];

export const AdminChallengeForm = ({ challengeId, defaultScenarioId, onBack, onSaved }: Props) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [skills, setSkills] = useState<Skill[]>([]);
  const [scenarios, setScenarios] = useState<AdminScenario[]>([]);

  const [formData, setFormData] = useState<AdminChallengeRequest>({
    title: '',
    type: defaultScenarioId ? 'ARCHITECTURE' : 'SITUATIONAL_QCM',
    difficulty: 'INTERMEDIATE',
    selectionType: 'SINGLE_CHOICE',
    question: '',
    context: '',
    explanation: '',
    estimatedTimeSeconds: 60,
    points: 10,
    categoryIds: [],
    skillIds: [],
    profileIds: [],
    scenarioId: defaultScenarioId,
    options: []
  });

  useEffect(() => {
    profileApi.getProfiles()
      .then(setProfiles)
      .catch(() => setProfiles([]));
    simulationApi.getCategories()
      .then(setCategories)
      .catch(() => setCategories([]));
    simulationApi.getSkills()
      .then(setSkills)
      .catch(() => setSkills([]));
    scenarioApi.getScenarios()
      .then(setScenarios)
      .catch(() => setScenarios([]));
  }, []);

  useEffect(() => {
    if (challengeId) {
      loadChallenge(challengeId);
    }
  }, [challengeId]);

  // Types autorisés : union des types des profils sélectionnés (vide = tous autorisés)
  const restrictedTypes = profiles
    .filter(p => formData.profileIds.includes(p.id))
    .map(p => p.allowedTypes ?? [])
    .filter(types => types.length > 0);
  const allowedTypes: ChallengeType[] = restrictedTypes.length === 0
    ? ALL_CHALLENGE_TYPES
    : ALL_CHALLENGE_TYPES.filter(t => restrictedTypes.some(types => types.includes(t)));
  const effectiveAllowedTypes = allowedTypes.length > 0 ? allowedTypes : ALL_CHALLENGE_TYPES;

  useEffect(() => {
    if (!effectiveAllowedTypes.includes(formData.type)) {
      setFormData(prev => ({ ...prev, type: effectiveAllowedTypes[0] }));
    }
  }, [effectiveAllowedTypes, formData.type]);

  const loadChallenge = async (id: number) => {
    setLoading(true);
    try {
      const data = await adminApi.getChallenge(id);
      setFormData({
        title: data.title,
        type: data.type,
        difficulty: data.difficulty,
        selectionType: data.selectionType,
        question: data.question,
        context: data.context || '',
        explanation: data.explanation || '',
        codeSnippet: data.codeSnippet || '',
        codeLanguage: data.codeLanguage || '',
        revealedInformation: data.revealedInformation || '',
        tradeoff: data.tradeoff || '',
        scenarioId: data.scenarioId ?? undefined,
        stepOrder: data.stepOrder ?? undefined,
        estimatedTimeSeconds: data.estimatedTimeSeconds || 60,
        points: data.points,
        categoryIds: data.categoryIds ?? [],
        skillIds: data.skillIds ?? [],
        profileIds: data.profileIds ?? [],
        options: data.options.map(o => ({
          ...o,
          content: o.content,
          correct: o.correct,
          displayOrder: o.displayOrder,
          explanation: o.explanation || '',
          severity: o.severity || ''
        }))
      });
    } catch (err) {
      setError('Erreur lors du chargement de la question.');
    } finally {
      setLoading(false);
    }
  };

  const handleScenarioCreated = (created: AdminScenario) => {
    setScenarios(prev => [...prev, created].sort((a, b) => a.title.localeCompare(b.title)));
    setFormData(prev => ({ ...prev, scenarioId: created.id }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const request: AdminChallengeRequest = formData.type === 'ARCHITECTURE'
        ? formData
        : { ...formData, scenarioId: undefined, stepOrder: undefined };
      if (challengeId) {
        await adminApi.updateChallenge(challengeId, request);
      } else {
        await adminApi.createChallenge(request);
      }
      onSaved();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Erreur lors de la sauvegarde.');
    } finally {
      setLoading(false);
    }
  };

  const scenarioTitle = formData.scenarioId != null
    ? scenarios.find(s => s.id === formData.scenarioId)?.title || `#${formData.scenarioId}`
    : undefined;

  return (
    <div className="space-y-6">
      <AdminFormHeader
        challengeId={challengeId}
        defaultScenarioId={defaultScenarioId}
        scenarioTitle={scenarioTitle}
        onBack={onBack}
        error={error}
      />

      <form onSubmit={handleSubmit} className="bg-surface rounded-2xl p-6 border border-border shadow-panel space-y-6">
        <AdminChallengeBasics
          formData={formData}
          setFormData={setFormData}
          allowedTypes={effectiveAllowedTypes}
        />

        <AdminTaxonomyFields
          formData={formData}
          setFormData={setFormData}
          profiles={profiles}
          categories={categories}
          skills={skills}
        />

        {formData.type === 'ARCHITECTURE' && (
          <AdminScenarioSection
            formData={formData}
            setFormData={setFormData}
            scenarios={scenarios}
            challengeId={challengeId}
            onError={setError}
            onScenarioCreated={handleScenarioCreated}
          />
        )}

        <AdminOptionsEditor formData={formData} setFormData={setFormData} />

        <div className="pt-6 border-t border-border-subtle flex justify-end gap-3">
          <Button type="button" variant="secondary" onClick={onBack} disabled={loading}>
            Annuler
          </Button>
          <Button type="submit" variant="primary" disabled={loading}>
            {loading ? 'Sauvegarde...' : 'Enregistrer'}
          </Button>
        </div>
      </form>
    </div>
  );
};
