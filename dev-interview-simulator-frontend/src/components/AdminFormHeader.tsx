import { ArrowLeft } from 'lucide-react';
import { PageTitle } from './common/PageTitle';

interface Props {
  challengeId?: number;
  defaultScenarioId?: number;
  scenarioTitle?: string;
  onBack: () => void;
  error: string | null;
}

export const AdminFormHeader = ({ challengeId, defaultScenarioId, scenarioTitle, onBack, error }: Props) => (
  <div className="space-y-6">
    <div className="flex items-center gap-4">
      <button onClick={onBack} className="p-2 hover:bg-canvas-subtle rounded-lg transition">
        <ArrowLeft className="w-5 h-5 text-ink-muted" />
      </button>
      <div>
        <PageTitle as="h2" size="md">
          {challengeId
            ? 'Modifier la question'
            : defaultScenarioId
              ? 'Nouvelle étape'
              : 'Nouvelle question'}
        </PageTitle>
        {scenarioTitle != null && (
          <p className="text-sm text-ink-secondary mt-1">
            Scénario : {scenarioTitle}
          </p>
        )}
      </div>
    </div>

    {error && (
      <div className="p-4 rounded-xl bg-danger-soft border border-danger-border text-danger text-sm">
        {error}
      </div>
    )}
  </div>
);
