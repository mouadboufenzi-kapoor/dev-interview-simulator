import { useState, useEffect } from 'react';
import { scenarioApi } from '../api/adminApi';
import type { AdminScenario, AdminScenarioStep } from '../api/adminApi';
import { Button } from './common/Button';
import { fieldInputSmall, fieldLabel, panel, panelToolbar, panelForm, emptyState } from '../styles/ui';
import { IconButton } from './common/IconButton';
import { Plus, ListOrdered } from 'lucide-react';

interface Props {
  onAddStep: (scenarioId: number) => void;
}

export const AdminScenarioPanel = ({ onAddStep }: Props) => {
  const [scenarios, setScenarios] = useState<AdminScenario[]>([]);
  const [loading, setLoading] = useState(true);
  const [expandedId, setExpandedId] = useState<number | null>(null);
  const [stepsByScenario, setStepsByScenario] = useState<Record<number, AdminScenarioStep[]>>({});
  const [creating, setCreating] = useState(false);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadScenarios = async () => {
    setLoading(true);
    try {
      setScenarios(await scenarioApi.getScenarios());
    } catch {
      setScenarios([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadScenarios();
  }, []);

  const toggleSteps = async (id: number) => {
    if (expandedId === id) {
      setExpandedId(null);
      return;
    }
    setExpandedId(id);
    if (!stepsByScenario[id]) {
      try {
        const steps = await scenarioApi.getScenarioSteps(id);
        setStepsByScenario(prev => ({ ...prev, [id]: steps }));
      } catch {
        setStepsByScenario(prev => ({ ...prev, [id]: [] }));
      }
    }
  };

  const handleCreate = async () => {
    if (!title.trim()) return;
    setSaving(true);
    setError(null);
    try {
      await scenarioApi.createScenario({
        title: title.trim(),
        description: description.trim() || undefined
      });
      setTitle('');
      setDescription('');
      setCreating(false);
      loadScenarios();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Erreur lors de la création du scénario.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className={panel}>
      <div className={panelToolbar}>
        <Button
          onClick={() => setCreating(prev => !prev)}
          variant="secondary"
          leftIcon={<Plus className="w-4 h-4" />}
        >
          Nouveau scénario
        </Button>
      </div>

      {creating && (
        <div className={panelForm}>
          <label className="block space-y-1.5">
            <span className={fieldLabel}>Titre du scénario</span>
            <input
              value={title}
              onChange={e => setTitle(e.target.value)}
              placeholder="Ex. Design a High-Scale Chat Platform"
              className={fieldInputSmall}
            />
          </label>
          <label className="block space-y-1.5">
            <span className={fieldLabel}>Description</span>
            <textarea
              value={description}
              onChange={e => setDescription(e.target.value)}
              rows={2}
              className={fieldInputSmall}
            />
          </label>
          {error && (
            <p className="text-sm text-danger">{error}</p>
          )}
          <div className="flex justify-end gap-3">
            <Button variant="secondary" size="sm" onClick={() => setCreating(false)} disabled={saving}>
              Annuler
            </Button>
            <Button variant="primary" size="sm" onClick={handleCreate} disabled={saving || !title.trim()}>
              {saving ? 'Création...' : 'Créer'}
            </Button>
          </div>
        </div>
      )}

      {loading ? (
        <div className={emptyState}>Chargement...</div>
      ) : scenarios.length === 0 ? (
        <div className={emptyState}>Aucun scénario Architecture pour le moment.</div>
      ) : (
        <div className="divide-y divide-border-subtle">
          {scenarios.map(scenario => (
            <div key={scenario.id}>
              <div className="px-6 py-4 flex items-center justify-between gap-4">
                <div>
                  <div className="font-semibold text-ink">{scenario.title}</div>
                  <div className="text-xs text-ink-secondary mt-1">
                    {scenario.stepCount} étape{scenario.stepCount > 1 ? 's' : ''}
                    {scenario.description ? ` · ${scenario.description}` : ''}
                  </div>
                </div>
                <div className="flex gap-2">
                  <IconButton
                    onClick={() => toggleSteps(scenario.id)}
                    title="Voir les étapes"
                  >
                    <ListOrdered className="w-4 h-4" />
                  </IconButton>
                  <Button size="sm" variant="secondary" onClick={() => onAddStep(scenario.id)}>
                    Ajouter une étape
                  </Button>
                </div>
              </div>
              {expandedId === scenario.id && (
                <div className="px-6 pb-4">
                  {(stepsByScenario[scenario.id] ?? []).length === 0 ? (
                    <p className="text-sm text-ink-muted">Aucune étape créée pour ce scénario.</p>
                  ) : (
                    <ul className="space-y-1">
                      {(stepsByScenario[scenario.id] ?? []).map(step => (
                        <li key={step.challengeId} className="flex items-center gap-2 text-sm text-ink-secondary">
                          <span className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-navy-100 text-navy-900 text-xs font-semibold">
                            {step.stepOrder ?? '–'}
                          </span>
                          <span>{step.title}</span>
                        </li>
                      ))}
                    </ul>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
