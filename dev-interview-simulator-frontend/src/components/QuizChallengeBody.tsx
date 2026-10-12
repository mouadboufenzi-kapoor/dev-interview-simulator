import type { SimulationChallengeResponse } from '../types';
import { Badge } from './common/Badge';
import { CodeBlock } from './common/CodeBlock';
import { Layers, Code2 } from 'lucide-react';

interface Props {
  challenge: SimulationChallengeResponse;
  showMultiChoiceHint: boolean;
}

export const QuizChallengeBody = ({ challenge, showMultiChoiceHint }: Props) => (
  <>
    {/* Architecture Scenario Context (if Architecture) */}
    {challenge.type === 'ARCHITECTURE' && challenge.scenarioTitle && (
      <div className="rounded-xl border border-navy-200 bg-navy-50 p-4 sm:p-5">
        <div className="flex items-start gap-3">
          <div className="p-2 rounded-lg bg-surface border border-navy-200 text-navy-900 flex-shrink-0">
            <Layers className="w-4 h-4" />
          </div>
          <div className="space-y-1">
            <p className="font-serif font-bold text-base text-navy-900">
              {challenge.scenarioTitle}
            </p>
            {challenge.scenarioDescription && (
              <p className="text-xs sm:text-sm text-ink-secondary leading-relaxed">
                {challenge.scenarioDescription}
              </p>
            )}
          </div>
        </div>
      </div>
    )}

    {/* Challenge Title */}
    <div className="space-y-3">
      <h2 className="font-serif text-2xl sm:text-3xl font-bold text-ink tracking-tight leading-snug">
        {challenge.title}
      </h2>

      {/* Context box if available */}
      {challenge.context && (
        <div className="p-4 rounded-xl bg-canvas-subtle border border-border text-sm text-ink-secondary leading-relaxed">
          <div className="text-[11px] font-mono text-ink-muted uppercase tracking-wider mb-1 font-semibold">
            Mise en situation
          </div>
          <p className="italic text-ink font-serif text-base">{challenge.context}</p>
        </div>
      )}
    </div>

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
        <span className="text-[11px] font-mono text-crimson-700 font-semibold tracking-wider uppercase">
          Question
        </span>
        {showMultiChoiceHint && (
          <Badge variant="crimson" size="sm">
            Sélectionnez toutes les options valides
          </Badge>
        )}
      </div>

      <p className="text-lg sm:text-xl font-serif text-ink font-semibold leading-relaxed">
        {challenge.question}
      </p>
    </div>
  </>
);
