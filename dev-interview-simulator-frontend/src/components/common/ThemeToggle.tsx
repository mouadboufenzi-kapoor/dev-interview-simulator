import React, { useState } from 'react';
import { Sun, Moon } from 'lucide-react';
import { resolveInitialTheme, applyTheme, type Theme } from '../../utils/theme';

/**
 * Bouton de bascule clair/sombre.
 * Même vocabulaire visuel qu'IconButton (ghost) : p-2 rounded-lg hover bg,
 * focus-visible ring navy — sans dépendre de lui (évite l'import circulaire
 * des variantes) et pour porter l'état interne du thème.
 */
export const ThemeToggle: React.FC = () => {
  /* Initialisation paresseuse : le thème est déjà appliqué par main.tsx avant le
     render — cet état sert uniquement à choisir l'icône (localStorage/matchMedia
     sont lus une seule fois au montage). */
  const [theme, setTheme] = useState<Theme>(() => resolveInitialTheme());

  const toggle = () => {
    const next: Theme = theme === 'dark' ? 'light' : 'dark';
    setTheme(next);
    applyTheme(next);
  };

  const isDark = theme === 'dark';

  return (
    <button
      type="button"
      onClick={toggle}
      title={isDark ? 'Passer en mode clair' : 'Passer en mode sombre'}
      aria-label={isDark ? 'Passer en mode clair' : 'Passer en mode sombre'}
      className="p-2 rounded-lg transition cursor-pointer hover:bg-canvas-subtle focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
    >
      {isDark ? (
        <Sun className="w-4 h-4 text-navy-900" />
      ) : (
        <Moon className="w-4 h-4 text-ink-warm" />
      )}
    </button>
  );
};
