import { useState, useEffect } from 'react';
import { scenarioApi } from '../api/adminApi';
import type { AdminScenario, AdminScenarioStep } from '../api/adminApi';
import { Button } from './common/Button';
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
    <div className="bg-white rounded-2xl border border-[#E8E2D8] shadow-[0_2px_10px_rgba(18,60,105,0.05)] overflow-hidden">
      <div className="p-4 border-b border-[#F2EDE6] flex justify-end">
        <Button
          onClick={() => setCreating(prev => !prev)}
          variant="secondary"
          leftIcon={<Plus className="w-4 h-4" />}
        >
          Nouveau scénario
        </Button>
      </div>

      {creating && (
        <div className="p-4 border-b border-[#F2EDE6] space-y-3 bg-[#FAF9F7]">
          <label className="block space-y-1.5">
            <span className="text-sm font-semibold text-[#102136]">Titre du scénario</span>
            <input
              value={title}
              onChange={e => setTitle(e.target.value)}
              placeholder="Ex. Design a High-Scale Chat Platform"
              className="w-full rounded-xl border border-[#E8E2D8] p-2.5 text-sm focus:border-[#123C69] outline-none bg-white"
            />
          </label>
          <label className="block space-y-1.5">
            <span className="text-sm font-semibold text-[#102136]">Description</span>
            <textarea
              value={description}
              onChange={e => setDescription(e.target.value)}
              rows={2}
              className="w-full rounded-xl border border-[#E8E2D8] p-2.5 text-sm focus:border-[#123C69] outline-none bg-white"
            />
          </label>
          {error && (
            <p className="text-sm text-[#9C2727]">{error}</p>
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
        <div className="px-6 py-8 text-center text-sm text-[#797E88]">Chargement...</div>
      ) : scenarios.length === 0 ? (
        <div className="px-6 py-8 text-center text-sm text-[#797E88]">Aucun scénario Architecture pour le moment.</div>
      ) : (
        <div className="divide-y divide-[#F2EDE6]">
          {scenarios.map(scenario => (
            <div key={scenario.id}>
              <div className="px-6 py-4 flex items-center justify-between gap-4">
                <div>
                  <div className="font-semibold text-[#102136]">{scenario.title}</div>
                  <div className="text-xs text-[#484F59] mt-1">
                    {scenario.stepCount} étape{scenario.stepCount > 1 ? 's' : ''}
                    {scenario.description ? ` · ${scenario.description}` : ''}
                  </div>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => toggleSteps(scenario.id)}
                    title="Voir les étapes"
                    className="p-2 text-[#123C69] hover:bg-[#E6EFF8] rounded-lg transition"
                  >
                    <ListOrdered className="w-4 h-4" />
                  </button>
                  <Button size="sm" variant="secondary" onClick={() => onAddStep(scenario.id)}>
                    Ajouter une étape
                  </Button>
                </div>
              </div>
              {expandedId === scenario.id && (
                <div className="px-6 pb-4">
                  {(stepsByScenario[scenario.id] ?? []).length === 0 ? (
                    <p className="text-sm text-[#797E88]">Aucune étape créée pour ce scénario.</p>
                  ) : (
                    <ul className="space-y-1">
                      {(stepsByScenario[scenario.id] ?? []).map(step => (
                        <li key={step.challengeId} className="flex items-center gap-2 text-sm text-[#484F59]">
                          <span className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-[#E6EFF8] text-[#123C69] text-xs font-semibold">
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
