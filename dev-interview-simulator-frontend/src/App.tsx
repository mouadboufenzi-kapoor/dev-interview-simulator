import { useState, useRef, useCallback } from 'react';
import type {
  StartSimulationRequest,
  SimulationResponse,
  SimulationResultDTO,
  ChallengeType,
  DifficultyLevel,
} from './types';
import { simulationApi } from './api/simulationApi';
import { userStatsApi } from './api/userStatsApi';
import {
  markGuestTestCompleted,
  pruneGuestSimulations,
  saveGuestSimulation,
} from './api/guestSimulations';
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
import { SettingsScreen } from './components/SettingsScreen';
import { LoadingNotice } from './components/common/LoadingNotice';
import { estimateLevel } from './utils/levelEstimation';
import {
  readPlacementSeenChallengeIds,
  savePlacementSeenChallengeIds,
} from './api/placementSeen';
import { trackEvent } from './api/events';

type ScreenState = 'SETUP' | 'QUIZ' | 'RESULT' | 'DASHBOARD' | 'ADMIN' | 'SETTINGS';

type LoadingAction = { message: string; detail: string };

const LOADING_REVISE: LoadingAction = {
  message: 'Préparation de votre révision en cours…',
  detail: 'Nous sélectionnons les questions adaptées à votre axe de travail.',
};

const LOADING_SIMULATION: LoadingAction = {
  message: 'Préparation de votre simulation en cours…',
  detail: 'La sélection des questions peut prendre quelques instants.',
};

const DIFFICULTY_ORDER: DifficultyLevel[] = ['JUNIOR', 'INTERMEDIATE', 'ADVANCED'];

// La plus élevée des deux difficultés (ignore les valeurs absentes).
const highestDifficulty = (
  first?: DifficultyLevel | null,
  second?: DifficultyLevel | null
): DifficultyLevel | undefined => {
  if (!first) return second ?? undefined;
  if (!second) return first;
  return DIFFICULTY_ORDER.indexOf(first) >= DIFFICULTY_ORDER.indexOf(second) ? first : second;
};

const LOADING_RESULT: LoadingAction = {
  message: 'Chargement de votre bilan en cours…',
  detail: 'Récupération du compte-rendu de votre session.',
};

