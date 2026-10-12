import React from 'react';
import { LogoMark } from './LogoMark';

export const Footer: React.FC = () => {
  return (
    <footer className="w-full border-t border-border bg-sand-100/75 navbar-dots py-8 px-4 sm:px-6 mt-auto">
      <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-ink-secondary">
        <div className="flex flex-wrap items-center justify-center gap-x-2 gap-y-1 text-center">
          <LogoMark size={18} />
          <span className="font-serif font-semibold text-navy-900">
            Interview Simulator
          </span>
          <span className="text-border-strong hidden sm:inline">—</span>
          <span className="text-[11px] sm:text-xs">Simulation d'entretiens techniques</span>
        </div>

        <div className="flex flex-wrap items-center justify-center gap-x-6 gap-y-1 text-[11px] font-sans text-ink-muted">
          <div className="flex items-center gap-1.5">
            <span className="inline-block w-1.5 h-1.5 rounded-full bg-success" />
            <span>Moteur d'évaluation actif</span>
          </div>
        </div>
      </div>
    </footer>
  );
};
