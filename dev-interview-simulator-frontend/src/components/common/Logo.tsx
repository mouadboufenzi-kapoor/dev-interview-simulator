import React from 'react';

interface LogoProps {
  size?: 'sm' | 'md' | 'lg';
  showSubtitle?: boolean;
  className?: string;
}

export const Logo: React.FC<LogoProps> = ({
  size = 'md',
  showSubtitle = true,
  className = '',
}) => {
  const iconSizes = {
    sm: 'w-7 h-7',
    md: 'w-9 h-9',
    lg: 'w-11 h-11',
  };

  const titleSizes = {
    sm: 'text-base',
    md: 'text-lg',
    lg: 'text-2xl',
  };

  return (
    <div className={`flex items-center gap-2.5 select-none ${className}`}>
      {/* Brand Monogram Icon */}
      <div
        className={`${iconSizes[size]} relative flex-shrink-0 rounded-lg bg-surface border border-border flex items-center justify-center p-1.5 shadow-card`}
      >
        <svg
          viewBox="0 0 32 32"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-full h-full"
        >
          {/* Deep Navy architectural facet */}
          <path d="M8 24V8L18 16L8 24Z" className="fill-navy-900" />
          {/* Rosewood upward facet */}
          <path d="M18 8V24L24 16L18 8Z" className="fill-crimson-700" />
          {/* Warm Sand dot */}
          <circle cx="21" cy="16" r="1.5" className="fill-peach-500" />
        </svg>
      </div>

      {/* Brand Typography */}
      <div className="flex flex-col leading-none">
        <div className="flex items-center gap-1.5">
          <span
            className={`${titleSizes[size]} font-serif font-semibold tracking-tight text-navy-900`}
          >
            Dev Interview
          </span>
          <span className="inline-block w-1.5 h-1.5 rounded-full bg-crimson-700"></span>
        </div>
        {showSubtitle && (
          <span className="font-sans text-[9px] tracking-[0.22em] uppercase text-ink-muted mt-1 font-semibold">
            SIMULATOR
          </span>
        )}
      </div>
    </div>
  );
};
