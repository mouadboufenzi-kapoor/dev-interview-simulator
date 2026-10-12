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
import { Field } from './common/Field';
import { PageTitle } from './common/PageTitle';
import { fieldInput, fieldLabel } from '../styles/ui';
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
    <Field label="Contexte">
            <textarea value={formData.context} onChange={e => setFormData({...formData, context: e.target.value})} className={fieldInput} rows={2} />
    </Field>
  );

  const pointsTimeFields = (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
      <Field label="Points">
                <input type="number" required value={formData.points} onChange={e => setFormData({...formData, points: parseInt(e.target.value)})} className={fieldInput} />
      </Field>
      <Field label="Temps estimé (secondes)">
                <input type="number" min={1} required={formData.type !== 'ARCHITECTURE'} value={formData.estimatedTimeSeconds ?? ''} onChange={e => setFormData({...formData, estimatedTimeSeconds: e.target.value ? parseInt(e.target.value) : undefined})} className={fieldInput} />
      </Field>
    </div>
  );

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <button onClick={onBack} className="p-2 hover:bg-canvas-subtle rounded-lg transition">
          <ArrowLeft className="w-5 h-5 text-ink-muted" />
        </button>
        <div>
          <PageTitle as="h2" size="md">
            {challengeId
              ? 'Modifier la question'
              : defaultScenarioId
                ? 'Nouvelle étape'
                : 'Nouvelle question'}
          </PageTitle>
          {formData.scenarioId != null && (
            <p className="text-sm text-ink-secondary mt-1">
              Scénario : {scenarios.find(s => s.id === formData.scenarioId)?.title || `#${formData.scenarioId}`}
            </p>
          )}
        </div>
      </div>

      {error && (
        <div className="p-4 rounded-xl bg-danger-soft border border-danger-border text-danger text-sm">
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="bg-surface rounded-2xl p-6 border border-border shadow-panel space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Field label="Titre">
                        <input required value={formData.title} onChange={e => setFormData({...formData, title: e.target.value})} className={fieldInput} />
          </Field>
          
          <Field label="Type">
                        <select required value={formData.type} onChange={e => setFormData({...formData, type: e.target.value as ChallengeType})} className={fieldInput}>
              {effectiveAllowedTypes.map(t => (
                <option key={t} value={t}>{t}</option>
              ))}
            </select>
          </Field>

          <Field label="Difficulté">
                        <select required value={formData.difficulty} onChange={e => setFormData({...formData, difficulty: e.target.value})} className={fieldInput}>
              <option value="JUNIOR">JUNIOR</option>
              <option value="INTERMEDIATE">INTERMEDIATE</option>
              <option value="SENIOR">SENIOR</option>
            </select>
          </Field>

          <Field label="Type de sélection">
                        <select required value={formData.selectionType} onChange={e => setFormData({...formData, selectionType: e.target.value})} className={fieldInput}>
              <option value="SINGLE_CHOICE">SINGLE_CHOICE</option>
              <option value="MULTIPLE_CHOICE">MULTIPLE_CHOICE</option>
            </select>
          </Field>
        </div>

        {formData.type !== 'ARCHITECTURE' && contextField}

        <Field label="Question *">
                    <textarea required value={formData.question} onChange={e => setFormData({...formData, question: e.target.value})} className={fieldInput} rows={2} />
        </Field>

        <Field label="Explication globale">
                    <textarea value={formData.explanation} onChange={e => setFormData({...formData, explanation: e.target.value})} className={fieldInput} rows={2} />
        </Field>

        {formData.type === 'ARCHITECTURE' ? (
          <details className="pt-1">
            <summary className={`cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white ${fieldLabel} select-none`}>
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

        <div className="space-y-4 pt-4 border-t border-border-subtle">
          <h3 className="font-serif font-bold text-lg text-navy-900">Profils, catégories et compétences</h3>
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
        <div className="space-y-4 pt-4 border-t border-border-subtle">
          <h3 className="font-serif font-bold text-lg text-navy-900">Parcours Architecture</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Field label="Scénario">
                            <select
                value={formData.scenarioId ?? ''}
                onChange={e => handleScenarioChange(e.target.value)}
                className={`${fieldInput} bg-surface`}
              >
                <option value="">Aucun scénario</option>
                {scenarios.map(s => (
                  <option key={s.id} value={s.id}>{s.title}</option>
                ))}
                <option value="__new__">+ Nouveau scénario…</option>
              </select>
            </Field>
            <Field label="Ordre de l'étape">
                            <input
                type="number"
                min={1}
                value={formData.stepOrder ?? ''}
                onChange={e => setFormData({ ...formData, stepOrder: e.target.value ? parseInt(e.target.value) : undefined })}
                className={fieldInput}
              />
            </Field>
          </div>

          {scenarioSteps.length > 0 && (
            <div className="space-y-1.5">
              <span className={fieldLabel}>Étapes déjà créées</span>
              <ul className="space-y-1">
                {scenarioSteps.map(step => (
                  <li key={step.challengeId} className="flex items-center gap-2 text-sm text-ink-secondary">
                    <span className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-navy-100 text-navy-900 text-xs font-semibold">
                      {step.stepOrder ?? '–'}
                    </span>
                    <span>{step.title}</span>
                    {challengeId === step.challengeId && (
                      <span className="text-xs text-ink-muted">(étape en cours d'édition)</span>
                    )}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {newScenarioOpen && (
            <div className="p-4 border border-border rounded-xl space-y-3 bg-canvas-subtle">
              <Field label="Titre du scénario">
                                <input
                  value={newScenarioTitle}
                  onChange={e => setNewScenarioTitle(e.target.value)}
                  placeholder="Ex. Design a High-Scale Chat Platform"
                  className="w-full rounded-lg border border-border p-2.5 text-sm focus:border-navy-900 outline-none bg-surface"
                />
              </Field>
              <Field label="Description">
                                <textarea
                  value={newScenarioDescription}
                  onChange={e => setNewScenarioDescription(e.target.value)}
                  rows={2}
                  className="w-full rounded-lg border border-border p-2.5 text-sm focus:border-navy-900 outline-none bg-surface"
                />
              </Field>
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

          <Field label="Information révélée après validation">
                        <textarea
              value={formData.revealedInformation}
              onChange={e => setFormData({ ...formData, revealedInformation: e.target.value })}
              rows={2}
              className={fieldInput}
            />
          </Field>
          <Field label="Trade-off pédagogique">
                        <textarea
              value={formData.tradeoff}
              onChange={e => setFormData({ ...formData, tradeoff: e.target.value })}
              rows={2}
              className={fieldInput}
            />
          </Field>
        </div>
        )}

        <div className="space-y-4 pt-4 border-t border-border-subtle">
          <div className="flex items-center justify-between">
            <h3 className="font-serif font-bold text-lg text-navy-900">Options de réponse</h3>
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
              <div key={idx} className="p-4 border border-border rounded-xl space-y-3">
                <div className="flex flex-wrap gap-x-4 gap-y-2 items-start">
                  <div className="flex-1 space-y-3">
                    <input
                      required
                      placeholder="Contenu de l'option..."
                      value={opt.content}
                      onChange={e => handleOptionChange(idx, 'content', e.target.value)}
                      className="w-full rounded-lg border border-border p-2.5 text-sm focus:border-navy-900 outline-none"
                    />
                    {formData.type === 'CODE_REVIEW' && (
                       <input
                        placeholder="Explication (spécifique à l'option)..."
                        value={opt.explanation}
                        onChange={e => handleOptionChange(idx, 'explanation', e.target.value)}
                        className="w-full rounded-lg border border-border p-2.5 text-sm focus:border-navy-900 outline-none"
                      />
                    )}
                  </div>
                  <label className="flex items-center gap-2 mt-2 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white">
                    <input
                      type="checkbox"
                      checked={opt.correct}
                      onChange={e => handleOptionChange(idx, 'correct', e.target.checked)}
                      className="w-4 h-4 text-crimson-700 rounded border-border"
                    />
                    <span className="text-sm font-medium">Correcte</span>
                  </label>
                  <button type="button" onClick={() => handleRemoveOption(idx)} className="mt-1 p-2 text-crimson-700 hover:bg-danger-soft rounded-lg transition">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

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
