import { useState } from 'react';
import { Button } from './common/Button';
import { PageTitle } from './common/PageTitle';
import { Plus } from 'lucide-react';
import { AdminChallengeForm } from './AdminChallengeForm';
import { AdminProfilePanel } from './AdminProfilePanel';
import { AdminStatsPanel } from './AdminStatsPanel';
import { AdminChallengesContent } from './AdminChallengesContent';
import { AdminGeneration } from './AdminGeneration';
import { AdminCoveragePanel } from './AdminCoveragePanel';
import { AdminUsersPanel } from './AdminUsersPanel';

type Tab = 'stats' | 'users' | 'coverage' | 'content' | 'profiles' | 'generation';

const TABS: { id: Tab; label: string }[] = [
  { id: 'stats', label: 'Statistiques' },
  { id: 'users', label: 'Utilisateurs' },
  { id: 'coverage', label: 'Couverture' },
  { id: 'content', label: 'Contenus' },
  { id: 'profiles', label: 'Profils' },
  { id: 'generation', label: 'Génération' },
];

export const AdminDashboard = () => {
  const [editingId, setEditingId] = useState<number | null>(null);
  const [isCreating, setIsCreating] = useState(false);
  const [tab, setTab] = useState<Tab>('stats');

  if (isCreating || editingId) {
    return (
      <AdminChallengeForm
        challengeId={editingId || undefined}
        onBack={() => {
          setIsCreating(false);
          setEditingId(null);
        }}
        onSaved={() => {
          setIsCreating(false);
          setEditingId(null);
        }}
      />
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <PageTitle>Administration</PageTitle>
          <p className="text-sm text-ink-secondary mt-1">Gérez les questions et contenus de la plateforme</p>
        </div>
        <Button
          onClick={() => setIsCreating(true)}
          variant="primary"
          leftIcon={<Plus className="w-4 h-4" />}
        >
          Nouvelle question
        </Button>
      </div>

      <div className="flex flex-wrap gap-2">
        {TABS.map(({ id, label }) => (
          <button
            key={id}
            onClick={() => setTab(id)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold transition ${
              tab === id
                ? 'bg-navy-900 dark:bg-navy-800 text-white'
                : 'bg-surface border border-border text-ink-secondary hover:bg-canvas-subtle'
            }`}
          >
            {label}
          </button>
        ))}
      </div>

      {tab === 'stats' ? (
        <AdminStatsPanel onOpenUsers={() => setTab('users')} />
      ) : tab === 'users' ? (
        <AdminUsersPanel />
      ) : tab === 'coverage' ? (
        <AdminCoveragePanel />
      ) : tab === 'profiles' ? (
        <AdminProfilePanel />
      ) : tab === 'generation' ? (
        <AdminGeneration />
      ) : (
        <AdminChallengesContent onEdit={setEditingId} />
      )}
    </div>
  );
};
