import React from 'react';
import { LogoMark } from './LogoMark';

// Footer Contraste : fond --color-nav, bordure haute --bw, texte --color-nav-text.
// Liens en 12px, copyright en Space Mono (spec §16). Pas de blur ni dots.
export const Footer: React.FC = () => {
  return (
    <footer className="w-full border-t-2 border-border bg-nav py-8 px-4 sm:px-6 mt-auto">
      <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-nav-text">
        <div className="flex flex-wrap items-center justify-center gap-x-2 gap-y-1 text-center">
          <LogoMark size={18} />
          <span className="font-bold text-nav-text">
            Interview<span style={{ color: 'var(--color-wordmark-accent)' }}>Lab</span>
          </span>
          <span className="text-nav-muted hidden sm:inline">—</span>
          <span className="text-[11px] sm:text-xs">Simulation d'entretiens techniques</span>
        </div>

        <div className="flex flex-wrap items-center justify-center gap-x-6 gap-y-1 text-[12px] font-mono text-nav-muted">
          <div className="flex items-center gap-1.5">
            <span className="inline-block w-1.5 h-1.5 rounded-full bg-success" />
            <span>500+ QUESTIONS POUR PROGRESSER</span>
          </div>
        </div>
      </div>
    </footer>
  );
};
