import { AlertTriangle } from 'lucide-react';
import { Button } from './Button';
import { PageTitle } from './PageTitle';

interface Props {
  onCancel: () => void;
  onConfirm: () => void;
}

export const NavbarQuitModal = ({ onCancel, onConfirm }: Props) => (
  <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm animate-in fade-in duration-200">
    <div className="w-full max-w-md bg-surface border-[0.5px] border-card-border rounded-2xl p-6 shadow-2xl space-y-4">
      <div className="flex items-start gap-3.5">
        <div className="p-2.5 rounded-xl bg-danger-soft border border-danger-border text-danger flex-shrink-0">
          <AlertTriangle className="w-5 h-5" />
        </div>
        <div>
          <PageTitle as="h3" size="xs" tone="ink">
            Quitter la session en cours ?
          </PageTitle>
          <p className="text-sm text-ink-secondary mt-1 leading-relaxed">
            Votre progression actuelle et les réponses non soumises seront perdues. Souhaitez-vous vraiment revenir au choix des entraînements ?
          </p>
        </div>
      </div>

      <div className="flex items-center justify-end gap-3 pt-3">
        <Button
          variant="secondary"
          size="sm"
          onClick={onCancel}
        >
          Continuer la session
        </Button>
        <Button
          variant="danger"
          size="sm"
          onClick={onConfirm}
        >
          Oui, quitter
        </Button>
      </div>
    </div>
  </div>
);
