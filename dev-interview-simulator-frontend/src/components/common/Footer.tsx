import React from 'react';
import { Sparkles } from 'lucide-react';

export const Footer: React.FC = () => {
  return (
    <footer className="w-full border-t border-[#DDD5D8] bg-[#EEE2DC]/75 py-8 px-4 sm:px-6 mt-auto">
      <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-[#484F59]">
        <div className="flex items-center gap-2">
          <Sparkles className="w-4 h-4 text-[#AC3B61]" />
          <span className="font-serif font-semibold text-[#123C69]">
            Dev Interview Simulator
          </span>
          <span className="text-[#BAB2B5]">—</span>
          <span>Simulation d'entretiens techniques pour développeurs</span>
        </div>

        <div className="flex items-center gap-6 text-[11px] font-sans text-[#797E88]">
          <div className="flex items-center gap-1.5">
            <span className="inline-block w-1.5 h-1.5 rounded-full bg-[#185E37]" />
            <span>Moteur d'évaluation actif</span>
          </div>
          <div>PostgreSQL • Spring Boot • React</div>
        </div>
      </div>
    </footer>
  );
};
