import { useEffect, useMemo, useState } from 'react';
import { ChevronDown, ChevronUp, Eye } from 'lucide-react';
import { coverageApi } from '../api/adminApi';
import type { CoverageCell, CoverageContentItem, CoverageOptions } from '../api/adminApi';
import type { ChallengeType, DifficultyLevel } from '../types';
import { DEFAULT_COVERAGE_THRESHOLDS } from '../utils/coverageThresholds';
import { DIFFICULTY_LABELS, MODE_LABELS } from '../utils/resultAnalysis';
import { emptyState, filterSelect, panel, tableHead } from '../styles/ui';

const PAGE_SIZE = 10;
type Dimension = 'CATEGORY' | 'SKILL';
type SortOrder = 'asc' | 'desc';

const rowKey = (cell: CoverageCell) =>
  `${cell.profileId}:${cell.difficulty}:${cell.type}:${cell.taxonomyId}`;

export const AdminCoveragePanel = () => {
  const [options, setOptions] = useState<CoverageOptions | null>(null);
  const [optionsError, setOptionsError] = useState<string | null>(null);
  const [profileId, setProfileId] = useState('');
  const [difficulty, setDifficulty] = useState<DifficultyLevel | ''>('');
  const [type, setType] = useState<ChallengeType | ''>('');
  const [dimension, setDimension] = useState<Dimension>('CATEGORY');
  const [cells, setCells] = useState<CoverageCell[] | null>(null);
  const [coverageLoading, setCoverageLoading] = useState(true);
  const [coverageError, setCoverageError] = useState<string | null>(null);
  const [sortOrder, setSortOrder] = useState<SortOrder>('asc');
  const [tablePage, setTablePage] = useState(0);
  const [expandedKey, setExpandedKey] = useState<string | null>(null);
  const [details, setDetails] = useState<CoverageContentItem[]>([]);
  const [detailPage, setDetailPage] = useState(0);
  const [detailTotalPages, setDetailTotalPages] = useState(0);
  const [detailLoading, setDetailLoading] = useState(false);
  const [detailError, setDetailError] = useState<string | null>(null);
  const [expandedScenarioId, setExpandedScenarioId] = useState<number | null>(null);
  const [scenarioSteps, setScenarioSteps] = useState<CoverageContentItem[]>([]);
  const [scenarioStepPage, setScenarioStepPage] = useState(0);
  const [scenarioStepPages, setScenarioStepPages] = useState(0);
  const [scenarioLoading, setScenarioLoading] = useState(false);
  const [scenarioError, setScenarioError] = useState<string | null>(null);

  useEffect(() => {
    coverageApi.getOptions()
      .then(setOptions)
      .catch(() => setOptionsError('Impossible de charger les options de filtre.'));
  }, []);

  const selectedProfile = options?.profiles.find(profile => String(profile.id) === profileId);
  const availableTypes = useMemo(() => (options?.types ?? []).filter(candidate =>
    selectedProfile
      ? selectedProfile.allowedTypes.length === 0 || selectedProfile.allowedTypes.includes(candidate)
      : (options?.profiles ?? []).some(profile =>
          profile.allowedTypes.length === 0 || profile.allowedTypes.includes(candidate))), [options, selectedProfile]);

  useEffect(() => {
    let cancelled = false;
    setCells(null);
    setTablePage(0);
    setCoverageError(null);
    setExpandedKey(null);
    setDetails([]);
    setDetailError(null);
    setCoverageLoading(true);
    coverageApi.getCoverage({
      profileId: profileId ? Number(profileId) : undefined,
      difficulty: difficulty || undefined,
      type: type || undefined,
      dimension,
    })
      .then(result => {
        if (!cancelled) setCells(result.cells);
      })
      .catch(() => {
        if (!cancelled) setCoverageError('Impossible de charger la couverture. Réessayez.');
      })
      .finally(() => {
        if (!cancelled) setCoverageLoading(false);
      });
    return () => { cancelled = true; };
  }, [profileId, difficulty, type, dimension]);

  const sortedCells = useMemo(() => [...(cells ?? [])].sort((a, b) => {
    const countOrder = sortOrder === 'asc' ? a.count - b.count : b.count - a.count;
    return countOrder
      || a.profileName.localeCompare(b.profileName, 'fr')
      || a.difficulty.localeCompare(b.difficulty)
      || a.type.localeCompare(b.type)
      || a.taxonomyName.localeCompare(b.taxonomyName, 'fr');
  }), [cells, sortOrder]);
  const tablePageCount = Math.ceil(sortedCells.length / PAGE_SIZE);
  const visibleCells = sortedCells.slice(tablePage * PAGE_SIZE, (tablePage + 1) * PAGE_SIZE);

  const loadDetails = async (cell: CoverageCell, page = 0) => {
    const key = rowKey(cell);
    setExpandedKey(key);
    setDetails([]);
    setDetailPage(page);
    setDetailTotalPages(0);
    setDetailLoading(true);
    setDetailError(null);
    setExpandedScenarioId(null);
    setScenarioSteps([]);
    setScenarioError(null);
    try {
      const result = await coverageApi.getDetails({
        profileId: cell.profileId,
        difficulty: cell.difficulty,
        type: cell.type,
        dimension,
        taxonomyId: cell.taxonomyId,
        page,
        size: PAGE_SIZE,
      });
      setDetails(result.content);
      setDetailPage(result.number);
      setDetailTotalPages(result.totalPages);
    } catch {
      setDetails([]);
      setDetailError('Impossible de charger le détail.');
    } finally {
      setDetailLoading(false);
    }
  };

  const loadScenarioSteps = async (scenarioId: number, cell: CoverageCell, page = 0) => {
    setExpandedScenarioId(scenarioId);
    setScenarioSteps([]);
    setScenarioStepPage(page);
    setScenarioStepPages(0);
    setScenarioLoading(true);
    setScenarioError(null);
    try {
      const result = await coverageApi.getScenarioSteps(scenarioId, {
        profileId: cell.profileId,
        difficulty: cell.difficulty,
        page,
        size: PAGE_SIZE,
      });
      setScenarioSteps(result.content);
      setScenarioStepPage(result.number);
      setScenarioStepPages(result.totalPages);
    } catch {
      setScenarioSteps([]);
      setScenarioError('Impossible de charger les étapes de ce scénario.');
    } finally {
      setScenarioLoading(false);
    }
  };

  const coverageFor = (count: number) => {
    if (count === 0 || count < DEFAULT_COVERAGE_THRESHOLDS.redBelow) {
      return { label: 'Insuffisant', className: 'bg-danger-soft text-danger border-danger-border' };
    }
    if (count < DEFAULT_COVERAGE_THRESHOLDS.greenFrom) {
      return { label: 'À renforcer', className: 'bg-amber-100 text-amber-900 border-amber-300' };
    }
    return { label: 'Satisfaisant', className: 'bg-success-soft text-success border-success-border' };
  };

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="inline-flex rounded-lg border-2 border-border bg-card p-1" aria-label="Dimension de taxonomie">
          <button
            type="button"
            aria-pressed={dimension === 'CATEGORY'}
            onClick={() => setDimension('CATEGORY')}
            className={`rounded px-3 py-1.5 text-sm font-semibold ${dimension === 'CATEGORY' ? 'bg-navy-900 text-white' : 'text-ink-secondary hover:bg-canvas-subtle'}`}
          >Catégories</button>
          <button
            type="button"
            aria-pressed={dimension === 'SKILL'}
            onClick={() => setDimension('SKILL')}
            className={`rounded px-3 py-1.5 text-sm font-semibold ${dimension === 'SKILL' ? 'bg-navy-900 text-white' : 'text-ink-secondary hover:bg-canvas-subtle'}`}
          >Compétences</button>
        </div>
        <div className="flex flex-wrap gap-2">
          <select aria-label="Filtrer par profil" value={profileId} onChange={event => { setProfileId(event.target.value); setType(''); }} className={filterSelect}>
            <option value="">Tous les profils</option>
            {(options?.profiles ?? []).map(profile => <option key={profile.id} value={profile.id}>{profile.name}</option>)}
          </select>
          <select aria-label="Filtrer par niveau" value={difficulty} onChange={event => setDifficulty(event.target.value as DifficultyLevel | '')} className={filterSelect}>
            <option value="">Tous les niveaux</option>
            {(options?.difficulties ?? []).map(level => <option key={level} value={level}>{DIFFICULTY_LABELS[level]}</option>)}
          </select>
          <select aria-label="Filtrer par type" value={type} onChange={event => setType(event.target.value as ChallengeType | '')} className={filterSelect}>
            <option value="">Tous les types</option>
            {availableTypes.map(candidate => <option key={candidate} value={candidate}>{MODE_LABELS[candidate]}</option>)}
          </select>
        </div>
      </div>

      {optionsError && <p className="text-sm text-danger" role="alert">{optionsError} Les filtres ne sont pas disponibles.</p>}
      <p className={`${panel} p-3 text-sm text-ink-secondary`}>
        Architecture compte les scénarios sélectionnables selon la règle actuelle du simulateur : scénario actif avec au moins une étape Architecture active et validée pour le profil et le niveau affichés. Cela ne garantit pas que toutes les étapes configurées soient validées.
      </p>

      <div className={panel}>
        {coverageLoading ? (
          <div className={emptyState}>Chargement de la couverture...</div>
        ) : coverageError ? (
          <div className={`${emptyState} text-danger`} role="alert">{coverageError}</div>
        ) : cells === null ? (
          <div className={emptyState}>Chargement de la couverture...</div>
        ) : cells.length === 0 ? (
          <div className={emptyState}>Aucune combinaison pertinente dans cette vue.</div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="w-full text-sm text-left">
              <thead className={tableHead}>
                <tr>
                  <th className="px-4 py-3 font-medium">Profil</th>
                  <th className="px-4 py-3 font-medium">Niveau</th>
                  <th className="px-4 py-3 font-medium">Type</th>
                  <th className="px-4 py-3 font-medium">{dimension === 'CATEGORY' ? 'Catégorie' : 'Compétence'}</th>
                  <th className="px-4 py-3 font-medium text-right">
                    <button type="button" onClick={() => { setSortOrder(current => current === 'asc' ? 'desc' : 'asc'); setTablePage(0); }} className="inline-flex items-center gap-1">
                      Nombre {sortOrder === 'asc' ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
                    </button>
                  </th>
                  <th className="px-4 py-3 font-medium">Couverture</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border-subtle">
                {visibleCells.map(cell => {
                  const coverage = coverageFor(cell.count);
                  const key = rowKey(cell);
                  const open = expandedKey === key;
                  return (
                    <CoverageRow
                      key={key}
                      cell={cell}
                      coverageLabel={coverage.label}
                      coverageClass={coverage.className}
                      open={open}
                      onToggle={() => open ? setExpandedKey(null) : loadDetails(cell)}
                      details={details}
                      detailLoading={detailLoading && open}
                      detailError={open ? detailError : null}
                      detailPage={detailPage}
                      detailTotalPages={detailTotalPages}
                      onPage={page => loadDetails(cell, page)}
                      expandedScenarioId={expandedScenarioId}
                      scenarioSteps={scenarioSteps}
                      scenarioStepPage={scenarioStepPage}
                      scenarioStepPages={scenarioStepPages}
                      scenarioLoading={scenarioLoading}
                      scenarioError={scenarioError}
                      onToggleScenario={scenarioId => expandedScenarioId === scenarioId
                        ? setExpandedScenarioId(null)
                        : loadScenarioSteps(scenarioId, cell)}
                      onScenarioPage={page => expandedScenarioId !== null && loadScenarioSteps(expandedScenarioId, cell, page)}
                    />
                  );
                })}
                </tbody>
              </table>
            </div>
            {tablePageCount > 1 && (
            <div className="flex items-center justify-between border-t border-border px-4 py-3 text-sm text-ink-secondary">
              <span>
                Lignes {tablePage * PAGE_SIZE + 1}–{Math.min((tablePage + 1) * PAGE_SIZE, sortedCells.length)} sur {sortedCells.length}
              </span>
              <div className="flex items-center gap-3">
                <button
                  type="button"
                  disabled={tablePage === 0}
                  onClick={() => { setTablePage(page => page - 1); setExpandedKey(null); }}
                  className="font-semibold text-navy-900 disabled:cursor-not-allowed disabled:opacity-50"
                >Précédent</button>
                <span>Page {tablePage + 1} / {tablePageCount}</span>
                <button
                  type="button"
                  disabled={tablePage + 1 >= tablePageCount}
                  onClick={() => { setTablePage(page => page + 1); setExpandedKey(null); }}
                  className="font-semibold text-navy-900 disabled:cursor-not-allowed disabled:opacity-50"
                >Suivant</button>
              </div>
            </div>
            )}
          </>
        )}
      </div>
    </div>
  );
};

