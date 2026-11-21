import { ArrowRight, BriefcaseBusiness } from 'lucide-react';
import { Button } from './common/Button';
import { StatTiles, type StatItem } from './common/StatTiles';

export const CHALLENGE_TAGS = ['QCM', 'Code review', 'Mises en situation'];

export const COMMERCIAL_STATS: readonly StatItem[] = [
  { value: 8000, suffix: '+', label: 'Questions' },
  { value: 100, suffix: '+', label: 'Utilisateurs' },
  { value: 4, label: 'Challenges' },
];

interface Props {
  onPlacement: () => void;
  onPersonalize: () => void;
  onLogin: () => void;
}

export const SetupProfileStep = ({ onPlacement, onPersonalize, onLogin }: Props) => (
  <div className="screen-transition relative w-full flex flex-col items-center pt-7 pb-4 sm:pt-10 sm:pb-6 px-4">
    <div className="w-full max-w-4xl mx-auto space-y-10 sm:space-y-12 text-center">
      <div className="space-y-6">
        <h1 className="mx-auto font-serif font-bold text-brand text-center leading-[1.12] tracking-[-0.02em] text-[clamp(24px,8vw,58px)] [text-wrap:balance] mb-[0.5em]">
          Réussissez vos <span className="hero-hl">entretiens techniques.</span>
        </h1>
        <p className="text-sm sm:text-base text-muted font-sans max-w-lg mx-auto leading-relaxed">
          Des exercices inspirés de situations réelles : en Java, Spring Boot, Full Stack, base de données et bien plus.
        </p>
        <ul className="flex flex-wrap items-center justify-center gap-1.5 sm:gap-3" aria-label="Types de challenges">
          {CHALLENGE_TAGS.map((tag) => (
            <li
              key={tag}
              className="whitespace-nowrap rounded-full border-2 border-brand bg-white px-2 py-1 text-xs font-semibold text-text shadow-card dark:bg-card sm:px-3 sm:py-1.5 sm:text-[15px]"
            >
              {tag}
            </li>
          ))}
        </ul>
        <StatTiles items={[...COMMERCIAL_STATS]} className="my-5 sm:my-6" />
        <section className="w-full rounded border-2 border-border bg-card p-5 text-left shadow-card sm:grid sm:grid-cols-2 sm:items-center sm:gap-6">
          <div>
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded border-2 border-border bg-bg text-muted">
                <BriefcaseBusiness className="h-4 w-4 stroke-[2]" />
              </div>
              <span className="rounded border-2 border-border bg-selected px-2 py-1 font-mono text-[10px] uppercase tracking-[0.06em] text-text shadow-card">
                Disponible
              </span>
            </div>
            <h2 className="mt-3 font-serif text-xl font-bold text-text">
              Développeur
            </h2>
            <p className="mt-3 text-sm text-muted">
              Teste-toi en 4 minutes et découvre ton niveau.
            </p>
          </div>
          <div className="mt-3 flex flex-col items-center sm:mt-0">
            <Button
              type="button"
              variant="primary"
              size="lg"
              rightIcon={<ArrowRight className="w-4 h-4" />}
              onClick={onPlacement}
              className="w-full sm:w-[300px]"
            >
              Tester mon niveau
            </Button>
            <button
              type="button"
              onClick={onPersonalize}
              className="mt-3 block min-h-11 text-xs text-link underline cursor-pointer"
            >
              Configurer mon entraînement →
            </button>
            <div className="mt-3 w-full border-t border-border pt-[10px] text-center text-xs text-ink-secondary sm:mt-0">
              Déjà un compte ?{' '}
              <button
                type="button"
                onClick={onLogin}
                className="min-h-11 text-link underline cursor-pointer"
              >
                Se connecter
              </button>
            </div>
          </div>
        </section>
      </div>
    </div>
  </div>
);
