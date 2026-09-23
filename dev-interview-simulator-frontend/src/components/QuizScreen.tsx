import { useState, useEffect, useRef } from 'react';
import type { SimulationResponse, SubmitAnswerResponse } from '../types';
import { simulationApi } from '../api/simulationApi';

interface Props {
  simulation: SimulationResponse;
  onFinish: () => void;
}

export const QuizScreen = ({ simulation, onFinish }: Props) => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedOptionIds, setSelectedOptionIds] = useState<number[]>([]);
  const [feedback, setFeedback] = useState<SubmitAnswerResponse | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [secondsElapsed, setSecondsElapsed] = useState(0);

  const startTimeRef = useRef<number>(Date.now());
  const currentChallenge = simulation.challenges[currentIndex];

  // Réinitialiser le timer à chaque nouvelle question
  useEffect(() => {
    startTimeRef.current = Date.now();
    setSecondsElapsed(0);

    const timer = setInterval(() => {
      setSecondsElapsed((prev) => prev + 1);
    }, 1000);

    return () => clearInterval(timer);
  }, [currentIndex]);

  const handleSelectOption = (optionId: number) => {
    if (feedback) return;
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
    if (selectedOptionIds.length === 0 || !currentChallenge) return;

    // Calcul du temps exact écoulé en millisecondes
    const responseTimeMs = Date.now() - startTimeRef.current;

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
    } finally {
      setSubmitting(false);
    }
  };

  const handleNext = () => {
    setFeedback(null);
    setSelectedOptionIds([]);
    if (currentIndex + 1 < simulation.challenges.length) {
      setCurrentIndex((prev) => prev + 1);
    } else {
      onFinish();
    }
  };

  const formatTime = (totalSeconds: number) => {
    const mins = Math.floor(totalSeconds / 60);
    const secs = totalSeconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="max-w-3xl mx-auto p-6 bg-white rounded-xl shadow-md my-10">
      <div className="flex justify-between items-center mb-6 pb-4 border-b">
        <span className="text-sm font-semibold text-gray-500">
          Question {currentIndex + 1} / {simulation.challenges.length}
        </span>
        <div className="flex items-center gap-4">
          <span className="text-sm font-medium text-gray-600 bg-gray-100 px-3 py-1 rounded-full">
            ⏱️ {formatTime(secondsElapsed)}
          </span>
          <span className="text-sm font-bold text-blue-600">
            Score : {feedback ? feedback.totalSimulationScore : simulation.totalScore} pts
          </span>
        </div>
      </div>

      <h2 className="text-xl font-bold mb-3 text-gray-800">{currentChallenge.title}</h2>
      {currentChallenge.context && (
        <p className="text-sm text-gray-600 bg-gray-50 p-3 rounded-lg mb-4 italic">
          {currentChallenge.context}
        </p>
      )}
      <p className="text-base text-gray-700 mb-6 font-medium">{currentChallenge.question}</p>

      {currentChallenge.codeSnippet && (
        <pre className="mb-6 overflow-x-auto rounded-lg bg-gray-900 p-4 text-sm text-gray-100">
          <code>{currentChallenge.codeSnippet}</code>
        </pre>
      )}

      <div className="space-y-3 mb-6">
        {currentChallenge.options.map((option) => {
          let style = 'bg-gray-50 border-gray-200 text-gray-800 hover:bg-gray-100';
          const correction = feedback?.corrections.find(
            (item) => item.optionId === option.id
          );

          if (feedback) {
            if (correction?.isCorrect && correction.wasSelected) {
              style = 'bg-green-100 border-green-500 text-green-900 font-semibold';
            } else if (correction?.isCorrect) {
              style = 'bg-green-50 border-green-300 text-green-800';
            } else if (correction?.wasSelected) {
              style = 'bg-red-100 border-red-500 text-red-900';
            }
          } else if (selectedOptionIds.includes(option.id)) {
            style = 'bg-blue-50 border-blue-500 text-blue-900 font-semibold';
          }

          return (
            <button
              key={option.id}
              onClick={() => handleSelectOption(option.id)}
              className={`w-full text-left p-4 rounded-lg border transition ${style}`}
            >
              {option.content}
            </button>
          );
        })}
      </div>

      {feedback && (
        <div className="p-4 rounded-lg bg-blue-50 border border-blue-200 mb-6">
          <p className="font-bold mb-1 text-sm text-blue-900">
            {feedback.isCorrect ? '✅ Bonne réponse !' : '❌ Mauvaise réponse'}
          </p>
          <p className="text-sm text-blue-800">{feedback.explanation}</p>
          {feedback.corrections.some((correction) => correction.explanation) && (
            <div className="mt-3 space-y-2 border-t border-blue-200 pt-3">
              {feedback.corrections
                .filter((correction) => correction.explanation)
                .map((correction) => (
                  <p key={correction.optionId} className="text-xs text-blue-900">
                    <strong>{correction.content} :</strong> {correction.explanation}
                  </p>
                ))}
            </div>
          )}
        </div>
      )}

      <div className="flex justify-end">
        {!feedback ? (
          <button
            onClick={handleSubmitAnswer}
            disabled={selectedOptionIds.length === 0 || submitting}
            className="bg-blue-600 text-white px-6 py-2.5 rounded-lg font-semibold hover:bg-blue-700 transition disabled:opacity-50"
          >
            {submitting ? 'Validation...' : 'Valider'}
          </button>
        ) : (
          <button
            onClick={handleNext}
            className="bg-green-600 text-white px-6 py-2.5 rounded-lg font-semibold hover:bg-green-700 transition"
          >
            {currentIndex + 1 < simulation.challenges.length ? 'Question suivante' : 'Voir le bilan'}
          </button>
        )}
      </div>
    </div>
  );
};