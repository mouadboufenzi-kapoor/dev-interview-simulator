import { Flame, TrendingUp } from 'lucide-react';
import { Button } from './common/Button';

interface Props {
  count: number;
  onCreateAccount: () => void;
}

export const ResultGuestCta = ({ count, onCreateAccount }: Props) => {
  const reinforced = count >= 3;

  return (
    <section className="bg-surface border-[0.5px] border-card-border rounded-2xl p-6 shadow-card flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
      <div className="flex items-start gap-3">
        <div className="p-2 rounded-lg bg-peach-100 border border-peach-500 text-peach-ink flex-shrink-0 mt-0.5">
          {reinforced ? <Flame className="w-4 h-4" /> : <TrendingUp className="w-4 h-4" />}
        </div>
        <div className="space-y-1">
          <p className="font-semibold text-sm text-ink">
            {reinforced
              ? `Vous avez déjà réalisé ${count} simulations.`
              : 'Suivre votre progression'}
          </p>
          <p className="text-xs text-ink-secondary leading-relaxed">
            {reinforced
              ? 'Vous commencez à construire votre profil technique. Créez un compte gratuit pour suivre votre progression, conserver votre historique et voir vos forces et axes d’amélioration évoluer dans le temps.'
              : 'Créez un compte gratuit pour conserver vos résultats et suivre votre évolution au fil des simulations.'}
          </p>
        </div>
      </div>

      <Button
        type="button"
        variant={reinforced ? 'primary' : 'outline'}
        size="lg"
        onClick={onCreateAccount}
        className="w-full sm:w-auto flex-shrink-0"
      >
        Créer mon compte
      </Button>
    </section>
  );
};
