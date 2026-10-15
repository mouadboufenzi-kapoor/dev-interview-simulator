import React from 'react';

export type IconButtonVariant = 'navy' | 'success' | 'danger' | 'ghost';

interface IconButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: IconButtonVariant;
}

const variantStyles: Record<IconButtonVariant, string> = {
  navy: 'text-navy-900 hover:bg-navy-100',
  success: 'text-success-strong hover:bg-success-surface',
  danger: 'text-crimson-700 hover:bg-danger-soft',
  ghost: 'hover:bg-canvas-subtle',
};

/**
 * Bouton d'action icône-seul (valider, modifier, archiver…).
 * Le titre/aria-label reste porté par l'appelant (i18n).
 */
export const IconButton: React.FC<IconButtonProps> = ({
  variant = 'navy',
  className = '',
  children,
  ...props
}) => (
  <button
    type="button"
    className={`p-2 rounded-lg transition cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${variantStyles[variant]} ${className}`.trim()}
    {...props}
  >
    {children}
  </button>
);
