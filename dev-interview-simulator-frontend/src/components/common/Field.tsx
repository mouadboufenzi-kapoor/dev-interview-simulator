import React from 'react';
import { fieldLabel } from '../../styles/ui';

interface FieldProps {
  /** Étiquette du champ — texte passé par l'appelant (extraction i18n possible). */
  label: string;
  /** Contrôle associé (input, select, textarea…). */
  children: React.ReactNode;
  className?: string;
}

/**
 * Paire label + champ, isolée du balisage de formulaire.
 * Le <label> englobe le contrôle (accessibilité : clic sur le label = focus champ).
 */
export const Field: React.FC<FieldProps> = ({
  label,
  children,
  className = '',
}) => (
  <label className={`block space-y-1.5 ${className}`.trim()}>
    <span className={fieldLabel}>{label}</span>
    {children}
  </label>
);
