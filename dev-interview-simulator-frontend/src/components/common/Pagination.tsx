import { ChevronLeft, ChevronRight } from 'lucide-react';

interface Props {
  page: number;
  pageCount: number;
  onPageChange: (page: number) => void;
  className?: string;
}

const arrowButtonClassName =
  'rounded-lg border border-border bg-surface p-1.5 text-ink-secondary transition hover:bg-canvas-subtle hover:text-ink disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas';

export const Pagination = ({ page, pageCount, onPageChange, className = '' }: Props) => {
  if (pageCount <= 1) return null;

  return (
    <div className={`flex items-center justify-end gap-2 text-xs text-ink-secondary ${className}`}>
      <button
        type="button"
        aria-label="Page précédente"
        onClick={() => onPageChange(page - 1)}
        disabled={page === 0}
        className={arrowButtonClassName}
      >
        <ChevronLeft className="h-3.5 w-3.5" />
      </button>
      <span className="font-mono">{page + 1} / {pageCount}</span>
      <button
        type="button"
        aria-label="Page suivante"
        onClick={() => onPageChange(page + 1)}
        disabled={page >= pageCount - 1}
        className={arrowButtonClassName}
      >
        <ChevronRight className="h-3.5 w-3.5" />
      </button>
    </div>
  );
};
