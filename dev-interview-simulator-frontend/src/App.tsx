import { useState } from 'react';
import type {
  StartSimulationRequest,
  SimulationResponse,
  SimulationResultDTO,
  ChallengeType,
} from './types';
import { simulationApi } from './api/simulationApi';
import { SetupScreen } from './components/SetupScreen';
import { QuizScreen } from './components/QuizScreen';
import { ResultScreen } from './components/ResultScreen';
import { Navbar } from './components/common/Navbar';
import { Footer } from './components/common/Footer';
import { AlertCircle, X } from 'lucide-react';

type ScreenState = 'SETUP' | 'QUIZ' | 'RESULT';

export default function App() {
  const [screen, setScreen] = useState<ScreenState>('SETUP');
  const [selectedDashboardMode, setSelectedDashboardMode] = useState<ChallengeType>('SITUATIONAL_QCM');
  const [simulation, setSimulation] = useState<SimulationResponse | null>(null);
  const [summary, setSummary] = useState<SimulationResultDTO | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleStartSimulation = async (request: StartSimulationRequest) => {
    setLoading(true);
    setError(null);
    try {
      const data = await simulationApi.startSimulation(request);

      if (!Array.isArray(data.challenges) || data.challenges.length === 0) {
        throw new Error('La session reçue ne contient aucune question.');
      }

      setSimulation(data);
      setScreen('QUIZ');
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch (err) {
      console.error(err);
      setError(
        'Impossible de lancer la session. Veuillez vérifier que le serveur backend Spring Boot est actif sur le port 8080.'
      );
    } finally {
      setLoading(false);
    }
  };

  const handleFinishQuiz = async () => {
    if (!simulation) return;
    setLoading(true);
    setError(null);
    try {
      const data = await simulationApi.getSimulationResult(simulation.id);
      setSummary(data);
      setScreen('RESULT');
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch (err) {
      console.error(err);
      setError('Impossible de récupérer le compte-rendu de la simulation.');
    } finally {
      setLoading(false);
    }
  };

  const handleRestart = () => {
    setSimulation(null);
    setSummary(null);
    setError(null);
    setScreen('SETUP');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleSelectNavbarMode = (mode: ChallengeType) => {
    setSelectedDashboardMode(mode);
    if (screen !== 'SETUP') {
      setSimulation(null);
      setSummary(null);
      setScreen('SETUP');
    }
  };

  return (
    <div className="min-h-screen flex flex-col bg-white watermark-pattern text-[#102136] selection:bg-[#EDC7B7] selection:text-[#123C69] relative">
      {/* Editorial Sticky Navbar */}
      <Navbar
        currentScreen={screen}
        mode={simulation?.mode}
        difficulty={simulation?.difficulty}
        onQuit={handleRestart}
        onSelectMode={handleSelectNavbarMode}
      />

      {/* Main Content Area */}
      <main className="flex-1 w-full max-w-5xl mx-auto px-4 sm:px-6 py-6 sm:py-8 flex flex-col">
        {/* Soft Error Banner */}
        {error && (
          <div className="mb-6 p-4 rounded-2xl bg-[#FDF2F2] border border-[#F3BEBE] text-[#9C2727] text-sm flex items-start justify-between gap-3 shadow-[0_2px_8px_rgba(172,59,97,0.08)] animate-in fade-in duration-200">
            <div className="flex items-start gap-3">
              <AlertCircle className="w-5 h-5 text-[#AC3B61] flex-shrink-0 mt-0.5" />
              <div>
                <p className="font-semibold text-[#8C294A]">Erreur de communication</p>
                <p className="text-xs text-[#AC3B61] mt-0.5">{error}</p>
              </div>
            </div>
            <button
              onClick={() => setError(null)}
              className="text-[#AC3B61] hover:text-[#6D1B37] p-1 rounded-md transition cursor-pointer"
              title="Fermer"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        )}

        {/* Dynamic Screen Transitions */}
        <div className="flex-1 flex flex-col justify-center">
          {screen === 'SETUP' && (
            <SetupScreen
              onStart={handleStartSimulation}
              loading={loading}
              activeMode={selectedDashboardMode}
            />
          )}

          {screen === 'QUIZ' && simulation && (
            <QuizScreen
              simulation={simulation}
              onFinish={handleFinishQuiz}
              onError={setError}
            />
          )}

          {screen === 'RESULT' && summary && (
            <ResultScreen summary={summary} onRestart={handleRestart} />
          )}
        </div>
      </main>

      {/* Discreet Editorial Footer */}
      <Footer />
    </div>
  );
}