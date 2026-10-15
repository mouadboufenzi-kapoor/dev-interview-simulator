import { useState, useEffect } from 'react';
import { adminApi } from '../api/adminApi';
import type { AdminChallengeResponse } from '../api/adminApi';
import { profileApi } from '../api/profileApi';
import type { Profile } from '../api/profileApi';
import { panel, tableHead } from '../styles/ui';
import { IconButton } from './common/IconButton';
import { Search, Edit2, Archive, CheckCircle } from 'lucide-react';
import { Badge } from './common/Badge';

const PAGE_SIZE = 6;

interface Props {
  onEdit: (id: number) => void;
}

export const AdminChallengesContent = ({ onEdit }: Props) => {
  const [challenges, setChallenges] = useState<AdminChallengeResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [profileFilter, setProfileFilter] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [difficultyFilter, setDifficultyFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');

  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);

  const loadChallenges = async () => {
    setLoading(true);
    try {
      const result = await adminApi.searchChallenges({
        search,
        page,
        size: PAGE_SIZE,
        profileId: profileFilter ? Number(profileFilter) : undefined,
        type: typeFilter || undefined,
        difficulty: difficultyFilter || undefined,
        status: statusFilter || undefined
      });
      setChallenges(result?.content ?? []);
      setTotalPages(result?.totalPages ?? 0);
      setTotalElements(result?.totalElements ?? 0);
    } catch (err) {
      console.error('Chargement des challenges impossible', err);
      setChallenges([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    profileApi.getProfiles()
      .then(setProfiles)
      .catch(() => setProfiles([]));
  }, []);

  useEffect(() => {
    loadChallenges();
  }, [search, page, profileFilter, typeFilter, difficultyFilter, statusFilter]);

  // Quand on change la recherche ou les filtres, on revient à la page 1
  useEffect(() => {
    setPage(0);
  }, [search, profileFilter, typeFilter, difficultyFilter, statusFilter]);

  const handleStatusChange = async (id: number, currentStatus: string) => {
    try {
      const newStatus = currentStatus === 'ARCHIVED' ? 'DRAFT' : 'ARCHIVED';
      await adminApi.changeStatus(id, newStatus);
      loadChallenges();
    } catch (err) {
      console.error(err);
    }
  };

  const handleValidate = async (id: number) => {
    try {
      await adminApi.changeStatus(id, 'VALIDATED');
      loadChallenges();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className={panel}>
      <div className="p-4 border-b border-border-subtle flex flex-wrap gap-4">
        <div className="relative flex-1 min-w-[220px] max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-ink-muted" />
          <input
            type="text"
            placeholder="Rechercher une question..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-4 py-2 text-sm rounded-xl border border-border focus:border-navy-900 outline-none"
          />
        </div>
        <select
          value={profileFilter}
          onChange={(e) => setProfileFilter(e.target.value)}
          className="py-2 px-3 text-sm rounded-xl border border-border focus:border-navy-900 outline-none bg-surface"
        >
          <option value="">Tous les profils</option>
          {profiles.map(p => (
            <option key={p.id} value={p.id}>{p.name}</option>
          ))}
        </select>
        <select
          value={typeFilter}
          onChange={(e) => setTypeFilter(e.target.value)}
          className="py-2 px-3 text-sm rounded-xl border border-border focus:border-navy-900 outline-none bg-surface"
        >
          <option value="">Tous les types</option>
          <option value="SITUATIONAL_QCM">SITUATIONAL_QCM</option>
          <option value="PROBLEM_SOLVING">PROBLEM_SOLVING</option>
          <option value="CODE_REVIEW">CODE_REVIEW</option>
          <option value="ARCHITECTURE">ARCHITECTURE</option>
        </select>
        <select
          value={difficultyFilter}
          onChange={(e) => setDifficultyFilter(e.target.value)}
          className="py-2 px-3 text-sm rounded-xl border border-border focus:border-navy-900 outline-none bg-surface"
        >
          <option value="">Toutes les difficultés</option>
          <option value="JUNIOR">JUNIOR</option>
          <option value="INTERMEDIATE">INTERMEDIATE</option>
          <option value="SENIOR">SENIOR</option>
        </select>
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="py-2 px-3 text-sm rounded-xl border border-border focus:border-navy-900 outline-none bg-surface"
        >
          <option value="">Tous les statuts</option>
          <option value="DRAFT">DRAFT</option>
          <option value="VALIDATED">VALIDATED</option>
          <option value="ARCHIVED">ARCHIVED</option>
        </select>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-sm text-left">
          <thead className={tableHead}>
            <tr>
              <th className="px-6 py-4 font-medium">Titre / Question</th>
              <th className="px-6 py-4 font-medium">Type</th>
              <th className="px-6 py-4 font-medium">Statut</th>
              <th className="px-6 py-4 font-medium">Profils</th>
              <th className="px-6 py-4 font-medium text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border-subtle">
            {loading ? (
              <tr>
                <td colSpan={5} className="px-6 py-8 text-center text-ink-muted">Chargement...</td>
              </tr>
            ) : challenges.length === 0 ? (
              <tr>
                <td colSpan={5} className="px-6 py-8 text-center text-ink-muted">Aucune question trouvée.</td>
              </tr>
            ) : (
              challenges.map((c) => (
                <tr key={c.id} className="hover:bg-surface-elevated transition">
                  <td className="px-6 py-4">
                    <div className="font-semibold text-ink">{c.title}</div>
                    <div className="text-xs text-ink-secondary mt-1 line-clamp-1">{c.question}</div>
                  </td>
                  <td className="px-6 py-4">
                    <Badge variant="default">{c.type}</Badge>
                    <div className="text-xs text-ink-muted mt-1">{c.difficulty}</div>
                  </td>
                  <td className="px-6 py-4">
                    <Badge variant={c.status === 'VALIDATED' ? 'success' : c.status === 'ARCHIVED' ? 'default' : 'warning'}>
                      {c.status}
                    </Badge>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-xs text-ink-secondary">
                      {(c.profileIds ?? []).length === 0 ? (
                        <span className="text-ink-muted">—</span>
                      ) : (
                        (c.profileIds ?? [])
                          .map(id => profiles.find(p => p.id === id)?.name ?? `#${id}`)
                          .join(', ')
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex justify-end gap-2">
                      {c.status === 'DRAFT' && (
                        <IconButton variant="success" onClick={() => handleValidate(c.id)} title="Valider">
                          <CheckCircle className="w-4 h-4" />
                        </IconButton>
                      )}
                      <IconButton onClick={() => onEdit(c.id)} title="Modifier">
                        <Edit2 className="w-4 h-4" />
                      </IconButton>
                      <IconButton variant="danger" onClick={() => handleStatusChange(c.id, c.status)} title={c.status === 'ARCHIVED' ? 'Restaurer' : 'Archiver'}>
                        <Archive className="w-4 h-4" />
                      </IconButton>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {totalPages > 1 && (
        <div className="flex items-center justify-between px-6 py-4 border-t border-border-subtle text-xs text-ink-secondary">
          <span>
            {page * PAGE_SIZE + 1}–{Math.min((page + 1) * PAGE_SIZE, totalElements)} sur {totalElements}
          </span>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setPage((p) => Math.max(0, p - 1))}
              disabled={page === 0 || loading}
              className="px-3 py-1.5 rounded-lg border border-border bg-surface hover:bg-canvas-subtle disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
            >
              Précédent
            </button>
            <span>Page {page + 1} / {totalPages}</span>
            <button
              onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
              disabled={page >= totalPages - 1 || loading}
              className="px-3 py-1.5 rounded-lg border border-border bg-surface hover:bg-canvas-subtle disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
            >
              Suivant
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
