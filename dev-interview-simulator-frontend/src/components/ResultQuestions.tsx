import { useState } from 'react';
import type { QuestionStatus, QuestionSummary, SimulationResultDTO } from '../types';
import { PageTitle } from './common/PageTitle';
import { Button } from './common/Button';
import { QuestionDetails } from './QuestionDetails';
import { Check, X, Clock3, CircleDashed, ChevronDown, ChevronUp } from 'lucide-react';
import { trackEvent } from '../api/events';

interface Props {
  summary: SimulationResultDTO;
  isGuest?: boolean;
  onCreateAccount?: () => void;
}

/** Questions visibles avant le dépliage « Voir toutes les questions ». */
const INITIAL_VISIBLE = 4;

export const ResultQuestions = ({ summary, isGuest = false, onCreateAccount }: Props) => {
  const [openQuestionId, setOpenQuestionId] = useState<number | null>(null);
  const [filter, setFilter] = useState<'ALL' | 'CORRECT' | 'INCORRECT'>('ALL');
  const [showAll, setShowAll] = useState(false);

  const toggleAccordion = (id: number) => {
    setOpenQuestionId(openQuestionId === id ? null : id);
  };

  const getQuestionStatus = (question: QuestionSummary): QuestionStatus =>
    question.status ?? (question.userSelectedOptionContent ? 'ANSWERED' : 'TIMED_OUT');
  const filteredQuestions = summary.questions.filter((q) => {
    const status = getQuestionStatus(q);
    if (filter === 'CORRECT') return status === 'ANSWERED' && q.isCorrect;
    if (filter === 'INCORRECT') return status !== 'ANSWERED' || !q.isCorrect;
    return true;
  });
  const incorrectCount = summary.questions.filter((q) => {
    const status = getQuestionStatus(q);
    return status !== 'ANSWERED' || !q.isCorrect;
  }).length;

  // Invité : 3 questions lisibles et dépliables, le reste regroupé dans une
  // zone floutée non interactive ; connecté : dépliage à la demande.
  const visibleQuestions = isGuest
    ? filteredQuestions.slice(0, 3)
    : showAll
      ? filteredQuestions
      : filteredQuestions.slice(0, INITIAL_VISIBLE);
  // Invité : jamais plus de 6 questions rendues (les suivantes n'existent pas
  // dans le DOM).
  const blurredQuestions = isGuest ? filteredQuestions.slice(3, 6) : [];

  return (
    <div className="bg-surface border-[0.5px] border-card-border rounded-2xl p-5 shadow-card space-y-4 sm:p-6">
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
            onClick={() => {
              if (!isGuest) setFilter('CORRECT');
            }}
            aria-disabled={isGuest || undefined}
            className={`px-3 py-1 rounded-lg transition-colors cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${
              filter === 'CORRECT'
                ? 'bg-success-soft text-success font-semibold'
                : 'text-ink-secondary hover:text-success'
            } ${isGuest ? 'cursor-default opacity-60' : ''}`}
          >
            Correctes ({summary.correctAnswersCount})
          </button>
          <button
            onClick={() => {
              if (!isGuest) setFilter('INCORRECT');
            }}
            aria-disabled={isGuest || undefined}
            className={`px-3 py-1 rounded-lg transition-colors cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${
              filter === 'INCORRECT'
                ? 'bg-danger-soft text-danger font-semibold'
                : 'text-ink-secondary hover:text-danger'
            } ${isGuest ? 'cursor-default opacity-60' : ''}`}
          >
            Erreurs ({incorrectCount})
          </button>
        </div>
      </div>

      {/* Questions Accordion List */}
      <div className="space-y-3">
        {visibleQuestions.map((q, index) => {
          const status = getQuestionStatus(q);
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
                aria-expanded={isOpen}
                className="w-full flex items-center justify-between p-5 text-left transition-colors hover:bg-canvas-subtle cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas select-none"
              >
                <div className="flex items-center gap-3.5 pr-2 flex-1 min-w-0">
                  <span
                    className={`flex-shrink-0 w-6 h-6 rounded-md flex items-center justify-center text-xs font-mono font-bold ${
                      status === 'ANSWERED'
                        ? q.isCorrect
                          ? 'bg-success-soft border border-success-border text-success'
                          : 'bg-danger-soft border border-danger-border text-danger'
                        : 'bg-canvas-subtle border border-border text-ink-muted'
                    }`}
                    aria-label={status === 'TIMED_OUT' ? 'Temps écoulé' : status === 'UNANSWERED' ? 'Non répondue' : q.isCorrect ? 'Réponse correcte' : 'Réponse incorrecte'}
                  >
                    {status === 'ANSWERED' ? (
                      q.isCorrect ? <Check className="w-3.5 h-3.5 stroke-[2.5]" /> : <X className="w-3.5 h-3.5 stroke-[2.5]" />
                    ) : status === 'TIMED_OUT' ? (
                      <Clock3 className="w-3.5 h-3.5" />
                    ) : (
                      <CircleDashed className="w-3.5 h-3.5" />
                    )}
                  </span>

                {/* break-words + min-w-0 : le titre s'enroule sur plusieurs lignes
                    (mots longs cassés proprement) — jamais tronqué en plein milieu,
                    aucune perte de contenu. */}
                <div className="min-w-0 flex-1 pr-2">
                  <span className="font-serif font-bold text-ink text-sm break-words sm:text-base">
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

      {isGuest && blurredQuestions.length > 0 && (
        <div className="relative">
          <div
            aria-hidden="true"
            className="pointer-events-none select-none space-y-3 opacity-80 blur-[2px] min-h-[220px]"
          >
            {blurredQuestions.map((q, index) => {
              const status = getQuestionStatus(q);
              return (
                <div
                  key={q.challengeId}
                  className="border-[0.5px] border-card-border rounded-2xl overflow-hidden bg-surface shadow-card"
                >
                  <div className="w-full flex items-center justify-between p-5 text-left">
                    <div className="flex items-center gap-3.5 pr-2 flex-1 min-w-0">
                      <span
                        className={`flex-shrink-0 w-6 h-6 rounded-md flex items-center justify-center text-xs font-mono font-bold ${
                          status === 'ANSWERED'
                            ? q.isCorrect
                              ? 'bg-success-soft border border-success-border text-success'
                              : 'bg-danger-soft border border-danger-border text-danger'
                            : 'bg-canvas-subtle border border-border text-ink-muted'
                        }`}
                      >
                        {status === 'ANSWERED' ? (
                          q.isCorrect ? <Check className="w-3.5 h-3.5 stroke-[2.5]" /> : <X className="w-3.5 h-3.5 stroke-[2.5]" />
                        ) : status === 'TIMED_OUT' ? (
                          <Clock3 className="w-3.5 h-3.5" />
                        ) : (
                          <CircleDashed className="w-3.5 h-3.5" />
                        )}
                      </span>
                      <div className="min-w-0 flex-1 pr-2">
                        <span className="font-serif font-bold text-ink text-sm break-words sm:text-base">
                          {index + 4}. {q.title}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
            <div className="inline-flex items-center gap-1 text-xs font-semibold text-navy-900">
              <ChevronDown className="w-3.5 h-3.5" /> Voir toutes les questions (
              {summary.questions.length})
            </div>
          </div>

          <div className="absolute inset-0 flex items-center justify-center px-2">
            <div className="w-full max-w-sm rounded-2xl border-[0.5px] border-card-border bg-surface p-5 shadow-card text-center space-y-3">
              <PageTitle as="h3" size="sm">
                Retrouve le détail de tes réponses
              </PageTitle>
              <p className="text-xs text-ink-secondary">
                Consulte ton historique et le détail de tes simulations gratuitement avec un compte.
              </p>
              <Button
                type="button"
                variant="primary"
                size="md"
                fullWidth
                onClick={() => {
                  trackEvent('guest_cta_clicked', { simulationId: summary.simulationId });
                  onCreateAccount?.();
                }}
              >
                Créer un compte
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* Dépliage : au-delà de INITIAL_VISIBLE questions, un bouton unique
          étend ou réduit la liste (même pattern que ResultPriority). */}
      {!isGuest && filteredQuestions.length > INITIAL_VISIBLE && (
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
