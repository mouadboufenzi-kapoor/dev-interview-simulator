/**
 * Constantes de classes Tailwind réutilisables.
 * Règle : ce fichier ne contient QUE du CSS — jamais de texte métier
 * (cela préserve l'extraction i18n future, étape 12).
 */

/** Champ de formulaire pleine largeur (input/textarea/select), taille standard. */
export const fieldInput =
  'w-full rounded-xl border border-border p-3 text-sm focus:border-navy-900 focus-visible:ring-2 focus-visible:ring-navy-900/30 outline-none';

/** Champ de formulaire compact (panneaux admin avec barre de création). */
export const fieldInputSmall =
  'w-full rounded-xl border border-border p-2.5 text-sm focus:border-navy-900 focus-visible:ring-2 focus-visible:ring-navy-900/30 outline-none bg-surface';

/** Sélecteur de filtre (barre d'outils admin). */
export const filterSelect =
  'py-2 px-3 text-sm rounded-xl border border-border focus:border-navy-900 focus-visible:ring-2 focus-visible:ring-navy-900/30 outline-none bg-surface';

/** Étiquette de champ de formulaire. */
export const fieldLabel = 'text-sm font-semibold text-ink';

/** Panneau blanc arrondi (tableaux et contenus administrés). */
export const panel =
  'bg-surface rounded-2xl border border-border shadow-panel overflow-hidden';

/** Carte de contenu blanche (sections avec padding interne, sans crop). */
export const panelCard =
  'bg-surface rounded-2xl border border-border shadow-panel';

/** Barre d'en-tête interne d'un panneau (titre + actions). */
export const panelToolbar = 'p-4 border-b border-border-subtle flex justify-end';

/** Zone de création/édition dépliable sous la barre d'un panneau. */
export const panelForm =
  'p-4 border-b border-border-subtle space-y-3 bg-canvas-subtle';

/** En-tête de tableau. */
export const tableHead =
  'text-xs text-ink-muted uppercase bg-canvas-subtle border-b border-border-subtle';

/** Message d'état vide dans un panneau. */
export const emptyState = 'px-6 py-8 text-center text-sm text-ink-muted';
