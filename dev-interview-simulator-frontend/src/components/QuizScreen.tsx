import { useState, useEffect, useRef } from 'react';
import type { SimulationResponse, SubmitAnswerResponse } from '../types';
import { simulationApi } from '../api/simulationApi';
import { Badge } from './common/Badge';
import { Button } from './common/Button';
import { CodeBlock } from './common/CodeBlock';
import {
  Clock,
  Award,
  CheckCircle2,
  XCircle,
  ArrowRight,
  Code2,
  Layers,
  Scale,
  Sparkles,
  ShieldAlert,
} from 'lucide-react';

interface Props {
  simulation: SimulationResponse;
  onFinish: () => void;
  onError: (message: string) => void;
}

export const QuizScreen = ({ simulation, onFinish, onError }: Props) => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedOptionIds, setSelectedOptionIds] = useState<number[]>([]);
  const [feedback, setFeedback] = useState<SubmitAnswerResponse | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [secondsElapsed, setSecondsElapsed] = useState(0);

  const startTimeRef = useRef<number>(0);
  const currentChallenge = simulation.challenges?.[currentIndex];

  const totalChallenges = simulation.challenges?.length || 1;
  const progressPercent = Math.round(((currentIndex + 1) / totalChallenges) * 100);

  // Timer interval per challenge
  useEffect(() => {
    startTimeRef.current = Date.now();

    const timer = setInterval(() => {
      setSecondsElapsed((prev) => prev + 1);
    }, 1000);

    return () => clearInterval(timer);
  }, [currentIndex]);

  if (!currentChallenge) {
    return (
      <div className="max-w-3xl mx-auto py-12 text-center">
        <div className="bg-white border border-[#F3BEBE] rounded-2xl p-8">
          <p className="text-[#9C2727] font-medium text-sm">
            Impossible de charger la question courante.
          </p>
        </div>
      </div>
    );
  }

  const handleSelectOption = (optionId: number) => {
    if (feedback) return; // Locked once answered
    if (currentChallenge.selectionType === 'MULTIPLE_CHOICE') {
      setSelectedOptionIds((currentIds) =>
        currentIds.includes(optionId)
          ? currentIds.filter((id) => id !== optionId)
          : [...currentIds, optionId]
      );
    } else {
      setSelectedOptionIds([optionId]);
    }
  };

  const handleSubmitAnswer = async () => {
    if (selectedOptionIds.length === 0 || !currentChallenge || submitting) return;

    const responseTimeMs = startTimeRef.current ? Date.now() - startTimeRef.current : secondsElapsed * 1000;
    setSubmitting(true);

    try {
      const res = await simulationApi.submitAnswer(simulation.id, {
        simulationChallengeId: currentChallenge.simulationChallengeId,
        selectedOptionIds,
        responseTimeMs,
      });
      setFeedback(res);
    } catch (err) {
      console.error(err);
      onError('Impossible de valider la réponse. Vérifie la connexion avec le serveur.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleNext = () => {
    setFeedback(null);
    setSelectedOptionIds([]);
    setSecondsElapsed(0);
    if (currentIndex + 1 < simulation.challenges.length) {
      setCurrentIndex((prev) => prev + 1);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } else {
      onFinish();
    }
  };

  const formatTime = (totalSeconds: number) => {
    const mins = Math.floor(totalSeconds / 60);
    const secs = totalSeconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const getOptionLetter = (idx: number) => {
    return String.fromCharCode(65 + idx);
  };

  const isMultiChoice = currentChallenge.selectionType === 'MULTIPLE_CHOICE';

  return (
    <div className="max-w-4xl mx-auto space-y-8 py-2 sm:py-4">
      {/* Editorial Progress Header */}
      <div className="space-y-3">
        <div className="flex flex-wrap items-center justify-between gap-3 text-xs">
          <div className="flex items-center gap-2">
            <span className="font-mono uppercase tracking-wider text-[#797E88] font-semibold">
              {currentChallenge.type === 'ARCHITECTURE'
                ? `ÉTAPE ${(currentChallenge.stepOrder ?? currentIndex + 1).toString().padStart(2, '0')} / ${(currentChallenge.totalSteps ?? totalChallenges).toString().padStart(2, '0')}`
                : `QUESTION ${(currentIndex + 1).toString().padStart(2, '0')} / ${totalChallenges.toString().padStart(2, '0')}`}
            </span>
            <span className="text-[#BAB2B5]">•</span>
            <Badge variant="navy" size="sm">
              {currentChallenge.type === 'CODE_REVIEW'
                ? 'Code Review'
                : currentChallenge.type === 'ARCHITECTURE'
                ? 'Architecture Système'
                : 'QCM de situation'}
            </Badge>
          </div>

          {/* Timer & Live Score */}
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1.5 font-mono text-xs bg-white px-2.5 py-1 rounded-md border border-[#DDD5D8] text-[#123C69] shadow-[0_1px_2px_rgba(18,60,105,0.02)]">
              <Clock className="w-3.5 h-3.5 text-[#123C69]" />
              <span>{formatTime(secondsElapsed)}</span>
            </div>

            <div className="flex items-center gap-1.5 font-mono text-xs bg-white px-2.5 py-1 rounded-md border border-[#DDD5D8] text-[#AC3B61] font-semibold shadow-[0_1px_2px_rgba(18,60,105,0.02)]">
              <Award className="w-3.5 h-3.5 text-[#AC3B61]" />
              <span>
                {feedback ? feedback.totalSimulationScore : simulation.totalScore} pts
              </span>
            </div>
          </div>
        </div>

        {/* Minimal Progress Bar in Accent Rosewood (#AC3B61) */}
        <div className="w-full h-1 bg-[#DDD5D8] rounded-full overflow-hidden">
          <div
            className="h-full bg-[#AC3B61] transition-all duration-300 ease-out"
            style={{ width: `${progressPercent}%` }}
          />
        </div>
      </div>

      {/* Main Challenge Surface */}
      <div className="bg-white border border-[#DDD5D8] rounded-2xl p-6 sm:p-9 shadow-[0_2px_8px_rgba(18,60,105,0.03)] space-y-7">
        {/* Architecture Scenario Context (if Architecture) */}
        {currentChallenge.type === 'ARCHITECTURE' && currentChallenge.scenarioTitle && (
          <div className="rounded-xl border border-[#B8D3EC] bg-[#F1F6FB] p-4 sm:p-5">
            <div className="flex items-start gap-3">
              <div className="p-2 rounded-lg bg-white border border-[#B8D3EC] text-[#123C69] flex-shrink-0">
                <Layers className="w-4 h-4" />
              </div>
              <div className="space-y-1">
                <p className="font-serif font-bold text-base text-[#123C69]">
                  {currentChallenge.scenarioTitle}
                </p>
                {currentChallenge.scenarioDescription && (
                  <p className="text-xs sm:text-sm text-[#484F59] leading-relaxed">
                    {currentChallenge.scenarioDescription}
                  </p>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Challenge Title */}
        <div className="space-y-3">
          <h2 className="font-serif text-2xl sm:text-3xl font-bold text-[#102136] tracking-tight leading-snug">
            {currentChallenge.title}
          </h2>

          {/* Context box if available */}
          {currentChallenge.context && (
            <div className="p-4 rounded-xl bg-[#FAF7F5] border border-[#DDD5D8] text-sm text-[#484F59] leading-relaxed">
              <div className="text-[11px] font-mono text-[#797E88] uppercase tracking-wider mb-1 font-semibold">
                Mise en situation
              </div>
              <p className="italic text-[#102136] font-serif text-base">{currentChallenge.context}</p>
            </div>
          )}
        </div>

        {/* Code Snippet for Code Review */}
        {currentChallenge.codeSnippet && (
          <div className="space-y-2">
            <div className="flex items-center justify-between text-xs text-[#484F59]">
              <span className="font-sans font-medium flex items-center gap-1.5 text-[#123C69]">
                <Code2 className="w-4 h-4 text-[#AC3B61]" />
                Extrait de code source à inspecter
              </span>
              {currentChallenge.codeLanguage && (
                <Badge variant="mono" size="sm">
                  {currentChallenge.codeLanguage}
                </Badge>
              )}
            </div>

            <CodeBlock
              code={currentChallenge.codeSnippet}
              language={currentChallenge.codeLanguage}
              filename="SourceSnippet"
            />
          </div>
        )}

        {/* Question Prompt */}
        <div className="space-y-2 pt-2 border-t border-[#E9E1DE]">
          <div className="flex items-center gap-2">
            <span className="text-[11px] font-mono text-[#AC3B61] font-semibold tracking-wider uppercase">
              Question
            </span>
            {isMultiChoice && !feedback && (
              <Badge variant="crimson" size="sm">
                Sélectionnez toutes les options valides
              </Badge>
            )}
          </div>
          <p className="text-lg sm:text-xl font-serif text-[#102136] font-semibold leading-relaxed">
            {currentChallenge.question}
          </p>
        </div>

        {/* Options List */}
        <div className="space-y-3 pt-2">
          {currentChallenge.options.map((option, idx) => {
            const isSelected = selectedOptionIds.includes(option.id);
            const correction = feedback?.corrections.find(
              (item) => item.optionId === option.id
            );

            // Dynamic styling
            let cardStyle =
              'border-[#DDD5D8] bg-white hover:border-[#BAB2B5] hover:bg-[#FAF7F5] text-[#102136] shadow-[0_1px_2px_rgba(18,60,105,0.02)]';
            let indicatorStyle =
              'border-[#DDD5D8] bg-[#FAF7F5] text-[#484F59]';

            if (feedback) {
              if (correction?.isCorrect && correction.wasSelected) {
                // Correct & Selected
                cardStyle =
                  'border-[#B6DEC5] bg-[#F0F7F3] text-[#185E37] ring-1 ring-[#B6DEC5]';
                indicatorStyle =
                  'border-[#185E37] bg-[#185E37] text-white font-bold';
              } else if (correction?.isCorrect) {
                // Correct but missed
                cardStyle =
                  'border-[#B6DEC5] bg-[#F0F7F3]/50 text-[#185E37]';
                indicatorStyle =
                  'border-[#B6DEC5] bg-white text-[#185E37]';
              } else if (correction?.wasSelected) {
                // Incorrectly chosen
                cardStyle =
                  'border-[#F3BEBE] bg-[#FDF2F2] text-[#9C2727] ring-1 ring-[#F3BEBE]';
                indicatorStyle =
                  'border-[#9C2727] bg-[#9C2727] text-white font-bold';
              } else {
                // Unselected incorrect
                cardStyle =
                  'border-[#E9E1DE] bg-white opacity-50 text-[#797E88]';
              }
            } else if (isSelected) {
              // User selected -> Rosewood / Crimson active state (#AC3B61)
              cardStyle =
                'border-[#AC3B61] bg-[#FCEBF1] text-[#102136] ring-1 ring-[#AC3B61] shadow-[0_2px_6px_rgba(172,59,97,0.06)]';
              indicatorStyle =
                'border-[#AC3B61] bg-[#AC3B61] text-white font-bold';
            }

            return (
              <div
                key={option.id}
                onClick={() => handleSelectOption(option.id)}
                className={`relative flex items-start gap-4 p-4 sm:p-5 rounded-xl border transition-all duration-150 select-none ${
                  feedback ? 'cursor-default' : 'cursor-pointer active:scale-[0.998]'
                } ${cardStyle}`}
              >
                {/* Index / Checkbox indicator */}
                <div
                  className={`w-6 h-6 rounded-md border flex items-center justify-center text-xs font-mono flex-shrink-0 mt-0.5 transition-colors ${indicatorStyle}`}
                >
                  {feedback ? (
                    correction?.isCorrect ? (
                      <CheckCircle2 className="w-4 h-4 stroke-[2.5]" />
                    ) : correction?.wasSelected ? (
                      <XCircle className="w-4 h-4 stroke-[2.5]" />
                    ) : (
                      getOptionLetter(idx)
                    )
                  ) : isSelected ? (
                    <CheckCircle2 className="w-4 h-4 stroke-[2.5]" />
                  ) : (
                    getOptionLetter(idx)
                  )}
                </div>

                {/* Option text */}
                <div className="flex-1 text-sm sm:text-base leading-relaxed font-sans">
                  {option.content}
                </div>
              </div>
            );
          })}
        </div>

        {/* Diagnostic Assessment Panel */}
        {feedback && (
          <div className="rounded-2xl border border-[#DDD5D8] bg-[#FAF7F5] p-5 sm:p-7 space-y-4 shadow-[0_2px_12px_rgba(18,60,105,0.04)] animate-in fade-in duration-200">
            {/* Header */}
            <div className="flex flex-wrap items-center justify-between gap-3 pb-3 border-b border-[#DDD5D8]">
              <div className="flex items-center gap-2">
                <span className="font-mono text-xs uppercase tracking-wider text-[#797E88]">
                  Évaluation :
                </span>
                <Badge
                  variant={feedback.isCorrect ? 'success' : 'danger'}
                  size="md"
                  dot
                >
                  {feedback.isCorrect ? 'Réponse validée' : 'Réponse incorrecte'}
                </Badge>
              </div>

              <div className="font-mono text-xs text-[#AC3B61] font-semibold">
                +{feedback.scoreAwarded} point(s) attribué(s)
              </div>
            </div>

            {/* Explanation */}
            {feedback.explanation && (
              <div className="space-y-1.5">
                <div className="text-xs font-sans text-[#123C69] font-semibold uppercase tracking-wider flex items-center gap-1.5">
                  <Sparkles className="w-3.5 h-3.5 text-[#AC3B61]" />
                  Explication de l'évaluateur
                </div>
                <p className="text-sm text-[#102136] leading-relaxed font-sans bg-white p-4 rounded-xl border border-[#DDD5D8]">
                  {feedback.explanation}
                </p>
              </div>
            )}

            {/* Architecture: Revealed Information */}
            {feedback.revealedInformation && (
              <div className="rounded-xl border border-[#B8D3EC] bg-[#F1F6FB] p-4 space-y-1">
                <div className="flex items-center gap-1.5 text-xs font-sans uppercase tracking-wider text-[#123C69] font-semibold">
                  <Layers className="w-3.5 h-3.5 text-[#123C69]" />
                  Information révélée sur le système
                </div>
                <p className="text-xs sm:text-sm text-[#102136] leading-relaxed">
                  {feedback.revealedInformation}
                </p>
              </div>
            )}

            {/* Architecture: Trade-off */}
            {feedback.tradeoff && (
              <div className="rounded-xl border border-[#E8D2A7] bg-[#FBF6ED] p-4 space-y-1">
                <div className="flex items-center gap-1.5 text-xs font-sans uppercase tracking-wider text-[#7A5214] font-semibold">
                  <Scale className="w-3.5 h-3.5 text-[#7A5214]" />
                  Arbitrage & Compromis architectural (Trade-off)
                </div>
                <p className="text-xs sm:text-sm text-[#102136] leading-relaxed">
                  {feedback.tradeoff}
                </p>
              </div>
            )}

            {/* Code Review: Detailed per-issue corrections */}
            {feedback.corrections.some((c) => c.explanation) && (
              <div className="pt-2 space-y-2">
                <div className="text-xs font-sans uppercase tracking-wider text-[#484F59] font-semibold flex items-center gap-1.5">
                  <ShieldAlert className="w-3.5 h-3.5 text-[#AC3B61]" />
                  Détail des anomalies
                </div>
                <div className="space-y-2">
                  {feedback.corrections
                    .filter((c) => c.explanation)
                    .map((correction) => (
                      <div
                        key={correction.optionId}
                        className="p-3.5 rounded-xl bg-white border border-[#DDD5D8] text-xs text-[#484F59] leading-relaxed space-y-1"
                      >
                        <div className="flex items-center gap-2">
                          {correction.severity && (
                            <Badge variant="crimson" size="sm">
                              {correction.severity}
                            </Badge>
                          )}
                          <span className="font-semibold text-[#102136]">
                            {correction.content}
                          </span>
                        </div>
                        <p className="text-[#484F59] pt-0.5">
                          {correction.explanation}
                        </p>
                      </div>
                    ))}
                </div>
              </div>
            )}
          </div>
        )}

        {/* Footer Actions */}
        <div className="pt-4 border-t border-[#E9E1DE] flex items-center justify-between gap-4">
          <div className="text-xs text-[#797E88] font-sans hidden sm:block">
            {!feedback ? (
              <span>
                {selectedOptionIds.length} option(s) sélectionnée(s)
              </span>
            ) : (
              <span>Score de session : {feedback.totalSimulationScore} points</span>
            )}
          </div>

          <div className="ml-auto">
            {!feedback ? (
              <Button
                variant="primary"
                size="md"
                onClick={handleSubmitAnswer}
                disabled={selectedOptionIds.length === 0 || submitting}
                loading={submitting}
                rightIcon={<ArrowRight className="w-4 h-4" />}
                className="px-6 font-semibold"
              >
                Valider ma réponse
              </Button>
            ) : (
              <Button
                variant="primary"
                size="md"
                onClick={handleNext}
                rightIcon={<ArrowRight className="w-4 h-4" />}
                className="px-6 font-semibold"
              >
                {currentIndex + 1 < simulation.challenges.length
                  ? 'Question suivante'
                  : 'Consulter le bilan'}
              </Button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};