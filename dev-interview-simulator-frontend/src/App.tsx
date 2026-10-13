import { useState, useRef } from 'react';
import type {
  StartSimulationRequest,
  SimulationResponse,
  SimulationResultDTO,
  ChallengeType,
} from './types';
import { simulationApi } from './api/simulationApi';
import { SetupScreen } from './components/SetupScreen';
import { QuizScreen } from './components/QuizScreen';
import { useEffect } from 'react';
import { authApi } from './api/authApi';
import { ResultScreen } from './components/ResultScreen';
import { Navbar } from './components/common/Navbar';
import { Footer } from './components/common/Footer';
import { AlertCircle, X } from 'lucide-react';
import { UserDashboard } from './components/UserDashboard';
import { UserAccessModal, type AuthUser } from './components/UserAccessModal';
import { AdminDashboard } from './components/AdminDashboard';

type ScreenState = 'SETUP' | 'QUIZ' | 'RESULT' | 'DASHBOARD' | 'ADMIN';

export default function App() {
  const [screen, setScreen] = useState<ScreenState>('SETUP');
  const [selectedDashboardMode, setSelectedDashboardMode] = useState<ChallengeType>('SITUATIONAL_QCM');
  const [simulation, setSimulation] = useState<SimulationResponse | null>(null);
  const [summary, setSummary] = useState<SimulationResultDTO | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [user, setUser] = useState<AuthUser | null>(null);
  const [reviseCategoryIds, setReviseCategoryIds] = useState<number[] | null>(null);
  const [showAccessModal, setShowAccessModal] = useState(false);
  // Garde anti double-clic sur « Réviser » : évite deux démarrages simultanés.
  const reviseInFlight = useRef(false);
  // Nombre de simulations terminées par l'invité dans SA session (sessionStorage).
  // Côté backend, tous les invités partagent default_user : un compteur serveur
  // serait faussé — donc zéro architecture ajoutée, compteur local uniquement.
  const [guestSimulationCount, setGuestSimulationCount] = useState(() => {
    try {
      return Number(sessionStorage.getItem('guest_simulation_count')) || 0;
    } catch {
      return 0;
    }
  });

  useEffect(() => {
    const storedUser = localStorage.getItem('user');
    const token = localStorage.getItem('jwt_token');
    if (storedUser && token) {
      try {
        const parsed = JSON.parse(storedUser);
        setUser(parsed);
      } catch (e) {
        localStorage.removeItem('user');
        localStorage.removeItem('jwt_token');
      }
    }

    const handleAuthLogout = () => {
      setUser(null);
      setScreen('SETUP');
    };

    window.addEventListener('auth:logout', handleAuthLogout);
    return () => window.removeEventListener('auth:logout', handleAuthLogout);
  }, []);

  // Lancement unique de session (Setup, « Nouvelle simulation », Réviser).
  // Retourne true si le quiz a démarré : permet aux appelsants de basculer
  // vers l'écran de configuration en cas d'échec (repli).
  const handleStartSimulation = async (
    request: StartSimulationRequest,
    failureMessage =
      'Impossible de lancer la session. Veuillez vérifier que le serveur backend Spring Boot est actif sur le port 8080.'
  ): Promise<boolean> => {
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
      return true;
    } catch (err) {
      console.error(err);
      // Message serveur réel si disponible (le backend renvoie désormais de
      // vrais codes HTTP, donc Axios rejette) — plus fiable que le générique.
      const serverMessage = (err as { response?: { data?: { message?: string } } })
        ?.response?.data?.message;
      setError(serverMessage || failureMessage);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const handleFinishQuiz = async () => {
    if (!simulation) return;
    setLoading(true);
    setError(null);
    try {
      // Clore la session côté serveur (statut COMPLETED) AVANT le bilan :
      // sans cet appel la simulation resterait IN_PROGRESS en base et les
      // compteurs du dashboard afficheraient « 0 terminée ». Best-effort :
      // si la clôture échoue, le bilan reste affichable (/result ne dépend
      // pas du statut).
      try {
        await simulationApi.completeSimulation(simulation.id);
      } catch (completeErr) {
        console.error('Clôture de la simulation impossible', completeErr);
      }
      const data = await simulationApi.getSimulationResult(simulation.id);
      setSummary(data);
      setScreen('RESULT');
      if (!user) {
        setGuestSimulationCount((current) => {
          const next = current + 1;
          try {
            sessionStorage.setItem('guest_simulation_count', String(next));
          } catch {
            /* stockage indisponible : le compteur reste valable pour la session */
          }
          return next;
        });
      }
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch (err) {
      console.error(err);
      setError('Impossible de récupérer le compte-rendu de la simulation.');
    } finally {
      setLoading(false);
    }
  };

  // Quitter en cours de quiz : marque la session ABANDONNÉE (best-effort)
  // pour que les compteurs du dashboard reflètent la réalité. Seules les
  // sessions encore IN_PROGRESS basculent (jamais un bilan déjà consulté).
  const handleQuit = () => {
    if (screen === 'QUIZ' && simulation?.status === 'IN_PROGRESS') {
      simulationApi.abandonSimulation(simulation.id).catch((err) => {
        console.error('Abandon de la simulation impossible', err);
      });
    }
    handleRestart();
  };

  const handleRestart = () => {
    setSimulation(null);
    setSummary(null);
    setError(null);
    setScreen('SETUP');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleAuthenticated = (authenticatedUser: AuthUser) => {
    setUser(authenticatedUser);
    setSimulation(null);
    setSummary(null);
    setError(null);
    setScreen('DASHBOARD');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleOpenSetup = () => {
    setSimulation(null);
    setSummary(null);
    setError(null);
    setScreen('SETUP');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Réviser depuis le dashboard : lance directement une simulation CIBLÉE sur
  // la compétence — même moteur de création que l'écran Setup (mode QCM par
  // défaut, toutes difficultés pour maximiser le pool). Repli : écran de
  // configuration pré-pré-sélectionné si aucune question n'est disponible.
  const handleRevise = async (categoryIds: number[]) => {
    if (reviseInFlight.current) return;
    reviseInFlight.current = true;
    try {
      const started = await handleStartSimulation(
        { mode: 'SITUATIONAL_QCM', categoryIds },
        'Aucune question ciblée disponible pour cette compétence pour le moment. Vous pouvez préparer votre session manuellement.'
      );
      if (started) {
        setReviseCategoryIds(null);
      } else {
        setReviseCategoryIds(categoryIds);
        setSimulation(null);
        setSummary(null);
        setScreen('SETUP');
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    } finally {
      reviseInFlight.current = false;
    }
  };

  const handleOpenResult = async (simulationId: number) => {
    try {
      const data = await simulationApi.getSimulationResult(simulationId);
      setSummary(data);
      setScreen('RESULT');
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch (err) {
      setError('Impossible de récupérer le détail de cette simulation.');
    }
  };

  const handleLogout = () => {
    authApi.logout();
    setUser(null);
    handleRestart();
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
    <div className="relative min-h-screen flex flex-col overflow-x-clip bg-canvas watermark-pattern text-ink selection:bg-peach-500 selection:text-navy-900">
      {screen === 'SETUP' && (
        <div
          className="pointer-events-none absolute inset-0 z-0 hidden overflow-hidden lg:block"
          aria-hidden="true"
        >
        </div>
      )}

      {/* Editorial Sticky Navbar */}
      <Navbar
        currentScreen={screen}
        mode={simulation?.mode}
        difficulty={simulation?.difficulty}
        onQuit={handleQuit}
        onSelectMode={handleSelectNavbarMode}
        user={user}
        onAuthenticated={handleAuthenticated}
        onLogout={handleLogout}
        onOpenDashboard={() => setScreen('DASHBOARD')}
        onOpenAdmin={() => setScreen('ADMIN')}
      />

      {/* Main Content Area */}
      <main className="relative z-10 flex-1 w-full max-w-5xl mx-auto px-4 sm:px-6 py-6 sm:py-8 flex flex-col">
        {/* Soft Error Banner */}
        {error && (
          <div className="mb-6 p-4 rounded-2xl bg-danger-soft border border-danger-border text-danger text-sm flex items-start justify-between gap-3 shadow-[0_2px_10px_rgba(172,59,97,0.08)] animate-in fade-in duration-200">
            <div className="flex items-start gap-3">
              <AlertCircle className="w-5 h-5 text-crimson-700 flex-shrink-0 mt-0.5" />
              <div>
                <p className="font-semibold text-crimson-800">Erreur de communication</p>
                <p className="text-xs text-crimson-700 mt-0.5">{error}</p>
              </div>
            </div>
            <button
              onClick={() => setError(null)}
              className="text-crimson-700 hover:text-crimson-900 dark:hover:text-white p-1 rounded-md transition cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
              title="Fermer"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        )}

        {/* Dynamic Screen Transitions — key={screen} remounts this container on
            every navigation so .screen-transition (index.css) replays: short
            fade + subtle horizontal slide.
            min-w-0 lets the column shrink to the viewport so only inner scroll
            zones (e.g. the code block) scroll, instead of the whole screen
            stretching horizontally. */}
        <div key={screen} className="screen-transition flex-1 flex flex-col justify-center min-w-0">
          {screen === 'SETUP' && (
            <SetupScreen
              onStart={handleStartSimulation}
              loading={loading}
              activeMode={selectedDashboardMode}
              initialCategoryIds={reviseCategoryIds ?? undefined}
            />
          )}

          {screen === 'DASHBOARD' && user && (
            <UserDashboard
              user={user}
              onStartSimulation={handleOpenSetup}
              onRevise={handleRevise}
              onOpenResult={handleOpenResult}
            />
          )}

          {screen === 'ADMIN' && user?.role === 'ADMIN' && (
            <AdminDashboard />
          )}

          {screen === 'QUIZ' && simulation && (
            <QuizScreen
              simulation={simulation}
              onFinish={handleFinishQuiz}
              onError={setError}
            />
          )}

          {screen === 'RESULT' && summary && (
            <ResultScreen
              summary={summary}
              onRestart={handleRestart}
              onStart={handleStartSimulation}
              loading={loading}
              isGuest={user === null}
              guestSimulationCount={guestSimulationCount}
              onCreateAccount={() => setShowAccessModal(true)}
            />
          )}
        </div>
      </main>

      {/* Modal de création de compte — ouverte depuis le CTA invité du bilan.
          Navbar possède sa propre instance : l'overlay empêche les clics tant
          qu'une modale est ouverte, les deux ne peuvent donc pas se chevaucher. */}
      {showAccessModal && (
        <UserAccessModal
          onClose={() => setShowAccessModal(false)}
          onAuthenticated={(authenticatedUser) => {
            setShowAccessModal(false);
            handleAuthenticated(authenticatedUser);
          }}
        />
      )}

      {/* Discreet Editorial Footer */}
      <Footer />
    </div>
  );
}