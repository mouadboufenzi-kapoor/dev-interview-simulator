import { useState } from 'react';
import { Button } from './common/Button';
import { PageTitle } from './common/PageTitle';
import { Plus } from 'lucide-react';
import { AdminChallengeForm } from './AdminChallengeForm';
import { AdminScenarioPanel } from './AdminScenarioPanel';
import { AdminProfilePanel } from './AdminProfilePanel';
import { AdminStatsPanel } from './AdminStatsPanel';
import { AdminChallengesContent } from './AdminChallengesContent';

type Tab = 'stats' | 'content' | 'scenarios' | 'profiles';

const TABS: { id: Tab; label: string }[] = [
  { id: 'stats', label: 'Statistiques' },
  { id: 'content', label: 'Contenus' },
  { id: 'scenarios', label: 'Scénarios' },
  { id: 'profiles', label: 'Profils' },
];

export const AdminDashboard = () => {
  const [editingId, setEditingId] = useState<number | null>(null);
  const [isCreating, setIsCreating] = useState(false);
  const [tab, setTab] = useState<Tab>('stats');
  const [preselectedScenarioId, setPreselectedScenarioId] = useState<number | undefined>(undefined);

  if (isCreating || editingId) {
    return (
      <AdminChallengeForm
        challengeId={editingId || undefined}
        defaultScenarioId={preselectedScenarioId}
        onBack={() => {
          setIsCreating(false);
          setEditingId(null);
          setPreselectedScenarioId(undefined);
        }}
        onSaved={() => {
          setIsCreating(false);
          setEditingId(null);
          setPreselectedScenarioId(undefined);
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
        <AdminStatsPanel />
      ) : tab === 'scenarios' ? (
        <AdminScenarioPanel onAddStep={id => { setPreselectedScenarioId(id); setIsCreating(true); }} />
      ) : tab === 'profiles' ? (
        <AdminProfilePanel />
      ) : (
        <AdminChallengesContent onEdit={setEditingId} />
      )}
    </div>
  );
};
