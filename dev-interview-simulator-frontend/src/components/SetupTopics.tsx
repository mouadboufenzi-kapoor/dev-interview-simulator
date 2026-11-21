import { useState } from 'react';
import type { Category, Skill } from '../types';
import { Loader2, Search, X } from 'lucide-react';
import { Button } from './common/Button';

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
}: Props) => {
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState('');
  const topCategories = categories.slice(0, 6);
  const remainingCount = Math.max(0, categories.length - 6) + skills.length;
  const visibleCategories = categories.filter((category) =>
    category.name.toLowerCase().includes(search.trim().toLowerCase())
  );
  const visibleSkills = skills.filter((skill) =>
    skill.name.toLowerCase().includes(search.trim().toLowerCase())
  );

  const chipClass = (selected: boolean) =>
    `min-h-11 rounded-full border-2 px-2.5 py-1.5 text-[13px] transition cursor-pointer sm:px-3 sm:py-2 sm:text-xs ${
      selected
        ? 'border-navy-900 bg-navy-100 font-semibold text-navy-900'
        : 'border-border bg-surface text-ink-secondary'
    }`;

  return (
    <div className="w-full text-left">
      <h2 className="text-sm font-semibold text-text">
        Technologies <span className="font-normal text-muted">· optionnel</span>
      </h2>

      {loading ? (
        <div className="mt-3 flex min-h-11 items-center gap-2 text-xs text-muted">
          <Loader2 className="h-3.5 w-3.5 animate-spin" />
          Chargement des technologies…
        </div>
      ) : error ? (
        <p className="mt-3 text-xs text-crimson-700">{error}</p>
      ) : (
        <div className="mt-2 flex flex-wrap gap-2">
          {topCategories.map((category) => (
            <button
              key={category.id}
              type="button"
              onClick={() => onToggleCategory(category.id)}
              aria-pressed={selectedCategoryIds.includes(category.id)}
              className={chipClass(selectedCategoryIds.includes(category.id))}
            >
              {category.name}
            </button>
          ))}
          {selectedCategoryIds
            .filter((id) => !topCategories.some((category) => category.id === id))
            .map((id) => {
              const category = categories.find((item) => item.id === id);
              return category ? (
                <button
                  key={category.id}
                  type="button"
                  onClick={() => onToggleCategory(category.id)}
                  aria-pressed="true"
                  className={chipClass(true)}
                >
                  {category.name}
                </button>
              ) : null;
            })}
          {skills
            .filter((skill) => selectedSkillIds.includes(skill.id))
            .map((skill) => (
              <button
                key={skill.id}
                type="button"
                onClick={() => onToggleSkill(skill.id)}
                aria-pressed="true"
                className={chipClass(true)}
              >
                {skill.name}
              </button>
            ))}
          {remainingCount > 0 && (
            <button
              type="button"
              onClick={() => setOpen(true)}
              className="min-h-11 rounded-full border-2 border-border bg-card px-2.5 py-1.5 text-[13px] text-ink-secondary sm:px-3 sm:py-2 sm:text-xs"
            >
              + {remainingCount} autres
            </button>
          )}
        </div>
      )}

      {open && (
        <div className="fixed inset-0 z-50 flex items-end justify-center bg-ink/25 sm:items-center sm:p-4">
          <div className="max-h-[85vh] w-full overflow-y-auto rounded-t-2xl border-[0.5px] border-card-border bg-surface p-5 shadow-modal sm:max-w-xl sm:rounded-2xl">
            <div className="flex items-center justify-between gap-3">
              <h2 className="font-serif text-lg font-bold text-text">Toutes les technologies</h2>
              <button
                type="button"
                onClick={() => setOpen(false)}
                className="flex min-h-11 min-w-11 items-center justify-center rounded text-muted"
                aria-label="Fermer"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            <label className="mt-3 flex min-h-11 items-center gap-2 rounded border-2 border-border bg-card px-3">
              <Search className="h-4 w-4 text-muted" />
              <input
                value={search}
                onChange={(event) => setSearch(event.target.value)}
                placeholder="Rechercher une technologie"
                className="min-w-0 flex-1 bg-transparent text-sm text-text outline-none"
              />
            </label>

            {visibleCategories.length > 0 && (
              <div className="mt-4">
                <h3 className="text-xs font-semibold uppercase tracking-wider text-muted">Technologies</h3>
                <div className="mt-3 flex flex-wrap gap-2">
                  {visibleCategories.map((category) => (
                    <button
                      key={category.id}
                      type="button"
                      onClick={() => onToggleCategory(category.id)}
                      aria-pressed={selectedCategoryIds.includes(category.id)}
                      className={chipClass(selectedCategoryIds.includes(category.id))}
                    >
                      {category.name}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {visibleSkills.length > 0 && (
              <div className="mt-4">
                <h3 className="text-xs font-semibold uppercase tracking-wider text-muted">Compétences</h3>
                <div className="mt-3 flex flex-wrap gap-2">
                  {visibleSkills.map((skill) => (
                    <button
                      key={skill.id}
                      type="button"
                      onClick={() => onToggleSkill(skill.id)}
                      aria-pressed={selectedSkillIds.includes(skill.id)}
                      className={chipClass(selectedSkillIds.includes(skill.id))}
                    >
                      {skill.name}
                    </button>
                  ))}
                </div>
              </div>
            )}

            <Button
              type="button"
              variant="primary"
              size="lg"
              fullWidth
              onClick={() => setOpen(false)}
              className="mt-5"
            >
              Valider
            </Button>
          </div>
        </div>
      )}
    </div>
  );
};
