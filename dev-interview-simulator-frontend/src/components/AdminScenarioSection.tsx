import { useState, useEffect } from 'react';
import type { Dispatch, SetStateAction } from 'react';
import type { AdminChallengeRequest, AdminScenario, AdminScenarioStep } from '../api/adminApi';
import { scenarioApi } from '../api/adminApi';
import { Button } from './common/Button';
import { Field } from './common/Field';
import { fieldInput, fieldLabel } from '../styles/ui';

interface Props {
  formData: AdminChallengeRequest;
  setFormData: Dispatch<SetStateAction<AdminChallengeRequest>>;
  scenarios: AdminScenario[];
  challengeId?: number;
  onError: (message: string) => void;
  onScenarioCreated: (scenario: AdminScenario) => void;
}

export const AdminScenarioSection = ({
  formData,
  setFormData,
  scenarios,
  challengeId,
  onError,
  onScenarioCreated,
}: Props) => {
  const [scenarioSteps, setScenarioSteps] = useState<AdminScenarioStep[]>([]);
  const [newScenarioOpen, setNewScenarioOpen] = useState(false);
  const [newScenarioTitle, setNewScenarioTitle] = useState('');
  const [newScenarioDescription, setNewScenarioDescription] = useState('');
  const [creatingScenario, setCreatingScenario] = useState(false);

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
  }, [formData.scenarioId, challengeId, setFormData]);

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
    onError('');
    try {
      const created = await scenarioApi.createScenario({
        title: newScenarioTitle.trim(),
        description: newScenarioDescription.trim() || undefined
      });
      onScenarioCreated(created);
      setNewScenarioOpen(false);
      setNewScenarioTitle('');
      setNewScenarioDescription('');
    } catch (err: any) {
      onError(err.response?.data?.message || 'Erreur lors de la création du scénario.');
    } finally {
      setCreatingScenario(false);
    }
  };

  return (
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
  );
};
