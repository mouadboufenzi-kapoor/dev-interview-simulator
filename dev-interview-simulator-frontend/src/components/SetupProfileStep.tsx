import { BriefcaseBusiness, Cloud, ClipboardCheck } from 'lucide-react';
import { StatTiles, type StatItem } from './common/StatTiles';

export interface ProfileCardConfig {
  id: string;
  title: string;
  description: string;
  icon: typeof BriefcaseBusiness;
  available: boolean;
}

export const PROFILES: ProfileCardConfig[] = [
  {
    id: 'developer',
    title: 'Développeur',
    description: 'Code, conception et résolution de problèmes techniques.',
    icon: BriefcaseBusiness,
    available: true,
  },
  {
    id: 'devops-cloud',
    title: 'DevOps / Cloud',
    description: 'Infrastructure, déploiement et fiabilité des services.',
    icon: Cloud,
    available: false,
  },
  {
    id: 'qa-testing',
    title: 'QA / Testing',
    description: 'Qualité logicielle, automatisation et stratégies de test.',
    icon: ClipboardCheck,
    available: false,
  },
];

const CHALLENGE_TAGS = ['QCM', 'Code review', 'Mises en situation', 'Raisonnement séquentiel'];

const STATS: StatItem[] = [
  { value: 8000, suffix: '+', label: 'Questions' },
  { value: 100, suffix: '+', label: 'Utilisateurs' },
  { value: 4, label: 'Challenges' },
];

interface Props {
  selectedProfile: string | null;
  onSelect: (profileId: string) => void;
}

export const SetupProfileStep = ({ selectedProfile, onSelect }: Props) => (
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
          {CHALLENGE_TAGS.map((tag, index) => (
            <li
              key={tag}
              /* Mobile : 3 pastilles suffisent pour laisser la carte
                 Développeur visible ; la 4e n'apparaît qu'à partir de sm. */
              className={`whitespace-nowrap rounded-full border-2 border-brand bg-white px-2 py-1 text-xs font-semibold text-text shadow-card dark:bg-card sm:px-3 sm:py-1.5 sm:text-[15px] ${
                index === CHALLENGE_TAGS.length - 1 ? 'hidden sm:block' : ''
              }`}
            >
              {tag}
            </li>
          ))}
        </ul>
        <StatTiles items={STATS} className="my-5 sm:my-6" />
      </div>

      <div className="grid w-full max-w-5xl grid-cols-1 items-stretch gap-6 text-left lg:grid-cols-2">
        {PROFILES.filter((profile) => profile.available).map((profile) => {
          const isSelected = selectedProfile === profile.id;
          const Icon = profile.icon;

          return (
            <button
              key={profile.id}
              type="button"
              onClick={() => onSelect(profile.id)}
              aria-pressed={isSelected}
              className={`group w-full min-h-36 rounded border-2 p-5 text-left transition-all duration-150 cursor-pointer focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg ${
                isSelected
                  ? 'bg-selected border-border shadow-elevated'
                  : 'bg-card border-border hover:border-brand hover:shadow-card'
              }`}
            >
              <div className="flex items-start justify-between gap-4">
                <div
                  className={`w-9 h-9 rounded flex items-center justify-center border-2 transition-colors ${
                    isSelected
                      ? 'bg-card border-border text-text'
                      : 'bg-bg border-border text-muted group-hover:text-text'
                  }`}
                >
                  <Icon className="w-4 h-4 stroke-[2]" />
                </div>
                <span className="rounded border-2 border-border bg-[#D6F5E3] px-2 py-1 font-mono text-[10px] uppercase tracking-[0.06em] text-[#14532D] shadow-card">
                  Disponible
                </span>
              </div>

              <div className="space-y-1.5 mt-5">
                <h2 className="font-serif text-xl font-bold text-text">
                  {profile.title}
                </h2>
                <p className="text-xs text-muted leading-relaxed">
                  {profile.description}
                </p>
              </div>

              <span
                aria-hidden="true"
                className="mt-5 inline-flex min-h-11 w-full items-center justify-center rounded bg-brand px-4 text-sm font-semibold text-cta-text sm:w-auto"
              >
                Commencer →
              </span>
            </button>
          );
        })}

        <section aria-labelledby="upcoming-profiles-title" className="space-y-3">
          <div className="flex items-center justify-between gap-3">
            <h2 id="upcoming-profiles-title" className="font-serif text-base font-bold text-text">
              D’autres profils arrivent
            </h2>
            <span className="font-mono text-[10px] uppercase tracking-[0.06em] text-muted">
              Bientôt
            </span>
          </div>
          <div className="grid grid-cols-2 gap-3 lg:grid-cols-1">
            {PROFILES.filter((profile) => !profile.available).map((profile) => {
              const Icon = profile.icon;

              return (
                <div key={profile.id} className="min-h-28 rounded border-2 border-border bg-card p-3 opacity-75">
                  <div className="flex items-center gap-2">
                    <Icon className="w-4 h-4 shrink-0 text-muted" />
                    <h3 className="font-serif text-sm font-bold leading-tight text-text">
                      {profile.title}
                    </h3>
                  </div>
                  <p className="mt-2 text-xs leading-relaxed text-muted">
                    {profile.description}
                  </p>
                </div>
              );
            })}
          </div>
        </section>
      </div>
    </div>
  </div>
);
