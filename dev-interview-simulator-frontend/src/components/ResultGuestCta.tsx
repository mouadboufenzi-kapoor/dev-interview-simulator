import { useEffect, useRef } from 'react';
import { Flame, TrendingUp } from 'lucide-react';
import { Button } from './common/Button';
import { trackEvent } from '../api/events';

interface Props {
  count: number;
  simulationId: number | null;
  onCreateAccount: () => void;
}

export const ResultGuestCta = ({ count, simulationId, onCreateAccount }: Props) => {
  const sectionRef = useRef<HTMLElement>(null);
  const viewedRef = useRef(false);

  useEffect(() => {
    const element = sectionRef.current;
    if (!element || typeof IntersectionObserver === 'undefined') return;
    const observer = new IntersectionObserver((entries) => {
      if (viewedRef.current || !entries.some((entry) => entry.isIntersecting)) return;
      viewedRef.current = true;
      trackEvent('guest_cta_viewed', { simulationId });
      observer.disconnect();
    }, { threshold: 0.5 });
    observer.observe(element);
    return () => observer.disconnect();
  }, [simulationId]);

  const handleCreateAccount = () => {
    trackEvent('guest_cta_clicked', { simulationId });
    onCreateAccount();
  };
  // Seuil 5 : en deçà on affiche le nombre réel ; au-delà on reste vague
  // (« plusieurs simulations ») — message plus professionnel, moins mécanique.
  const reinforced = count >= 5;

  return (
    <section ref={sectionRef} className="bg-surface border-[0.5px] border-card-border rounded-2xl p-6 shadow-card flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
      <div className="flex items-start gap-3">
        <div className="p-2 rounded-lg bg-peach-100 border border-peach-500 text-peach-ink flex-shrink-0 mt-0.5">
          {reinforced ? <Flame className="w-4 h-4" /> : <TrendingUp className="w-4 h-4" />}
        </div>
        <div className="space-y-1">
          <p className="font-semibold text-sm text-ink">
            {reinforced
              ? 'Vous avez déjà réalisé plusieurs simulations.'
              : `Vous avez déjà réalisé ${count} simulation${count > 1 ? 's' : ''}.`}
          </p>
          <p className="text-xs text-ink-secondary leading-relaxed">
            {reinforced
              ? 'Créez un compte pour conserver votre progression et suivre vos performances dans le temps.'
              : 'Créez un compte gratuit pour conserver vos résultats et suivre votre évolution au fil des simulations.'}
          </p>
        </div>
      </div>

      <Button
        type="button"
        variant={reinforced ? 'primary' : 'outline'}
        size="lg"
        onClick={handleCreateAccount}
        className="w-full sm:w-auto flex-shrink-0"
      >
        Créer mon compte
      </Button>
    </section>
  );
};
