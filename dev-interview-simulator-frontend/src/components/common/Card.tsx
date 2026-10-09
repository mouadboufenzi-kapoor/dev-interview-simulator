import React from 'react';

interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'elevated' | 'interactive' | 'active';
  padding?: 'none' | 'sm' | 'md' | 'lg';
  activeBorderColor?: 'burgundy' | 'champagne' | 'navy';
}

export const Card: React.FC<CardProps> = ({
  children,
  variant = 'default',
  padding = 'md',
  activeBorderColor = 'burgundy',
  className = '',
  ...props
}) => {
  const paddingStyles = {
    none: '',
    sm: 'p-3.5 sm:p-4',
    md: 'p-5 sm:p-6',
    lg: 'p-6 sm:p-8',
  };

  const activeColorStyles = {
    burgundy: 'border-[#AC3B61] bg-[#FCF4F7] shadow-[0_4px_16px_rgba(172,59,97,0.08)] ring-1 ring-[#AC3B61]',
    navy: 'border-[#123C69] bg-[#F1F6FB] shadow-[0_4px_16px_rgba(18,60,105,0.08)] ring-1 ring-[#123C69]',
    champagne: 'border-[#EDC7B7] bg-[#FDF7F5] shadow-[0_4px_16px_rgba(237,199,183,0.12)] ring-1 ring-[#EDC7B7]',
  };

  const variantStyles = {
    default: 'bg-white border-[#DDD5D8] text-[#102136] shadow-[0_1px_3px_rgba(18,60,105,0.03)]',
    elevated: 'bg-white border-[#DDD5D8] text-[#102136] shadow-[0_4px_16px_rgba(18,60,105,0.06)]',
    interactive:
      'bg-white border-[#DDD5D8] hover:border-[#BAB2B5] hover:shadow-[0_2px_8px_rgba(18,60,105,0.06)] transition-all duration-150 cursor-pointer text-[#102136]',
    active: `bg-white ${activeColorStyles[activeBorderColor]} transition-all duration-150 text-[#102136]`,
  };

  return (
    <div
      className={`rounded-2xl border ${variantStyles[variant]} ${paddingStyles[padding]} ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};
