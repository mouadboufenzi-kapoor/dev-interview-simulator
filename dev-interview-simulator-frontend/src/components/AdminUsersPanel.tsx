import { useEffect, useState } from 'react';
import { Search } from 'lucide-react';
import { adminUserApi } from '../api/adminApi';
import type { AdminUser } from '../api/adminApi';
import { emptyState, panel, tableHead } from '../styles/ui';
import { Badge } from './common/Badge';
import { Pagination } from './common/Pagination';
import { formatDate } from '../utils/format';

const PAGE_SIZE = 10;

type LoadState = 'loading' | 'ready' | 'error';

export const AdminUsersPanel = () => {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [state, setState] = useState<LoadState>('loading');

  useEffect(() => {
    let active = true;
    setState('loading');
    adminUserApi
      .search({ search: search.trim() || undefined, page, size: PAGE_SIZE })
      .then((result) => {
        if (!active) return;
        setUsers(result.content ?? []);
        setTotalElements(result.totalElements ?? 0);
        setTotalPages(result.totalPages ?? 0);
        setState('ready');
      })
      .catch(() => {
        if (!active) return;
        setUsers([]);
        setTotalElements(0);
        setTotalPages(0);
        setState('error');
      });
    return () => {
      active = false;
    };
  }, [search, page]);

  const updateSearch = (value: string) => {
    setSearch(value);
    setPage(0);
  };

  return (
    <div className={panel}>
      <div className="flex flex-col gap-3 border-b-2 border-border p-4 sm:flex-row sm:items-center sm:justify-between">
        <label className="relative block w-full max-w-md">
          <span className="sr-only">Rechercher un utilisateur</span>
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-muted" />
          <input
            type="search"
            value={search}
            onChange={(event) => updateSearch(event.target.value)}
            placeholder="Rechercher par nom ou email..."
            className="w-full rounded border-2 border-border bg-card py-2 pl-9 pr-3 text-sm text-text"
          />
        </label>
        <p className="text-xs text-ink-muted">
          {totalElements} {totalElements > 1 ? 'utilisateurs' : 'utilisateur'}
        </p>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm">
          <thead className={tableHead}>
            <tr>
              <th className="px-4 py-3 font-medium sm:px-6">ID</th>
              <th className="px-4 py-3 font-medium sm:px-6">Utilisateur</th>
              <th className="px-4 py-3 font-medium sm:px-6">Email</th>
              <th className="px-4 py-3 font-medium sm:px-6">Rôle</th>
              <th className="px-4 py-3 font-medium sm:px-6">Inscription</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border-subtle">
            {state === 'loading' ? (
              <tr>
                <td colSpan={5} className={emptyState}>Chargement...</td>
              </tr>
            ) : state === 'error' ? (
              <tr>
                <td colSpan={5} className={emptyState}>Impossible de charger les utilisateurs.</td>
              </tr>
            ) : users.length === 0 ? (
              <tr>
                <td colSpan={5} className={emptyState}>Aucun utilisateur trouvé.</td>
              </tr>
            ) : (
              users.map((user) => (
                <tr key={user.id} className="transition hover:bg-surface-elevated">
                  <td className="px-4 py-3 font-mono text-xs text-ink-muted sm:px-6">{user.id}</td>
                  <td className="px-4 py-3 sm:px-6">
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-ink">{user.username}</span>
                      {!user.enabled && <Badge variant="danger" size="sm">Désactivé</Badge>}
                    </div>
                  </td>
                  <td className="px-4 py-3 text-ink-secondary sm:px-6">{user.email}</td>
                  <td className="px-4 py-3 sm:px-6">
                    <Badge variant={user.role === 'ADMIN' ? 'navy' : 'default'} size="sm">
                      {user.role}
                    </Badge>
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 text-ink-secondary sm:px-6">
                    {formatDate(user.createdAt)}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {state === 'ready' && totalElements > 0 && (
        <div className="flex flex-wrap items-center justify-between gap-3 border-t-2 border-border px-4 py-4 text-xs text-ink-secondary sm:px-6">
          <span>
            {page * PAGE_SIZE + 1}–{Math.min((page + 1) * PAGE_SIZE, totalElements)} sur {totalElements}
          </span>
          <Pagination page={page} pageCount={totalPages} onPageChange={setPage} />
        </div>
      )}
    </div>
  );
};
