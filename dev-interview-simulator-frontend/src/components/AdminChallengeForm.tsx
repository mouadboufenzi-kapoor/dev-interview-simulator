import { useState, useEffect } from 'react';
import { Button } from './common/Button';
import { ArrowLeft, Plus, Trash2 } from 'lucide-react';
import type { AdminChallengeRequest, AdminChallengeOptionRequest, AdminScenario, AdminScenarioStep } from '../api/adminApi';
import { adminApi, scenarioApi } from '../api/adminApi';
import { profileApi } from '../api/profileApi';
import type { Profile } from '../api/profileApi';
import { simulationApi } from '../api/simulationApi';
import type { Category, Skill } from '../types';
import { MultiSelect } from './common/MultiSelect';
import type { ChallengeType } from '../types';

interface Props {
  challengeId?: number;
  defaultScenarioId?: number;
  onBack: () => void;
  onSaved: () => void;
}

const ALL_CHALLENGE_TYPES: ChallengeType[] = ['SITUATIONAL_QCM', 'PROBLEM_SOLVING', 'CODE_REVIEW', 'ARCHITECTURE'];

export const AdminChallengeForm = ({ challengeId, defaultScenarioId, onBack, onSaved }: Props) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [skills, setSkills] = useState<Skill[]>([]);
  const [scenarios, setScenarios] = useState<AdminScenario[]>([]);
  const [scenarioSteps, setScenarioSteps] = useState<AdminScenarioStep[]>([]);
  const [newScenarioOpen, setNewScenarioOpen] = useState(false);
  const [newScenarioTitle, setNewScenarioTitle] = useState('');
  const [newScenarioDescription, setNewScenarioDescription] = useState('');
  const [creatingScenario, setCreatingScenario] = useState(false);

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

  // Charge les étapes déjà créées du scénario sélectionné et propose l'ordre suivant
  useEffect(() => {
    const scenarioId = formData.scenarioId;
    if (!scenarioId) {
      setScenarioSteps([]);
      return;
    }
    let cancelled = false;
    scenarioApi.getScenarioSteps(scenarioId)
      .then(steps => {
        if (cancelled) return;
        setScenarioSteps(steps);
        if (!challengeId) {
          const maxOrder = steps.reduce((max, s) => Math.max(max, s.stepOrder ?? 0), 0);
          setFormData(prev => prev.scenarioId === scenarioId
            ? { ...prev, stepOrder: maxOrder + 1 }
            : prev);
        }
      })
      .catch(() => {
        if (!cancelled) setScenarioSteps([]);
      });
    return () => { cancelled = true; };
  }, [formData.scenarioId, challengeId]);

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

  const handleAddOption = () => {
    setFormData(prev => ({
      ...prev,
      options: [
        ...prev.options,
        { content: '', correct: false, displayOrder: prev.options.length + 1 }
      ]
    }));
  };

  const handleOptionChange = (index: number, field: keyof AdminChallengeOptionRequest, value: any) => {
    setFormData(prev => {
      const newOptions = [...prev.options];
      newOptions[index] = { ...newOptions[index], [field]: value };
      return { ...prev, options: newOptions };
    });
  };

  const handleRemoveOption = (index: number) => {
    setFormData(prev => {
      const newOptions = [...prev.options];
      newOptions.splice(index, 1);
      return { ...prev, options: newOptions };
    });
  };

  const handleScenarioChange = (value: string) => {
    if (value === '__new__') {
      setNewScenarioOpen(true);
      return;
    }
    setNewScenarioOpen(false);
    setFormData(prev => ({
      ...prev,
      scenarioId: value ? Number(value) : undefined
    }));
  };

  const handleCreateScenario = async () => {
    if (!newScenarioTitle.trim()) return;
    setCreatingScenario(true);
    setError(null);
    try {
      const created = await scenarioApi.createScenario({
        title: newScenarioTitle.trim(),
        description: newScenarioDescription.trim() || undefined
      });
      setScenarios(prev => [...prev, created].sort((a, b) => a.title.localeCompare(b.title)));
      setFormData(prev => ({ ...prev, scenarioId: created.id }));
      setNewScenarioOpen(false);
      setNewScenarioTitle('');
      setNewScenarioDescription('');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Erreur lors de la création du scénario.');
    } finally {
      setCreatingScenario(false);
    }
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

  const contextField = (
    <label className="block space-y-1.5">
      <span className="text-sm font-semibold text-[#102136]">Contexte</span>
      <textarea value={formData.context} onChange={e => setFormData({...formData, context: e.target.value})} className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none" rows={2} />
    </label>
  );

  const pointsTimeFields = (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
      <label className="block space-y-1.5">
        <span className="text-sm font-semibold text-[#102136]">Points</span>
        <input type="number" required value={formData.points} onChange={e => setFormData({...formData, points: parseInt(e.target.value)})} className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none" />
      </label>
      <label className="block space-y-1.5">
        <span className="text-sm font-semibold text-[#102136]">Temps estimé (secondes)</span>
        <input type="number" min={1} required={formData.type !== 'ARCHITECTURE'} value={formData.estimatedTimeSeconds ?? ''} onChange={e => setFormData({...formData, estimatedTimeSeconds: e.target.value ? parseInt(e.target.value) : undefined})} className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none" />
      </label>
    </div>
  );

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <button onClick={onBack} className="p-2 hover:bg-[#FAF9F7] rounded-lg transition">
          <ArrowLeft className="w-5 h-5 text-[#797E88]" />
        </button>
        <div>
          <h2 className="text-2xl font-serif font-bold text-[#123C69]">
            {challengeId
              ? 'Modifier la question'
              : defaultScenarioId
                ? 'Nouvelle étape'
                : 'Nouvelle question'}
          </h2>
          {formData.scenarioId != null && (
            <p className="text-sm text-[#484F59] mt-1">
              Scénario : {scenarios.find(s => s.id === formData.scenarioId)?.title || `#${formData.scenarioId}`}
            </p>
          )}
        </div>
      </div>

      {error && (
        <div className="p-4 rounded-xl bg-[#FDF2F2] border border-[#F3BEBE] text-[#9C2727] text-sm">
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="bg-white rounded-2xl p-6 border border-[#E8E2D8] shadow-[0_4px_12px_rgba(18,60,105,0.05)] space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <label className="block space-y-1.5">
            <span className="text-sm font-semibold text-[#102136]">Titre</span>
            <input required value={formData.title} onChange={e => setFormData({...formData, title: e.target.value})} className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none" />
          </label>
          
          <label className="block space-y-1.5">
            <span className="text-sm font-semibold text-[#102136]">Type</span>
            <select required value={formData.type} onChange={e => setFormData({...formData, type: e.target.value as ChallengeType})} className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none">
              {effectiveAllowedTypes.map(t => (
                <option key={t} value={t}>{t}</option>
              ))}
            </select>
          </label>

          <label className="block space-y-1.5">
            <span className="text-sm font-semibold text-[#102136]">Difficulté</span>
            <select required value={formData.difficulty} onChange={e => setFormData({...formData, difficulty: e.target.value})} className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none">
              <option value="JUNIOR">JUNIOR</option>
              <option value="INTERMEDIATE">INTERMEDIATE</option>
              <option value="SENIOR">SENIOR</option>
            </select>
          </label>

          <label className="block space-y-1.5">
            <span className="text-sm font-semibold text-[#102136]">Type de sélection</span>
            <select required value={formData.selectionType} onChange={e => setFormData({...formData, selectionType: e.target.value})} className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none">
              <option value="SINGLE_CHOICE">SINGLE_CHOICE</option>
              <option value="MULTIPLE_CHOICE">MULTIPLE_CHOICE</option>
            </select>
          </label>
        </div>

        {formData.type !== 'ARCHITECTURE' && contextField}

        <label className="block space-y-1.5">
          <span className="text-sm font-semibold text-[#102136]">Question *</span>
          <textarea required value={formData.question} onChange={e => setFormData({...formData, question: e.target.value})} className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none" rows={2} />
        </label>

        <label className="block space-y-1.5">
          <span className="text-sm font-semibold text-[#102136]">Explication globale</span>
          <textarea value={formData.explanation} onChange={e => setFormData({...formData, explanation: e.target.value})} className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none" rows={2} />
        </label>

        {formData.type === 'ARCHITECTURE' ? (
          <details className="pt-1">
            <summary className="cursor-pointer text-sm font-semibold text-[#102136] select-none">
              Champs avancés (contexte, points, temps estimé)
            </summary>
            <div className="mt-6 space-y-6">
              {contextField}
              {pointsTimeFields}
            </div>
          </details>
        ) : (
          pointsTimeFields
        )}

        <div className="space-y-4 pt-4 border-t border-[#F2EDE6]">
          <h3 className="font-serif font-bold text-lg text-[#123C69]">Profils, catégories et compétences</h3>
          <MultiSelect
            label="Profils associés"
            options={profiles}
            selectedIds={formData.profileIds}
            onChange={ids => setFormData({ ...formData, profileIds: ids })}
            emptyMessage="Aucun profil actif disponible."
          />
          <MultiSelect
            label="Catégories"
            options={categories}
            selectedIds={formData.categoryIds}
            onChange={ids => setFormData({ ...formData, categoryIds: ids })}
            emptyMessage="Aucune catégorie disponible."
          />
          <MultiSelect
            label="Compétences"
            options={skills}
            selectedIds={formData.skillIds}
            onChange={ids => setFormData({ ...formData, skillIds: ids })}
            emptyMessage="Aucune compétence disponible."
          />
        </div>

        {formData.type === 'ARCHITECTURE' && (
        <div className="space-y-4 pt-4 border-t border-[#F2EDE6]">
          <h3 className="font-serif font-bold text-lg text-[#123C69]">Parcours Architecture</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <label className="block space-y-1.5">
              <span className="text-sm font-semibold text-[#102136]">Scénario</span>
              <select
                value={formData.scenarioId ?? ''}
                onChange={e => handleScenarioChange(e.target.value)}
                className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none bg-white"
              >
                <option value="">Aucun scénario</option>
                {scenarios.map(s => (
                  <option key={s.id} value={s.id}>{s.title}</option>
                ))}
                <option value="__new__">+ Nouveau scénario…</option>
              </select>
            </label>
            <label className="block space-y-1.5">
              <span className="text-sm font-semibold text-[#102136]">Ordre de l'étape</span>
              <input
                type="number"
                min={1}
                value={formData.stepOrder ?? ''}
                onChange={e => setFormData({ ...formData, stepOrder: e.target.value ? parseInt(e.target.value) : undefined })}
                className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none"
              />
            </label>
          </div>

          {scenarioSteps.length > 0 && (
            <div className="space-y-1.5">
              <span className="text-sm font-semibold text-[#102136]">Étapes déjà créées</span>
              <ul className="space-y-1">
                {scenarioSteps.map(step => (
                  <li key={step.challengeId} className="flex items-center gap-2 text-sm text-[#484F59]">
                    <span className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-[#E6EFF8] text-[#123C69] text-xs font-semibold">
                      {step.stepOrder ?? '–'}
                    </span>
                    <span>{step.title}</span>
                    {challengeId === step.challengeId && (
                      <span className="text-xs text-[#797E88]">(étape en cours d'édition)</span>
                    )}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {newScenarioOpen && (
            <div className="p-4 border border-[#E8E2D8] rounded-xl space-y-3 bg-[#FAF9F7]">
              <label className="block space-y-1.5">
                <span className="text-sm font-semibold text-[#102136]">Titre du scénario</span>
                <input
                  value={newScenarioTitle}
                  onChange={e => setNewScenarioTitle(e.target.value)}
                  placeholder="Ex. Design a High-Scale Chat Platform"
                  className="w-full rounded-lg border border-[#E8E2D8] p-2.5 text-sm focus:border-[#123C69] outline-none bg-white"
                />
              </label>
              <label className="block space-y-1.5">
                <span className="text-sm font-semibold text-[#102136]">Description</span>
                <textarea
                  value={newScenarioDescription}
                  onChange={e => setNewScenarioDescription(e.target.value)}
                  rows={2}
                  className="w-full rounded-lg border border-[#E8E2D8] p-2.5 text-sm focus:border-[#123C69] outline-none bg-white"
                />
              </label>
              <div className="flex justify-end gap-3">
                <Button type="button" variant="secondary" size="sm" onClick={() => setNewScenarioOpen(false)} disabled={creatingScenario}>
                  Annuler
                </Button>
                <Button type="button" variant="primary" size="sm" onClick={handleCreateScenario} disabled={creatingScenario || !newScenarioTitle.trim()}>
                  {creatingScenario ? 'Création...' : 'Créer et sélectionner'}
                </Button>
              </div>
            </div>
          )}

          <label className="block space-y-1.5">
            <span className="text-sm font-semibold text-[#102136]">Information révélée après validation</span>
            <textarea
              value={formData.revealedInformation}
              onChange={e => setFormData({ ...formData, revealedInformation: e.target.value })}
              rows={2}
              className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none"
            />
          </label>
          <label className="block space-y-1.5">
            <span className="text-sm font-semibold text-[#102136]">Trade-off pédagogique</span>
            <textarea
              value={formData.tradeoff}
              onChange={e => setFormData({ ...formData, tradeoff: e.target.value })}
              rows={2}
              className="w-full rounded-xl border border-[#E8E2D8] p-3 text-sm focus:border-[#123C69] outline-none"
            />
          </label>
        </div>
        )}

        <div className="space-y-4 pt-4 border-t border-[#F2EDE6]">
          <div className="flex items-center justify-between">
            <h3 className="font-serif font-bold text-lg text-[#123C69]">Options de réponse</h3>
            <Button
              type="button"
              onClick={handleAddOption}
              variant="secondary"
              size="sm"
              leftIcon={<Plus className="w-4 h-4" />}
            >
              Ajouter une option
            </Button>
          </div>

          <div className="space-y-3">
            {formData.options.map((opt, idx) => (
              <div key={idx} className="p-4 border border-[#E8E2D8] rounded-xl space-y-3">
                <div className="flex gap-4 items-start">
                  <div className="flex-1 space-y-3">
                    <input
                      required
                      placeholder="Contenu de l'option..."
                      value={opt.content}
                      onChange={e => handleOptionChange(idx, 'content', e.target.value)}
                      className="w-full rounded-lg border border-[#E8E2D8] p-2.5 text-sm focus:border-[#123C69] outline-none"
                    />
                    {formData.type === 'CODE_REVIEW' && (
                       <input
                        placeholder="Explication (spécifique à l'option)..."
                        value={opt.explanation}
                        onChange={e => handleOptionChange(idx, 'explanation', e.target.value)}
                        className="w-full rounded-lg border border-[#E8E2D8] p-2.5 text-sm focus:border-[#123C69] outline-none"
                      />
                    )}
                  </div>
                  <label className="flex items-center gap-2 mt-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={opt.correct}
                      onChange={e => handleOptionChange(idx, 'correct', e.target.checked)}
                      className="w-4 h-4 text-[#AC3B61] rounded border-[#E8E2D8]"
                    />
                    <span className="text-sm font-medium">Correcte</span>
                  </label>
                  <button type="button" onClick={() => handleRemoveOption(idx)} className="mt-1 p-2 text-[#AC3B61] hover:bg-[#FDF2F2] rounded-lg transition">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="pt-6 border-t border-[#F2EDE6] flex justify-end gap-3">
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
