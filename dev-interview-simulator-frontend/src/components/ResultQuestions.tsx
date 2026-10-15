import { useState } from 'react';
import type { SimulationResultDTO } from '../types';
import { PageTitle } from './common/PageTitle';
import { QuestionDetails } from './QuestionDetails';
import { Check, X, ChevronDown, ChevronUp } from 'lucide-react';

interface Props {
  summary: SimulationResultDTO;
}

/** Questions visibles avant le dépliage « Voir toutes les questions ». */
const INITIAL_VISIBLE = 4;

export const ResultQuestions = ({ summary }: Props) => {
  const [openQuestionId, setOpenQuestionId] = useState<number | null>(null);
  const [filter, setFilter] = useState<'ALL' | 'CORRECT' | 'INCORRECT'>('ALL');
  const [showAll, setShowAll] = useState(false);

  const toggleAccordion = (id: number) => {
    setOpenQuestionId(openQuestionId === id ? null : id);
  };

  const filteredQuestions = summary.questions.filter((q) => {
    if (filter === 'CORRECT') return q.isCorrect;
    if (filter === 'INCORRECT') return !q.isCorrect;
    return true;
  });

  // Densité visuelle : initialement seulement quelques questions, déploiement
  // à la demande (le filtre actif s'applique quelle que soit l'étendue).
  const visibleQuestions = showAll
    ? filteredQuestions
    : filteredQuestions.slice(0, INITIAL_VISIBLE);

  return (
    <div className="space-y-4">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-2 border-b border-border">
        <div>
          <PageTitle as="h2" size="sm">
            Détail des questions
          </PageTitle>
          <p className="text-xs text-ink-muted">
            Cliquez sur une question pour déplier l'analyse complète
          </p>
        </div>

        {/* Filter Tabs — flex-wrap : les trois onglets tiennent mal sur mobile
            étroit ; ils passent sur deux lignes au lieu de forcer un overflow-x. */}
        <div className="flex flex-wrap items-center gap-1.5 bg-surface border border-border p-1 rounded-xl text-xs font-sans shadow-card self-start sm:self-auto">
          <button
            onClick={() => setFilter('ALL')}
            className={`px-3 py-1 rounded-lg transition-colors cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${
              filter === 'ALL'
                ? 'bg-navy-100 text-navy-900 font-semibold'
                : 'text-ink-secondary hover:text-navy-900'
            }`}
          >
            Toutes ({summary.questions.length})
          </button>
          <button
            onClick={() => setFilter('CORRECT')}
            className={`px-3 py-1 rounded-lg transition-colors cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${
              filter === 'CORRECT'
                ? 'bg-success-soft text-success font-semibold'
                : 'text-ink-secondary hover:text-success'
            }`}
          >
            Correctes ({summary.correctAnswersCount})
          </button>
          <button
            onClick={() => setFilter('INCORRECT')}
            className={`px-3 py-1 rounded-lg transition-colors cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${
              filter === 'INCORRECT'
                ? 'bg-danger-soft text-danger font-semibold'
                : 'text-ink-secondary hover:text-danger'
            }`}
          >
            Erreurs ({summary.questions.length - summary.correctAnswersCount})
          </button>
        </div>
      </div>

      {/* Questions Accordion List */}
      <div className="space-y-3">
        {visibleQuestions.map((q, index) => {
          const isOpen = openQuestionId === q.challengeId;

          return (
            <div
              key={q.challengeId}
              className="border-[0.5px] border-card-border rounded-2xl overflow-hidden bg-surface transition-all duration-150 shadow-card"
            >
              {/* Accordion Trigger */}
              <button
                type="button"
                onClick={() => toggleAccordion(q.challengeId)}
                className="w-full flex items-center justify-between p-5 text-left hover:bg-canvas-subtle transition-colors cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas select-none"
              >
                <div className="flex items-center gap-3.5 pr-2 flex-1 min-w-0">
                  <span
                    className={`flex-shrink-0 w-6 h-6 rounded-md flex items-center justify-center text-xs font-mono font-bold ${
                      q.isCorrect
                        ? 'bg-success-soft border border-success-border text-success'
                        : 'bg-danger-soft border border-danger-border text-danger'
                    }`}
                  >
                    {q.isCorrect ? (
                      <Check className="w-3.5 h-3.5 stroke-[2.5]" />
                    ) : (
                      <X className="w-3.5 h-3.5 stroke-[2.5]" />
                    )}
                  </span>

                {/* break-words + min-w-0 : le titre s'enroule sur plusieurs lignes
                    (mots longs cassés proprement) — jamais tronqué en plein milieu,
                    aucune perte de contenu. */}
                <div className="min-w-0 flex-1 pr-2">
                  <span className="font-serif font-bold text-ink text-base break-words">
                    {index + 1}. {q.title}
                  </span>
                </div>
                </div>

                <div className="flex items-center gap-3 flex-shrink-0">
                  <span className="text-xs font-mono text-crimson-700 font-semibold hidden sm:inline">
                    +{q.pointsEarned} pts
                  </span>
                  <span className="text-xs text-ink-muted flex items-center gap-1 font-sans">
                    {isOpen ? (
                      <>
                        <span className="hidden sm:inline">Masquer</span>
                        <ChevronUp className="w-4 h-4" />
                      </>
                    ) : (
                      <>
                        <span className="hidden sm:inline">Détails</span>
                        <ChevronDown className="w-4 h-4" />
                      </>
                    )}
                  </span>
                </div>
              </button>

              {/* Accordion Content */}
              {isOpen && <QuestionDetails question={q} />}
            </div>
          );
        })}
      </div>

      {/* Dépliage : au-delà de INITIAL_VISIBLE questions, un bouton unique
          étend ou réduit la liste (même pattern que ResultPriority). */}
      {filteredQuestions.length > INITIAL_VISIBLE && (
        <button
          type="button"
          onClick={() => setShowAll((v) => !v)}
          className="inline-flex items-center gap-1 text-xs font-semibold text-navy-900 hover:text-navy-950 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas rounded"
        >
          {showAll ? (
            <>
              <ChevronUp className="w-3.5 h-3.5" /> Réduire la liste
            </>
          ) : (
            <>
              <ChevronDown className="w-3.5 h-3.5" /> Voir toutes les questions (
              {filteredQuestions.length})
            </>
          )}
        </button>
      )}
    </div>
  );
};
