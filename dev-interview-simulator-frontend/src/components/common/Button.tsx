import React from 'react';
import { Loader2 } from 'lucide-react';

export type ButtonVariant =
  | 'primary'
  | 'secondary'
  | 'navy'
  | 'outline'
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
    'inline-flex items-center justify-center font-medium transition-all duration-150 select-none cursor-pointer focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-offset-sand-100 disabled:opacity-50 disabled:cursor-not-allowed disabled:pointer-events-none active:scale-[0.99]';

  const variantStyles: Record<ButtonVariant, string> = {
    primary:
      'bg-crimson-700 hover:bg-crimson-800 text-white border border-crimson-700 shadow-[0_2px_8px_rgba(172,59,97,0.25)] hover:shadow-[0_4px_12px_rgba(172,59,97,0.35)] focus-visible:ring-crimson-700',
    navy:
      'bg-navy-900 hover:bg-navy-950 text-white border border-navy-900 shadow-[0_2px_8px_rgba(18,60,105,0.25)] hover:shadow-[0_4px_12px_rgba(18,60,105,0.35)] focus-visible:ring-navy-900',
    secondary:
      'bg-surface hover:bg-canvas-subtle text-navy-900 border border-border hover:border-border-strong shadow-card focus-visible:ring-navy-900',
    outline:
      'bg-transparent hover:bg-navy-100 text-navy-900 hover:text-navy-950 border border-border-strong hover:border-navy-900 focus-visible:ring-navy-900',
    champagne:
      'bg-peach-500 hover:bg-peach-400 text-navy-900 font-semibold border border-peach-500 shadow-card focus-visible:ring-crimson-700',
    ghost:
      'bg-transparent hover:bg-sand-300 text-ink-secondary hover:text-navy-900 border border-transparent focus-visible:ring-navy-900',
    danger:
      'bg-danger-soft hover:bg-danger-soft-hover text-danger border border-danger-border focus-visible:ring-danger',
  };

  const sizeStyles: Record<ButtonSize, string> = {
    sm: 'text-xs px-3 py-1.5 rounded-lg gap-1.5 h-8',
    md: 'text-sm px-4 py-2 rounded-lg gap-2 h-10',
    lg: 'text-base px-6 py-2.5 rounded-xl gap-2.5 h-12',
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
