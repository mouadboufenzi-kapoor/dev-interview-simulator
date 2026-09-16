import type { SimulationSummaryResponse } from '../types';

interface Props {
  summary: SimulationSummaryResponse;
  onRestart: () => void;
}

export const ResultScreen = ({ summary, onRestart }: Props) => {
  return (
    <div className="max-w-md mx-auto p-8 bg-white rounded-xl shadow-md my-10 text-center">
      <h1 className="text-3xl font-extrabold text-gray-800 mb-2">Simulation terminée !</h1>
      <p className="text-gray-500 mb-6">Voici le résumé de ta session</p>

      <div className="bg-gray-50 p-6 rounded-xl space-y-4 mb-6">
        <div>
          <span className="text-xs text-gray-400 uppercase font-semibold">Score Total</span>
          <p className="text-4xl font-black text-blue-600">{summary.totalScore} pts</p>
        </div>
        <div className="flex justify-around border-t pt-4">
          <div>
            <span className="text-xs text-gray-400 font-semibold">Bonnes réponses</span>
            <p className="text-lg font-bold text-gray-800">
              {summary.correctAnswers} / {summary.totalQuestions}
            </p>
          </div>
        </div>
      </div>

      <button
        onClick={onRestart}
        className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition"
      >
        Nouvelle simulation
      </button>
    </div>
  );
};