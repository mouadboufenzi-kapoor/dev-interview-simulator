import { useState } from 'react';
import type { SimulationResultDTO } from '../types';
import { Badge } from './common/Badge';
import { Button } from './common/Button';
import {
  CheckCircle2,
  XCircle,
  Clock,
  Target,
  RotateCcw,
  ChevronDown,
  ChevronUp,
  Sparkles,
  Check,
  X,
  Gauge,
} from 'lucide-react';

interface Props {
  summary: SimulationResultDTO;
  onRestart: () => void;
}

export const ResultScreen = ({ summary, onRestart }: Props) => {
  const [openQuestionId, setOpenQuestionId] = useState<number | null>(null);
  const [filter, setFilter] = useState<'ALL' | 'CORRECT' | 'INCORRECT'>('ALL');

  const toggleAccordion = (id: number) => {
    setOpenQuestionId(openQuestionId === id ? null : id);
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return mins > 0 ? `${mins}m ${secs.toString().padStart(2, '0')}s` : `${secs}s`;
  };

  const avgTimePerQuestion =
    summary.totalQuestions > 0
      ? Math.round(summary.totalTimeSpentSeconds / summary.totalQuestions)
      : 0;

  // Seniority assessment based on score
  const getAssessment = (percent: number) => {
    if (percent >= 80) {
      return {
        label: 'Excellente Maîtrise',
        desc: 'Niveau Senior démontré. Décisions techniques solides, bonne gestion des cas limites et vision d’architecture affirmée.',
        variant: 'success' as const,
      };
    }
    if (percent >= 60) {
      return {
        label: 'Niveau Confirmé',
        desc: 'Compétences opérationnelles solides. Quelques points de vigilance sur les détails de mise en œuvre et les arbitrages.',
        variant: 'navy' as const,
      };
    }
    return {
      label: 'Axes d’amélioration',
      desc: 'Certains fondamentaux de production ou d’architecture méritent d’être consolidés avant un entretien à fort enjeu.',
      variant: 'crimson' as const,
    };
  };

  const assessment = getAssessment(summary.successPercentage);

  const filteredQuestions = summary.questions.filter((q) => {
    if (filter === 'CORRECT') return q.isCorrect;
    if (filter === 'INCORRECT') return !q.isCorrect;
    return true;
  });

  return (
    <div className="max-w-4xl mx-auto space-y-10 py-4 sm:py-6">
      {/* Editorial Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 pb-6 border-b border-[#DDD5D8]">
        <div className="space-y-2">
          <Badge variant={assessment.variant} size="sm" dot>
            Évaluation terminée
          </Badge>
          <h1 className="font-serif text-3xl sm:text-4xl lg:text-5xl font-semibold text-[#123C69] tracking-tight leading-tight">
            Bilan de votre évaluation
          </h1>
          <p className="text-base text-[#484F59]">
            Retrouvez le compte-rendu complet de vos réponses, votre précision et vos axes de progression.
          </p>
        </div>

        <div>
          <Badge variant={assessment.variant} size="md">
            {assessment.label}
          </Badge>
        </div>
      </div>

      {/* KPI Metrics Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Score Card */}
        <div className="bg-white border border-[#DDD5D8] rounded-2xl p-6 shadow-[0_1px_3px_rgba(18,60,105,0.03)] space-y-2">
          <div className="flex items-center justify-between text-[#797E88] font-sans text-xs font-semibold uppercase tracking-wider">
            <span>Taux de réussite</span>
            <Target className="w-4 h-4 text-[#AC3B61]" />
          </div>
          <div>
            <span className="font-serif text-4xl font-bold text-[#AC3B61]">
              {summary.successPercentage}%
            </span>
          </div>
          <p className="text-xs text-[#484F59]">
            {summary.totalScore} / {summary.maxPossibleScore} points obtenus
          </p>
        </div>

        {/* Accuracy Card */}
        <div className="bg-white border border-[#DDD5D8] rounded-2xl p-6 shadow-[0_1px_3px_rgba(18,60,105,0.03)] space-y-2">
          <div className="flex items-center justify-between text-[#797E88] font-sans text-xs font-semibold uppercase tracking-wider">
            <span>Bonnes réponses</span>
            <CheckCircle2 className="w-4 h-4 text-[#185E37]" />
          </div>
          <div>
            <span className="font-serif text-4xl font-bold text-[#102136]">
              {summary.correctAnswersCount}{' '}
              <span className="text-lg text-[#797E88] font-normal">
                / {summary.totalQuestions}
              </span>
            </span>
          </div>
          <p className="text-xs text-[#484F59]">
            {summary.totalQuestions - summary.correctAnswersCount} erreur(s) identifiée(s)
          </p>
        </div>

        {/* Time Card */}
        <div className="bg-white border border-[#DDD5D8] rounded-2xl p-6 shadow-[0_1px_3px_rgba(18,60,105,0.03)] space-y-2">
          <div className="flex items-center justify-between text-[#797E88] font-sans text-xs font-semibold uppercase tracking-wider">
            <span>Temps total</span>
            <Clock className="w-4 h-4 text-[#123C69]" />
          </div>
          <div>
            <span className="font-serif text-4xl font-bold text-[#102136]">
              {formatTime(summary.totalTimeSpentSeconds)}
            </span>
          </div>
          <p className="text-xs text-[#484F59]">
            Durée de la session
          </p>
        </div>

        {/* Average Pace Card */}
        <div className="bg-white border border-[#DDD5D8] rounded-2xl p-6 shadow-[0_1px_3px_rgba(18,60,105,0.03)] space-y-2">
          <div className="flex items-center justify-between text-[#797E88] font-sans text-xs font-semibold uppercase tracking-wider">
            <span>Rythme moyen</span>
            <Gauge className="w-4 h-4 text-[#123C69]" />
          </div>
          <div>
            <span className="font-serif text-4xl font-bold text-[#102136]">
              {avgTimePerQuestion}s
            </span>
          </div>
          <p className="text-xs text-[#484F59]">
            par question
          </p>
        </div>
      </div>

      {/* Synthesis Box */}
      <div className="bg-white border border-[#DDD5D8] rounded-2xl p-6 sm:p-7 flex items-start gap-4 shadow-[0_1px_3px_rgba(18,60,105,0.03)]">
        <div className="p-3 rounded-xl bg-[#FCEBF1] border border-[#F1BED0] text-[#AC3B61] flex-shrink-0">
          <Sparkles className="w-5 h-5" />
        </div>
        <div className="space-y-1">
          <h3 className="font-serif text-xl font-bold text-[#123C69]">
            Diagnostic global : {assessment.label}
          </h3>
          <p className="text-sm text-[#484F59] leading-relaxed">
            {assessment.desc} Consultez le détail ci-dessous pour revoir les explications complètes sur chaque point technique.
          </p>
        </div>
      </div>

      {/* Questions Detailed Accordion */}
      <div className="space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-2 border-b border-[#DDD5D8]">
          <div>
            <h2 className="font-serif text-xl font-bold text-[#123C69]">
              Détail des questions
            </h2>
            <p className="text-xs text-[#797E88]">
              Cliquez sur une question pour déplier l'analyse complète
            </p>
          </div>

          {/* Filter Tabs */}
          <div className="flex items-center gap-1.5 bg-white border border-[#DDD5D8] p-1 rounded-xl text-xs font-sans shadow-[0_1px_2px_rgba(18,60,105,0.02)]">
            <button
              onClick={() => setFilter('ALL')}
              className={`px-3 py-1 rounded-lg transition-colors cursor-pointer ${
                filter === 'ALL'
                  ? 'bg-[#E6EFF8] text-[#123C69] font-semibold'
                  : 'text-[#484F59] hover:text-[#123C69]'
              }`}
            >
              Toutes ({summary.questions.length})
            </button>
            <button
              onClick={() => setFilter('CORRECT')}
              className={`px-3 py-1 rounded-lg transition-colors cursor-pointer ${
                filter === 'CORRECT'
                  ? 'bg-[#F0F7F3] text-[#185E37] font-semibold'
                  : 'text-[#484F59] hover:text-[#185E37]'
              }`}
            >
              Correctes ({summary.correctAnswersCount})
            </button>
            <button
              onClick={() => setFilter('INCORRECT')}
              className={`px-3 py-1 rounded-lg transition-colors cursor-pointer ${
                filter === 'INCORRECT'
                  ? 'bg-[#FDF2F2] text-[#9C2727] font-semibold'
                  : 'text-[#484F59] hover:text-[#9C2727]'
              }`}
            >
              Erreurs ({summary.questions.length - summary.correctAnswersCount})
            </button>
          </div>
        </div>

        {/* Questions Accordion List */}
        <div className="space-y-3">
          {filteredQuestions.map((q, index) => {
            const isOpen = openQuestionId === q.challengeId;

            return (
              <div
                key={q.challengeId}
                className="border border-[#DDD5D8] rounded-2xl overflow-hidden bg-white transition-all duration-150 shadow-[0_1px_3px_rgba(18,60,105,0.02)]"
              >
                {/* Accordion Trigger */}
                <button
                  type="button"
                  onClick={() => toggleAccordion(q.challengeId)}
                  className="w-full flex items-center justify-between p-5 text-left hover:bg-[#FAF7F5] transition-colors cursor-pointer select-none"
                >
                  <div className="flex items-center gap-3.5 pr-2 flex-1 min-w-0">
                    <span
                      className={`flex-shrink-0 w-6 h-6 rounded-md flex items-center justify-center text-xs font-mono font-bold ${
                        q.isCorrect
                          ? 'bg-[#F0F7F3] border border-[#B6DEC5] text-[#185E37]'
                          : 'bg-[#FDF2F2] border border-[#F3BEBE] text-[#9C2727]'
                      }`}
                    >
                      {q.isCorrect ? (
                        <Check className="w-3.5 h-3.5 stroke-[2.5]" />
                      ) : (
                        <X className="w-3.5 h-3.5 stroke-[2.5]" />
                      )}
                    </span>

                    <div className="truncate">
                      <span className="font-serif font-bold text-[#102136] text-base">
                        {index + 1}. {q.title}
                      </span>
                    </div>
                  </div>

                  <div className="flex items-center gap-3 flex-shrink-0">
                    <span className="text-xs font-mono text-[#AC3B61] font-semibold hidden sm:inline">
                      +{q.pointsEarned} pts
                    </span>
                    <span className="text-xs text-[#797E88] flex items-center gap-1 font-sans">
                      {isOpen ? (
                        <>
                          <span className="hidden xs:inline">Masquer</span>
                          <ChevronUp className="w-4 h-4" />
                        </>
                      ) : (
                        <>
                          <span className="hidden xs:inline">Détails</span>
                          <ChevronDown className="w-4 h-4" />
                        </>
                      )}
                    </span>
                  </div>
                </button>

                {/* Accordion Content */}
                {isOpen && (
                  <div className="p-5 sm:p-7 bg-[#FAF7F5] border-t border-[#DDD5D8] text-sm space-y-4 animate-in fade-in duration-150">
                    {/* Context if available */}
                    {q.context && (
                      <div className="p-4 rounded-xl bg-white border border-[#DDD5D8] text-xs text-[#484F59] italic font-serif text-sm">
                        <div className="font-sans not-italic uppercase tracking-wider text-[#797E88] text-[10px] mb-1 font-semibold">
                          Mise en situation
                        </div>
                        {q.context}
                      </div>
                    )}

                    {/* Question Prompt */}
                    <div>
                      <span className="text-[10px] font-mono uppercase tracking-wider text-[#AC3B61] font-semibold block mb-1">
                        Question posée
                      </span>
                      <p className="font-serif text-base font-semibold text-[#102136]">{q.question}</p>
                    </div>

                    {/* User Answer */}
                    <div className="space-y-1">
                      <span className="text-[10px] font-mono uppercase tracking-wider text-[#797E88] block">
                        Votre réponse soumise :
                      </span>
                      <div
                        className={`p-3.5 rounded-xl border text-sm flex items-start gap-2.5 ${
                          q.isCorrect
                            ? 'bg-[#F0F7F3] border-[#B6DEC5] text-[#185E37]'
                            : 'bg-[#FDF2F2] border-[#F3BEBE] text-[#9C2727]'
                        }`}
                      >
                        {q.isCorrect ? (
                          <CheckCircle2 className="w-4 h-4 text-[#185E37] flex-shrink-0 mt-0.5" />
                        ) : (
                          <XCircle className="w-4 h-4 text-[#9C2727] flex-shrink-0 mt-0.5" />
                        )}
                        <span>{q.userSelectedOptionContent || '(Aucune réponse enregistrée)'}</span>
                      </div>
                    </div>

                    {/* Expected Answer (if incorrect) */}
                    {!q.isCorrect && q.correctOptionContent && (
                      <div className="space-y-1">
                        <span className="text-[10px] font-mono uppercase tracking-wider text-[#797E88] block">
                          Bonne réponse attendue :
                        </span>
                        <div className="p-3.5 rounded-xl bg-[#F0F7F3] border border-[#B6DEC5] text-[#185E37] text-sm flex items-start gap-2.5">
                          <CheckCircle2 className="w-4 h-4 text-[#185E37] flex-shrink-0 mt-0.5" />
                          <span>{q.correctOptionContent}</span>
                        </div>
                      </div>
                    )}

                    {/* Evaluator Explanation */}
                    <div className="bg-white border border-[#DDD5D8] p-4 rounded-xl space-y-1.5 shadow-[0_1px_2px_rgba(18,60,105,0.02)]">
                      <div className="flex items-center gap-1.5 text-xs font-sans uppercase tracking-wider text-[#123C69] font-semibold">
                        <Sparkles className="w-3.5 h-3.5 text-[#AC3B61]" />
                        <span>Explication technique de l'évaluateur</span>
                      </div>
                      <p className="text-xs sm:text-sm text-[#102136] leading-relaxed font-sans">
                        {q.explanation || 'Aucune explication renseignée pour cette question.'}
                      </p>
                    </div>

                    {/* Question Metadata Footer */}
                    <div className="flex items-center gap-4 text-xs font-mono text-[#797E88] pt-1">
                      <span>Points obtenus : +{q.pointsEarned}</span>
                      <span>•</span>
                      <span>
                        Temps de réponse : {q.timeSpentMs != null ? `${Math.round(q.timeSpentMs / 1000)}s` : 'Non renseigné'}
                      </span>
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Restart CTA */}
      <div className="pt-8 border-t border-[#DDD5D8] flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="text-sm text-[#484F59] text-center sm:text-left">
          Prêt à tester une nouvelle compétence ou un autre niveau ?
        </div>

        <Button
          onClick={onRestart}
          variant="primary"
          size="lg"
          leftIcon={<RotateCcw className="w-4 h-4" />}
          className="w-full sm:w-auto px-8"
        >
          Lancer une nouvelle session
        </Button>
      </div>
    </div>
  );
};