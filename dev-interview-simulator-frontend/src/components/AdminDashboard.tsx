import { useState, useEffect } from 'react';
import { adminApi } from '../api/adminApi';
import type { AdminChallengeResponse } from '../api/adminApi';
import { profileApi } from '../api/profileApi';
import type { Profile } from '../api/profileApi';

import { Button } from './common/Button';
import { Plus, Search, Edit2, Archive, CheckCircle} from 'lucide-react';
import { AdminChallengeForm } from './AdminChallengeForm';
import { AdminScenarioPanel } from './AdminScenarioPanel';
import { AdminProfilePanel } from './AdminProfilePanel';
import { Badge } from './common/Badge';

export const AdminDashboard = () => {
  const [challenges, setChallenges] = useState<AdminChallengeResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [profileFilter, setProfileFilter] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [difficultyFilter, setDifficultyFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  
  const [editingId, setEditingId] = useState<number | null>(null);
  const [isCreating, setIsCreating] = useState(false);
  const [tab, setTab] = useState<'content' | 'scenarios' | 'profiles'>('content');
  const [preselectedScenarioId, setPreselectedScenarioId] = useState<number | undefined>(undefined);

 const PAGE_SIZE = 6;

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

  const handleStatusChange = async (id: number, currentStatus: string) => {
    try {
      const newStatus = currentStatus === 'ARCHIVED' ? 'DRAFT' : 'ARCHIVED';
      await adminApi.changeStatus(id, newStatus);
      loadChallenges();
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
  if (!editingId && !isCreating) {
    loadChallenges();
  }
  }, [editingId, isCreating, search, page, profileFilter, typeFilter, difficultyFilter, statusFilter]);

  // Quand on change la recherche ou les filtres, on revient à la page 1
  useEffect(() => {
    setPage(0);
  }, [search, profileFilter, typeFilter, difficultyFilter, statusFilter]);

  const handleValidate = async (id: number) => {
    try {
      await adminApi.changeStatus(id, 'VALIDATED');
      loadChallenges();
    } catch (err) {
      console.error(err);
    }
  };

  if (isCreating || editingId) {
    return (
      <AdminChallengeForm
        challengeId={editingId || undefined}
        defaultScenarioId={preselectedScenarioId}
        onBack={() => {
          setIsCreating(false);
          setEditingId(null);
          setPreselectedScenarioId(undefined);
        }}
        onSaved={() => {
          setIsCreating(false);
          setEditingId(null);
          setPreselectedScenarioId(undefined);
        }}
      />
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-serif font-bold text-[#123C69]">Administration</h1>
          <p className="text-sm text-[#484F59] mt-1">Gérez les questions et contenus de la plateforme</p>
        </div>
        <Button
          onClick={() => setIsCreating(true)}
          variant="primary"
          leftIcon={<Plus className="w-4 h-4" />}
        >
          Nouvelle question
        </Button>
      </div>

      <div className="flex gap-2">
        <button
          onClick={() => setTab('content')}
          className={`px-4 py-2 rounded-xl text-sm font-semibold transition ${
            tab === 'content'
              ? 'bg-[#123C69] text-white'
              : 'bg-white border border-[#E8E2D8] text-[#484F59] hover:bg-[#FAF9F7]'
          }`}
        >
          Contenus
        </button>
        <button
          onClick={() => setTab('scenarios')}
          className={`px-4 py-2 rounded-xl text-sm font-semibold transition ${
            tab === 'scenarios'
              ? 'bg-[#123C69] text-white'
              : 'bg-white border border-[#E8E2D8] text-[#484F59] hover:bg-[#FAF9F7]'
          }`}
        >
          Scénarios
        </button>
        <button
          onClick={() => setTab('profiles')}
          className={`px-4 py-2 rounded-xl text-sm font-semibold transition ${
            tab === 'profiles'
              ? 'bg-[#123C69] text-white'
              : 'bg-white border border-[#E8E2D8] text-[#484F59] hover:bg-[#FAF9F7]'
          }`}
        >
          Profils
        </button>
      </div>

      {tab === 'scenarios' ? (
        <AdminScenarioPanel onAddStep={id => { setPreselectedScenarioId(id); setIsCreating(true); }} />
      ) : tab === 'profiles' ? (
        <AdminProfilePanel />
      ) : (
      <div className="bg-white rounded-2xl border border-[#E8E2D8] shadow-[0_2px_10px_rgba(18,60,105,0.05)] overflow-hidden">
        <div className="p-4 border-b border-[#F2EDE6] flex flex-wrap gap-4">
          <div className="relative flex-1 min-w-[220px] max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#797E88]" />
            <input
              type="text"
              placeholder="Rechercher une question..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-9 pr-4 py-2 text-sm rounded-xl border border-[#E8E2D8] focus:border-[#123C69] outline-none"
            />
          </div>
          <select
            value={profileFilter}
            onChange={(e) => setProfileFilter(e.target.value)}
            className="py-2 px-3 text-sm rounded-xl border border-[#E8E2D8] focus:border-[#123C69] outline-none bg-white"
          >
            <option value="">Tous les profils</option>
            {profiles.map(p => (
              <option key={p.id} value={p.id}>{p.name}</option>
            ))}
          </select>
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
            className="py-2 px-3 text-sm rounded-xl border border-[#E8E2D8] focus:border-[#123C69] outline-none bg-white"
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
            className="py-2 px-3 text-sm rounded-xl border border-[#E8E2D8] focus:border-[#123C69] outline-none bg-white"
          >
            <option value="">Toutes les difficultés</option>
            <option value="JUNIOR">JUNIOR</option>
            <option value="INTERMEDIATE">INTERMEDIATE</option>
            <option value="SENIOR">SENIOR</option>
          </select>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="py-2 px-3 text-sm rounded-xl border border-[#E8E2D8] focus:border-[#123C69] outline-none bg-white"
          >
            <option value="">Tous les statuts</option>
            <option value="DRAFT">DRAFT</option>
            <option value="VALIDATED">VALIDATED</option>
            <option value="ARCHIVED">ARCHIVED</option>
          </select>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-sm text-left">
            <thead className="text-xs text-[#797E88] uppercase bg-[#FAF9F7] border-b border-[#F2EDE6]">
              <tr>
                <th className="px-6 py-4 font-medium">Titre / Question</th>
                <th className="px-6 py-4 font-medium">Type</th>
                <th className="px-6 py-4 font-medium">Statut</th>
                <th className="px-6 py-4 font-medium">Profils</th>
                <th className="px-6 py-4 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#F2EDE6]">
              {loading ? (
                <tr>
                  <td colSpan={5} className="px-6 py-8 text-center text-[#797E88]">Chargement...</td>
                </tr>
              ) : challenges.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-6 py-8 text-center text-[#797E88]">Aucune question trouvée.</td>
                </tr>
              ) : (
                challenges.map((c) => (
                  <tr key={c.id} className="hover:bg-[#FCFBF9] transition">
                    <td className="px-6 py-4">
                      <div className="font-semibold text-[#102136]">{c.title}</div>
                      <div className="text-xs text-[#484F59] mt-1 line-clamp-1">{c.question}</div>
                    </td>
                    <td className="px-6 py-4">
                      <Badge variant="default">{c.type}</Badge>
                      <div className="text-xs text-[#797E88] mt-1">{c.difficulty}</div>
                    </td>
                    <td className="px-6 py-4">
                      <Badge variant={c.status === 'VALIDATED' ? 'success' : c.status === 'ARCHIVED' ? 'default' : 'warning'}>
                        {c.status}
                      </Badge>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-xs text-[#484F59]">
                        {(c.profileIds ?? []).length === 0 ? (
                          <span className="text-[#797E88]">—</span>
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
                          <button onClick={() => handleValidate(c.id)} title="Valider" className="p-2 text-[#2E7D32] hover:bg-[#E8F5E9] rounded-lg transition">
                            <CheckCircle className="w-4 h-4" />
                          </button>
                        )}
                        <button onClick={() => setEditingId(c.id)} title="Modifier" className="p-2 text-[#123C69] hover:bg-[#E6EFF8] rounded-lg transition">
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button onClick={() => handleStatusChange(c.id, c.status)} title={c.status === 'ARCHIVED' ? 'Restaurer' : 'Archiver'} className="p-2 text-[#AC3B61] hover:bg-[#FDF2F2] rounded-lg transition">
                          <Archive className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>   {/* fin de overflow-x-auto */}

            {totalPages > 1 && (
              <div className="flex items-center justify-between px-6 py-4 border-t border-[#F2EDE6] text-xs text-[#484F59]">
                <span>
                  {page * PAGE_SIZE + 1}–{Math.min((page + 1) * PAGE_SIZE, totalElements)} sur {totalElements}
                </span>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setPage((p) => Math.max(0, p - 1))}
                    disabled={page === 0 || loading}
                    className="px-3 py-1.5 rounded-lg border border-[#E8E2D8] bg-white hover:bg-[#FAF9F7] disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer"
                  >
                    Précédent
                  </button>
                  <span>Page {page + 1} / {totalPages}</span>
                  <button
                    onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
                    disabled={page >= totalPages - 1 || loading}
                    className="px-3 py-1.5 rounded-lg border border-[#E8E2D8] bg-white hover:bg-[#FAF9F7] disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer"
                  >
                    Suivant
                  </button>
                </div>
              </div>
            )}
          </div>
      )}
    </div>
  );
};
