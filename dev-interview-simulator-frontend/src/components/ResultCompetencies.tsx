import { useState, type ReactNode } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';
import type { AnalyzedCompetency } from '../utils/resultAnalysis';
import { PageTitle } from './common/PageTitle';

interface Props {
  title: string;
  subtitle?: string;
  icon: ReactNode;
  /** Classes de la puce d'en-tête (fond + bordure + couleur de l'icône). */
  iconChipClassName: string;
  tone: 'success' | 'crimson' | 'navy';
  items: AnalyzedCompetency[];
}

const TONE_STYLES = {
  success: { value: 'text-success', bar: 'bg-success' },
  crimson: { value: 'text-crimson-700', bar: 'bg-crimson-700' },
  navy: { value: 'text-navy-900', bar: 'bg-navy-900' },
} as const;

export const ResultCompetencies = ({
  title,
  subtitle,
  icon,
  iconChipClassName,
  tone,
  items,
}: Props) => {
  const [expanded, setExpanded] = useState(false);
  const styles = TONE_STYLES[tone];
  const visibleItems = expanded ? items : items.slice(0, 4);

  return (
    <section className="bg-surface border-[0.5px] border-card-border rounded-2xl p-6 shadow-card space-y-4">
      <div className="flex items-center gap-2.5">
        <div className={`p-2 rounded-lg border flex-shrink-0 ${iconChipClassName}`}>{icon}</div>
        <div>
          <PageTitle as="h2" size="sm">
            {title}
          </PageTitle>
          {subtitle && <p className="mt-1 text-xs text-ink-muted">{subtitle}</p>}
        </div>
      </div>

      <ul className="space-y-3.5">
        {visibleItems.map((c) => (
          <li key={c.id} className="space-y-1.5">
            <div className="flex items-center justify-between gap-3 text-sm">
              <span className="font-semibold text-ink truncate">{c.name}</span>
              <span
                className={`font-mono text-xs font-semibold flex-shrink-0 ${styles.value}`}
              >
                {c.pct} %
              </span>
            </div>
            <div className="h-1.5 rounded-full bg-canvas-subtle overflow-hidden">
              <div
                className={`h-full rounded-full ${styles.bar}`}
                style={{ width: `${c.pct}%` }}
              />
            </div>
            <p className="text-[11px] text-ink-muted">
              {c.correct} bonne(s) réponse(s) sur {c.total}
            </p>
          </li>
        ))}
      </ul>

      {items.length > 4 && (
        <button
          type="button"
          onClick={() => setExpanded((current) => !current)}
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-navy-900 transition hover:text-crimson-700 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas rounded-md"
        >
          {expanded ? (
            <>Réduire <ChevronUp className="h-3.5 w-3.5" /></>
          ) : (
            <>Voir tout ({items.length}) <ChevronDown className="h-3.5 w-3.5" /></>
          )}
        </button>
      )}
    </section>
  );
};
