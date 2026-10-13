import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  type DragEndEvent,
} from '@dnd-kit/core';
import {
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  verticalListSortingStrategy,
  arrayMove,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { Check, CornerDownRight, GripVertical, X } from 'lucide-react';
import type { SimulationChallengeResponse, SubmitAnswerResponse } from '../types';

interface Props {
  challenge: SimulationChallengeResponse;
  /** Ids des étapes dans l'ordre courant de l'utilisateur (position 1 = première). */
  orderedOptionIds: number[];
  onChange: (orderedIds: number[]) => void;
  /** Verrouillé après validation (feedback affiché). */
  disabled: boolean;
  /** Présent après validation : colore chaque position et montre l'ordre attendu. */
  feedback?: SubmitAnswerResponse | null;
}

/** État d'une position en mode correction. */
type StepStatus = 'correct' | 'incorrect' | null;

const SortableStep = ({
  id,
  index,
  content,
  disabled,
  status,
  expectedContent,
  stepExplanation,
}: {
  id: number;
  index: number;
  content: string;
  disabled: boolean;
  status: StepStatus;
  expectedContent: string | null;
  stepExplanation: string | null;
}) => {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({
    id: String(id),
    disabled,
  });

  const frameStyle =
    status === 'correct'
      ? 'border-success-border bg-success-soft'
      : status === 'incorrect'
      ? 'border-danger-border bg-danger-soft'
      : 'border-border bg-surface';

  const badgeStyle =
    status === 'correct'
      ? 'bg-success text-white'
      : status === 'incorrect'
      ? 'bg-danger text-white'
      : 'bg-navy-100 text-navy-900';

  return (
    <div
      ref={setNodeRef}
      style={{ transform: CSS.Transform.toString(transform), transition }}
      // touch-none : indispensable au drag tactile — sans lui le navigateur
      // capte le geste vertical comme un scroll (pointercancel) et le
      // déplacement ne démarre jamais sur mobile.
      className={`flex items-center gap-3 rounded-xl border p-3.5 min-h-[3.5rem] touch-none select-none ${frameStyle} ${
        isDragging ? 'relative z-10 shadow-elevated' : ''
      } ${disabled ? 'cursor-default' : 'cursor-grab active:cursor-grabbing'}`}
      {...attributes}
      {...listeners}
    >
      <span
        className={`flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-lg font-mono text-xs font-bold ${badgeStyle}`}
      >
        {index + 1}
      </span>

      <div className="min-w-0 flex-1 space-y-1">
        <p className="text-sm leading-snug text-ink break-words">{content}</p>
        {status === 'incorrect' && expectedContent && (
          <p className="flex items-start gap-1 text-[11px] leading-snug text-ink-muted">
            <CornerDownRight className="w-3 h-3 mt-0.5 flex-shrink-0" />
            <span>Position attendue : « {expectedContent} »</span>
          </p>
        )}
        {status === 'incorrect' && stepExplanation && (
          <p className="text-[11px] leading-snug text-ink-muted italic">{stepExplanation}</p>
        )}
      </div>

      {status === null ? (
        <GripVertical className="h-4 w-4 flex-shrink-0 text-ink-muted" />
      ) : status === 'correct' ? (
        <Check className="h-4 w-4 flex-shrink-0 text-success" />
      ) : (
        <X className="h-4 w-4 flex-shrink-0 text-danger" />
      )}
    </div>
  );
};

// Raisonnement séquentiel : liste verticale d'étapes déplaçables (drag & drop
// tactile + desktop via @dnd-kit — PointerSensor couvre souris ET doigt, d'où
// l'absence de TouchSensor parallèle). L'ordre affiché EST la réponse soumise —
// l'ordre attendu n'est jamais côté client (voir mapToResponse backend).
// Après validation : chaque position devient verte (à sa bonne place) ou rouge
// (avec la position attendue + la raison de l'étape sous le libellé).
export const QuizSequenceList = ({
  challenge,
  orderedOptionIds,
  onChange,
  disabled,
  feedback,
}: Props) => {
  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 4 } }),
    useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates })
  );

  const optionById = new Map(challenge.options.map((option) => [option.id, option]));
  const expectedOrder = feedback?.expectedOrder ?? null;
  const isCorrection =
    !!feedback && !!expectedOrder && expectedOrder.length === orderedOptionIds.length;

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;
    const oldIndex = orderedOptionIds.findIndex((id) => String(id) === active.id);
    const newIndex = orderedOptionIds.findIndex((id) => String(id) === over.id);
    if (oldIndex < 0 || newIndex < 0) return;
    onChange(arrayMove(orderedOptionIds, oldIndex, newIndex));
  };

  const correctCount = isCorrection
    ? orderedOptionIds.filter((id, index) => expectedOrder?.[index] === id).length
    : 0;
  const allCorrect = isCorrection && correctCount === orderedOptionIds.length;

  return (
    <div className="space-y-3">
      {isCorrection ? (
        <p
          className={`text-xs font-sans font-semibold uppercase tracking-wider ${
            allCorrect ? 'text-success' : 'text-ink-secondary'
          }`}
        >
          {correctCount} / {orderedOptionIds.length} étapes bien placées
        </p>
      ) : (
        <p className="text-xs font-sans font-semibold uppercase tracking-wider text-ink-muted">
          Remets les étapes dans l'ordre logique
        </p>
      )}

      <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
        <SortableContext
          items={orderedOptionIds.map(String)}
          strategy={verticalListSortingStrategy}
        >
          <div className="space-y-2.5">
            {orderedOptionIds.map((optionId, index) => {
              const expectedId = isCorrection ? expectedOrder?.[index] : null;
              const misplaced = isCorrection && expectedId !== optionId;
              return (
                <SortableStep
                  key={optionId}
                  id={optionId}
                  index={index}
                  content={optionById.get(optionId)?.content ?? ''}
                  disabled={disabled}
                  status={isCorrection ? (misplaced ? 'incorrect' : 'correct') : null}
                  expectedContent={
                    misplaced && expectedId != null
                      ? (optionById.get(expectedId)?.content ?? null)
                      : null
                  }
                  stepExplanation={
                    misplaced
                      ? (feedback?.corrections.find((c) => c.optionId === optionId)?.explanation ??
                        null)
                      : null
                  }
                />
              );
            })}
          </div>
        </SortableContext>
      </DndContext>

      {!disabled && (
        <p className="text-[11px] text-ink-muted">
          Glisse une étape (souris ou doigt) pour changer sa position.
        </p>
      )}
    </div>
  );
};
