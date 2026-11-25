import { useState } from 'react';
import { Target, ChevronDown, ChevronUp } from 'lucide-react';
import { Button } from './common/Button';
import { PageTitle } from './common/PageTitle';
import type { AnalyzedCompetency } from '../utils/resultAnalysis';
import type { SimulationResultDTO } from '../types';
import { buildTargetedRequest } from '../utils/resultAnalysis';

interface Props {
  technicalWeaknesses: AnalyzedCompetency[];
  tagsByCategory: Record<string, string[]>;
  summary: SimulationResultDTO;
  loading: boolean;
  onStart: (request: ReturnType<typeof buildTargetedRequest>) => void;
  /** Faux en Architecture : les filtres sont ignorés par le backend. */
  showCta: boolean;
  /** Relance le mode en cours sans ciblage (Architecture). */
  genericCta?: boolean;
}

const MAX_VISIBLE = 3;
const MAX_TAGS = 3;
const TAG_CLASS_NAME =
  'inline-flex rounded-full border border-border-subtle bg-surface px-1.5 py-0.5 text-[10px] font-medium text-ink-secondary';

export const ResultPriority = ({
  technicalWeaknesses,
  tagsByCategory,
  summary,
  loading,
  onStart,
  showCta,
  genericCta = false,
}: Props) => {
  const [expanded, setExpanded] = useState(false);
  const priority = technicalWeaknesses[0];
  if (!priority) return null;

  const visibleWeaknesses = expanded
    ? technicalWeaknesses
    : technicalWeaknesses.slice(0, MAX_VISIBLE);
  const hiddenCount = technicalWeaknesses.length - visibleWeaknesses.length;

  const renderAxes = () => (
    <section aria-label="Axes techniques" className="border-t border-border-subtle pt-3">
      <ul className="space-y-2 lg:max-h-[12rem] lg:overflow-y-auto lg:overscroll-contain lg:pr-1">
        {visibleWeaknesses.map((item, index) => {
          const tags = tagsByCategory[item.name] ?? [];
          const visibleTags = tags.slice(0, MAX_TAGS);
          const hiddenTags = tags.slice(MAX_TAGS);
          return (
            <li key={item.id}>
              <div className="flex items-center justify-between gap-2">
                <span className="min-w-0 truncate text-sm font-semibold text-ink" title={item.name}>
                  {item.name}
                </span>
                <span className={`flex-shrink-0 font-mono text-xs font-semibold ${index === 0 && item.pct < 65 ? 'text-crimson-700' : 'text-ink-secondary'}`}>
                  {item.pct} %
                </span>
              </div>
              {tags.length > 0 && (
                <div className="mt-1.5 flex flex-wrap gap-1.5">
                  {visibleTags.map((tag) => (
                    <span key={tag} className={TAG_CLASS_NAME}>
                      {tag}
                    </span>
                  ))}
                  {hiddenTags.length > 0 && (
                    <span
                      className={TAG_CLASS_NAME}
                      title={hiddenTags.join(', ')}
                      aria-label={hiddenTags.join(', ')}
                    >
                      +{hiddenTags.length}
                    </span>
                  )}
                </div>
              )}
            </li>
          );
        })}
      </ul>
    </section>
  );

  return (
    <section className="bg-surface border-[0.5px] border-card-border rounded-2xl p-5 shadow-elevated space-y-4 sm:p-6 lg:flex lg:flex-col">
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <div className="p-2 rounded-lg bg-navy-100 border border-navy-200 text-navy-900 flex-shrink-0">
            <Target className="w-4 h-4" />
          </div>
          <PageTitle as="h2" size="sm">À travailler en priorité</PageTitle>
        </div>
        <span className="flex-shrink-0 text-[11px] text-ink-muted">
          {technicalWeaknesses.length} axe{technicalWeaknesses.length > 1 ? 's' : ''}
        </span>
      </div>

      {renderAxes()}

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

      {(showCta || genericCta) && (
        <div className="lg:mt-auto lg:px-2">
          <Button
            type="button"
            variant="primary"
            size="lg"
            loading={loading}
            rightIcon={<Target className="h-4 w-4" />}
            onClick={() => onStart(genericCta
              ? {
                  mode: summary.mode,
                  difficulty: summary.difficulty ?? undefined,
                  profileId: summary.profileId ?? undefined,
                }
              : buildTargetedRequest(
                  summary,
                  priority,
                  summary.questions.map((question) => question.challengeId),
                  'CATEGORY'
                ))}
            className="w-full sm:w-auto lg:w-full"
          >
            {genericCta ? 'Refaire une mise en situation' : `Travailler ${priority.name}`}
          </Button>
        </div>
      )}
    </section>
  );
};
