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
import { Check, GripVertical, X } from 'lucide-react';
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
  /** Expiration : présente l'ordre attendu comme correction sans fausse réponse utilisateur. */
  timedOut?: boolean;
}

/** État d'une position en mode correction. */
type StepStatus = 'correct' | 'incorrect' | null;

const SortableStep = ({
  id,
  index,
  content,
  disabled,
  status,
}: {
  id: number;
  index: number;
  content: string;
  disabled: boolean;
  status: StepStatus;
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
      ? 'text-success'
      : status === 'incorrect'
        ? 'text-danger'
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

      <div className="min-w-0 flex-1">
        <p className="text-sm leading-snug text-ink break-words">{content}</p>
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
// Après validation : « Votre classement » (l'ordre réellement soumis) est le
// seul à porter la couleur — ligne verte si bien placée / rouge si mal placée ;
// « Ordre attendu » est une référence neutre, sans aucune couleur ni icône.
export const QuizSequenceList = ({
  challenge,
  orderedOptionIds,
  onChange,
  disabled,
  feedback,
  timedOut = false,
}: Props) => {
  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 4 } }),
    useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates })
  );

  const optionById = new Map(challenge.options.map((option) => [option.id, option]));
  const expectedOrder = feedback?.expectedOrder ?? null;
  const isCorrection =
    !timedOut && !!feedback && !!expectedOrder && expectedOrder.length === orderedOptionIds.length;
  const showExpectedOrder = Boolean(expectedOrder?.length) && (isCorrection || timedOut);

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
      {timedOut && (
        <p className="text-sm font-semibold text-danger" role="status">
          Temps écoulé — voici l’ordre attendu.
        </p>
      )}

      {isCorrection ? (
        <p
          className={`text-xs font-sans font-semibold uppercase tracking-wider ${
            allCorrect ? 'text-success' : 'text-ink-secondary'
          }`}
        >
          {correctCount} / {orderedOptionIds.length} étapes bien placées
        </p>
      ) : !timedOut ? (
        <p className="text-xs font-sans font-semibold uppercase tracking-wider text-ink-muted">
          Remets les étapes dans l'ordre logique
        </p>
      ) : null}

      {isCorrection && (
        <p className="text-xs font-sans font-semibold uppercase tracking-wider text-ink-muted">
          Votre classement
        </p>
      )}

      {!timedOut && (
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
                  />
                );
              })}
            </div>
          </SortableContext>
        </DndContext>
      )}

      {/* Ordre attendu : référence purement neutre — liste numérotée, sans
          fond/bordure colorés et sans icône de correction : le rouge/vert
          ne sert qu'à la performance de l'utilisateur, dans son classement. */}
      {showExpectedOrder && expectedOrder && (
        <div className="space-y-2 pt-1">
          <p className="text-xs font-sans font-semibold uppercase tracking-wider text-ink-muted">
            Ordre attendu
          </p>
          <ol className="space-y-2">
            {expectedOrder.map((expectedId, position) => (
              <li
                key={expectedId}
                className="flex items-center gap-3 rounded-xl border border-border bg-surface p-3.5"
              >
                <span className="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-lg font-mono text-xs font-bold bg-navy-100 text-navy-900">
                  {position + 1}
                </span>
                <p className="min-w-0 flex-1 text-sm leading-snug text-ink break-words">
                  {optionById.get(expectedId)?.content ?? ''}
                </p>
              </li>
            ))}
          </ol>
        </div>
      )}

      {!disabled && !timedOut && (
        <p className="text-[11px] text-ink-muted">
          Glisse une étape (souris ou doigt) pour changer sa position.
        </p>
      )}
    </div>
  );
};
