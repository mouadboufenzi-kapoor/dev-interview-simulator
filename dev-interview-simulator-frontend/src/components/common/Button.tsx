import React from 'react';
import { Loader2 } from 'lucide-react';

export type ButtonVariant =
  | 'primary'
  | 'secondary'
  | 'navy'
  | 'outline'
  | 'outline-nav'
  | 'champagne'
  | 'ghost'
  | 'danger';

export type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  fullWidth?: boolean;
}

export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  loading = false,
  leftIcon,
  rightIcon,
  fullWidth = false,
  disabled,
  className = '',
  ...props
}) => {
  const baseStyles =
    'inline-flex items-center justify-center font-medium select-none cursor-pointer focus:outline-none focus-visible:ring-2 focus-visible:ring-brand focus-visible:ring-offset-2 focus-visible:ring-offset-bg disabled:opacity-50 disabled:cursor-not-allowed disabled:pointer-events-none disabled:shadow-none';

  const variantStyles: Record<ButtonVariant, string> = {
    // Primary = CTA Contraste (spec §9) : fond cta-bg, bordure cta-border,
    // ombre décalée pleine, hover/active translate — piloté par .cta-brutal.
    primary: 'cta-brutal font-semibold',
    secondary:
      'bg-card hover:bg-selected text-text border-2 border-border shadow-card hover:shadow-elevated',
    navy: 'cta-brutal font-semibold',
    outline:
      'bg-transparent hover:bg-selected text-text border-2 border-border hover:border-brand',
    'outline-nav':
      'bg-transparent hover:bg-selected text-nav-text hover:text-text border-2 border-nav-border hover:border-nav-accent',
    champagne:
      'bg-nav hover:bg-selected text-nav-text hover:text-text font-semibold border-2 border-nav-border shadow-card',
    ghost:
      'bg-transparent hover:bg-selected text-muted hover:text-text border-2 border-transparent',
    danger:
      'bg-error-bg hover:bg-error text-error hover:text-card border-2 border-error',
  };

  const sizeStyles: Record<ButtonSize, string> = {
    sm: 'text-xs px-3 py-2 rounded gap-1.5 min-h-9',
    md: 'text-sm px-4 py-2 rounded gap-2 min-h-11',
    lg: 'text-base px-6 py-3 rounded gap-2.5 min-h-12',
  };

  const widthStyle = fullWidth ? 'w-full' : '';

  return (
    <button
      className={`${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]} ${widthStyle} ${className}`}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? (
        <>
          <Loader2 className="w-4 h-4 animate-spin flex-shrink-0" />
          <span>{children}</span>
        </>
      ) : (
        <>
          {leftIcon && <span className="flex-shrink-0">{leftIcon}</span>}
          <span>{children}</span>
          {rightIcon && <span className="flex-shrink-0">{rightIcon}</span>}
        </>
      )}
    </button>
  );
};
