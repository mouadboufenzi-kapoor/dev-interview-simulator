import React from 'react';

interface LogoMarkProps {
  /** Taille en pixels (30 dans la navbar). */
  size?: number;
  className?: string;
}

/**
 * Logo « bulle de dialogue + curseur de terminal » — flat, sans ombre ni
 * dégradé. Couleurs pilotées par tokens (spec §8) :
 *   - corps de la bulle + queue : var(--color-logo-body)
 *   - chevron « > » du terminal  : var(--color-nav)
 *   - trait du curseur           : var(--color-logo-cursor)
 * Les var() suivent automatiquement la palette (encre/soleil/menthe) et le mode.
 */
export const LogoMark: React.FC<LogoMarkProps> = ({ size = 30, className = '' }) => (
  <svg
    viewBox="0 0 64 64"
    width={size}
    height={size}
    className={`flex-shrink-0 select-none ${className}`}
    role="img"
    aria-label="InterviewLab"
  >
    {/* Corps de la bulle */}
    <rect
      x="6"
      y="8"
      width="52"
      height="38"
      rx="12"
      style={{ fill: 'var(--color-logo-body)' }}
    />
    {/* Queue de la bulle */}
    <path d="M16 44 L14 58 L30 46 Z" style={{ fill: 'var(--color-logo-body)' }} />
    {/* Chevron « > » du terminal */}
    <path
      d="M22 19 L32 27 L22 35"
      fill="none"
      style={{ stroke: 'var(--color-nav)' }}
      strokeWidth="4"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    {/* Trait du curseur (accent) */}
    <path
      d="M36 35 H46"
      style={{ stroke: 'var(--color-logo-cursor)' }}
      strokeWidth="4"
      strokeLinecap="round"
    />
  </svg>
);
