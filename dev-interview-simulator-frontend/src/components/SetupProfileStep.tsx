import { Check, BriefcaseBusiness, Cloud, ClipboardCheck, ShieldCheck, Database, KanbanSquare } from 'lucide-react';
import { PageTitle } from './common/PageTitle';

export interface ProfileCardConfig {
  id: string;
  title: string;
  description: string;
  icon: typeof BriefcaseBusiness;
}

export const PROFILES: ProfileCardConfig[] = [
  {
    id: 'developer',
    title: 'Développeur',
    description: 'Code, conception et résolution de problèmes techniques.',
    icon: BriefcaseBusiness,
  },
  {
    id: 'devops-cloud',
    title: 'DevOps / Cloud',
    description: 'Infrastructure, déploiement et fiabilité des services.',
    icon: Cloud,
  },
  {
    id: 'qa-testing',
    title: 'QA / Testing',
    description: 'Qualité logicielle, automatisation et stratégies de test.',
    icon: ClipboardCheck,
  },
  {
    id: 'cybersecurity',
    title: 'Cybersécurité',
    description: 'Sécurité applicative, risques et protection des systèmes.',
    icon: ShieldCheck,
  },
  {
    id: 'data',
    title: 'Data',
    description: 'Données, analyse et mise en place de solutions pertinentes.',
    icon: Database,
  },
  {
    id: 'it-project-manager',
    title: 'Chef de projet IT',
    description: 'Pilotage, coordination et livraison de projets numériques.',
    icon: KanbanSquare,
  },
];

interface Props {
  selectedProfile: string | null;
  onSelect: (profileId: string) => void;
}

export const SetupProfileStep = ({ selectedProfile, onSelect }: Props) => (
  <div className="screen-transition relative w-full min-h-[calc(80vh-80px)] flex flex-col items-center justify-center py-10 sm:py-16 px-4">
    <div className="w-full max-w-4xl mx-auto space-y-10 sm:space-y-12 text-center">
      <div className="space-y-4">
        <p className="font-sans text-xs uppercase tracking-[0.2em] text-ink-muted font-semibold">
          Dev Interview Simulator
        </p>
        <PageTitle size="hero">
          Vous êtes quel profil ?
        </PageTitle>
        <p className="text-sm sm:text-base text-ink-secondary font-sans max-w-lg mx-auto leading-relaxed">
          Choisissez votre domaine pour commencer une simulation adaptée à
          votre parcours.
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5 text-left">
        {PROFILES.map((profile) => {
          const isSelected = selectedProfile === profile.id;
          const Icon = profile.icon;

          return (
            <button
              key={profile.id}
              type="button"
              onClick={() => onSelect(profile.id)}
              aria-pressed={isSelected}
              className={`group relative min-h-36 rounded-2xl border-[0.5px] p-5 text-left transition-all duration-200 cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${
                isSelected
                  ? 'bg-surface border-navy-900 shadow-elevated ring-1 ring-navy-900'
                  : 'bg-surface/90 border-card-border hover:border-border-strong hover:shadow-panel'
              }`}
            >
              <div className="flex items-start justify-between gap-4">
                <div
                  className={`w-9 h-9 rounded-xl flex items-center justify-center border transition-colors ${
                    isSelected
                      ? 'bg-navy-100 border-navy-200 text-navy-900'
                      : 'bg-canvas-subtle border-border text-ink-muted group-hover:text-navy-900'
                  }`}
                >
                  <Icon className="w-4 h-4 stroke-[2]" />
                </div>
                <div
                  className={`w-4 h-4 rounded-full border flex items-center justify-center transition-all ${
                    isSelected
                      ? 'border-navy-900 bg-navy-900 dark:bg-navy-800 text-white'
                      : 'border-border bg-surface'
                  }`}
                >
                  {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                </div>
              </div>

              <div className="space-y-1.5 mt-6">
                <h2
                  className={`font-serif text-xl font-bold transition-colors ${
                    isSelected ? 'text-navy-900' : 'text-ink'
                  }`}
                >
                  {profile.title}
                </h2>
                <p className="text-xs text-ink-warm leading-relaxed">
                  {profile.description}
                </p>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  </div>
);