export default function App() {
  const [screen, setScreen] = useState<ScreenState>('SETUP');
  const [selectedDashboardMode, setSelectedDashboardMode] = useState<ChallengeType>('SITUATIONAL_QCM');
  const [simulation, setSimulation] = useState<SimulationResponse | null>(null);
  const [summary, setSummary] = useState<SimulationResultDTO | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loadingAction, setLoadingAction] = useState<LoadingAction | null>(null);
  const [user, setUser] = useState<AuthUser | null>(null);
  const [authReady, setAuthReady] = useState(false);
  // Après un bilan, « Lancer une nouvelle session » doit retomber sur le choix
  // du type de challenge : le profil ne doit plus être demandé.
  const [skipProfileStepOnSetup, setSkipProfileStepOnSetup] = useState(false);
  const [reviseCategoryIds, setReviseCategoryIds] = useState<number[] | null>(null);
  const [reviseSkillIds, setReviseSkillIds] = useState<number[] | null>(null);
  const [showAccessModal, setShowAccessModal] = useState(false);
  const [accessModalInitialMode, setAccessModalInitialMode] = useState<'login' | 'register'>('login');
  const [accessModalGoogleFirst, setAccessModalGoogleFirst] = useState(false);
  const [isPlacementSimulation, setIsPlacementSimulation] = useState(false);
  const [setupInitialDifficulty, setSetupInitialDifficulty] = useState<DifficultyLevel | undefined>();
  // Niveau stocké du compte : sert à présélectionner la difficulté et à cibler
  // la révision. Reste nul pour un invité ou si l'appel échoue.
  const [accountLevel, setAccountLevel] = useState<DifficultyLevel | null>(null);
  // Garde anti double-clic sur « Réviser » : évite deux démarrages simultanés.
  const reviseInFlight = useRef(false);
  const resultInFlight = useRef(false);
  const landingTracked = useRef(false);
  const questionIndexRef = useRef<number | null>(null);
  const handleQuestionIndexChange = useCallback((index: number) => {
    questionIndexRef.current = index;
  }, []);
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
    if (!landingTracked.current) {
      landingTracked.current = true;
      trackEvent('landing_viewed');
    }
    pruneGuestSimulations();
    const storedUser = localStorage.getItem('user');
    const token = localStorage.getItem('jwt_token');
    if (storedUser && token) {
      try {
        const parsed = JSON.parse(storedUser);
        setUser(parsed);
        setScreen('DASHBOARD');
      } catch (e) {
        localStorage.removeItem('user');
        localStorage.removeItem('jwt_token');
      }
    }
    setAuthReady(true);

    const handlePageUnload = () => {
      if (screen === 'QUIZ' && simulation?.status === 'IN_PROGRESS') {
        simulationApi.abandonSimulationOnUnload(simulation.id, simulation.guestAccessToken);
        trackEvent('simulation_abandoned', {
          simulationId: simulation.id,
          mode: simulation.mode,
          difficulty: simulation.difficulty,
          questionIndex: questionIndexRef.current,
        });
      }
    };
    const handleVisibilityChange = () => {
      if (screen === 'QUIZ' && simulation?.status === 'IN_PROGRESS' && document.visibilityState === 'hidden') {
        simulationApi.abandonSimulationOnUnload(simulation.id, simulation.guestAccessToken);
        trackEvent('simulation_abandoned', {
          simulationId: simulation.id,
          mode: simulation.mode,
          difficulty: simulation.difficulty,
          questionIndex: questionIndexRef.current,
        });
      }
    };
    window.addEventListener('pagehide', handlePageUnload);
    window.addEventListener('visibilitychange', handleVisibilityChange);
    const handleAuthLogout = () => {
      setUser(null);
      setScreen('SETUP');
    };

    window.addEventListener('auth:logout', handleAuthLogout);
    return () => {
      window.removeEventListener('pagehide', handlePageUnload);
      window.removeEventListener('visibilitychange', handleVisibilityChange);
    };
  }, []);

  useEffect(() => {
    if (!user) {
      setAccountLevel(null);
      return;
    }
    let isMounted = true;
    userStatsApi.getLevel()
      .then((level) => {
        if (isMounted) setAccountLevel(level.currentLevel);
      })
      .catch(() => {
        if (isMounted) setAccountLevel(null);
      });
    return () => {
      isMounted = false;
    };
  }, [user]);

  // Lancement unique de session (Setup, « Nouvelle simulation », Réviser).
  // Retourne true si le quiz a démarré : permet aux appelsants de basculer
  // vers l'écran de configuration en cas d'échec (repli).
  const handleStartSimulation = async (
    request: StartSimulationRequest,
    failureMessage =
      'Impossible de lancer la session. Veuillez vérifier que le serveur backend Spring Boot est actif sur le port 8080.',
    pendingAction: LoadingAction = LOADING_SIMULATION
  ): Promise<boolean> => {
    setLoadingAction(pendingAction);
    setLoading(true);
    setError(null);
    try {
      const placementRequest = request.placement
        ? {
            ...request,
            excludeChallengeIds: readPlacementSeenChallengeIds(),
          }
        : request;
      const data = await simulationApi.startSimulation(placementRequest);

      if (!Array.isArray(data.challenges) || data.challenges.length === 0) {
        throw new Error('La session reçue ne contient aucune question.');
      }

      saveGuestSimulation(data);
      if (placementRequest.placement) {
        savePlacementSeenChallengeIds(
          data.challenges.map((challenge) => challenge.challengeId)
        );
      }
      trackEvent('simulation_started', {
        simulationId: data.id,
        mode: data.mode,
        difficulty: data.difficulty,
        metadata: request.placement ? { placement: true } : null,
      });
      setSimulation(data);
      setIsPlacementSimulation(Boolean(request.placement));
      setScreen('QUIZ');
      // Même mécanisme que goToSetup : sur mobile, un défilement lancé avant
      // le remplacement de l'écran est parfois abandonné — on le rejoue après
      // le rendu, en défilement instantané.
      if (window.matchMedia('(max-width: 639px)').matches) {
        window.requestAnimationFrame(() => {
          window.scrollTo({ top: 0, behavior: 'auto' });
        });
      } else {
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
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
      setLoadingAction(null);
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
      // Clôture côté serveur : best-effort, l'événement est émis quand même      // car le bilan peut s'afficher même si le statut serveur n'a pas changé.      try {
        await simulationApi.completeSimulation(simulation.id, simulation.guestAccessToken ?? undefined);
      } catch (completeErr) {
        console.error('Clôture de la simulation impossible', completeErr);
      }
      trackEvent('simulation_completed', {
        simulationId: simulation.id,
        mode: simulation.mode,
        difficulty: simulation.difficulty,
      });
      const data = await simulationApi.getSimulationResult(simulation.id, simulation.guestAccessToken ?? undefined);
      trackEvent('result_viewed', {
        simulationId: simulation.id,
        mode: simulation.mode,
        difficulty: simulation.difficulty,
      });
      setSummary(data);
      if (!user) markGuestTestCompleted();
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
      simulationApi.abandonSimulation(simulation.id, simulation.guestAccessToken).catch((err) => {
        console.error('Abandon de la simulation impossible', err);
      });
      trackEvent('simulation_abandoned', {
        simulationId: simulation.id,
        mode: simulation.mode,
        difficulty: simulation.difficulty,
        questionIndex: questionIndexRef.current,
      });
    }

    if (screen === 'QUIZ' && user) {
      setSimulation(null);
      setSummary(null);
      setError(null);
      setScreen('DASHBOARD');
      window.scrollTo({ top: 0, behavior: 'smooth' });
      return;
    }

    handleRestart();
  };

  // Sur mobile, un défilement lancé avant le remplacement de l'écran (page
  // longue → page courte) est parfois abandonné par le navigateur : on le
  // rejoue juste après le rendu, en défilement instantané.
  const scrollToTopAfterRender = () => {
    window.requestAnimationFrame(() => {
      window.scrollTo({ top: 0, behavior: 'auto' });
    });
  };

  const goToSetup = ({ skipProfile = false }: { skipProfile?: boolean } = {}) => {
    setSimulation(null);
    setSummary(null);
    setError(null);
    setSkipProfileStepOnSetup(skipProfile);
    setScreen('SETUP');
    scrollToTopAfterRender();
  };

  // Depuis le bilan ou un abandon : toujours le choix du challenge.
  const handleRestart = () => goToSetup({ skipProfile: true });

  const handleHome = () => {
    if (user) {
      setSimulation(null);
      setSummary(null);
      setError(null);
      setScreen('DASHBOARD');
      window.scrollTo({ top: 0, behavior: 'smooth' });
      return;
    }
    goToSetup();
  };

  const handleAuthenticated = (authenticatedUser: AuthUser) => {
    setUser(authenticatedUser);
    if (screen === 'RESULT' && simulation) {
      simulationApi.getSimulationResult(simulation.id)
        .then((data) => {
          setSummary(data);
          setScreen('RESULT');
          window.scrollTo({ top: 0, behavior: 'smooth' });
        })
        .catch((err) => {
          console.error('Rafraîchissement du bilan après authentification impossible', err);
          setScreen('RESULT');
        });
      return;
    }
    setSimulation(null);
    setSummary(null);
    setError(null);
    setScreen('DASHBOARD');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleOpenSetup = () => {
    setSetupInitialDifficulty(undefined);
    goToSetup();
  };

  const handleContinuePlacement = () => {
    if (!summary) return;
    const level = estimateLevel(
      [{ difficulty: summary.difficulty, answered: summary.totalQuestions, correct: summary.correctAnswersCount }],
      1
    );
    const difficulty: DifficultyLevel =
      level == null || level.index <= 1
        ? 'JUNIOR'
        : level.index <= 3
          ? 'INTERMEDIATE'
          : 'ADVANCED';
    setSetupInitialDifficulty(difficulty);
    goToSetup({ skipProfile: true });
  };

  // Page Paramètres (profil + apparence) — accessible depuis le menu utilisateur.
  const handleOpenSettings = () => {
    setScreen('SETTINGS');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Réviser depuis le dashboard : lance directement une simulation CIBLÉE sur
  // la compétence — même moteur de création que l'écran Setup (mode QCM par
  // défaut, toutes difficultés pour maximiser le pool). Repli : écran de
  // configuration pré-pré-sélectionné si aucune question n'est disponible.
  const handleRevise = async (
    filters: { categoryIds?: number[]; skillIds?: number[]; difficulty?: DifficultyLevel }
  ) => {
    if (reviseInFlight.current) return;
    reviseInFlight.current = true;
    // Difficulté la plus élevée entre le niveau du compte et celle de la
    // simulation d'où vient le point faible (si elle est connue).
    const difficulty = highestDifficulty(accountLevel, filters.difficulty);
    try {
      const started = await handleStartSimulation(
        { mode: 'SITUATIONAL_QCM', ...filters, difficulty },
        'Aucune question ciblée disponible pour cette compétence pour le moment. Vous pouvez préparer votre session manuellement.',
        LOADING_REVISE
      );
      if (started) {
        setReviseCategoryIds(null);
        setReviseSkillIds(null);
      } else {
        setReviseCategoryIds(filters.categoryIds ?? null);
        setReviseSkillIds(filters.skillIds ?? null);
        goToSetup();
      }
    } finally {
      reviseInFlight.current = false;
    }
  };

  const handleOpenResult = async (simulationId: number) => {
    if (resultInFlight.current) return;
    resultInFlight.current = true;
    setLoadingAction(LOADING_RESULT);
    setError(null);
    try {
      const data = await simulationApi.getSimulationResult(simulationId);
      trackEvent('result_viewed', {
        simulationId: data.simulationId,
        mode: data.mode,
        difficulty: data.difficulty,
      });
      setSummary(data);
      setScreen('RESULT');
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch (err) {
      setError('Impossible de récupérer le détail de cette simulation.');
    } finally {
      resultInFlight.current = false;
      setLoadingAction(null);
    }
  };

  const handleLogout = () => {
    authApi.logout();
    setUser(null);
    goToSetup();
  };

  const handleSelectNavbarMode = (mode: ChallengeType) => {
    setSelectedDashboardMode(mode);
    if (screen !== 'SETUP') {
      setSimulation(null);
      setSummary(null);
      setScreen('SETUP');
    }
  };

  if (!authReady) {
    return null;
  }

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
        onOpenSettings={handleOpenSettings}
        onOpenAdmin={() => setScreen('ADMIN')}
      />

      {/* Main Content Area */}
      <main className="relative z-10 flex-1 w-full max-w-5xl mx-auto px-4 sm:px-6 py-3 sm:py-4 flex flex-col">
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
        <div key={screen} className="screen-transition flex-1 flex flex-col min-w-0">
          {screen === 'SETUP' && (
            <SetupScreen
              onStart={handleStartSimulation}
              onLogin={() => {
                setAccessModalInitialMode('login');
                setAccessModalGoogleFirst(false);
                setShowAccessModal(true);
              }}
              loading={loading}
              activeMode={selectedDashboardMode}
              initialCategoryIds={reviseCategoryIds ?? undefined}
              initialSkillIds={reviseSkillIds ?? undefined}
              skipProfileSelection={user !== null || skipProfileStepOnSetup}
              initialDifficulty={setupInitialDifficulty}
              accountDifficulty={accountLevel ?? undefined}
              onBack={handleHome}
              isGuest={user === null}
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

          {screen === 'SETTINGS' && user && (
            <SettingsScreen user={user} />
          )}

          {screen === 'QUIZ' && simulation && (
            <QuizScreen
              simulation={simulation}
              onFinish={handleFinishQuiz}
              onError={setError}
              finishing={loading}
              onQuestionIndexChange={handleQuestionIndexChange}
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
              onCreateAccount={() => {
                setAccessModalInitialMode('register');
                setAccessModalGoogleFirst(false);
                setShowAccessModal(true);
              }}
              isPlacement={isPlacementSimulation}
              onContinuePlacement={handleContinuePlacement}
              onBack={handleHome}
            />
          )}
        </div>
      </main>

      {loadingAction && (
        <LoadingNotice overlay message={loadingAction.message} detail={loadingAction.detail} />
      )}

      {/* Modal de création de compte — ouverte depuis le CTA invité du bilan.
          Navbar possède sa propre instance : l'overlay empêche les clics tant
          qu'une modale est ouverte, les deux ne peuvent donc pas se chevaucher. */}
      {showAccessModal && (
        <UserAccessModal
          initialMode={accessModalInitialMode}
          googleFirst={accessModalGoogleFirst}
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