interface CoverageRowProps {
  cell: CoverageCell;
  coverageLabel: string;
  coverageClass: string;
  open: boolean;
  onToggle: () => void;
  details: CoverageContentItem[];
  detailLoading: boolean;
  detailError: string | null;
  detailPage: number;
  detailTotalPages: number;
  onPage: (page: number) => void;
  expandedScenarioId: number | null;
  scenarioSteps: CoverageContentItem[];
  scenarioStepPage: number;
  scenarioStepPages: number;
  scenarioLoading: boolean;
  scenarioError: string | null;
  onToggleScenario: (scenarioId: number) => void;
  onScenarioPage: (page: number) => void;
}

const CoverageRow = ({
  cell, coverageLabel, coverageClass, open, onToggle, details, detailLoading, detailError,
  detailPage, detailTotalPages, onPage, expandedScenarioId, scenarioSteps, scenarioStepPage,
  scenarioStepPages, scenarioLoading, scenarioError, onToggleScenario, onScenarioPage,
}: CoverageRowProps) => (
  <>
    <tr
      className="cursor-pointer transition hover:bg-surface-elevated focus:outline-none focus:ring-2 focus:ring-inset focus:ring-navy-700"
      onClick={onToggle}
      onKeyDown={event => {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          onToggle();
        }
      }}
      tabIndex={0}
      aria-expanded={open}
      aria-label={`Détail de ${cell.taxonomyName}, ${cell.profileName}, ${DIFFICULTY_LABELS[cell.difficulty]}, ${MODE_LABELS[cell.type]}`}
    >
      <td className="px-4 py-3 font-medium text-ink">{cell.profileName}</td>
      <td className="px-4 py-3 text-ink-secondary">{DIFFICULTY_LABELS[cell.difficulty]}</td>
      <td className="px-4 py-3 text-ink-secondary">{MODE_LABELS[cell.type]}</td>
      <td className="px-4 py-3 font-medium text-ink">
        <button
          type="button"
          onClick={event => { event.stopPropagation(); onToggle(); }}
          className="inline-flex items-center gap-2 text-left"
          aria-expanded={open}
        >
          {cell.taxonomyName}<Eye className="h-4 w-4 text-navy-900" />
        </button>
      </td>
      <td className="px-4 py-3 text-right font-mono font-semibold text-navy-900">{cell.count}</td>
      <td className="px-4 py-3"><span className={`inline-flex rounded-full border px-2.5 py-1 text-xs font-semibold ${coverageClass}`}>{coverageLabel}</span></td>
    </tr>
    {open && (
      <tr>
        <td colSpan={6} className="bg-canvas-subtle px-5 py-4">
          {detailLoading ? <p className="text-sm text-ink-muted">Chargement du détail...</p>
            : detailError ? <p className="text-sm text-danger" role="alert">{detailError}</p>
              : details.length === 0 ? <p className="text-sm text-ink-muted">Aucun contenu disponible dans cette combinaison.</p>
                : <div className="space-y-3">
                  <ul className="space-y-2">
                    {details.map(item => (
                      <li key={item.id} className="rounded-lg border border-border bg-card p-3">
                        <div className="flex flex-wrap items-center justify-between gap-2">
                          <span className="font-semibold text-ink">{item.title}</span>
                          {cell.type === 'ARCHITECTURE' && item.scenarioId !== null && (
                            <button type="button" onClick={() => onToggleScenario(item.scenarioId!)} className="text-xs font-semibold text-navy-900 underline">
                              Voir les {item.stepCount} étapes disponibles
                            </button>
                          )}
                        </div>
                        <p className="mt-1 text-xs text-ink-secondary">
                          {cell.type === 'ARCHITECTURE' ? `Scénario · ${item.stepCount} étapes disponibles` : `${MODE_LABELS[item.type]} · ${DIFFICULTY_LABELS[item.difficulty]}`}
                        </p>
                        {cell.type !== 'ARCHITECTURE' && item.question && <p className="mt-2 text-sm text-ink-secondary">{item.question}</p>}
                        {cell.type === 'ARCHITECTURE' && expandedScenarioId === item.scenarioId && (
                          <div className="mt-3 border-t border-border pt-3">
                            {scenarioLoading ? <p className="text-xs text-ink-muted">Chargement des étapes...</p>
                              : scenarioError ? <p className="text-xs text-danger" role="alert">{scenarioError}</p>
                                : <>
                                  <ol className="space-y-1 text-sm text-ink-secondary">
                                    {scenarioSteps.map(step => (
                                      <li key={step.id}>
                                        <span>{step.stepOrder ?? '–'}. {step.title}</span>
                                        {step.question && <p className="ml-5 text-xs text-ink-muted">{step.question}</p>}
                                      </li>
                                    ))}
                                  </ol>
                                  {scenarioStepPages > 1 && <div className="mt-2 flex items-center justify-between text-xs"><button disabled={scenarioStepPage === 0 || scenarioLoading} onClick={() => onScenarioPage(scenarioStepPage - 1)}>Précédent</button><span>Page {scenarioStepPage + 1} / {scenarioStepPages}</span><button disabled={scenarioStepPage + 1 >= scenarioStepPages || scenarioLoading} onClick={() => onScenarioPage(scenarioStepPage + 1)}>Suivant</button></div>}
                                </>}
                          </div>
                        )}
                      </li>
                    ))}
                  </ul>
                  {detailTotalPages > 1 && <div className="flex items-center justify-between text-xs text-ink-secondary"><button disabled={detailPage === 0 || detailLoading} onClick={() => onPage(detailPage - 1)}>Précédent</button><span>Page {detailPage + 1} / {detailTotalPages}</span><button disabled={detailPage + 1 >= detailTotalPages || detailLoading} onClick={() => onPage(detailPage + 1)}>Suivant</button></div>}
                </div>}
        </td>
      </tr>
    )}
  </>
);
