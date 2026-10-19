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
  const [secondsElapsed, setSecondsElapsed] = useState(0);

  const startTimeRef = useRef<number>(0);
  const challengeSurfaceRef = useRef<HTMLDivElement>(null);
  const isFirstQuestionRef = useRef(true);
  const currentChallenge = simulation.challenges?.[currentIndex];

  const totalChallenges = simulation.challenges?.length || 1;

  // Timer interval per challenge
  useEffect(() => {
    startTimeRef.current = Date.now();

    const timer = setInterval(() => {
      setSecondsElapsed((prev) => prev + 1);
    }, 1000);

    return () => clearInterval(timer);
  }, [currentIndex]);

  useEffect(() => {
    if (isFirstQuestionRef.current) {
      isFirstQuestionRef.current = false;
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
    if (currentIndex + 1 >= simulation.challenges.length) {
      onFinish();
      return;
    }
    setFeedback(null);
    setSelectedOptionIds([]);
    setSecondsElapsed(0);
    setCurrentIndex((prev) => prev + 1);
  };

  const isMultiChoice = currentChallenge.selectionType === 'MULTIPLE_CHOICE';

  return (
    <div className="w-full max-w-4xl min-w-0 mx-auto space-y-8 py-2 sm:py-4">
      {/* Editorial Progress Header */}
      <QuizProgressHeader
        challenge={currentChallenge}
        currentIndex={currentIndex}
        totalChallenges={totalChallenges}
        secondsElapsed={secondsElapsed}
        score={feedback ? feedback.totalSimulationScore : simulation.totalScore}
      />

      {/* Main Challenge Surface — p-5 sur mobile (p-6 gagnait trop de largeur
          utile sur écran étroit), identique à partir de sm. */}
      <div
        ref={challengeSurfaceRef}
        className="scroll-mt-14 sm:scroll-mt-16 bg-surface border-[0.5px] border-card-border rounded-2xl p-5 sm:p-9 shadow-elevated space-y-7"
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
            disabled={!!feedback}
            feedback={feedback}
          />
        ) : (
          <QuizOptionsList
            challenge={currentChallenge}
            selectedOptionIds={selectedOptionIds}
            feedback={feedback}
            onSelect={handleSelectOption}
          />
        )}

        {feedback && <QuizFeedbackPanel feedback={feedback} />}

        <QuizActionsFooter
          feedback={feedback}
          selectedCount={selectedOptionIds.length}
          submitting={submitting}
          isLastQuestion={currentIndex + 1 >= simulation.challenges.length}
          onSubmit={handleSubmitAnswer}
          onNext={handleNext}
        />
      </div>
    </div>
  );
};
