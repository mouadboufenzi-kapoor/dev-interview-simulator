import type { Category, Skill } from '../types';
import { Loader2 } from 'lucide-react';

interface Props {
  categories: Category[];
  skills: Skill[];
  selectedCategoryIds: number[];
  selectedSkillIds: number[];
  onToggleCategory: (id: number) => void;
  onToggleSkill: (id: number) => void;
  onClear: () => void;
  loading: boolean;
  error: string | null;
}

export const SetupTopics = ({
  categories,
  skills,
  selectedCategoryIds,
  selectedSkillIds,
  onToggleCategory,
  onToggleSkill,
  onClear,
  loading,
  error,
}: Props) => (
  <div className="w-full max-w-2xl rounded-2xl border-[0.5px] border-card-border bg-surface-elevated px-4 py-4 text-left sm:px-5">
    <div className="flex flex-col gap-1 sm:flex-row sm:items-center sm:justify-between">
      <div>
        <h2 className="text-sm font-semibold text-ink">
          Technologies / sujets <span className="font-normal text-ink-muted">— optionnel</span>
        </h2>
        <p className="mt-1 text-xs text-ink-muted">
          Affinez les questions proposées, ou continuez sans filtre.
        </p>
      </div>
      {(selectedCategoryIds.length > 0 || selectedSkillIds.length > 0) && (
        <button
          type="button"
          onClick={onClear}
          className="self-start text-xs font-medium text-crimson-700 transition hover:text-crimson-800 sm:self-auto"
        >
          Tout désélectionner
        </button>
      )}
    </div>

    {loading ? (
      <div className="mt-4 flex items-center gap-2 text-xs text-ink-muted">
        <Loader2 className="h-3.5 w-3.5 animate-spin" />
        Chargement des technologies…
      </div>
    ) : error ? (
      <p className="mt-4 text-xs text-crimson-700">{error}</p>
    ) : (
      <div className="mt-4 flex flex-wrap gap-2">
        {categories.map((category) => {
          const isSelected = selectedCategoryIds.includes(category.id);
          return (
            <button
              key={`category-${category.id}`}
              type="button"
              onClick={() => onToggleCategory(category.id)}
              aria-pressed={isSelected}
              className={`rounded-lg border px-3 py-1.5 text-xs transition ${
                isSelected
                  ? 'border-navy-900 bg-navy-100 font-semibold text-navy-900'
                  : 'border-border bg-surface text-ink-secondary hover:border-border-strong hover:text-navy-900'
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
              onClick={() => onToggleSkill(skill.id)}
              aria-pressed={isSelected}
              className={`rounded-lg border px-3 py-1.5 text-xs transition ${
                isSelected
                  ? 'border-navy-900 bg-navy-100 font-semibold text-navy-900'
                  : 'border-border bg-surface text-ink-secondary hover:border-border-strong hover:text-navy-900'
              }`}
            >
              {skill.name}
            </button>
          );
        })}
        {categories.length === 0 && skills.length === 0 && (
          <p className="text-xs text-ink-muted">
            Aucun sujet disponible pour cette configuration.
          </p>
        )}
      </div>
    )}
  </div>
);
