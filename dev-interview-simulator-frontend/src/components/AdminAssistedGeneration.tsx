import { useEffect, useState } from 'react';
import type {
  AssistedAnalysis,
  AssistedPromptRequest,
  GenerationDifficulty,
  GenerationReport,
} from '../api/adminApi';
import { assistApi, generationApi, adminProfileApi, type AdminProfile } from '../api/adminApi';
import { simulationApi } from '../api/simulationApi';
import type { Category, Skill, ChallengeType } from '../types';
import { MultiSelect } from './common/MultiSelect';
import { Button } from './common/Button';
import { Field } from './common/Field';
import { fieldInput } from '../styles/ui';
import { AlertCircle } from 'lucide-react';

const ALL_CHALLENGE_TYPES: ChallengeType[] = [
  'SITUATIONAL_QCM',
  'CODE_REVIEW',
  'ARCHITECTURE',
  'SEQUENTIAL_REASONING',
];

const DIFFICULTIES: GenerationDifficulty[] = ['JUNIOR', 'INTERMEDIATE', 'ADVANCED'];

// Miroir de app.generation.assist.max-batch côté backend (défaut 20) : borne
// appliquée côté frontend, le backend reste l'autorité.
const MAX_ASSIST_COUNT = 20;
const DEFAULT_ASSIST_COUNT = 5;

const parseCount = (raw: string): number | null => {
  const trimmed = raw.trim();
  if (!/^\d+$/.test(trimmed)) return null;
  const value = Number(trimmed);
  return value >= 1 && value <= MAX_ASSIST_COUNT ? value : null;
};

