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
    'inline-flex items-center justify-center font-medium transition-all duration-150 select-none cursor-pointer focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-offset-[#EEE2DC] disabled:opacity-50 disabled:cursor-not-allowed disabled:pointer-events-none active:scale-[0.99]';

  const variantStyles: Record<ButtonVariant, string> = {
    primary:
      'bg-[#AC3B61] hover:bg-[#8D2B4C] text-white border border-[#AC3B61] shadow-[0_2px_8px_rgba(172,59,97,0.25)] hover:shadow-[0_4px_12px_rgba(172,59,97,0.35)] focus-visible:ring-[#AC3B61]',
    navy:
      'bg-[#123C69] hover:bg-[#0B1E34] text-white border border-[#123C69] shadow-[0_2px_8px_rgba(18,60,105,0.25)] hover:shadow-[0_4px_12px_rgba(18,60,105,0.35)] focus-visible:ring-[#123C69]',
    secondary:
      'bg-white hover:bg-[#FAF7F5] text-[#123C69] border border-[#DDD5D8] hover:border-[#BAB2B5] shadow-[0_1px_2px_rgba(18,60,105,0.04)] focus-visible:ring-[#123C69]',
    outline:
      'bg-transparent hover:bg-[#E6EFF8] text-[#123C69] hover:text-[#0B1E34] border border-[#BAB2B5] hover:border-[#123C69] focus-visible:ring-[#123C69]',
    champagne:
      'bg-[#EDC7B7] hover:bg-[#E2B5A2] text-[#123C69] font-semibold border border-[#EDC7B7] shadow-[0_1px_3px_rgba(18,60,105,0.06)] focus-visible:ring-[#AC3B61]',
    ghost:
      'bg-transparent hover:bg-[#E8DAD3] text-[#484F59] hover:text-[#123C69] border border-transparent focus-visible:ring-[#123C69]',
    danger:
      'bg-[#FDF2F2] hover:bg-[#FBE4E4] text-[#9C2727] border border-[#F3BEBE] focus-visible:ring-[#9C2727]',
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
