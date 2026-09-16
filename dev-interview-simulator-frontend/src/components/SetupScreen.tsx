import { useState, useEffect } from 'react';
import type { Category, ChallengeType, DifficultyLevel, StartSimulationRequest } from '../types';
import { simulationApi } from '../api/simulationApi';

interface Props {
  onStart: (request: StartSimulationRequest) => void;
  loading: boolean;
}

export const SetupScreen = ({ onStart, loading }: Props) => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [selectedMode, setSelectedMode] = useState<ChallengeType>('SITUATIONAL_QCM');
  const [selectedDifficulty, setSelectedDifficulty] = useState<DifficultyLevel>('JUNIOR');
  const [selectedCategoryIds, setSelectedCategoryIds] = useState<number[]>([]);

  useEffect(() => {
    simulationApi.getCategories().then(setCategories).catch(console.error);
  }, []);

  const toggleCategory = (id: number) => {
    setSelectedCategoryIds((prev) =>
      prev.includes(id) ? prev.filter((catId) => catId !== id) : [...prev, id]
    );
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onStart({
      mode: selectedMode,
      difficulty: selectedDifficulty,
      categoryIds: selectedCategoryIds.length > 0 ? selectedCategoryIds : undefined,
    });
  };

  return (
    <div className="max-w-2xl mx-auto p-6 bg-white rounded-xl shadow-md my-10">
      <h1 className="text-2xl font-bold mb-6 text-gray-800">Démarrer un entraînement</h1>
      <form onSubmit={handleSubmit} className="space-y-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Mode de jeu</label>
          <select
            value={selectedMode}
            onChange={(e) => setSelectedMode(e.target.value as ChallengeType)}
            className="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500"
          >
            <option value="SITUATIONAL_QCM">QCM Situationnel</option>
            <option value="CODE_REVIEW">Code Review</option>
            <option value="ARCHITECTURE">Architecture</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Niveau de difficulté</label>
          <div className="flex gap-4">
            {(['JUNIOR', 'INTERMEDIATE', 'ADVANCED'] as DifficultyLevel[]).map((level) => (
              <button
                key={level}
                type="button"
                onClick={() => setSelectedDifficulty(level)}
                className={`flex-1 py-2 rounded-lg border text-sm font-medium transition ${
                  selectedDifficulty === level
                    ? 'bg-blue-600 text-white border-blue-600'
                    : 'bg-gray-50 border-gray-300 text-gray-700 hover:bg-gray-100'
                }`}
              >
                {level}
              </button>
            ))}
          </div>
        </div>

        {categories.length > 0 && (
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Catégories (optionnel)
            </label>
            <div className="flex flex-wrap gap-2">
              {categories.map((cat) => (
                <button
                  key={cat.id}
                  type="button"
                  onClick={() => toggleCategory(cat.id)}
                  className={`px-3 py-1.5 rounded-full text-xs font-medium border transition ${
                    selectedCategoryIds.includes(cat.id)
                      ? 'bg-blue-100 text-blue-800 border-blue-300'
                      : 'bg-gray-100 text-gray-600 border-gray-200 hover:bg-gray-200'
                  }`}
                >
                  {cat.name}
                </button>
              ))}
            </div>
          </div>
        )}

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition disabled:opacity-50"
        >
          {loading ? 'Chargement...' : 'Lancer la simulation'}
        </button>
      </form>
    </div>
  );
};