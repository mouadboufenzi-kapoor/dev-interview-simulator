import { useState } from 'react';
import type { SimulationResponse, SubmitAnswerResponse } from '../types';
import { simulationApi } from '../api/simulationApi';

interface Props {
  simulation: SimulationResponse;
  onFinish: () => void;
}

export const QuizScreen = ({ simulation, onFinish }: Props) => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedOptionId, setSelectedOptionId] = useState<number | null>(null);
  const [feedback, setFeedback] = useState<SubmitAnswerResponse | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const currentChallenge = simulation.challenges[currentIndex];

  const handleSelectOption = (optionId: number) => {
    if (feedback) return; // Empêche le changement après validation
    setSelectedOptionId(optionId);
  };

  const handleSubmitAnswer = async () => {
    if (!selectedOptionId || !currentChallenge) return;

    setSubmitting(true);
    try {
      const res = await simulationApi.submitAnswer(simulation.id, {
        simulationChallengeId: currentChallenge.simulationChallengeId,
        selectedOptionId,
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
    setSelectedOptionId(null);
    if (currentIndex + 1 < simulation.challenges.length) {
      setCurrentIndex((prev) => prev + 1);
    } else {
      onFinish();
    }
  };

  return (
    <div className="max-w-3xl mx-auto p-6 bg-white rounded-xl shadow-md my-10">
      <div className="flex justify-between items-center mb-6 pb-4 border-b">
        <span className="text-sm font-semibold text-gray-500">
          Question {currentIndex + 1} / {simulation.challenges.length}
        </span>
        <span className="text-sm font-bold text-blue-600">
          Score : {feedback ? feedback.totalSimulationScore : simulation.totalScore} pts
        </span>
      </div>

      <h2 className="text-xl font-bold mb-3 text-gray-800">{currentChallenge.title}</h2>
      {currentChallenge.context && (
        <p className="text-sm text-gray-600 bg-gray-50 p-3 rounded-lg mb-4 italic">
          {currentChallenge.context}
        </p>
      )}
      <p className="text-base text-gray-700 mb-6 font-medium">{currentChallenge.question}</p>

      <div className="space-y-3 mb-6">
        {currentChallenge.options.map((option) => {
          let style = 'bg-gray-50 border-gray-200 text-gray-800 hover:bg-gray-100';

          if (feedback) {
            if (option.id === feedback.correctOptionId) {
              style = 'bg-green-100 border-green-500 text-green-900 font-semibold';
            } else if (option.id === selectedOptionId && !feedback.isCorrect) {
              style = 'bg-red-100 border-red-500 text-red-900';
            }
          } else if (selectedOptionId === option.id) {
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
        </div>
      )}

      <div className="flex justify-end">
        {!feedback ? (
          <button
            onClick={handleSubmitAnswer}
            disabled={!selectedOptionId || submitting}
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