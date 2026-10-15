import type { Dispatch, SetStateAction } from 'react';
import type { AdminChallengeRequest, AdminChallengeOptionRequest } from '../api/adminApi';
import { Button } from './common/Button';
import { Plus, Trash2 } from 'lucide-react';

interface Props {
  formData: AdminChallengeRequest;
  setFormData: Dispatch<SetStateAction<AdminChallengeRequest>>;
}

export const AdminOptionsEditor = ({ formData, setFormData }: Props) => {
  const handleAddOption = () => {
    setFormData(prev => ({
      ...prev,
      options: [
        ...prev.options,
        {
          content: '',
          // Séquentiel : chaque option est une étape de la réponse → toujours correcte.
          correct: formData.type === 'SEQUENTIAL_REASONING',
          displayOrder: prev.options.length + 1
        }
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

  const isSequential = formData.type === 'SEQUENTIAL_REASONING';

  return (
    <div className="space-y-4 pt-4 border-t border-border-subtle">
      <div className="flex items-center justify-between">
        <h3 className="font-serif font-bold text-lg text-navy-900">
          {isSequential ? 'Étapes à ordonner' : 'Options de réponse'}
        </h3>
        <Button
          type="button"
          onClick={handleAddOption}
          variant="secondary"
          size="sm"
          leftIcon={<Plus className="w-4 h-4" />}
        >
          {isSequential ? 'Ajouter une étape' : 'Ajouter une option'}
        </Button>
      </div>
      {isSequential && (
        <p className="text-xs text-ink-muted">
          L'ordre ci-dessous est l'ordre attendu (étape 1 en premier) : l'utilisateur devra remettre les étapes dans cet ordre.
        </p>
      )}

      <div className="space-y-3">
        {formData.options.map((opt, idx) => (
          <div key={idx} className="p-4 border border-border rounded-xl space-y-3">
            <div className="flex flex-wrap gap-x-4 gap-y-2 items-start">
              <div className="flex-1 space-y-3">
                <input
                  required
                  placeholder={isSequential ? "Libellé de l'étape..." : "Contenu de l'option..."}
                  value={opt.content}
                  onChange={e => handleOptionChange(idx, 'content', e.target.value)}
                  className="w-full rounded-lg border border-border p-2.5 text-sm focus:border-navy-900 outline-none"
                />
                {(formData.type === 'CODE_REVIEW' || isSequential) && (
                  <input
                    placeholder={isSequential ? "Raison de l'étape à ce rang (optionnel)..." : "Explication (spécifique à l'option)..."}
                    value={opt.explanation}
                    onChange={e => handleOptionChange(idx, 'explanation', e.target.value)}
                    className="w-full rounded-lg border border-border p-2.5 text-sm focus:border-navy-900 outline-none"
                  />
                )}
              </div>
              {isSequential ? (
                <span className="mt-2 flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-lg bg-navy-100 font-mono text-xs font-bold text-navy-900">
                  {idx + 1}
                </span>
              ) : (
                <label className="flex items-center gap-2 mt-2 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas">
                  <input
                    type="checkbox"
                    checked={opt.correct}
                    onChange={e => handleOptionChange(idx, 'correct', e.target.checked)}
                    className="w-4 h-4 text-crimson-700 rounded border-border"
                  />
                  <span className="text-sm font-medium">Correcte</span>
                </label>
              )}
              <button type="button" onClick={() => handleRemoveOption(idx)} className="mt-1 p-2 text-crimson-700 hover:bg-danger-soft rounded-lg transition">
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