export const AdminAssistedGeneration = () => {
  const [profiles, setProfiles] = useState<AdminProfile[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [skills, setSkills] = useState<Skill[]>([]);
  const [dataLoading, setDataLoading] = useState(true);

  const [form, setForm] = useState<AssistedPromptRequest>({
    profileIds: [],
    categoryIds: [],
    skillIds: [],
    difficulty: 'INTERMEDIATE',
    type: 'SITUATIONAL_QCM',
    count: DEFAULT_ASSIST_COUNT,
    instructions: '',
  });
  const [countInput, setCountInput] = useState<string>(String(DEFAULT_ASSIST_COUNT));

  const [prompt, setPrompt] = useState<string | null>(null);
  const [promptLoading, setPromptLoading] = useState(false);
  const [copied, setCopied] = useState(false);

  const [pastedJson, setPastedJson] = useState('');
  const [analyzeLoading, setAnalyzeLoading] = useState(false);
  const [analysis, setAnalysis] = useState<AssistedAnalysis | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);

  const [importLoading, setImportLoading] = useState(false);
  const [importReport, setImportReport] = useState<GenerationReport | null>(null);
  const [importStatus, setImportStatus] = useState<'DRAFT' | 'VALIDATED'>('DRAFT');
  const [lastImportStatus, setLastImportStatus] = useState<'DRAFT' | 'VALIDATED'>('DRAFT');

  useEffect(() => {
    let cancelled = false;
    Promise.all([
      adminProfileApi.getProfiles(),
      simulationApi.getCategories(),
      simulationApi.getSkills(),
    ])
      .then(([loadedProfiles, loadedCategories, loadedSkills]) => {
        if (cancelled) return;
        setProfiles(loadedProfiles);
        setCategories(loadedCategories);
        setSkills(loadedSkills);
      })
      .catch(() => undefined)
      .finally(() => {
        if (!cancelled) setDataLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const selectOptions = <T extends { id: number; name: string }>(items: T[]) =>
    items.map((item) => ({ id: item.id, name: item.name }));

  const setField = <K extends keyof AssistedPromptRequest>(key: K, value: AssistedPromptRequest[K]) => {
    setForm((prev) => ({ ...prev, [key]: value }));
    setActionError(null);
  };

  const handleCountChange = (raw: string) => {
    const next = raw.replace(/[^\d]/g, '').replace(/^0+(?=\d)/, '');
    setCountInput(next);
    setActionError(null);
  };

  const countValue = parseCount(countInput);
  const missingFields: string[] = [];
  if (!ALL_CHALLENGE_TYPES.includes(form.type)) missingFields.push('le type de question');
  if (!DIFFICULTIES.includes(form.difficulty)) missingFields.push('la difficulté');
  if (countValue === null) missingFields.push(`le nombre de questions (1 à ${MAX_ASSIST_COUNT})`);
  if ((form.profileIds ?? []).length === 0) missingFields.push('au moins un profil');
  if ((form.categoryIds ?? []).length === 0) missingFields.push('au moins une catégorie');
  if ((form.skillIds ?? []).length === 0) missingFields.push('au moins une compétence');
  const formValid = !dataLoading && missingFields.length === 0;

  const handleGeneratePrompt = async () => {
    if (!formValid || countValue === null || promptLoading) return;
    setPromptLoading(true);
    setActionError(null);
    setImportReport(null);
    try {
      const response = await assistApi.prompt({ ...form, count: countValue });
      setPrompt(response.prompt);
      setCopied(false);
    } catch (err) {
      setPrompt(null);
      setActionError(generationApi.mapError(err).message);
    } finally {
      setPromptLoading(false);
    }
  };

  const handleCopy = async () => {
    if (!prompt) return;
    try {
      await navigator.clipboard.writeText(prompt);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 2500);
    } catch {
      setCopied(false);
    }
  };

  const handleAnalyze = async () => {
    if (!pastedJson.trim() || analyzeLoading) return;
    setAnalyzeLoading(true);
    setActionError(null);
    setImportReport(null);
    try {
      setAnalysis(await assistApi.analyze(pastedJson));
    } catch (err) {
      setAnalysis(null);
      setActionError(generationApi.mapError(err).message);
    } finally {
      setAnalyzeLoading(false);
    }
  };

  const handleImport = async () => {
    if (!analysis || analysis.valid === 0 || importLoading) return;
    setImportLoading(true);
    setActionError(null);
    try {
      const report = await assistApi.importJson(pastedJson, importStatus);
      setImportReport(report);
      setLastImportStatus(importStatus);
    } catch (err) {
      setActionError(generationApi.mapError(err).message);
    } finally {
      setImportLoading(false);
    }
  };

  const breakdown = (values: Record<string, number>) =>
    Object.entries(values)
      .map(([key, count]) => `${key} (${count})`)
      .join(', ') || '—';

  const indexLabel = (index: number) => (
    <span className="font-mono text-ink-muted w-12 inline-block">#{index}</span>
  );

  return (
    <div className="space-y-6">
      <p className="text-sm text-ink-secondary">
        Produisez un prompt prêt à l'emploi pour un LLM externe (ChatGPT, Gemini, Claude…), puis collez
        sa réponse JSON pour l'analyser et l'importer en brouillon. InterviewLab n'effectue aucun appel
        LLM dans ce parcours.
      </p>

      <div className="bg-surface rounded-2xl p-6 border border-border shadow-panel space-y-6">
        <div>
          <h3 className="font-serif font-bold text-lg text-navy-900">Paramètres du lot</h3>
          <p className="text-xs text-ink-muted mt-1">
            Le prompt produit reprend exactement ces critères : type, difficulté, profils, catégories
            et compétences.
          </p>
        </div>

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

          <Field label={`Nombre de questions (1 à ${MAX_ASSIST_COUNT})`}>
            <input
              type="number"
              min={1}
              max={MAX_ASSIST_COUNT}
              required
              value={countInput}
              onChange={(e) => handleCountChange(e.target.value)}
              className={fieldInput}
            />
          </Field>
        </div>

        <div className="space-y-4">
          <MultiSelect
            label="Profils métier"
            options={selectOptions(profiles)}
            selectedIds={form.profileIds ?? []}
            onChange={(ids) => setField('profileIds', ids)}
            emptyMessage="Aucun profil actif disponible."
          />
          {(form.profileIds ?? []).length === 0 && (
            <p className="text-xs text-ink-muted">
              Sélection obligatoire : au moins un profil de référence pour orienter les questions.
            </p>
          )}

          <MultiSelect
            label="Catégories"
            options={selectOptions(categories)}
            selectedIds={form.categoryIds ?? []}
            onChange={(ids) => setField('categoryIds', ids)}
            emptyMessage="Aucune catégorie disponible."
          />
          {(form.categoryIds ?? []).length === 0 && (
            <p className="text-xs text-ink-muted">
              Sélection obligatoire : au moins une catégorie pour cadrer le lot.
            </p>
          )}

          <MultiSelect
            label="Compétences"
            options={selectOptions(skills)}
            selectedIds={form.skillIds ?? []}
            onChange={(ids) => setField('skillIds', ids)}
            emptyMessage="Aucune compétence disponible."
          />
          {(form.skillIds ?? []).length === 0 && (
            <p className="text-xs text-ink-muted">
              Sélection obligatoire : au moins une compétence pour cadrer le lot.
            </p>
          )}
        </div>

        <Field label="Instructions complémentaires (facultatif)">
          <textarea
            value={form.instructions}
            onChange={(e) => setField('instructions', e.target.value)}
            placeholder="Précisions facultatives pour le LLM externe..."
            className={fieldInput}
            rows={3}
          />
        </Field>

        {!formValid && missingFields.length > 0 && (
          <p className="text-xs text-ink-muted">
            Renseignez {missingFields.join(', ')} pour générer le prompt.
          </p>
        )}

        <div className="flex justify-end gap-3 pt-2">
          <Button
            type="button"
            variant="primary"
            onClick={handleGeneratePrompt}
            disabled={!formValid}
            loading={promptLoading}
          >
            Générer le prompt
          </Button>
        </div>
      </div>

      {prompt && (
        <div className="bg-surface rounded-2xl p-6 border border-border shadow-panel space-y-4">
          <div>
            <h3 className="font-serif font-bold text-lg text-navy-900">Prompt à copier</h3>
            <p className="text-xs text-ink-muted mt-1">
              Collez ce prompt dans votre LLM, puis collez sa réponse JSON dans le bloc suivant.
            </p>
          </div>
          <textarea value={prompt} readOnly rows={12} className={`${fieldInput} font-mono text-xs`} />
          <div className="flex justify-end gap-3">
            <Button type="button" variant="secondary" onClick={handleCopy}>
              {copied ? 'Prompt copié ✓' : 'Copier le prompt'}
            </Button>
          </div>
        </div>
      )}

      <div className="bg-surface rounded-2xl p-6 border border-border shadow-panel space-y-4">
        <div>
          <h3 className="font-serif font-bold text-lg text-navy-900">Réponse du LLM externe</h3>
          <p className="text-xs text-ink-muted mt-1">
            Collez le JSON renvoyé par le LLM, analysez-le, puis importez. L'analyse n'enregistre rien.
          </p>
        </div>
        <textarea
          value={pastedJson}
          onChange={(e) => {
            setPastedJson(e.target.value);
            setActionError(null);
          }}
          placeholder='{"questions": [...]}'
          rows={10}
          className={`${fieldInput} font-mono text-xs`}
        />
        <div className="flex flex-col gap-3 md:flex-row md:items-end md:justify-between">
          <Field label="Statut à l'import">
            <select
              value={importStatus}
              onChange={(e) => setImportStatus(e.target.value as 'DRAFT' | 'VALIDATED')}
              className={`${fieldInput} md:w-72`}
            >
              <option value="DRAFT">Brouillon (DRAFT) — à valider ensuite</option>
              <option value="VALIDATED">Validé (VALIDATED) — jouable immédiatement</option>
            </select>
          </Field>
          <div className="flex flex-wrap justify-end gap-3">
          <Button
            type="button"
            variant="secondary"
            onClick={handleAnalyze}
            disabled={!pastedJson.trim() || analyzeLoading}
            loading={analyzeLoading}
          >
            Analyser le JSON
          </Button>
          <Button
            type="button"
            variant="primary"
            onClick={handleImport}
            disabled={!analysis || analysis.valid === 0 || importLoading}
            loading={importLoading}
          >
            Importer les questions
          </Button>
          </div>
        </div>
        <p className="text-xs text-ink-muted">
          L'import n'ajoute que les questions valides et non dupliquées, avec le statut choisi ci-dessus
          ({importStatus}) : les doublons et erreurs sont ignorés et restent listés dans l'aperçu.
        </p>
      </div>

      {analysis && (
        <div className="bg-surface rounded-2xl p-6 border border-border shadow-panel space-y-5">
          <div>
            <h3 className="font-serif font-bold text-lg text-navy-900">Aperçu de l'analyse</h3>
            <p className="text-xs text-ink-muted mt-1">
              Aucune donnée n'est enregistrée tant que vous n'avez pas cliqué sur « Importer les
              questions ». Vous pouvez corriger le JSON et relancer l'analyse.
            </p>
          </div>

          <div className="flex flex-wrap gap-3 text-sm">
            <span className="px-3 py-1 rounded-xl bg-canvas-subtle text-ink">Reçues : {analysis.total}</span>
            <span className="px-3 py-1 rounded-xl bg-canvas-subtle text-ink">Valides : {analysis.valid}</span>
            <span className="px-3 py-1 rounded-xl bg-canvas-subtle text-ink">Doublons : {analysis.duplicates}</span>
            <span className="px-3 py-1 rounded-xl bg-canvas-subtle text-ink">Erreurs : {analysis.errors}</span>
          </div>

          <div className="text-xs text-ink-secondary space-y-1">
            <p><span className="font-semibold">Types :</span> {breakdown(analysis.byType)}</p>
            <p><span className="font-semibold">Niveaux :</span> {breakdown(analysis.byDifficulty)}</p>
            <p><span className="font-semibold">Profils :</span> {breakdown(analysis.byProfile)}</p>
            <p><span className="font-semibold">Catégories :</span> {breakdown(analysis.byCategory)}</p>
          </div>

          {analysis.questions.some((q) => q.status === 'ERROR') && (
            <section className="space-y-2">
              <h4 className="font-serif font-bold text-base text-navy-900">Erreurs à corriger dans le JSON</h4>
              <ul className="space-y-1 text-sm">
                {analysis.questions
                  .filter((q) => q.status === 'ERROR')
                  .map((q) => (
                    <li key={q.index} className="text-danger">
                      {indexLabel(q.index)}
                      {q.title ? `« ${q.title} » — ` : ''}
                      {q.reason}
                    </li>
                  ))}
              </ul>
            </section>
          )}

          {analysis.questions.some((q) => q.status === 'DUPLICATE') && (
            <section className="space-y-2">
              <h4 className="font-serif font-bold text-base text-navy-900">Doublons (non importés)</h4>
              <ul className="space-y-1 text-sm text-ink-secondary">
                {analysis.questions
                  .filter((q) => q.status === 'DUPLICATE')
                  .map((q) => (
                    <li key={q.index}>
                      {indexLabel(q.index)}
                      {q.title ? `« ${q.title} » — ` : ''}
                      {q.reason}
                    </li>
                  ))}
              </ul>
            </section>
          )}

          {analysis.valid > 0 && (
            <section className="space-y-2">
              <h4 className="font-serif font-bold text-base text-navy-900">
                Questions valides qui seront importées en {importStatus}
              </h4>
              <ul className="space-y-1 text-sm text-ink-secondary">
                {analysis.questions
                  .filter((q) => q.status === 'VALID')
                  .map((q) => (
                    <li key={q.index}>
                      {indexLabel(q.index)}
                      {q.title}
                    </li>
                  ))}
              </ul>
            </section>
          )}

          {analysis.warnings.length > 0 && (
            <section className="space-y-2">
              <h4 className="font-serif font-bold text-base text-navy-900">Avertissements</h4>
              <ul className="space-y-1 text-sm text-ink-secondary">
                {analysis.warnings.map((warning) => (
                  <li key={warning}>{warning}</li>
                ))}
              </ul>
            </section>
          )}

          {analysis.valid === 0 && (
            <p className="text-xs text-danger">
              Aucune question valide dans ce lot : corrigez le JSON et relancez l'analyse (vos critères
              sont conservés).
            </p>
          )}
        </div>
      )}

      {importReport && (
        <div className="bg-card rounded border-2 border-border shadow-panel p-6 space-y-3">
          <h3 className="font-serif font-bold text-lg text-navy-900">Importation terminée</h3>
          <p className="text-sm text-ink-secondary">
            {importReport.executed.created} question(s) créée(s), {importReport.executed.updated}{' '}
            mise(s) à jour, {importReport.duplicates.length} doublon(s), {importReport.errors.length}{' '}
            erreur(s).
          </p>
          <p className="text-xs text-ink-muted">
            {lastImportStatus === 'VALIDATED'
              ? 'Les questions importées sont VALIDÉES : elles sont immédiatement jouables par les candidats en simulation.'
              : 'Les questions importées sont en brouillon (DRAFT) : elles passent par le circuit de validation habituel de l\'onglet Contenus.'}
          </p>
          <div className="flex justify-end">
            <Button type="button" variant="secondary" onClick={() => setImportReport(null)}>
              Masquer
            </Button>
          </div>
        </div>
      )}

      {actionError && (
        <div className="bg-danger-soft border-2 border-danger-border rounded-2xl p-5 text-sm shadow-[0_2px_10px_rgba(172,59,97,0.08)]">
          <div className="flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-danger shrink-0 mt-0.5" />
            <div>
              <p className="font-semibold text-danger">Opération échouée</p>
              <p className="text-ink-secondary mt-1">{actionError}</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};