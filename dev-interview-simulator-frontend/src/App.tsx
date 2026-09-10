import { useState } from 'react';

export default function App() {
  const [count, setCount] = useState(0);

  return (
    <main className="min-h-screen bg-slate-900 text-slate-100 flex items-center justify-center p-4">
      <div className="w-full max-w-md md:max-w-xl lg:max-w-2xl bg-slate-800 border border-slate-700 rounded-2xl p-6 sm:p-8 shadow-xl text-center space-y-6">
        <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold tracking-tight text-emerald-400">
          Dev Interview Simulator
        </h1>
        <p className="text-sm sm:text-base text-slate-300">
          Environnement Frontend (React 19 + TypeScript + Vite + Tailwind CSS 4) validé.
        </p>
        
        <div className="pt-2">
          <button
            onClick={() => setCount((c) => c + 1)}
            className="w-full sm:w-auto px-6 py-3 bg-emerald-500 hover:bg-emerald-600 active:bg-emerald-700 text-slate-950 font-semibold rounded-lg transition-colors cursor-pointer"
          >
            Compteur de test : {count}
          </button>
        </div>
      </div>
    </main>
  );
}