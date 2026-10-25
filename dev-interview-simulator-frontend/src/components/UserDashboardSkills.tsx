import { useState } from 'react';
import { Cpu, ChevronDown, ChevronUp, Wrench } from 'lucide-react';
import { panelCard } from '../styles/ui';
import type { UserStats } from '../api/userStatsApi';

interface Props {
  byCategory: UserStats['byCategory'];
  bySkill: NonNullable<UserStats['bySkill']>;
}

const VISIBLE_COUNT = 3;

// Les domaines techniques et les savoir-faire transversaux restent distincts ;
// chaque liste est courte sur mobile et se déplie séparément si nécessaire.
export const UserDashboardSkills = ({ byCategory, bySkill }: Props) => {
  const [expandedCategories, setExpandedCategories] = useState(false);
  const [expandedSkills, setExpandedSkills] = useState(false);

  const sortedCategories = [...byCategory].sort((a, b) => {
    const byRate = b.successRate - a.successRate;
    return byRate !== 0 ? byRate : b.answered - a.answered;
  });
  const sortedSkills = [...(bySkill ?? [])].sort((a, b) => {
    const byRate = b.successRate - a.successRate;
    return byRate !== 0 ? byRate : b.answered - a.answered;
  });
  const renderEntries = (
    entries: UserStats['byCategory'],
    expanded: boolean,
    setExpanded: (value: boolean) => void,
    label: string,
    Icon: typeof Cpu
  ) => {
    const visible = expanded ? entries : entries.slice(0, VISIBLE_COUNT);
    return (
      <div className="space-y-3">
        <div className="flex items-center gap-2 text-xs font-semibold text-ink-secondary">
          <Icon className="h-3.5 w-3.5 text-navy-900" /> {label}
        </div>
        {visible.map((entry) => (
          <div key={entry.id}>
            <div className="flex items-center justify-between gap-3 text-sm">
              <span className="min-w-0 truncate font-medium text-ink">{entry.name}</span>
              <span className="flex-shrink-0 text-xs font-mono text-ink-muted">{Math.round(entry.successRate)}%</span>
            </div>
            <div className="mt-1.5 h-1.5 w-full overflow-hidden rounded-full bg-navy-100">
              <div
                className={`h-full rounded-full transition-all ${entry.successRate < 50 ? 'bg-crimson-700' : 'bg-navy-900'}`}
                style={{ width: `${Math.max(3, entry.successRate)}%` }}
              />
            </div>
          </div>
        ))}
        {entries.length > VISIBLE_COUNT && (
          <button
            type="button"
            onClick={() => setExpanded(!expanded)}
            className="inline-flex items-center gap-1 text-xs font-semibold text-navy-900 transition hover:text-crimson-700 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas rounded-md"
          >
            {expanded ? <>Réduire <ChevronUp className="h-3.5 w-3.5" /></> : <>Voir tout ({entries.length}) <ChevronDown className="h-3.5 w-3.5" /></>}
          </button>
        )}
      </div>
    );
  };

  return (
    <section className={`${panelCard} p-5 sm:p-6`}>
      <div className="flex items-center justify-between gap-4">
        <div>
          <h2 className="font-serif text-lg font-bold text-ink sm:text-xl">Vos acquis</h2>
          <p className="mt-1 text-xs text-ink-muted">Résultats par domaine et savoir-faire</p>
        </div>
        <Cpu className="h-5 w-5 text-navy-900" />
      </div>

      <div className="mt-5 space-y-5">
        {renderEntries(sortedCategories, expandedCategories, setExpandedCategories, 'Domaines techniques', Cpu)}
        {sortedSkills.length > 0 && renderEntries(sortedSkills, expandedSkills, setExpandedSkills, 'Savoir-faire transversaux', Wrench)}
      </div>
    </section>
  );
};
