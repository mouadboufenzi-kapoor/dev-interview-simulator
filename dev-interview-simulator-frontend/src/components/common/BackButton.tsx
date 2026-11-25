import { ArrowLeft } from 'lucide-react';

interface Props {
  onClick: () => void;
  className?: string;
}

export const BackButton = ({ onClick, className = '' }: Props) => (
  <button
    type="button"
    onClick={onClick}
    aria-label="Retour à la page principale"
    title="Retour à la page principale"
    className={`inline-flex h-7 w-7 flex-shrink-0 items-center justify-center rounded text-ink transition-colors hover:bg-canvas-subtle focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg lg:h-10 lg:w-10 lg:rounded-lg ${className}`}
  >
    <ArrowLeft className="h-4 w-4 lg:h-5 lg:w-5" aria-hidden="true" />
  </button>
);
