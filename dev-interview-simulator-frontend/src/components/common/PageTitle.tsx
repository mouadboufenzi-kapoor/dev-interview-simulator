import React from 'react';

type PageTitleSize =
  | 'xs'
  | 'sm'
  | 'md'
  | 'lg'
  | 'xl'
  | 'hero'
  | 'hero-compact';
type PageTitleTone = 'navy' | 'ink';
type PageTitleTag = 'h1' | 'h2' | 'h3';

interface PageTitleProps {
  size?: PageTitleSize;
  tone?: PageTitleTone;
  /** Balise sémantique (h1/h2/h3) — défaut h1. */
  as?: PageTitleTag;
  className?: string;
  children: React.ReactNode;
}

/** Échelle typographique éditoriale (titre serif accent navy), centralisée. */
const sizeStyles: Record<PageTitleSize, string> = {
  xs: 'text-base font-serif font-bold',
  sm: 'text-xl font-serif font-bold',
  md: 'text-2xl font-serif font-bold',
  lg: 'text-3xl font-serif font-bold',
  xl: 'font-serif text-4xl font-semibold tracking-tight',
  hero: 'font-serif text-3xl sm:text-5xl lg:text-6xl font-semibold tracking-tight leading-[1.12]',
  'hero-compact': 'font-serif text-3xl sm:text-4xl lg:text-5xl font-semibold tracking-tight leading-tight',
};

const toneStyles: Record<PageTitleTone, string> = {
  navy: 'text-navy-900',
  ink: 'text-ink',
};

export const PageTitle: React.FC<PageTitleProps> = ({
  size = 'md',
  tone = 'navy',
  as: Tag = 'h1',
  className = '',
  children,
}) => (
  <Tag className={`${sizeStyles[size]} ${toneStyles[tone]} ${className}`.trim()}>
    {children}
  </Tag>
);
