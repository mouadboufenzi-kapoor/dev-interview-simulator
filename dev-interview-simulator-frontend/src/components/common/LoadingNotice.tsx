import { Loader2 } from 'lucide-react';

interface Props {
  message: string;
  detail?: string;
  overlay?: boolean;
}

export const LoadingNotice = ({ message, detail, overlay = false }: Props) => {
  const card = (
    <div
      role="status"
      aria-live="polite"
      className={`inline-flex flex-col items-center gap-4 bg-surface border-[0.5px] border-card-border rounded-2xl px-8 py-10 shadow-elevated${
        overlay ? ' w-full max-w-sm text-center' : ''
      }`}
    >
      <Loader2 className="w-7 h-7 animate-spin text-brand" />
      <div className="space-y-1">
        <p className="text-sm font-semibold text-text">{message}</p>
        {detail && <p className="text-xs text-muted">{detail}</p>}
      </div>
    </div>
  );

  if (!overlay) return card;

  return (
    <div
      role="dialog"
      aria-modal="true"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-ink/25 backdrop-blur-[2px] animate-in fade-in duration-200"
    >
      {card}
    </div>
  );
};
