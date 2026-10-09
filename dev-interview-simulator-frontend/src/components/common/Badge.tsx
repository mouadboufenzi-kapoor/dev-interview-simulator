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
      'bg-[#FAF7F5] text-[#484F59] border-[#DDD5D8]',
    navy:
      'bg-[#E6EFF8] text-[#123C69] border-[#B8D3EC] font-semibold',
    crimson:
      'bg-[#FCEBF1] text-[#AC3B61] border-[#F1BED0] font-semibold',
    burgundy:
      'bg-[#FCEBF1] text-[#AC3B61] border-[#F1BED0] font-semibold',
    peach:
      'bg-[#FBF0EB] text-[#8A4A33] border-[#EDC7B7]',
    champagne:
      'bg-[#FBF0EB] text-[#8A4A33] border-[#EDC7B7]',
    success:
      'bg-[#F0F7F3] text-[#185E37] border-[#B6DEC5]',
    danger:
      'bg-[#FDF2F2] text-[#9C2727] border-[#F3BEBE]',
    warning:
      'bg-[#FBF6ED] text-[#7A5214] border-[#E8D2A7]',
    info:
      'bg-[#E6EFF8] text-[#123C69] border-[#B8D3EC]',
    mono:
      'bg-[#FAF7F5] text-[#484F59] border-[#DDD5D8] font-mono text-[11px]',
  };

  const dotColors: Record<BadgeVariant, string> = {
    default: 'bg-[#BAB2B5]',
    navy: 'bg-[#123C69]',
    crimson: 'bg-[#AC3B61]',
    burgundy: 'bg-[#AC3B61]',
    peach: 'bg-[#EDC7B7]',
    champagne: 'bg-[#EDC7B7]',
    success: 'bg-[#185E37]',
    danger: 'bg-[#9C2727]',
    warning: 'bg-[#7A5214]',
    info: 'bg-[#123C69]',
    mono: 'bg-[#BAB2B5]',
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
