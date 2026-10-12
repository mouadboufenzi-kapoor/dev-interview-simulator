import { Target } from 'lucide-react';
import { Button } from './common/Button';
import type { AnalyzedCompetency } from '../utils/resultAnalysis';

interface Props {
  target: AnalyzedCompetency;
  loading: boolean;
  onStart: () => void;
}

export const ResultObjective = ({ target, loading, onStart }: Props) => (
  <section className="bg-surface border-[0.5px] border-card-border rounded-2xl p-6 shadow-elevated space-y-4">
    <div className="flex items-center gap-2.5">
      <div className="p-2 rounded-lg bg-navy-100 border border-navy-200 text-navy-900 flex-shrink-0">
        <Target className="w-4 h-4" />
      </div>
      <span className="font-sans text-xs uppercase tracking-wider text-navy-900 font-semibold">
        Ton prochain objectif
      </span>
    </div>

    <div className="space-y-1">
      <p className="font-serif text-lg font-bold text-ink">
        Améliorer ton niveau en {target.name}.
      </p>
      <p className="text-xs text-ink-secondary">
        {target.correct}/{target.total} réponses justes sur cette simulation — l'axe le plus fragile
        de cette session.
      </p>
    </div>

    <Button
      type="button"
      variant="primary"
      size="lg"
      loading={loading}
      rightIcon={<Target className="w-4 h-4" />}
      onClick={onStart}
      className="w-full sm:w-auto px-8"
    >
      S'entraîner sur {target.name}
    </Button>
  </section>
);
