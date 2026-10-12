import type { Dispatch, SetStateAction } from 'react';
import type { AdminChallengeRequest } from '../api/adminApi';
import type { ChallengeType } from '../types';
import { Field } from './common/Field';
import { fieldInput, fieldLabel } from '../styles/ui';

interface Props {
  formData: AdminChallengeRequest;
  setFormData: Dispatch<SetStateAction<AdminChallengeRequest>>;
  /** Types autorisés (union des profils sélectionnés). */
  allowedTypes: ChallengeType[];
}

export const AdminChallengeBasics = ({ formData, setFormData, allowedTypes }: Props) => {
  const contextField = (
    <Field label="Contexte">
      <textarea
        value={formData.context}
        onChange={e => setFormData({ ...formData, context: e.target.value })}
        className={fieldInput}
        rows={2}
      />
    </Field>
  );

  const pointsTimeFields = (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
      <Field label="Points">
        <input
          type="number"
          required
          value={formData.points}
          onChange={e => setFormData({ ...formData, points: parseInt(e.target.value) })}
          className={fieldInput}
        />
      </Field>
      <Field label="Temps estimé (secondes)">
        <input
          type="number"
          min={1}
          required={formData.type !== 'ARCHITECTURE'}
          value={formData.estimatedTimeSeconds ?? ''}
          onChange={e => setFormData({ ...formData, estimatedTimeSeconds: e.target.value ? parseInt(e.target.value) : undefined })}
          className={fieldInput}
        />
      </Field>
    </div>
  );

  return (
    <>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Field label="Titre">
          <input required value={formData.title} onChange={e => setFormData({ ...formData, title: e.target.value })} className={fieldInput} />
        </Field>

        <Field label="Type">
          <select required value={formData.type} onChange={e => setFormData({ ...formData, type: e.target.value as ChallengeType })} className={fieldInput}>
            {allowedTypes.map(t => (
              <option key={t} value={t}>{t}</option>
            ))}
          </select>
        </Field>

        <Field label="Difficulté">
          <select required value={formData.difficulty} onChange={e => setFormData({ ...formData, difficulty: e.target.value })} className={fieldInput}>
            <option value="JUNIOR">JUNIOR</option>
            <option value="INTERMEDIATE">INTERMEDIATE</option>
            <option value="SENIOR">SENIOR</option>
          </select>
        </Field>

        <Field label="Type de sélection">
          <select required value={formData.selectionType} onChange={e => setFormData({ ...formData, selectionType: e.target.value })} className={fieldInput}>
            <option value="SINGLE_CHOICE">SINGLE_CHOICE</option>
            <option value="MULTIPLE_CHOICE">MULTIPLE_CHOICE</option>
          </select>
        </Field>
      </div>

      {formData.type !== 'ARCHITECTURE' && contextField}

      <Field label="Question *">
        <textarea required value={formData.question} onChange={e => setFormData({ ...formData, question: e.target.value })} className={fieldInput} rows={2} />
      </Field>

      <Field label="Explication globale">
        <textarea value={formData.explanation} onChange={e => setFormData({ ...formData, explanation: e.target.value })} className={fieldInput} rows={2} />
      </Field>

      {formData.type === 'ARCHITECTURE' ? (
        <details className="pt-1">
          <summary className={`cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${fieldLabel} select-none`}>
            Champs avancés (contexte, points, temps estimé)
          </summary>
          <div className="mt-6 space-y-6">
            {contextField}
            {pointsTimeFields}
          </div>
        </details>
      ) : (
        pointsTimeFields
      )}
    </>
  );
};
