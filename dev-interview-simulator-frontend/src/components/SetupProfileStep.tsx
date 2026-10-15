import { BriefcaseBusiness, Cloud, ClipboardCheck, ShieldCheck, Database, KanbanSquare } from 'lucide-react';
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
        <p className="font-mono text-[11px] uppercase tracking-[0.06em] text-muted font-medium">
          InterviewLab
        </p>
        <PageTitle size="hero">
          Vous êtes quel profil ?
        </PageTitle>
        <p className="text-sm sm:text-base text-muted font-sans max-w-lg mx-auto leading-relaxed">
          Choisissez votre domaine pour commencer une simulation adaptée à
          votre parcours.
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5 text-left">
        {PROFILES.map((profile, index) => {
          const isSelected = selectedProfile === profile.id;
          const Icon = profile.icon;

          return (
            <button
              key={profile.id}
              type="button"
              onClick={() => onSelect(profile.id)}
              aria-pressed={isSelected}
              className={`group relative min-h-36 rounded border-2 p-5 text-left transition-all duration-150 cursor-pointer focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg ${
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
                {/* Numéro de carte en mono (spec §10) */}
                <span className="font-mono text-[11px] uppercase tracking-[0.06em] text-muted">
                  {String(index + 1).padStart(2, '0')}
                </span>
              </div>

              <div className="space-y-1.5 mt-6">
                <h2
                  className={`font-serif text-xl font-bold transition-colors ${
                    isSelected ? 'text-text' : 'text-text'
                  }`}
                >
                  {profile.title}
                </h2>
                <p className="text-xs text-muted leading-relaxed">
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
