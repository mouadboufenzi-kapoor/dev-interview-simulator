import type { SimulationChallengeResponse } from '../types';
import { Badge } from './common/Badge';
import { CodeBlock } from './common/CodeBlock';
import { Code2 } from 'lucide-react';

interface Props {
  challenge: SimulationChallengeResponse;
  showMultiChoiceHint: boolean;
}

export const QuizChallengeBody = ({ challenge, showMultiChoiceHint }: Props) => (
  <>
    {/* Architecture Scenario Context (if Architecture) */}
    {challenge.type === 'ARCHITECTURE' && challenge.scenarioTitle && (
      <header className="space-y-1.5 border-b border-border-subtle pb-4">
        <p className="font-mono text-[11px] font-semibold uppercase tracking-wider text-ink-muted">
          Scénario
        </p>
        <p className="font-serif text-xl font-bold text-ink tracking-tight leading-snug break-words sm:text-2xl">
          {challenge.scenarioTitle}
        </p>
        {challenge.scenarioDescription && (
          <p className="text-xs sm:text-sm text-ink-secondary leading-relaxed break-words">
            {challenge.scenarioDescription}
          </p>
        )}
      </header>
    )}

    {/* Context box if available (le titre du challenge n'est plus affiché) */}
    {challenge.context && (
      <div className="rounded-none border-l-4 border-y-0 border-r-0 border-brand bg-canvas-subtle pl-4 py-3 text-sm text-ink-secondary leading-relaxed break-words">
        <div className="text-[11px] font-mono text-ink-muted uppercase tracking-wider mb-1 font-semibold">
          Mise en situation
        </div>
        <p className="not-italic text-ink font-sans text-base">{challenge.context}</p>
      </div>
    )}

    {/* Code Snippet for Code Review */}
    {challenge.codeSnippet && (
      <div className="space-y-2">
        <div className="flex items-center justify-between text-xs text-ink-secondary">
          <span className="font-sans font-medium flex items-center gap-1.5 text-navy-900">
            <Code2 className="w-4 h-4 text-crimson-700" />
            Extrait de code source à inspecter
          </span>
          {challenge.codeLanguage && (
            <Badge variant="mono" size="sm">
              {challenge.codeLanguage}
            </Badge>
          )}
        </div>

        <CodeBlock
          code={challenge.codeSnippet}
          language={challenge.codeLanguage}
          filename="SourceSnippet"
        />
      </div>
    )}

    {/* Question Prompt */}
    <div className="space-y-2 pt-2 border-t border-border">
      <div className="flex items-center gap-2">
        <span className="text-[11px] font-mono text-accent-text font-semibold tracking-wider uppercase">
          Question
        </span>
        {showMultiChoiceHint && (
          <Badge variant="crimson" size="sm">
            Sélectionnez toutes les options valides
          </Badge>
        )}
      </div>

      <p className="text-lg sm:text-xl font-serif text-ink font-semibold leading-relaxed break-words">
        {challenge.question}
      </p>
    </div>
  </>
);
