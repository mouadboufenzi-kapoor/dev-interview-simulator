import React from 'react';

export type BadgeVariant =
  | 'default'
  | 'navy'
  | 'crimson'
  | 'peach'
  | 'burgundy'
  | 'champagne'
  | 'success'
  | 'danger'
  | 'warning'
  | 'info'
  | 'mono';

interface BadgeProps {
  children: React.ReactNode;
  variant?: BadgeVariant;
  size?: 'sm' | 'md';
  dot?: boolean;
  pulseDot?: boolean;
  className?: string;
}

export const Badge: React.FC<BadgeProps> = ({
  children,
  variant = 'default',
  size = 'md',
  dot = false,
  pulseDot = false,
  className = '',
}) => {
  // Toutes les valeurs passent par les tokens (spec §14).
  const variantStyles: Record<BadgeVariant, string> = {
    default: 'bg-bg text-muted border-border',
    navy: 'bg-selected text-text border-border',
    crimson: 'bg-accent text-card border-border',
    burgundy: 'bg-accent text-card border-border',
    peach: 'bg-selected text-text border-border',
    champagne: 'bg-selected text-text border-border',
    success: 'bg-success-bg text-success border-success',
    danger: 'bg-error-bg text-error border-error',
    warning: 'bg-selected text-text border-border',
    info: 'bg-selected text-text border-border',
    mono: 'bg-bg text-muted border-border',
  };

  const dotColors: Record<BadgeVariant, string> = {
    default: 'bg-muted',
    navy: 'bg-text',
    crimson: 'bg-card',
    burgundy: 'bg-card',
    peach: 'bg-text',
    champagne: 'bg-text',
    success: 'bg-success',
    danger: 'bg-error',
    warning: 'bg-text',
    info: 'bg-text',
    mono: 'bg-muted',
  };

  const sizeStyles = {
    sm: 'text-[11px] px-2 py-0.5',
    md: 'text-[11px] px-2.5 py-1',
  };

  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded border-2 font-mono uppercase tracking-[0.06em] font-medium leading-none select-none ${variantStyles[variant]} ${sizeStyles[size]} ${className}`}
    >
      {dot && (
        <span className="relative flex h-1.5 w-1.5">
          {pulseDot && (
            <span
              className={`absolute inline-flex h-full w-full animate-ping rounded-full opacity-75 ${dotColors[variant]}`}
            />
          )}
          <span
            className={`relative inline-flex h-1.5 w-1.5 rounded-full ${dotColors[variant]}`}
          />
        </span>
      )}
      {children}
    </span>
  );
};
