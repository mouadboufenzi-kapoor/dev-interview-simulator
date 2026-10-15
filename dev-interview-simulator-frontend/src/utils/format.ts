/**
 * Utilitaires de formatage.
 *
 * Point de bascule i18n (étape 12) : la locale est centralisée ici.
 * Pour basculer l'application en anglais, remplacer FR_LOCALE par 'en-US'
 * (ou brancher sur la locale résolue par la lib i18n future).
 * Aucune dépendance i18n n'est ajoutée pour l'instant.
 */
export const FR_LOCALE = 'fr-FR';

/** Date ISO → date courte ("15 sept. 2026"). */
export const formatDate = (iso: string): string =>
  new Date(iso).toLocaleDateString(FR_LOCALE, {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
