/**
 * Persistance du thème clair/sombre (dark mode, classe `.dark` sur <html>).
 * Aucune lib : localStorage + prefers-color-scheme uniquement.
 */
export type Theme = 'light' | 'dark';

const STORAGE_KEY = 'theme';

/** Thème enregistré par l'utilisateur, ou null si aucune préférence. */
export const getStoredTheme = (): Theme | null => {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    return stored === 'dark' || stored === 'light' ? stored : null;
  } catch {
    return null;
  }
};

/** Thème initial : préférence utilisateur, sinon préférence système. */
export const resolveInitialTheme = (): Theme => {
  const stored = getStoredTheme();
  if (stored) return stored;
  return window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
};

/** Applique le thème sur <html> et le persiste. */
export const applyTheme = (theme: Theme): void => {
  document.documentElement.classList.toggle('dark', theme === 'dark');
  try {
    localStorage.setItem(STORAGE_KEY, theme);
  } catch {
    /* stockage indisponible (mode privé) : le thème reste valable pour la session */
  }
};
