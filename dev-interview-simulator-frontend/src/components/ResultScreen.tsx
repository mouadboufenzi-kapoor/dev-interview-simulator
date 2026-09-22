import { useState } from 'react';
import type { SimulationResultDTO } from '../types';

interface Props {
  summary: SimulationResultDTO;
  onRestart: () => void;
}

export const ResultScreen = ({ summary, onRestart }: Props) => {
  const [openQuestionId, setOpenQuestionId] = useState<number | null>(null);

  const toggleAccordion = (id: number) => {
    setOpenQuestionId(openQuestionId === id ? null : id);
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return mins > 0 ? `${mins}m ${secs}s` : `${secs}s`;
  };

  return (
    <div className="max-w-2xl mx-auto p-6 bg-white rounded-xl shadow-md my-8">
      {/* En-tête */}
      <div className="text-center mb-6">
        <h1 className="text-3xl font-extrabold text-gray-800 mb-1">
          Simulation terminée !
        </h1>
        <p className="text-gray-500 text-sm">Voici le bilan détaillé de ta session</p>
      </div>

      {/* Carte des scores et métriques */}
      <div className="bg-gray-50 p-6 rounded-xl mb-6">
        <div className="text-center mb-4 border-b pb-4">
          <span className="text-xs text-gray-400 uppercase font-semibold">Taux de réussite</span>
          <p className="text-4xl font-black text-blue-600">{summary.successPercentage}%</p>
          <p className="text-sm text-gray-500 mt-1">
            {summary.totalScore} / {summary.maxPossibleScore} points obtenus
          </p>
        </div>

        <div className="grid grid-cols-2 gap-4 text-center">
          <div>
            <span className="text-xs text-gray-400 font-semibold uppercase">Bonnes réponses</span>
            <p className="text-lg font-bold text-gray-800">
              {summary.correctAnswersCount} / {summary.totalQuestions}
            </p>
          </div>
          <div>
            <span className="text-xs text-gray-400 font-semibold uppercase">Temps total</span>
            <p className="text-lg font-bold text-gray-800">
              {formatTime(summary.totalTimeSpentSeconds)}
            </p>
          </div>
        </div>
      </div>

      {/* Récapitulatif détaillé par question */}
      <div className="mb-6">
        <h2 className="text-lg font-bold text-gray-800 mb-3">Détail des questions</h2>
        <div className="space-y-3">
          {summary.questions.map((q, index) => {
            const isOpen = openQuestionId === q.challengeId;

            return (
              <div 
                key={q.challengeId} 
                className="border rounded-lg overflow-hidden transition-all bg-white"
              >
                {/* En-tête cliquable de l'accordéon */}
                <button
                  onClick={() => toggleAccordion(q.challengeId)}
                  className="w-full flex items-center justify-between p-4 text-left hover:bg-gray-50 transition"
                >
                  <div className="flex items-center space-x-3 pr-2">
                    <span 
                      className={`flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold text-white ${
                        q.isCorrect ? 'bg-green-500' : 'bg-red-500'
                      }`}
                    >
                      {q.isCorrect ? '✓' : '✕'}
                    </span>
                    <span className="font-semibold text-gray-800 text-sm">
                      {index + 1}. {q.title}
                    </span>
                  </div>
                  <span className="text-gray-400 text-xs font-semibold ml-2">
                    {isOpen ? '▲ Masquer' : '▼ Dépenses'}
                  </span>
                </button>

                {/* Contenu dépliable */}
                {isOpen && (
                  <div className="p-4 bg-gray-50 border-t text-sm space-y-3">
                    {q.context && (
                      <p className="text-gray-500 italic bg-white p-2 rounded border">
                        {q.context}
                      </p>
                    )}
                    
                    <p className="font-medium text-gray-900">{q.question}</p>

                    <div className="space-y-1">
                      <p className="text-xs text-gray-500">Ta réponse :</p>
                      <p className={`p-2 rounded font-medium ${
                        q.isCorrect 
                          ? 'bg-green-100 text-green-800 border border-green-200' 
                          : 'bg-red-100 text-red-800 border border-red-200'
                      }`}>
                        {q.userSelectedOptionContent}
                      </p>
                    </div>

                    {!q.isCorrect && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500">Bonne réponse attendue :</p>
                        <p className="p-2 rounded font-medium bg-green-50 text-green-800 border border-green-200">
                          {q.correctOptionContent}
                        </p>
                      </div>
                    )}

                    <div className="bg-blue-50 border border-blue-200 p-3 rounded text-blue-900 text-xs">
                      <span className="font-bold block mb-1">💡 Explication :</span>
                      {q.explanation}
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Bouton d'action */}
      <button
        onClick={onRestart}
        className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition shadow"
      >
        Lancer une nouvelle simulation
      </button>
    </div>
  );
};