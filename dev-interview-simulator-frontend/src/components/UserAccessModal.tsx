import { useState } from 'react';
import { Button } from './common/Button';
import { PageTitle } from './common/PageTitle';
import { Mail, UserRound, X } from 'lucide-react';
import { authApi } from '../api/authApi';
import { clearStoredAuth } from '../api/authStorage';

export interface AuthUser {
  id?: number;
  username: string;
  email: string;
  role?: string;
  profile?: string;
}

interface Props {
  onClose: () => void;
  onAuthenticated: (user: AuthUser) => void;
}

type AccessMode = 'login' | 'register';

export const UserAccessModal = ({ onClose, onAuthenticated }: Props) => {
  const [mode, setMode] = useState<AccessMode>('login');
  const [usernameOrEmail, setUsernameOrEmail] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    setError(null);
    setLoading(true);

    try {
      if (mode === 'login') {
        const response = await authApi.login({ usernameOrEmail, password });
        onAuthenticated({
          id: response.userId,
          username: response.username,
          email: response.email,
          role: response.role,
        });
      } else {
        const response = await authApi.register({ username: usernameOrEmail, email, password });
        onAuthenticated({
          id: response.userId,
          username: response.username,
          email: response.email,
          role: response.role,
        });
      }
    } catch (err: any) {
      console.error(err);
      clearStoredAuth();
      setError(err.response?.data?.message || 'Erreur d\'authentification. Veuillez vérifier vos informations.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-ink/25 p-4 backdrop-blur-[2px]">
      <div className="w-full max-w-md rounded-2xl border border-border bg-surface p-6 shadow-modal">
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="text-[10px] font-semibold uppercase tracking-[0.18em] text-ink-muted">
              Espace personnel
            </p>
            <PageTitle as="h2" size="md" className="mt-2">
              {mode === 'login' ? 'Ravi de vous revoir' : 'Créer votre compte'}
            </PageTitle>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-lg p-1.5 text-ink-muted transition hover:bg-canvas-subtle hover:text-navy-900"
            aria-label="Fermer"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="mt-6 flex gap-5 border-b border-border-subtle text-sm">
          <button
            type="button"
            onClick={() => setMode('login')}
            className={`border-b-2 pb-3 font-medium transition ${
              mode === 'login'
                ? 'border-crimson-700 text-navy-900'
                : 'border-transparent text-ink-muted'
            }`}
          >
            Se connecter
          </button>
          <button
            type="button"
            onClick={() => setMode('register')}
            className={`border-b-2 pb-3 font-medium transition ${
              mode === 'register'
                ? 'border-crimson-700 text-navy-900'
                : 'border-transparent text-ink-muted'
            }`}
          >
            Créer un compte
          </button>
        </div>

        {error && (
          <div className="mt-4 rounded-xl bg-danger-soft border border-danger-border p-3 text-sm text-crimson-700">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="mt-6 space-y-4">
          <label className="block space-y-1.5">
            <span className="text-xs font-semibold text-ink-secondary">
              {mode === 'login' ? 'Username ou Email' : 'Username'}
            </span>
            <div className="flex items-center gap-2 rounded-xl border border-border px-3 focus-within:border-navy-900">
              <UserRound className="h-4 w-4 text-ink-muted" />
              <input
                required
                value={usernameOrEmail}
                onChange={(event) => setUsernameOrEmail(event.target.value)}
                className="h-11 min-w-0 flex-1 bg-transparent text-sm text-ink outline-none"
                placeholder={mode === 'login' ? 'nom@exemple.com' : 'votre-username'}
              />
            </div>
          </label>

          {mode === 'register' && (
            <label className="block space-y-1.5">
              <span className="text-xs font-semibold text-ink-secondary">Email</span>
              <div className="flex items-center gap-2 rounded-xl border border-border px-3 focus-within:border-navy-900">
                <Mail className="h-4 w-4 text-ink-muted" />
                <input
                  required
                  type="email"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  className="h-11 min-w-0 flex-1 bg-transparent text-sm text-ink outline-none"
                  placeholder="nom@exemple.com"
                />
              </div>
            </label>
          )}

          <label className="block space-y-1.5">
            <span className="text-xs font-semibold text-ink-secondary">Mot de passe</span>
            <input
              required
              type="password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              className="h-11 w-full rounded-xl border border-border bg-transparent px-3 text-sm text-ink outline-none focus:border-navy-900"
              placeholder="••••••••"
            />
          </label>

          <Button type="submit" variant="primary" fullWidth loading={loading} className="mt-2">
            {mode === 'login' ? 'Se connecter' : 'Créer mon compte'}
          </Button>
        </form>
      </div>
    </div>
  );
};
