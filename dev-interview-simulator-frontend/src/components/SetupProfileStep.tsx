import { ArrowRight } from 'lucide-react';
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
}

export const SetupProfileStep = ({ onPlacement, onPersonalize }: Props) => (
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
      </div>

      <section className="w-full max-w-3xl rounded border-2 border-border bg-card p-5 text-left shadow-card sm:p-6">
        <h2 className="font-serif text-xl font-bold text-text">
          Teste ton niveau en développement backend
        </h2>
        <p className="mt-2 text-sm text-muted">
          Java · Spring Boot · SQL · API
        </p>
        <p className="mt-3 text-xs text-ink-secondary">
          5 questions · 3 minutes · niveau estimé à la fin
        </p>
        <Button
          type="button"
          variant="primary"
          size="lg"
          rightIcon={<ArrowRight className="w-4 h-4" />}
          fullWidth
          onClick={onPlacement}
          className="mt-5 sm:w-auto"
        >
          Commencer
        </Button>
        <button
          type="button"
          onClick={onPersonalize}
          className="mt-4 block text-sm text-link underline cursor-pointer mx-auto"
        >
          Personnaliser ma simulation
        </button>
      </section>
    </div>
  </div>
);
