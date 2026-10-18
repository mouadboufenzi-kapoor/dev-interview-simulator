import React, { useState } from 'react';
import { Sun, Moon } from 'lucide-react';
import {
  getStoredPalette,
  getStoredMode,
  applyTheme,
  resolveMode,
  type Palette,
  type Mode,
  type ResolvedMode,
} from '../../utils/theme';

/**
 * Bouton de bascule clair/sombre (axe « mode » uniquement — la palette se
 * choisit dans la section Apparence du profil). Conserve le même vocabulaire
 * visuel qu'IconButton (ghost). Bascule entre light et dark de façon explicite
 * (elle fige le mode, elle ne repasse pas en « system »).
 */
export const ThemeToggle: React.FC = () => {
  /* Initialisation paresseuse : le thème est déjà appliqué par le script inline
     de index.html + initTheme — cet état sert uniquement à choisir l'icône. */
  const [mode, setMode] = useState<Mode>(() => getStoredMode());
  const palette: Palette = getStoredPalette();
  const resolved: ResolvedMode = resolveMode(mode);

  const toggle = () => {
    const next: Mode = resolved === 'dark' ? 'light' : 'dark';
    setMode(next);
    applyTheme(palette, next);
  };

  const isDark = resolved === 'dark';

  /* Taille visuelle alignée sur les voisins du navbar (~32px) : la cible
     tactile ≥44px est assurée par le pseudo-élément before étendu (inset
     négatif), qui n'affecte pas la mise en page ni l'alignement. */
  return (
    <button
      type="button"
      onClick={toggle}
      title={isDark ? 'Passer en mode clair' : 'Passer en mode sombre'}
      aria-label={isDark ? 'Passer en mode clair' : 'Passer en mode sombre'}
      className="relative p-2 rounded flex items-center justify-center transition cursor-pointer hover:bg-nav-hover focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg before:absolute before:-inset-2 before:content-['']"
    >
      {isDark ? (
        <Sun className="w-4 h-4 text-nav-text" />
      ) : (
        <Moon className="w-4 h-4 text-nav-muted" />
      )}
    </button>
  );
};
