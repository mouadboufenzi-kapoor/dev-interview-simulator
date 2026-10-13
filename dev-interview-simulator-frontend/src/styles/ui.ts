/**
 * Constantes de classes Tailwind réutilisables.
 * Règle : ce fichier ne contient QUE du CSS — jamais de texte métier
 * (cela préserve l'extraction i18n future, étape 12).
 * Style « Contraste » : bordures --bw (2px), rayons --radius, tokens couleur.
 * Le focus (outline 3px solid brand, offset 2px) est déjà global via
 * index.css @layer base — pas besoin de le répéter ici.
 */

/** Champ de formulaire pleine largeur (input/textarea/select), taille standard. */
export const fieldInput =
  'w-full rounded border-2 border-border p-3 text-sm bg-card text-text';

/** Champ de formulaire compact (panneaux admin avec barre de création). */
export const fieldInputSmall =
  'w-full rounded border-2 border-border p-2.5 text-sm bg-card text-text';

/** Sélecteur de filtre (barre d'outils admin). */
export const filterSelect =
  'py-2 px-3 text-sm rounded border-2 border-border bg-card text-text';

/** Étiquette de champ de formulaire. */
export const fieldLabel = 'text-sm font-semibold text-ink';

/** Panneau (tableaux et contenus administrés) — bordure 2px + ombre décalée. */
export const panel =
  'bg-card rounded border-2 border-border shadow-panel overflow-hidden';

/** Carte de contenu (sections avec padding interne, sans crop). */
export const panelCard =
  'bg-card rounded border-2 border-border shadow-card';

/** Barre d'en-tête interne d'un panneau (titre + actions). */
export const panelToolbar = 'p-4 border-b-2 border-border flex justify-end';

/** Zone de création/édition dépliable sous la barre d'un panneau. */
export const panelForm =
  'p-4 border-b-2 border-border space-y-3 bg-bg';

/** En-tête de tableau. */
export const tableHead =
  'text-xs text-ink-muted uppercase bg-bg border-b-2 border-border font-mono tracking-[0.06em]';

/** Message d'état vide dans un panneau. */
export const emptyState = 'px-6 py-8 text-center text-sm text-ink-muted';
