import { useState, useEffect } from 'react';
import { adminProfileApi } from '../api/adminApi';
import type { AdminProfile } from '../api/adminApi';
import { Button } from './common/Button';
import { fieldInputSmall, fieldLabel, panel, panelToolbar, panelForm, emptyState } from '../styles/ui';
import { IconButton } from './common/IconButton';
import { Badge } from './common/Badge';
import { Plus, Edit2 } from 'lucide-react';

const ALL_TYPES = ['SITUATIONAL_QCM', 'PROBLEM_SOLVING', 'CODE_REVIEW', 'ARCHITECTURE'];

const emptyForm = { code: '', name: '', description: '', allowedTypes: [] as string[] };

export const AdminProfilePanel = () => {
  const [profiles, setProfiles] = useState<AdminProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [creating, setCreating] = useState(false);
  const [form, setForm] = useState(emptyForm);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadProfiles = async () => {
    setLoading(true);
    try {
      setProfiles(await adminProfileApi.getProfiles());
    } catch {
      setProfiles([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProfiles();
  }, []);

  const openCreate = () => {
    setEditingId(null);
    setForm(emptyForm);
    setCreating(true);
    setError(null);
  };

  const openEdit = (profile: AdminProfile) => {
    setCreating(false);
    setEditingId(profile.id);
    setForm({
      code: profile.code,
      name: profile.name,
      description: profile.description || '',
      allowedTypes: profile.allowedTypes ?? []
    });
    setError(null);
  };

  const closeForm = () => {
    setCreating(false);
    setEditingId(null);
    setForm(emptyForm);
    setError(null);
  };

  const toggleAllowedType = (type: string) => {
    setForm(prev => ({
      ...prev,
      allowedTypes: prev.allowedTypes.includes(type)
        ? prev.allowedTypes.filter(t => t !== type)
        : [...prev.allowedTypes, type]
    }));
  };

  const handleSave = async () => {
    if (!form.code.trim() || !form.name.trim()) return;
    setSaving(true);
    setError(null);
    try {
      const request = {
        code: form.code.trim(),
        name: form.name.trim(),
        description: form.description.trim() || undefined,
        allowedTypes: form.allowedTypes
      };
      if (editingId) {
        await adminProfileApi.updateProfile(editingId, request);
      } else {
        await adminProfileApi.createProfile(request);
      }
      closeForm();
      loadProfiles();
    } catch (err: any) {
      setError(err.response?.data?.message || 'Erreur lors de la sauvegarde du profil.');
    } finally {
      setSaving(false);
    }
  };

  const handleToggleActive = async (profile: AdminProfile) => {
    try {
      await adminProfileApi.setActive(profile.id, !profile.active);
      loadProfiles();
    } catch (err: any) {
      setError(err.response?.data?.message || "Erreur lors du changement d'état du profil.");
    }
  };

  return (
    <div className={panel}>
      <div className={panelToolbar}>
        <Button onClick={openCreate} variant="secondary" leftIcon={<Plus className="w-4 h-4" />}>
          Nouveau profil
        </Button>
      </div>

      {(creating || editingId) && (
        <div className={panelForm}>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <label className="block space-y-1.5">
              <span className={fieldLabel}>Code</span>
              <input
                value={form.code}
                onChange={e => setForm({ ...form, code: e.target.value })}
                placeholder="Ex. BACKEND"
                className={fieldInputSmall}
              />
            </label>
            <label className="block space-y-1.5">
              <span className={fieldLabel}>Nom</span>
              <input
                value={form.name}
                onChange={e => setForm({ ...form, name: e.target.value })}
                placeholder="Ex. Backend"
                className={fieldInputSmall}
              />
            </label>
          </div>
          <label className="block space-y-1.5">
            <span className={fieldLabel}>Description</span>
            <textarea
              value={form.description}
              onChange={e => setForm({ ...form, description: e.target.value })}
              rows={2}
              className={fieldInputSmall}
            />
          </label>
          <div className="space-y-1.5">
            <span className={fieldLabel}>Types de challenges autorisés</span>
            <p className="text-xs text-ink-muted">Aucun type coché = tous les types autorisés.</p>
            <div className="flex flex-wrap gap-2">
              {ALL_TYPES.map(type => {
                const isSelected = form.allowedTypes.includes(type);
                return (
                  <button
                    key={type}
                    type="button"
                    onClick={() => toggleAllowedType(type)}
                    className={`px-3 py-2 rounded-xl border text-sm transition cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${
                      isSelected
                        ? 'bg-navy-100 border-navy-900 text-navy-900 font-semibold'
                        : 'bg-surface border-border text-ink-secondary hover:bg-canvas-subtle'
                    }`}
                  >
                    {type}
                  </button>
                );
              })}
            </div>
          </div>
          {error && (
            <p className="text-sm text-danger">{error}</p>
          )}
          <div className="flex justify-end gap-3">
            <Button variant="secondary" size="sm" onClick={closeForm} disabled={saving}>
              Annuler
            </Button>
            <Button
              variant="primary"
              size="sm"
              onClick={handleSave}
              disabled={saving || !form.code.trim() || !form.name.trim()}
            >
              {saving ? 'Sauvegarde...' : editingId ? 'Enregistrer' : 'Créer'}
            </Button>
          </div>
        </div>
      )}

      {loading ? (
        <div className={emptyState}>Chargement...</div>
      ) : profiles.length === 0 ? (
        <div className={emptyState}>Aucun profil pour le moment.</div>
      ) : (
        <div className="divide-y divide-border-subtle">
          {profiles.map(profile => (
            <div key={profile.id} className="px-6 py-4 flex items-center justify-between gap-4">
              <div>
                <div className="flex items-center gap-2">
                  <span className="font-semibold text-ink">{profile.name}</span>
                  <span className="font-mono text-xs text-ink-muted">{profile.code}</span>
                  <Badge variant={profile.active ? 'success' : 'default'}>
                    {profile.active ? 'Actif' : 'Inactif'}
                  </Badge>
                </div>
                {profile.description && (
                  <p className="text-xs text-ink-secondary mt-1">{profile.description}</p>
                )}
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => handleToggleActive(profile)}
                  title={profile.active ? 'Désactiver' : 'Activer'}
                  className={`px-3 py-1.5 rounded-lg border text-xs font-semibold transition cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas ${
                    profile.active
                      ? 'border-border text-ink-secondary hover:bg-canvas-subtle'
                      : 'border-navy-200 text-navy-900 hover:bg-navy-100'
                  }`}
                >
                  {profile.active ? 'Désactiver' : 'Activer'}
                </button>
                <IconButton
                  onClick={() => openEdit(profile)}
                  title="Modifier"
                >
                  <Edit2 className="w-4 h-4" />
                </IconButton>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
