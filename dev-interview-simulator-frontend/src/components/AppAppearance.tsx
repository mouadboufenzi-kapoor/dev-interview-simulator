import { useEffect, useState } from 'react';
import { Check } from 'lucide-react';
import {
  getStoredPalette,
  getStoredMode,
  applyTheme,
  watchSystemMode,
  type Palette,
} from '../utils/theme';

const PALETTE_CHOICES: { id: Palette; label: string; swatch: string; check: string }[] = [
  { id: 'soleil', label: 'Jaune', swatch: '#FFD23F', check: '#111111' },
  { id: 'menthe', label: 'Menthe', swatch: '#8FE3C0', check: '#111111' },
  { id: 'encre', label: 'Bleu', swatch: '#123C69', check: '#FFFFFF' },
];

export const AppAppearance = () => {
  const [palette, setPalette] = useState<Palette>(() => getStoredPalette());

  useEffect(() => watchSystemMode(), []);

  const selectPalette = (next: Palette) => {
    setPalette(next);
    applyTheme(next, getStoredMode());
  };

  return (
    <section className="bg-card rounded border-2 border-border shadow-card p-5 sm:p-6 space-y-4">
      <div className="space-y-1">
        <h2 className="font-serif text-lg sm:text-xl font-bold text-text">Apparence</h2>
        <p className="text-xs text-muted">
          Choisissez votre couleur. Le mode clair ou nuit suit automatiquement votre système.
        </p>
      </div>

      <div className="flex items-start gap-3 sm:gap-5">
        {PALETTE_CHOICES.map((choice) => {
          const isSelected = palette === choice.id;
          return (
            <button
              key={choice.id}
              type="button"
              onClick={() => selectPalette(choice.id)}
              aria-pressed={isSelected}
              className="flex flex-col items-center gap-2 p-2 rounded cursor-pointer focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg"
            >
              <span
                className={`flex h-11 w-11 items-center justify-center rounded-full border-2 border-border transition-all ${isSelected ? 'shadow-[2px_2px_0_var(--color-shadow)]' : ''}`}
                style={{ backgroundColor: choice.swatch }}
              >
                {isSelected && <Check className="w-5 h-5" style={{ color: choice.check }} />}
              </span>
              <span className="text-xs font-semibold text-text">{choice.label}</span>
            </button>
          );
        })}
      </div>
    </section>
  );
};
