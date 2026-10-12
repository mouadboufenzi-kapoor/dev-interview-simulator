import type { ReactNode } from 'react';
import type { AnalyzedCompetency } from '../utils/resultAnalysis';
import { PageTitle } from './common/PageTitle';

interface Props {
  title: string;
  icon: ReactNode;
  /** Classes de la puce d'en-tête (fond + bordure + couleur de l'icône). */
  iconChipClassName: string;
  tone: 'success' | 'crimson';
  items: AnalyzedCompetency[];
  /** Affiché à la place de la liste quand aucun item (ex. tout est à 100 %). */
  emptyMessage?: string;
  footerNote?: ReactNode;
}

const TONE_STYLES = {
  success: { value: 'text-success', bar: 'bg-success' },
  crimson: { value: 'text-crimson-700', bar: 'bg-crimson-700' },
} as const;

export const ResultCompetencies = ({
  title,
  icon,
  iconChipClassName,
  tone,
  items,
  emptyMessage,
  footerNote,
}: Props) => {
  const styles = TONE_STYLES[tone];

  return (
    <section className="bg-surface border-[0.5px] border-card-border rounded-2xl p-6 shadow-card space-y-4">
      <div className="flex items-center gap-2.5">
        <div className={`p-2 rounded-lg border flex-shrink-0 ${iconChipClassName}`}>{icon}</div>
        <PageTitle as="h2" size="sm">
          {title}
        </PageTitle>
      </div>

      {items.length > 0 ? (
        <>
          <ul className="space-y-3.5">
            {items.map((c) => (
              <li key={c.id} className="space-y-1.5">
                <div className="flex items-center justify-between gap-3 text-sm">
                  <span className="font-semibold text-ink truncate">{c.name}</span>
                  <span
                    className={`font-mono text-xs font-semibold flex-shrink-0 ${styles.value}`}
                  >
                    {c.pct} %
                  </span>
                </div>
                <div className="h-1.5 rounded-full bg-canvas-subtle overflow-hidden">
                  <div
                    className={`h-full rounded-full ${styles.bar}`}
                    style={{ width: `${c.pct}%` }}
                  />
                </div>
                <p className="text-[11px] text-ink-muted">
                  {c.correct} bonne(s) réponse(s) sur {c.total}
                </p>
              </li>
            ))}
          </ul>

          {footerNote && (
            <p className="text-xs text-ink-secondary leading-relaxed border-t border-border pt-3">
              {footerNote}
            </p>
          )}
        </>
      ) : (
        emptyMessage && (
          <p className="text-xs text-ink-secondary leading-relaxed">{emptyMessage}</p>
        )
      )}
    </section>
  );
};
