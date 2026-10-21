import { useState, useEffect, useRef } from 'react';
import { Loader2 } from 'lucide-react';
import type { SimulationResponse, SubmitAnswerResponse } from '../types';
import { simulationApi } from '../api/simulationApi';
import { QuizProgressHeader } from './QuizProgressHeader';
import { QuizChallengeBody } from './QuizChallengeBody';
import { QuizOptionsList } from './QuizOptionsList';
import { QuizSequenceList } from './QuizSequenceList';
import { QuizFeedbackPanel } from './QuizFeedbackPanel';
import { QuizActionsFooter } from './QuizActionsFooter';

const FALLBACK_QUESTION_TIME_SECONDS = 90;
const AUTO_ADVANCE_DELAY_MS = 1500;

interface Props {
  simulation: SimulationResponse;
  onFinish: () => void;
  onError: (message: string) => void;
  finishing: boolean;
}

export const QuizScreen = ({ simulation, onFinish, onError, finishing }: Props) => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedOptionIds, setSelectedOptionIds] = useState<number[]>([]);
  const [feedback, setFeedback] = useState<SubmitAnswerResponse | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [timeoutError, setTimeoutError] = useState(false);

  const startTimeRef = useRef<number>(0);
  const timeoutSubmittedRef = useRef(false);
  const submissionInFlightRef = useRef(false);
  const submitAnswerRef = useRef<(forceTimeout?: boolean) => Promise<void>>(async () => {});
  const autoAdvanceTimerRef = useRef<number | null>(null);
  const challengeSurfaceRef = useRef<HTMLDivElement>(null);
  const feedbackPanelRef = useRef<HTMLDivElement>(null);
  const scrollToFeedbackRef = useRef(false);
  const isFirstQuestionRef = useRef(true);
  const currentChallenge = simulation.challenges?.[currentIndex];
  const questionTimeLimit = Math.max(
    1,
    currentChallenge?.estimatedTimeSeconds ?? FALLBACK_QUESTION_TIME_SECONDS
  );
  const [timerState, setTimerState] = useState(() => ({
    challengeId: simulation.challenges?.[0]?.simulationChallengeId ?? null,
    secondsRemaining: Math.max(
      1,
      simulation.challenges?.[0]?.estimatedTimeSeconds ?? FALLBACK_QUESTION_TIME_SECONDS
    ),
  }));
  const timerDeadlineRef = useRef(Date.now() + Math.max(
    1,
    simulation.challenges?.[0]?.estimatedTimeSeconds ?? FALLBACK_QUESTION_TIME_SECONDS
  ) * 1000);
  const secondsRemaining = timerState.secondsRemaining;
  const isTimedOut = Boolean(currentChallenge) && secondsRemaining === 0;
  const [optionOrderByChallenge] = useState(() => {
    const orders = new Map<number, SimulationResponse['challenges'][number]['options']>();
    (simulation.challenges ?? []).forEach(challenge => {
      if (challenge.type === 'SEQUENTIAL_REASONING') {
        orders.set(challenge.simulationChallengeId, challenge.options);
        return;
      }

      const shuffledOptions = [...challenge.options];
      for (let index = shuffledOptions.length - 1; index > 0; index -= 1) {
        const swapIndex = Math.floor(Math.random() * (index + 1));
        [shuffledOptions[index], shuffledOptions[swapIndex]] = [
          shuffledOptions[swapIndex],
          shuffledOptions[index],
        ];
      }
      orders.set(challenge.simulationChallengeId, shuffledOptions);
    });
    return orders;
  });
  const displayedOptions = currentChallenge
    ? optionOrderByChallenge.get(currentChallenge.simulationChallengeId) ?? currentChallenge.options
    : [];

  const totalChallenges = simulation.challenges?.length || 1;

  // Le compte à rebours est réinitialisé pour chaque question et mis en pause
  // pendant la validation ou l'affichage du feedback.
  useEffect(() => {
    if (!currentChallenge) return;
    const challengeId = currentChallenge.simulationChallengeId;

    if (timerState.challengeId !== challengeId) {
      timeoutSubmittedRef.current = false;
      setTimeoutError(false);
      startTimeRef.current = Date.now();
      timerDeadlineRef.current = Date.now() + questionTimeLimit * 1000;
      setTimerState({ challengeId, secondsRemaining: questionTimeLimit });
      return;
    }

    if (!startTimeRef.current) startTimeRef.current = Date.now();
    if (feedback || finishing || submitting) return;

    const timer = window.setInterval(() => {
      setTimerState(current => {
        if (current.challengeId !== challengeId || current.secondsRemaining <= 0) return current;
        const remaining = Math.max(0, Math.ceil((timerDeadlineRef.current - Date.now()) / 1000));
        return { ...current, secondsRemaining: remaining };
      });
    }, 1000);

    return () => window.clearInterval(timer);
  }, [currentChallenge?.simulationChallengeId, feedback, finishing, questionTimeLimit, submitting, timerState.challengeId]);

  useEffect(() => {
    if (!feedback || !scrollToFeedbackRef.current) return;
    scrollToFeedbackRef.current = false;
    feedbackPanelRef.current?.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }, [feedback]);

  useEffect(() => {
    if (isFirstQuestionRef.current) {
      isFirstQuestionRef.current = false;
      if (window.matchMedia('(max-width: 639px)').matches) {
        challengeSurfaceRef.current?.scrollIntoView({
          behavior: 'smooth',
          block: 'start',
        });
      }
      return;
    }
    challengeSurfaceRef.current?.scrollIntoView({
      behavior: 'smooth',
      block: 'start',
    });
  }, [currentIndex]);

  // Raisonnement séquentiel : l'ordre initial = l'ordre de présentation reçu
  // (displayOrder renuméroté côté serveur — jamais l'ordre attendu).
  const isSequentialChallenge = currentChallenge?.type === 'SEQUENTIAL_REASONING';
  useEffect(() => {
    const challenge = simulation.challenges?.[currentIndex];
    if (challenge?.type === 'SEQUENTIAL_REASONING') {
      setSelectedOptionIds(
        [...challenge.options]
          .sort((a, b) => a.displayOrder - b.displayOrder)
          .map((option) => option.id)
      );
    }
  }, [currentIndex, simulation]);

  useEffect(() => {
    if (!currentChallenge
      || timerState.challengeId !== currentChallenge.simulationChallengeId
      || secondsRemaining > 0
      || feedback
      || submitting
      || finishing
      || timeoutSubmittedRef.current) return;

    void submitAnswerRef.current(true);
  }, [currentChallenge?.simulationChallengeId, feedback, finishing, secondsRemaining, submitting, timeoutError, timerState.challengeId]);

  useEffect(() => () => {
    if (autoAdvanceTimerRef.current !== null) {
      window.clearTimeout(autoAdvanceTimerRef.current);
    }
  }, []);

  if (finishing) {
    return (
      <div className="w-full max-w-4xl mx-auto py-16 text-center">
        <div className="inline-flex flex-col items-center gap-4 bg-surface border-[0.5px] border-card-border rounded-2xl px-8 py-10 shadow-elevated">
          <Loader2 className="w-7 h-7 animate-spin text-brand" />
          <div className="space-y-1">
            <p className="text-sm font-semibold text-text">Préparation de votre bilan…</p>
            <p className="text-xs text-muted">
              La session est en cours de clôture, un instant.
            </p>
          </div>
        </div>
      </div>
    );
  }

  if (!currentChallenge) {
    return (
      <div className="w-full max-w-3xl mx-auto py-12 text-center">
        <div className="bg-surface border border-danger-border rounded-2xl p-8">
          <p className="text-danger font-medium text-sm">
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

  const advanceToNextQuestion = () => {
    if (currentIndex + 1 >= simulation.challenges.length) {
      onFinish();
      return;
    }
    if (autoAdvanceTimerRef.current !== null) {
      window.clearTimeout(autoAdvanceTimerRef.current);
      autoAdvanceTimerRef.current = null;
    }
    const nextChallenge = simulation.challenges[currentIndex + 1];
    const nextTimeLimit = Math.max(1, nextChallenge.estimatedTimeSeconds ?? FALLBACK_QUESTION_TIME_SECONDS);
    setFeedback(null);
    setSelectedOptionIds([]);
    timeoutSubmittedRef.current = false;
    setTimeoutError(false);
    startTimeRef.current = Date.now();
    timerDeadlineRef.current = Date.now() + nextTimeLimit * 1000;
    setTimerState({ challengeId: nextChallenge.simulationChallengeId, secondsRemaining: nextTimeLimit });
    setCurrentIndex((prev) => prev + 1);
  };

  const handleSubmitAnswer = async (forceTimeout = false) => {
    if (!currentChallenge || submitting || submissionInFlightRef.current || feedback) return;
    if (timeoutError && !forceTimeout) return;
    const timedOut = forceTimeout || Date.now() >= timerDeadlineRef.current;
    if (selectedOptionIds.length === 0 && !timedOut) return;

    submissionInFlightRef.current = true;
    scrollToFeedbackRef.current = !timedOut;
    if (timedOut) timeoutSubmittedRef.current = true;
    const responseTimeMs = startTimeRef.current ? Date.now() - startTimeRef.current : 0;
    setSubmitting(true);

    try {
      const res = await simulationApi.submitAnswer(simulation.id, {
        simulationChallengeId: currentChallenge.simulationChallengeId,
        selectedOptionIds: timedOut ? [] : selectedOptionIds,
        responseTimeMs,
      }, simulation.guestAccessToken ?? undefined);
      setTimeoutError(false);
      if (timedOut) {
        timeoutSubmittedRef.current = true;
        if (isSequentialChallenge) {
          setSelectedOptionIds([]);
          setFeedback(res);
        }
        autoAdvanceTimerRef.current = window.setTimeout(() => {
          autoAdvanceTimerRef.current = null;
          advanceToNextQuestion();
        }, AUTO_ADVANCE_DELAY_MS);
      } else {
        setFeedback(res);
      }
    } catch (err) {
      console.error(err);
      scrollToFeedbackRef.current = false;
      if (timedOut) {
        setTimeoutError(true);
        timeoutSubmittedRef.current = true;
        onError("Impossible d'enregistrer l'expiration. Réessayez.");
      } else {
        onError('Impossible de valider la réponse. Vérifie la connexion avec le serveur.');
      }
    } finally {
      submissionInFlightRef.current = false;
      setSubmitting(false);
    }
  };
  submitAnswerRef.current = handleSubmitAnswer;

  const handleNext = () => {
    advanceToNextQuestion();
  };

  const isMultiChoice = currentChallenge.selectionType === 'MULTIPLE_CHOICE';

  return (
    <div className="w-full max-w-4xl min-w-0 mx-auto space-y-8 py-2 sm:py-4">
      {/* Editorial Progress Header */}
      <QuizProgressHeader
        challenge={currentChallenge}
        currentIndex={currentIndex}
        totalChallenges={totalChallenges}
        secondsRemaining={secondsRemaining}
        isTimeWarning={secondsRemaining <= 15 && !feedback && !submitting && !finishing}
        timerPaused={Boolean(feedback) || submitting || finishing || isTimedOut}
        score={feedback ? feedback.totalSimulationScore : simulation.totalScore}
      />

      {/* Main Challenge Surface — p-5 sur mobile (p-6 gagnait trop de largeur
          utile sur écran étroit), identique à partir de sm. */}
      <div
        ref={challengeSurfaceRef}
        className={`scroll-mt-14 sm:scroll-mt-16 border-[0.5px] rounded-2xl p-5 sm:p-9 space-y-7 transition-colors duration-200 ${
          secondsRemaining <= 15 && !feedback && !submitting
            ? 'border-danger-border bg-danger-soft shadow-[0_2px_10px_rgba(172,59,97,0.12)] animate-pulse'
            : 'bg-surface border-card-border shadow-elevated'
        }`}
      >
        <QuizChallengeBody
          challenge={currentChallenge}
          showMultiChoiceHint={isMultiChoice && !feedback}
        />

        {isSequentialChallenge ? (
          <QuizSequenceList
            challenge={currentChallenge}
            orderedOptionIds={selectedOptionIds}
            onChange={setSelectedOptionIds}
            disabled={!!feedback || isTimedOut}
            timedOut={isTimedOut && Boolean(feedback?.expectedOrder?.length)}
            feedback={feedback}
          />
        ) : (
          <QuizOptionsList
            challenge={{ ...currentChallenge, options: displayedOptions }}
            selectedOptionIds={selectedOptionIds}
            feedback={feedback}
            timedOut={isTimedOut}
            onSelect={handleSelectOption}
          />
        )}

        {feedback && !isTimedOut && (
          <div ref={feedbackPanelRef} className="scroll-mt-24">
            <QuizFeedbackPanel feedback={feedback} />
          </div>
        )}

        {(!isTimedOut || timeoutError) && (
          <QuizActionsFooter
            feedback={feedback}
            selectedCount={selectedOptionIds.length}
            submitting={submitting}
            timedOut={isTimedOut}
            timeoutError={timeoutError}
            isLastQuestion={currentIndex + 1 >= simulation.challenges.length}
            onSubmit={() => {
              if (timeoutError) {
                setTimeoutError(false);
                timeoutSubmittedRef.current = false;
              }
              void handleSubmitAnswer(isTimedOut || timeoutError);
            }}
            onNext={handleNext}
          />
        )}
      </div>
    </div>
  );
};
