import { useState } from 'react';
import { Target, ChevronDown, ChevronUp } from 'lucide-react';
import { Button } from './common/Button';
import { PageTitle } from './common/PageTitle';
import type { AnalyzedCompetency } from '../utils/resultAnalysis';
import type { SimulationResultDTO } from '../types';
import { buildTargetedRequest } from '../utils/resultAnalysis';

interface Props {
  /** Axes faibles des deux familles, triés du plus fragile au moins fragile. */
  weaknesses: Array<AnalyzedCompetency & { source: 'CATEGORY' | 'SKILL' }>;
  summary: SimulationResultDTO;
  loading: boolean;
  /** Démarre la simulation ciblée sur la compétence prioritaire. */
  onStart: (request: ReturnType<typeof buildTargetedRequest>) => void;
  /** Faux en Architecture : diagnostic affiché, CTA masqué (filtres backend ignorés). */
  showCta: boolean;
}

/** Lignes visibles avant le dépliage « Voir les autres ». */
const MAX_VISIBLE = 3;

export const ResultPriority = ({ weaknesses, summary, loading, onStart, showCta }: Props) => {
  const [expanded, setExpanded] = useState(false);

  const priority = weaknesses[0];
  const hiddenCount = weaknesses.length - MAX_VISIBLE;
  const visible = expanded ? weaknesses : weaknesses.slice(0, MAX_VISIBLE);

  if (!priority) return null;

  // Égalité en tête (ex. deux axes à 0 %) : le badge « Priorité principale »
  // serait arbitraire → badge « Priorité » partagé + phrase d'égalité.
  const tiedPriorityCount = weaknesses.filter((c) => c.pct === priority.pct).length;
  const isTied = tiedPriorityCount > 1;
  const tiedNames = weaknesses
    .filter((c) => c.pct === priority.pct)
    .map((c) => c.name);
  // 2 axes liés : on nomme les deux. 3+ : on compte (sinon la phrase devient un pavé).
  const joinedNames =
    tiedNames.length === 2
      ? `${tiedNames[0]} et ${tiedNames[1]}`
      : `${tiedNames.length} compétences`;

  return (
    <section className="bg-surface border-[0.5px] border-card-border rounded-2xl p-6 shadow-elevated space-y-4 h-full">
      <div className="flex items-center gap-2.5">
        <div className="p-2 rounded-lg bg-navy-100 border border-navy-200 text-navy-900 flex-shrink-0">
          <Target className="w-4 h-4" />
        </div>
        <PageTitle as="h2" size="sm">
          Votre priorité
        </PageTitle>
      </div>

      {/* Liste compacte : nom + % ; la priorité principale est marquée par une
          pastille, pas par un paragraphe dédié. */}
      <ul className="space-y-2.5">
        {visible.map((c, index) => (
          <li key={`${c.source}-${c.id}`} className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-2 min-w-0">
              <span className="font-semibold text-sm text-ink truncate">{c.name}</span>
              {index === 0 && !isTied && (
                <span className="flex-shrink-0 text-[10px] uppercase tracking-wider font-semibold px-1.5 py-0.5 rounded bg-navy-100 border border-navy-200 text-navy-900">
                  Priorité principale
                </span>
              )}
              {isTied && c.pct === priority.pct && (
                <span className="flex-shrink-0 text-[10px] uppercase tracking-wider font-semibold px-1.5 py-0.5 rounded bg-navy-100 border border-navy-200 text-navy-900">
                  Priorité
                </span>
              )}
            </div>
            <span
              className={`font-mono text-xs font-semibold flex-shrink-0 ${
                index === 0 ? 'text-crimson-700' : 'text-ink-secondary'
              }`}
            >
              {c.pct} %
            </span>
          </li>
        ))}
      </ul>

      {hiddenCount > 0 && (
        <button
          type="button"
          onClick={() => setExpanded((v) => !v)}
          className="inline-flex items-center gap-1 text-xs font-semibold text-navy-900 hover:text-navy-950 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas rounded"
        >
          {expanded ? (
            <>
              <ChevronUp className="w-3.5 h-3.5" /> Réduire
            </>
          ) : (
            <>
              <ChevronDown className="w-3.5 h-3.5" /> Voir les autres ({hiddenCount})
            </>
          )}
        </button>
      )}

      {showCta && (
        <div className="space-y-3 border-t border-border pt-4">
          <p className="text-xs text-ink-secondary leading-relaxed">
            {isTied ? (
              <>
                <span className="font-semibold text-ink">{joinedNames}</span> sont au même niveau
                ({priority.pct} %) sur cette simulation — commencez par l'un de ces axes.
              </>
            ) : (
              <>
                Commencez par{' '}
                <span className="font-semibold text-ink">{priority.name}</span> — l'axe le plus
                fragile de cette simulation.
              </>
            )}
          </p>

          <Button
            type="button"
            variant="primary"
            size="lg"
            loading={loading}
            rightIcon={<Target className="w-4 h-4" />}
            onClick={() => onStart(buildTargetedRequest(summary, priority, summary.questions.map((q) => q.challengeId), priority.source))}
            className="w-full sm:w-auto px-8"
          >
            S'entraîner sur {priority.name}
          </Button>
        </div>
      )}
    </section>
  );
};
