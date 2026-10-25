import { useState } from 'react';
import { Target, ChevronDown, ChevronUp, Code2, Wrench } from 'lucide-react';
import { Button } from './common/Button';
import { PageTitle } from './common/PageTitle';
import type { AnalyzedCompetency } from '../utils/resultAnalysis';
import type { SimulationResultDTO } from '../types';
import { buildTargetedRequest } from '../utils/resultAnalysis';

interface PriorityAxis extends AnalyzedCompetency {
  source: 'CATEGORY' | 'SKILL';
}

interface Props {
  technicalWeaknesses: PriorityAxis[];
  transversalWeaknesses: PriorityAxis[];
  summary: SimulationResultDTO;
  loading: boolean;
  onStart: (request: ReturnType<typeof buildTargetedRequest>) => void;
  /** Faux en Architecture : les filtres sont ignorés par le backend. */
  showCta: boolean;
}

const MAX_VISIBLE = 5;

export const ResultPriority = ({
  technicalWeaknesses,
  transversalWeaknesses,
  summary,
  loading,
  onStart,
  showCta,
}: Props) => {
  const [expanded, setExpanded] = useState(false);
  const priority = technicalWeaknesses[0] ?? transversalWeaknesses[0];
  if (!priority) return null;

  const visibleTechnical = expanded
    ? technicalWeaknesses
    : technicalWeaknesses.slice(0, MAX_VISIBLE);
  // Keep transversal axes out of the compact overview when technical axes exist.
  // If there are no technical weaknesses, show transversal ones immediately.
  const visibleTransversal = expanded
    ? transversalWeaknesses
    : technicalWeaknesses.length === 0
      ? transversalWeaknesses.slice(0, MAX_VISIBLE)
      : [];
  const hiddenCount =
    technicalWeaknesses.length - visibleTechnical.length
    + transversalWeaknesses.length - visibleTransversal.length;

  const renderFamily = (
    label: string,
    source: 'CATEGORY' | 'SKILL',
    items: PriorityAxis[],
    Icon: typeof Code2,
    tone: 'technical' | 'transversal'
  ) => {
    if (items.length === 0) return null;
    return (
      <section
        aria-label={`Axes ${label.toLowerCase()}`}
        className="border-t border-border-subtle pt-3"
      >
        <div className="mb-2 flex items-center justify-between gap-3">
          <span className={`inline-flex items-center gap-1.5 rounded-sm border-2 px-2 py-1 text-[10px] font-semibold uppercase tracking-wide shadow-[2px_2px_0_var(--color-shadow)] ${tone === 'technical' ? 'border-navy-200 bg-navy-100 text-navy-900' : 'border-crimson-200 bg-crimson-100 text-crimson-700'}`}>
            <Icon className="h-3 w-3" aria-hidden="true" /> {label}
          </span>
          <span className="text-[11px] text-ink-muted">
            {items.length} axe{items.length > 1 ? 's' : ''}
          </span>
        </div>
        <ul className="space-y-2">
          {items.map((item, index) => (
            <li key={`${source}-${item.id}`} className="flex items-center justify-between gap-3">
              <span className="min-w-0 truncate text-sm font-semibold text-ink">{item.name}</span>
              <span className={`flex-shrink-0 font-mono text-xs font-semibold ${index === 0 ? 'text-crimson-700' : 'text-ink-secondary'}`}>
                {item.pct} %
              </span>
            </li>
          ))}
        </ul>
      </section>
    );
  };

  return (
    <section className="bg-surface border-[0.5px] border-card-border rounded-2xl p-5 shadow-elevated space-y-4 sm:p-6">
      <div className="flex items-center gap-2.5">
        <div className="p-2 rounded-lg bg-navy-100 border border-navy-200 text-navy-900 flex-shrink-0">
          <Target className="w-4 h-4" />
        </div>
        <PageTitle as="h2" size="sm">À travailler en priorité</PageTitle>
      </div>

      {renderFamily('Technique', 'CATEGORY', visibleTechnical, Code2, 'technical')}
      {renderFamily('Transversal', 'SKILL', visibleTransversal, Wrench, 'transversal')}

      {hiddenCount > 0 && (
        <button
          type="button"
          onClick={() => setExpanded((current) => !current)}
          className="inline-flex items-center gap-1 text-xs font-semibold text-navy-900 transition hover:text-navy-950 focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas rounded"
        >
          {expanded
            ? <><ChevronUp className="h-3.5 w-3.5" /> Réduire</>
            : <><ChevronDown className="h-3.5 w-3.5" /> Voir les {hiddenCount} autres axes</>}
        </button>
      )}

      {showCta && (
        <Button
          type="button"
          variant="primary"
          size="lg"
          loading={loading}
          rightIcon={<Target className="h-4 w-4" />}
          onClick={() => onStart(buildTargetedRequest(
            summary,
            priority,
            summary.questions.map((question) => question.challengeId),
            priority.source
          ))}
          className="w-full sm:w-auto"
        >
          Travailler {priority.name}
        </Button>
      )}
    </section>
  );
};
