import React, { useState } from 'react';
import { Copy, Check, Code2 } from 'lucide-react';

/* Textes FR embarqués — regroupés ici comme points de bascule i18n (étape 12).
   Pour une locale EN, remplacer ces valeurs (ou les injecter via props/contexte). */
const DEFAULT_FILENAME = 'Source';
const SCROLL_HINT = '↔ glisser';
const COPY_LABEL = 'Copier';
const COPIED_LABEL = 'Copié';
const COPY_TITLE = 'Copier le code';

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
  filename = DEFAULT_FILENAME,
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
      className={`rounded-xl border border-border bg-surface overflow-hidden max-w-full shadow-card text-sm font-mono ${className}`}
    >
      {/* Editor Top Bar */}
      <div className="flex items-center justify-between px-3.5 py-2.5 bg-canvas-subtle border-b border-border select-none">
        <div className="flex items-center gap-2">
          {/* Subtle dots */}
          <div className="flex items-center gap-1.5 mr-2">
            <span className="w-2.5 h-2.5 rounded-full bg-border-strong" />
            <span className="w-2.5 h-2.5 rounded-full bg-border-strong" />
            <span className="w-2.5 h-2.5 rounded-full bg-border-strong" />
          </div>

          <Code2 className="w-3.5 h-3.5 text-navy-900" />
          <span className="text-xs font-semibold text-navy-900">
            {filename}
          </span>
          {language && (
            <span className="text-[10px] uppercase tracking-wider px-2 py-0.5 rounded-md bg-crimson-100 text-crimson-700 border border-crimson-200 font-semibold">
              {language}
            </span>
          )}

          {/* Mobile-only scroll hint: horizontal gesture to see the whole snippet */}
          <span className="sm:hidden ml-1 text-[10px] text-ink-muted font-medium whitespace-nowrap">
            {SCROLL_HINT}
          </span>
        </div>

        <button
          onClick={handleCopy}
          type="button"
          className="flex items-center gap-1.5 text-xs text-navy-900 hover:text-navy-950 dark:hover:text-white px-2.5 py-1 rounded-md bg-surface hover:bg-sand-100 border border-border transition-colors cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas shadow-card"
          title={COPY_TITLE}
        >
          {copied ? (
            <>
              <Check className="w-3.5 h-3.5 text-success" />
              <span className="text-success text-[11px] font-semibold">{COPIED_LABEL}</span>
            </>
          ) : (
            <>
              <Copy className="w-3.5 h-3.5" />
              <span className="text-[11px] font-medium">{COPY_LABEL}</span>
            </>
          )}
        </button>
      </div>

      {/* Code Container: width is hard-capped to the card (max-w-full above),
          horizontal scrolling happens ONLY inside this div.
          min-w-max = the <pre> is at least as wide as the longest line,
          so long lines trigger an internal scrollbar instead of stretching the page.
          The line-number gutter stays sticky (left-0) while scrolling. */}
      <div className="w-full overflow-x-auto overscroll-x-contain p-4 text-xs sm:text-sm leading-relaxed text-ink bg-surface">
        <pre className="flex min-w-max">
          {showLineNumbers && (
            <div
              className="sticky left-0 z-10 select-none bg-surface text-border-strong text-right pr-4 border-r border-border mr-4 font-mono text-xs flex flex-col"
              aria-hidden="true"
            >
              {lines.map((_, i) => (
                <span key={i} className="leading-relaxed">
                  {(i + 1).toString().padStart(2, '0')}
                </span>
              ))}
            </div>
          )}
          <code className="font-mono leading-relaxed text-ink">
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
