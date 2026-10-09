import React, { useState } from 'react';
import { Copy, Check, Code2 } from 'lucide-react';

interface CodeBlockProps {
  code: string;
  language?: string | null;
  filename?: string;
  showLineNumbers?: boolean;
  className?: string;
}

export const CodeBlock: React.FC<CodeBlockProps> = ({
  code,
  language = null,
  filename = 'Source',
  showLineNumbers = true,
  className = '',
}) => {
  const [copied, setCopied] = useState(false);

  const lines = code.trim().split('\n');

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(code);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.error('Failed to copy code: ', err);
    }
  };

  return (
    <div
      className={`rounded-xl border border-[#DDD5D8] bg-white overflow-hidden shadow-[0_1px_3px_rgba(18,60,105,0.03)] text-sm font-mono ${className}`}
    >
      {/* Editor Top Bar */}
      <div className="flex items-center justify-between px-3.5 py-2.5 bg-[#FAF7F5] border-b border-[#DDD5D8] select-none">
        <div className="flex items-center gap-2">
          {/* Subtle dots */}
          <div className="flex items-center gap-1.5 mr-2">
            <span className="w-2.5 h-2.5 rounded-full bg-[#BAB2B5]" />
            <span className="w-2.5 h-2.5 rounded-full bg-[#BAB2B5]" />
            <span className="w-2.5 h-2.5 rounded-full bg-[#BAB2B5]" />
          </div>

          <Code2 className="w-3.5 h-3.5 text-[#123C69]" />
          <span className="text-xs font-semibold text-[#123C69]">
            {filename}
          </span>
          {language && (
            <span className="text-[10px] uppercase tracking-wider px-2 py-0.5 rounded-md bg-[#FCEBF1] text-[#AC3B61] border border-[#F1BED0] font-semibold">
              {language}
            </span>
          )}
        </div>

        <button
          onClick={handleCopy}
          type="button"
          className="flex items-center gap-1.5 text-xs text-[#123C69] hover:text-[#0B1E34] px-2.5 py-1 rounded-md bg-white hover:bg-[#EEE2DC] border border-[#DDD5D8] transition-colors cursor-pointer shadow-[0_1px_2px_rgba(18,60,105,0.03)]"
          title="Copier le code"
        >
          {copied ? (
            <>
              <Check className="w-3.5 h-3.5 text-[#185E37]" />
              <span className="text-[#185E37] text-[11px] font-semibold">Copié</span>
            </>
          ) : (
            <>
              <Copy className="w-3.5 h-3.5" />
              <span className="text-[11px] font-medium">Copier</span>
            </>
          )}
        </button>
      </div>

      {/* Code Container with Clean Line Numbers */}
      <div className="overflow-x-auto p-4 text-xs sm:text-sm leading-relaxed text-[#102136] bg-[#FFFFFF]">
        <pre className="flex">
          {showLineNumbers && (
            <div
              className="select-none text-[#BAB2B5] text-right pr-4 border-r border-[#DDD5D8] mr-4 font-mono text-xs flex flex-col"
              aria-hidden="true"
            >
              {lines.map((_, i) => (
                <span key={i} className="leading-relaxed">
                  {(i + 1).toString().padStart(2, '0')}
                </span>
              ))}
            </div>
          )}
          <code className="flex-1 font-mono leading-relaxed overflow-x-auto text-[#102136]">
            {lines.map((line, i) => (
              <div key={i} className="whitespace-pre">
                {line || ' '}
              </div>
            ))}
          </code>
        </pre>
      </div>
    </div>
  );
};
