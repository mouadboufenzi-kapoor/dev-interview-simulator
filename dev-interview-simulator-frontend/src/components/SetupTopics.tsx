import { useState } from 'react';
import type { Category, Skill } from '../types';
import { Loader2 } from 'lucide-react';

const INITIAL_TECHNOLOGY_COUNT = 5;

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
  onExpand?: () => void;
}

export const SetupTopics = ({
  categories,
  skills,
  selectedCategoryIds,
  selectedSkillIds,
  onToggleCategory,
  onToggleSkill,
  loading,
  error,
  onExpand,
}: Props) => {
  const [expanded, setExpanded] = useState(false);
  const topCategories = categories.slice(0, INITIAL_TECHNOLOGY_COUNT);
  const extraSelectedCategories = categories.filter(
    (category) =>
      selectedCategoryIds.includes(category.id) &&
      !topCategories.some((top) => top.id === category.id)
  );
  const selectedSkills = skills.filter((skill) => selectedSkillIds.includes(skill.id));
  const visibleCategories = expanded
    ? categories
    : [...topCategories, ...extraSelectedCategories];
  const visibleSkills = expanded ? skills : selectedSkills;
  const remainingCount = Math.max(
    0,
    categories.length +
      skills.length -
      topCategories.length -
      extraSelectedCategories.length -
      selectedSkills.length
  );

  const chipClass = (selected: boolean) =>
    `min-h-0 rounded-full border px-2 py-1 text-xs leading-4 transition cursor-pointer sm:min-h-11 sm:border-2 sm:px-3 sm:py-2 lg:min-h-8 lg:border lg:px-2.5 lg:py-1 lg:text-[11px] ${
      selected
        ? 'border-navy-900 bg-navy-100 font-semibold text-navy-900'
        : 'border-border bg-surface text-ink-secondary'
    }`;

  return (
    <div className="w-full text-left">
      <h2 className="text-[11px] font-semibold text-text sm:text-sm">
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
        <div className="mt-1.5 sm:mt-2">
          <div id="setup-technologies" className="flex flex-wrap gap-1.5 sm:gap-2">
          {visibleCategories.map((category) => (
            <button
              key={`category-${category.id}`}
              type="button"
              onClick={() => onToggleCategory(category.id)}
              aria-pressed={selectedCategoryIds.includes(category.id)}
              className={chipClass(selectedCategoryIds.includes(category.id))}
            >
              {category.name}
            </button>
          ))}
          {visibleSkills.map((skill) => (
            <button
              key={`skill-${skill.id}`}
              type="button"
              onClick={() => onToggleSkill(skill.id)}
              aria-pressed={selectedSkillIds.includes(skill.id)}
              className={chipClass(selectedSkillIds.includes(skill.id))}
            >
              {skill.name}
            </button>
          ))}
          </div>
          {(remainingCount > 0 || expanded) && (
            <button
              type="button"
              onClick={() => {
                const next = !expanded;
                setExpanded(next);
                if (next) onExpand?.();
              }}
              aria-expanded={expanded}
              aria-controls="setup-technologies"
              className="mt-1.5 min-h-0 rounded-full border border-brand bg-brand px-2 py-1 text-xs leading-4 text-cta-text sm:mt-2 sm:min-h-11 sm:border-2 sm:px-3 sm:py-2 lg:mt-2 lg:min-h-8 lg:border lg:px-2.5 lg:py-1 lg:text-[11px]"
            >
              {expanded ? 'Voir moins' : `+ ${remainingCount} autres`}
            </button>
          )}
        </div>
      )}

    </div>
  );
};
