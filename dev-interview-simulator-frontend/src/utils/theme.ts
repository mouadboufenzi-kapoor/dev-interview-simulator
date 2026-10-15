/**
 * Persistance du thème (palette) et du mode (clair/sombre).
 * Aucune lib : localStorage + prefers-color-scheme uniquement.
 *
 * Deux axes indépendants, portés par deux attributs sur <html> :
 *   - palette : 'soleil' | 'menthe'          → data-theme="..."
 *   - mode    : 'light' | 'dark' | 'system'  → data-mode="light|dark"
 *
 * Le mode « system » est une préférence utilisateur, mais il est RÉSOLU ici
 * en light/dark (via prefers-color-scheme) avant d'être écrit sur l'attribut :
 * il n'existe AUCUN mode CSS « system » (spec §2).
 */
export type Palette = 'soleil' | 'menthe';
export type Mode = 'light' | 'dark' | 'system';
/** Mode réellement appliqué sur data-mode (jamais « system »). */
export type ResolvedMode = 'light' | 'dark';

const PALETTE_KEY = 'theme'; // 'soleil' | 'menthe'
const MODE_KEY = 'mode'; // 'light' | 'dark' | 'system'

export const DEFAULT_PALETTE: Palette = 'soleil';
export const DEFAULT_MODE: Mode = 'system';

/** Palette enregistrée, ou défaut si absente/valeur inconnue. */
export const getStoredPalette = (): Palette => {
  try {
    const stored = localStorage.getItem(PALETTE_KEY);
    return stored === 'soleil' || stored === 'menthe' ? stored : DEFAULT_PALETTE;
  } catch {
    return DEFAULT_PALETTE;
  }
};

/** Mode enregistré, ou défaut si absente/valeur inconnue. */
export const getStoredMode = (): Mode => {
  try {
    const stored = localStorage.getItem(MODE_KEY);
    return stored === 'light' || stored === 'dark' || stored === 'system'
      ? stored
      : DEFAULT_MODE;
  } catch {
    return DEFAULT_MODE;
  }
};

/** Résout le mode système via prefers-color-scheme. */
export const systemMode = (): ResolvedMode =>
  window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';

/** Passe un mode (peut inclure « system ») en mode réel appliquable. */
export const resolveMode = (mode: Mode): ResolvedMode =>
  mode === 'system' ? systemMode() : mode;

const applyToDocument = (palette: Palette, resolved: ResolvedMode): void => {
  const root = document.documentElement;
  root.setAttribute('data-theme', palette);
  root.setAttribute('data-mode', resolved);
};

/** Applique palette + mode sur <html> et persiste les deux préférences. */
export const applyTheme = (palette: Palette, mode: Mode): void => {
  applyToDocument(palette, resolveMode(mode));
  try {
    localStorage.setItem(PALETTE_KEY, palette);
    localStorage.setItem(MODE_KEY, mode);
  } catch {
    /* stockage indisponible (mode privé) : le thème reste valable pour la session */
  }
};

/** Applique les préférences enregistrées (ou les défauts) au chargement. */
export const initTheme = (): void => {
  applyTheme(getStoredPalette(), getStoredMode());
};

/**
 * Ré-applique le thème quand la préférence système change — uniquement si
 * l'utilisateur est en mode « system ». Retourne un désabonnement.
 */
export const watchSystemMode = (palette: Palette, mode: Mode): (() => void) => {
  const mql = window.matchMedia?.('(prefers-color-scheme: dark)');
  if (!mql) return () => {};
  const onChange = () => {
    // Uniquement si l'utilisateur est réellement en mode « system ».
    if (mode === 'system') {
      applyToDocument(palette, systemMode());
    }
  };
  mql.addEventListener('change', onChange);
  return () => mql.removeEventListener('change', onChange);
};
