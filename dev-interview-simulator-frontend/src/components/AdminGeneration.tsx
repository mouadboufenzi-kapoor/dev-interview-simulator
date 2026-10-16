import { useState, useEffect } from 'react';
import type { GenerationRequest, GenerationDifficulty } from '../api/adminApi';
import { generationApi } from '../api/adminApi';
import { adminProfileApi, type AdminProfile } from '../api/adminApi';
import { simulationApi } from '../api/simulationApi';
import type { Category, Skill, ChallengeType } from '../types';
import { MultiSelect } from './common/MultiSelect';
import { Button } from './common/Button';
import { Badge } from './common/Badge';
import { Field } from './common/Field';
import { fieldInput } from '../styles/ui';
import { AlertCircle } from 'lucide-react';

const ALL_CHALLENGE_TYPES: ChallengeType[] = [
  'SITUATIONAL_QCM',
  'PROBLEM_SOLVING',
  'CODE_REVIEW',
  'ARCHITECTURE',
  'SEQUENTIAL_REASONING',
];

const DIFFICULTIES: GenerationDifficulty[] = [
  'JUNIOR',
  'INTERMEDIATE',
  'ADVANCED',
];

const DEFAULT_COUNT = 3;

export const AdminGeneration = () => {
  const [profiles, setProfiles] = useState<AdminProfile[]>([]);
  const [profilesLoading, setProfilesLoading] = useState(true);
  const [categories, setCategories] = useState<Category[]>([]);
  const [skills, setSkills] = useState<Skill[]>([]);
  const [taxonomyLoading, setTaxonomyLoading] = useState(true);

  const [form, setForm] = useState<GenerationRequest>({
    profileIds: [],
    categoryIds: [],
    skillIds: [],
    difficulty: 'INTERMEDIATE',
    type: 'SITUATIONAL_QCM',
    count: DEFAULT_COUNT,
    instructions: '',
  });

  type Result =
    | { kind: 'loading' }
    | { kind: 'idle' }
    | { kind: 'done'; report: Awaited<ReturnType<typeof generationApi.generate>> }
    | { kind: 'error'; status: number; message: string; request: GenerationRequest };

  const [result, setResult] = useState<Result>({ kind: 'idle' });

  useEffect(() => {
    const loadProfiles = adminProfileApi.getProfiles().then(setProfiles).finally(() => setProfilesLoading(false));
    const loadTaxonomy = Promise.all([
      simulationApi.getCategories().then(setCategories),
      simulationApi.getSkills().then(setSkills),
    ]).finally(() => setTaxonomyLoading(false));

    let cancelled = false;
    Promise.all([loadProfiles, loadTaxonomy]).catch(() => {
      if (!cancelled) {
        setProfiles([]);
        setCategories([]);
        setSkills([]);
      }
    });
    return () => { cancelled = true; };
  }, []);

  const selectOptions = <T extends { id: number; name: string }>(items: T[]) =>
    items.map((item) => ({ id: item.id, name: item.name }));

  const canSubmit = !profilesLoading && !taxonomyLoading;

  const setField = <K extends keyof GenerationRequest>(key: K, value: GenerationRequest[K]) => {
    setForm((prev) => ({ ...prev, [key]: value }));
    if (result.kind === 'error') {
      setResult({ kind: 'idle' });
    }
  };

  const handleGenerate = async () => {
    if (!canSubmit) return;
    setResult({ kind: 'loading' });
    try {
      const report = await generationApi.generate(form);
      setResult({ kind: 'done', report });
    } catch (err) {
      const { status, message } = generationApi.mapError(err);
      setResult({ kind: 'error', status, message, request: form });
    }
  };

  const counterHint = (ids: number[]) =>
    ids.length === 0 ? 'Aucune sélection : ce critère ne filtrera pas.' : `${ids.length} sélectionné(s)`;

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="font-serif text-2xl font-bold text-navy-900">Génération automatique</h2>
          <p className="text-sm text-ink-secondary mt-1">
            Générez des questions en brouillon depuis le fournisseur configuré côté serveur.
          </p>
        </div>
      </div>

      {profilesLoading || taxonomyLoading ? (
        <div className="bg-card rounded border-2 border-border shadow-panel p-6 text-sm text-ink-secondary">
          Chargement des données administratives...
        </div>
      ) : (
        <div className="bg-surface rounded-2xl p-6 border border-border shadow-panel space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Field label="Type de question">
              <select
                value={form.type}
                onChange={(e) => setField('type', e.target.value as ChallengeType)}
                className={fieldInput}
              >
                {ALL_CHALLENGE_TYPES.map((t) => (
                  <option key={t} value={t}>{t}</option>
                ))}
              </select>
            </Field>

            <Field label="Difficulté">
              <select
                value={form.difficulty}
                onChange={(e) => setField('difficulty', e.target.value as GenerationDifficulty)}
                className={fieldInput}
              >
                {DIFFICULTIES.map((d) => (
                  <option key={d} value={d}>{d}</option>
                ))}
              </select>
            </Field>
          </div>

          <Field label="Nombre de questions (1 à 10)">
            <input
              type="number"
              min={1}
              max={10}
              required
              value={form.count}
              onChange={(e) => setField('count', parseInt(e.target.value, 10) || 0)}
              className={fieldInput}
            />
          </Field>

          <div className="border-t border-border-subtle pt-4 space-y-4">
            <h3 className="font-serif font-bold text-lg text-navy-900">Filtres optionnels</h3>

            <MultiSelect
              label="Profils métier"
              options={selectOptions(profiles)}
              selectedIds={form.profileIds ?? []}
              onChange={(ids) => setField('profileIds', ids)}
              emptyMessage="Aucun profil actif disponible."
            />
            {profiles.length > 0 && form.profileIds && form.profileIds.length === 0 && (
              <p className="text-xs text-ink-muted">{counterHint(form.profileIds)}</p>
            )}

            <MultiSelect
              label="Catégories"
              options={selectOptions(categories)}
              selectedIds={form.categoryIds ?? []}
              onChange={(ids) => setField('categoryIds', ids)}
              emptyMessage="Aucune catégorie disponible."
            />
            {categories.length > 0 && form.categoryIds && form.categoryIds.length === 0 && (
              <p className="text-xs text-ink-muted">{counterHint(form.categoryIds)}</p>
            )}

            <MultiSelect
              label="Compétences"
              options={selectOptions(skills)}
              selectedIds={form.skillIds ?? []}
              onChange={(ids) => setField('skillIds', ids)}
              emptyMessage="Aucune compétence disponible."
            />
            {skills.length > 0 && form.skillIds && form.skillIds.length === 0 && (
              <p className="text-xs text-ink-muted">{counterHint(form.skillIds)}</p>
            )}
          </div>

          <Field label="Instructions complémentaires (facultatif)">
            <textarea
              value={form.instructions}
              onChange={(e) => setField('instructions', e.target.value)}
              placeholder="Précisions facultatives pour le fournisseur de génération..."
              className={fieldInput}
              rows={3}
            />
          </Field>

          <div className="flex justify-end gap-3 pt-2">
            <Button
              type="button"
              variant="primary"
              onClick={handleGenerate}
              disabled={!canSubmit}
              loading={result.kind === 'loading'}
            >
              Générer les questions
            </Button>
          </div>
        </div>
      )}

      {result.kind === 'done' && (
        <div className="bg-card rounded border-2 border-border shadow-panel p-6 space-y-5">
          <div className="flex items-start gap-3">
            <Badge variant="success" size="md" dot>
              {(result.report.executed.created ?? 0).toString()}
            </Badge>
            <div className="flex-1">
              <p className="font-semibold text-ink">
                {(result.report.executed.created ?? 0) === (result.report.planned.created ?? 0)
                  ? `Génération terminée : ${result.report.executed.created} question(s) créée(s).`
                  : `Partiel : ${result.report.executed.created} question(s) créée(s) sur ${result.report.planned.created ?? 0} demandée(s).`}
              </p>
              <p className="text-sm text-ink-secondary mt-1">
                Les questions générées sont enregistrées en brouillon (DRAFT). Elles ne sont pas publiées automatiquement.
              </p>
            </div>
          </div>

          {result.report.duplicates && result.report.duplicates.length > 0 && (
            <section className="border-t border-border-subtle pt-4 space-y-3">
              <h3 className="font-serif font-bold text-base text-navy-900">Doublons détectés</h3>
              <ul className="space-y-2 text-sm">
                {result.report.duplicates.map((d) => (
                  <li key={`${d.index}-${d.externalIdOrTitle}`} className="flex gap-3 text-ink-secondary">
                    <span className="font-mono text-ink-muted w-12 shrink-0">#{d.index}</span>
                    <span>
                      « {d.externalIdOrTitle} » existe déjà (#{d.existingId} — {d.existingTitle}).
                    </span>
                  </li>
                ))}
              </ul>
            </section>
          )}

          {result.report.warnings && result.report.warnings.length > 0 && (
            <section className="border-t border-border-subtle pt-4 space-y-3">
              <h3 className="font-serif font-bold text-base text-navy-900">Avertissements</h3>
              <ul className="space-y-2 text-sm">
                {result.report.warnings.map((w) => (
                  <li key={`${w.index}-${w.externalIdOrTitle}`} className="flex gap-3 text-ink-secondary">
                    <span className="font-mono text-ink-muted w-12 shrink-0">#{w.index}</span>
                    <span>{w.externalIdOrTitle} — {w.message}</span>
                  </li>
                ))}
              </ul>
            </section>
          )}

          {result.report.errors && result.report.errors.length > 0 && (
            <section className="border-t border-border-subtle pt-4 space-y-3">
              <h3 className="font-serif font-bold text-base text-navy-900">Erreurs d’import</h3>
              <ul className="space-y-2 text-sm">
                {result.report.errors.map((e) => (
                  <li key={`${e.index}-${e.externalIdOrTitle}`} className="flex gap-3 text-ink-secondary">
                    <span className="font-mono text-ink-muted w-12 shrink-0">#{e.index}</span>
                    <span>{e.externalIdOrTitle} — {e.reason}</span>
                  </li>
                ))}
              </ul>
            </section>
          )}

          <div className="flex justify-end gap-3 pt-2">
            <Button type="button" variant="secondary" onClick={() => setResult({ kind: 'idle' })}>
              Nouvelle génération
            </Button>
          </div>
        </div>
      )}

      {result.kind === 'error' && (
        <div className="bg-danger-soft border-2 border-danger-border rounded-2xl p-5 text-sm space-y-3 shadow-[0_2px_10px_rgba(172,59,97,0.08)]">
          <div className="flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-danger shrink-0 mt-0.5" />
            <div>
              <p className="font-semibold text-danger">Génération échouée</p>
              <p className="text-ink-secondary mt-1">{result.message}</p>
              <p className="text-xs text-ink-muted mt-2">
                Votre configuration a été conservée. Corrigez le paramètre si besoin puis réessayez.
              </p>
            </div>
          </div>

          {result.request.profileIds && result.request.profileIds.length === 0 && (
            <p className="text-xs text-ink-muted">{counterHint(result.request.profileIds)}</p>
          )}
          {result.request.categoryIds && result.request.categoryIds.length === 0 && (
            <p className="text-xs text-ink-muted">{counterHint(result.request.categoryIds)}</p>
          )}
          {result.request.skillIds && result.request.skillIds.length === 0 && (
            <p className="text-xs text-ink-muted">{counterHint(result.request.skillIds)}</p>
          )}

          <div className="flex justify-end gap-3 pt-2">
            <Button type="button" variant="secondary" onClick={() => setResult({ kind: 'idle' })}>
              Masquer l’erreur
            </Button>
            <Button
              type="button"
              variant="primary"
              onClick={handleGenerate}
              disabled={!canSubmit}
              loading={result.kind === 'loading'}
            >
              Réessayer
            </Button>
          </div>
        </div>
      )}
    </div>
  );
};
