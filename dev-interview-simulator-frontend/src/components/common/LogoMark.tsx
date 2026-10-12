import React from 'react';

interface LogoMarkProps {
  /** Taille en pixels (30 dans la navbar). */
  size?: number;
  className?: string;
}

/**
 * Logo « bulle de dialogue + curseur de terminal » — flat, sans ombre ni dégradé.
 * - Corps : navy-900 (#123C69 en jour), navy-700 en nuit pour rester lisible
 *   sur la navbar sombre (tokens existants, bascule dark: classique).
 * - Chevron (#E8E2D8) et trait terracotta (#D9694B) : couleurs de marque fixes
 *   identiques dans les deux thèmes (elles vivent SUR le corps navy).
 */
export const LogoMark: React.FC<LogoMarkProps> = ({ size = 30, className = '' }) => (
  <svg
    viewBox="0 0 64 64"
    width={size}
    height={size}
    className={`flex-shrink-0 select-none ${className}`}
    role="img"
    aria-label="Dev Interview Simulator"
  >
    {/* Corps de la bulle */}
    <rect
      x="6"
      y="8"
      width="52"
      height="38"
      rx="12"
      className="fill-navy-900 dark:fill-navy-700"
    />
    {/* Chevron de la bulle */}
    <path d="M16 44 L14 58 L30 46 Z" className="fill-navy-900 dark:fill-navy-700" />
    {/* Chevron « > » du terminal */}
    <path
      d="M22 19 L32 27 L22 35"
      fill="none"
      stroke="#E8E2D8"
      strokeWidth="4"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    {/* Trait du curseur (accent terracotta) */}
    <path d="M36 35 H46" stroke="#D9694B" strokeWidth="4" strokeLinecap="round" />
  </svg>
);
