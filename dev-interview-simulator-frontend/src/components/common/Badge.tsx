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
  const variantStyles: Record<BadgeVariant, string> = {
    default:
      'bg-canvas-subtle text-ink-secondary border-border',
    navy:
      'bg-navy-100 text-navy-900 border-navy-200 font-semibold',
    crimson:
      'bg-crimson-100 text-crimson-700 border-crimson-200 font-semibold',
    burgundy:
      'bg-crimson-100 text-crimson-700 border-crimson-200 font-semibold',
    peach:
      'bg-peach-100 text-peach-ink border-peach-500',
    champagne:
      'bg-peach-100 text-peach-ink border-peach-500',
    success:
      'bg-success-soft text-success border-success-border',
    danger:
      'bg-danger-soft text-danger border-danger-border',
    warning:
      'bg-warning-soft text-warning border-warning-border',
    info:
      'bg-navy-100 text-navy-900 border-navy-200',
    mono:
      'bg-canvas-subtle text-ink-secondary border-border font-mono text-[11px]',
  };

  const dotColors: Record<BadgeVariant, string> = {
    default: 'bg-border-strong',
    navy: 'bg-navy-900',
    crimson: 'bg-crimson-700',
    burgundy: 'bg-crimson-700',
    peach: 'bg-peach-500',
    champagne: 'bg-peach-500',
    success: 'bg-success',
    danger: 'bg-danger',
    warning: 'bg-warning',
    info: 'bg-navy-900',
    mono: 'bg-border-strong',
  };

  const sizeStyles = {
    sm: 'text-[11px] px-2 py-0.5',
    md: 'text-xs px-2.5 py-1',
  };

  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-md border font-medium leading-none tracking-tight select-none ${variantStyles[variant]} ${sizeStyles[size]} ${className}`}
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
