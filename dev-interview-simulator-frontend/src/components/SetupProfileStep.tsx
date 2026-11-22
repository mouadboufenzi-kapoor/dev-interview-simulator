import { StatTiles, type StatItem } from './common/StatTiles';
import { ProgramSection } from './ProgramSection';
import { useHasCompletedGuestTest } from '../hooks/useHasCompletedGuestTest';

export const COMMERCIAL_STATS: readonly StatItem[] = [
  { value: 9000, suffix: '+', label: 'Questions' },
  { value: 100, suffix: '+', label: 'Utilisateurs' },
  { value: 4, label: 'Challenges' },
];

interface Props {
  onPlacement: () => void;
  onPersonalize: () => void;
  onLogin: () => void;
  isGuest: boolean;
}

interface StepCopy {
  description: string;
  placementLabel: string;
}

const COPY: Record<'default' | 'returning', StepCopy> = {
  default: {
    description: 'Teste-toi et découvre ton niveau actuel.',
    placementLabel: 'Tester mon niveau',
  },
  returning: {
    description: 'Pas convaincu du résultat ? Retente ta chance.',
    placementLabel: 'Retenter le test',
  },
};

export const SetupProfileStep = ({ onPlacement, onPersonalize, onLogin, isGuest }: Props) => {
  const hasCompletedTest = useHasCompletedGuestTest();
  const copy = COPY[hasCompletedTest ? 'returning' : 'default'];

  return (
  <div className="screen-transition relative w-full flex flex-col items-center pt-4 pb-4 sm:pt-10 sm:pb-6 px-4 md:px-6 md:pt-14 md:pb-0">
    <div className="w-full max-w-4xl mx-auto space-y-10 sm:space-y-12 text-center md:max-w-[1120px] md:space-y-0 md:text-left">
      <div className="md:grid md:grid-cols-2 md:items-center md:gap-14">
        <div className="space-y-6">
          <h1 className="mx-auto font-serif font-bold text-brand text-center leading-[1.12] tracking-[-0.02em] text-[clamp(24px,8vw,58px)] [text-wrap:balance] mb-[0.95em] md:mb-0 md:text-left md:text-[clamp(36px,5vw,56px)]">
            Réussissez vos <span className="hero-hl md:text-[clamp(30px,4.4vw,50px)]">entretiens techniques.</span>
          </h1>
          <p className="text-sm sm:text-base text-muted font-sans max-w-lg mx-auto leading-relaxed max-sm:-mt-2 md:mx-0 md:mt-[26px] md:max-w-[520px] md:text-[19px] md:leading-[1.55]">
            Des exercices inspirés de situations réelles : en <b>Java</b>, <b>Spring Boot</b>, <b>Full Stack</b>, <b>Base de données</b>, <b>DevOps</b> et bien plus.
          </p>
          <StatTiles items={[...COMMERCIAL_STATS]} className="my-6 sm:my-6 md:mt-[30px] md:max-w-[520px]" />
        </div>
        <div className="max-sm:mt-8">
        <section className="box-border w-full max-w-full rounded-[6px] border-2 border-[#0a2342] bg-white p-4 text-left shadow-[6px_6px_0_#ff5a2f] dark:border-border dark:bg-card dark:shadow-[6px_6px_0_var(--color-shadow)] md:mx-auto md:max-w-[460px] md:p-7">
          <div className="flex items-center gap-3">
            <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-[6px] border-2 border-[#0a2342] bg-[#eaeef5] text-[#0a2342] md:h-9 md:w-9">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#0a2342" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                <rect x="3" y="7" width="18" height="13" rx="2" />
                <path d="M9 7V4h6v3" />
              </svg>
            </div>
            <h2 className="min-w-0 flex-1 truncate font-serif text-[24px] font-bold leading-none text-[#0a2342] dark:text-text md:text-[26px]">
              Développeur
            </h2>
            <span className="flex-none whitespace-nowrap rounded border-2 border-[#0a2342] bg-[#d6e0f0] px-1 py-[2px] font-mono text-[9px] uppercase tracking-[0.04em] text-[#0a2342] md:px-1.5 md:py-[3px] md:text-[11px] md:tracking-[0.06em]">
              Disponible
            </span>
          </div>
          <p className="mt-2.5 text-[13px] font-normal leading-[1.5] text-[#52647a] dark:text-muted md:text-[15px]">
            {copy.description}
          </p>
          <ul className="mt-3 flex items-center gap-5 text-[13px] font-bold text-[#0a2342] dark:text-text md:text-[14px]">
            <li className="flex items-center gap-1.5">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ff5a2f" strokeWidth={2.2} strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                <path d="M8 6h12M8 12h12M8 18h12M4 6h.01M4 12h.01M4 18h.01" />
              </svg>
              <span>6 questions</span>
            </li>
            <li className="flex items-center gap-1.5">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ff5a2f" strokeWidth={2.2} strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                <circle cx="12" cy="12" r="9" />
                <path d="M12 7v5l3 2" />
              </svg>
              <span>4 minutes</span>
            </li>
          </ul>
          <div className="mt-4 box-border flex flex-col">
            <button
              type="button"
              onClick={onPlacement}
              className="box-border flex h-[52px] w-full max-w-full items-center justify-between rounded border-2 border-[#0a2342] bg-[#ff5a2f] px-5 text-[15px] font-bold text-white text-relief shadow-[3px_3px_0_#0a2342] md:h-[60px] md:text-[18px]"
            >
              {copy.placementLabel}
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5} strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                <path d="M5 12h14M13 6l6 6-6 6" />
              </svg>
            </button>
            <button
              type="button"
              onClick={onPersonalize}
              className="mt-2.5 box-border flex h-[46px] w-full max-w-full items-center justify-start gap-2.5 rounded border-2 border-[#0a2342] bg-white px-5 text-[14px] font-bold text-[#0a2342] md:h-[50px] md:text-[16px]"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#0a2342" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                <path d="M4 7h10M18 7h2M4 17h2M10 17h10" />
                <circle cx="16" cy="7" r="2" />
                <circle cx="8" cy="17" r="2" />
              </svg>
              <span>Configurer mon entraînement</span>
            </button>
          </div>
        </section>
        {isGuest && (
          <div className="mt-[18px] text-center text-sm text-[#52647a] dark:text-muted sm:text-base">
            Déjà un compte ?{' '}
            <button
              type="button"
              onClick={onLogin}
              className="min-h-11 text-[#0a2342] underline cursor-pointer dark:text-brand"
            >
              Se connecter
            </button>
          </div>
        )}
        </div>
      </div>
      <ProgramSection />
    </div>
  </div>
  );
};
