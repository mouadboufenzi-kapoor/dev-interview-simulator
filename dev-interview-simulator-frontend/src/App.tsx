import { useState } from 'react';
import type {
  StartSimulationRequest,
  SimulationResponse,
  SimulationResultDTO,
} from './types';
import { simulationApi } from './api/simulationApi';
import { SetupScreen } from './components/SetupScreen';
import { QuizScreen } from './components/QuizScreen';
import { ResultScreen } from './components/ResultScreen';

type ScreenState = 'SETUP' | 'QUIZ' | 'RESULT';

export default function App() {
  const [screen, setScreen] = useState<ScreenState>('SETUP');
  const [simulation, setSimulation] = useState<SimulationResponse | null>(null);
  const [summary, setSummary] = useState<SimulationResultDTO | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleStartSimulation = async (request: StartSimulationRequest) => {
    setLoading(true);
    setError(null);
    try {
      const data = await simulationApi.startSimulation(request);
      setSimulation(data);
      setScreen('QUIZ');
    } catch (err) {
      console.error(err);
      setError('Impossible de démarrer la simulation. Vérifie que le backend est lancé.');
    } finally {
      setLoading(false);
    }
  };

  const handleFinishQuiz = async () => {
    if (!simulation) return;
    setLoading(true);
    try {
      const data = await simulationApi.getSimulationResult(simulation.id);
      setSummary(data);
      setScreen('RESULT');
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleRestart = () => {
    setSimulation(null);
    setSummary(null);
    setScreen('SETUP');
  };

  return (
    <div className="min-h-screen bg-gray-100 py-10 px-4">
      <header className="max-w-3xl mx-auto mb-8 text-center">
        <h1 className="text-3xl font-black text-gray-900 tracking-tight">
          Dev Interview Simulator
        </h1>
        <p className="text-sm text-gray-500 mt-1">
          Prépare tes entretiens techniques en conditions réelles
        </p>
      </header>

      {error && (
        <div className="max-w-2xl mx-auto mb-6 p-4 bg-red-100 border border-red-300 text-red-800 rounded-lg text-sm text-center">
          {error}
        </div>
      )}

      {screen === 'SETUP' && (
        <SetupScreen onStart={handleStartSimulation} loading={loading} />
      )}

      {screen === 'QUIZ' && simulation && (
        <QuizScreen simulation={simulation} onFinish={handleFinishQuiz} />
      )}

      {screen === 'RESULT' && summary && (
        <ResultScreen summary={summary} onRestart={handleRestart} />
      )}
    </div>
  );
}