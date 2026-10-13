import { useEffect, useState } from 'react';
import { Sun, Moon, Monitor } from 'lucide-react';
import {
  getStoredPalette,
  getStoredMode,
  applyTheme,
  watchSystemMode,
  type Palette,
  type Mode,
} from '../utils/theme';

// Aperçu miniature d'une palette (carte) — sert à distinguer Soleil / Menthe.
const PalettePreview = ({ palette }: { palette: Palette }) => {
  const isSoleil = palette === 'soleil';
  const bg = isSoleil ? '#F2F2EC' : '#F6F4EE';
  const nav = isSoleil ? '#FFD23F' : '#8FE3C0';
  const brand = '#123C69';
  const accent = '#FF5A36';

  return (
    <div
      className="w-full h-16 rounded border-2 border-border overflow-hidden flex"
      style={{ background: bg }}
      aria-hidden="true"
    >
      <div className="w-1/4 h-full" style={{ background: nav }} />
      <div className="flex-1 p-2 flex flex-col justify-center gap-1.5">
        <div className="h-2 rounded-sm w-2/3" style={{ background: brand }} />
        <div className="h-2 rounded-sm w-1/3" style={{ background: accent }} />
      </div>
    </div>
  );
};

const MODE_OPTIONS: { id: Mode; label: string; icon: typeof Sun }[] = [
  { id: 'light', label: 'Clair', icon: Sun },
  { id: 'dark', label: 'Nuit', icon: Moon },
  { id: 'system', label: 'Système', icon: Monitor },
];

/**
 * Section « Apparence » (spec §18) : choix de la palette (Soleil / Menthe) et
 * du mode (Clair / Nuit / Système). Le changement est immédiat (attributs
 * data-theme / data-mode sur <html>), persisté dans localStorage, et le mode
 * « system » suit les changements de préférence système en direct.
 */
export const AppAppearance = () => {
  const [palette, setPalette] = useState<Palette>(() => getStoredPalette());
  const [mode, setMode] = useState<Mode>(() => getStoredMode());

  // Suit prefers-color-scheme quand le mode est « system ».
  useEffect(() => watchSystemMode(palette, mode), [palette, mode]);

  const selectPalette = (next: Palette) => {
    setPalette(next);
    applyTheme(next, mode);
  };

  const selectMode = (next: Mode) => {
    setMode(next);
    applyTheme(palette, next);
  };

  return (
    <section className="bg-card rounded border-2 border-border shadow-card p-5 sm:p-6 space-y-5">
      <div className="space-y-1">
        <h2 className="font-serif text-lg sm:text-xl font-bold text-text">Apparence</h2>
        <p className="text-xs text-muted">
          Choisissez la palette et le mode d'affichage. Le changement est immédiat.
        </p>
      </div>

      {/* Palette */}
      <div className="space-y-2">
        <span className="font-mono text-[11px] uppercase tracking-[0.06em] text-muted font-medium">
          Palette
        </span>
        <div className="grid grid-cols-2 gap-3">
          {(['soleil', 'menthe'] as Palette[]).map((p) => {
            const isSelected = palette === p;
            return (
              <button
                key={p}
                type="button"
                onClick={() => selectPalette(p)}
                aria-pressed={isSelected}
                className={`p-3 rounded border-2 text-left transition-all cursor-pointer focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg min-h-11 ${
                  isSelected
                    ? 'bg-selected border-border shadow-[2px_2px_0_var(--color-shadow)]'
                    : 'bg-card border-border hover:border-brand'
                }`}
              >
                <div className="space-y-2">
                  <PalettePreview palette={p} />
                  <span className="flex items-center justify-between">
                    <span className="text-sm font-semibold text-text capitalize">{p}</span>
                    {isSelected && (
                      <span className="font-mono text-[11px] uppercase tracking-[0.06em] text-success">
                        Actif
                      </span>
                    )}
                  </span>
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Mode */}
      <div className="space-y-2">
        <span className="font-mono text-[11px] uppercase tracking-[0.06em] text-muted font-medium">
          Mode
        </span>
        <div className="flex flex-wrap gap-2">
          {MODE_OPTIONS.map((opt) => {
            const isSelected = mode === opt.id;
            const Icon = opt.icon;
            return (
              <button
                key={opt.id}
                type="button"
                onClick={() => selectMode(opt.id)}
                aria-pressed={isSelected}
                className={`inline-flex items-center gap-2 px-3.5 py-2 min-h-11 rounded border-2 text-xs font-semibold transition-all cursor-pointer focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg ${
                  isSelected
                    ? 'bg-brand text-cta-text border-border shadow-[2px_2px_0_var(--color-shadow)]'
                    : 'bg-card text-text border-border hover:border-brand'
                }`}
              >
                <Icon className="w-4 h-4" />
                {opt.label}
              </button>
            );
          })}
        </div>
      </div>
    </section>
  );
};
