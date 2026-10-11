import { useState, useEffect } from 'react';
import { adminProfileApi } from '../api/adminApi';
import type { AdminProfile } from '../api/adminApi';
import { Button } from './common/Button';
import { Badge } from './common/Badge';
import { Plus, Edit2 } from 'lucide-react';

const emptyForm = { code: '', name: '', description: '' };

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
    setForm({ code: profile.code, name: profile.name, description: profile.description || '' });
    setError(null);
  };

  const closeForm = () => {
    setCreating(false);
    setEditingId(null);
    setForm(emptyForm);
    setError(null);
  };

  const handleSave = async () => {
    if (!form.code.trim() || !form.name.trim()) return;
    setSaving(true);
    setError(null);
    try {
      const request = {
        code: form.code.trim(),
        name: form.name.trim(),
        description: form.description.trim() || undefined
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
    <div className="bg-white rounded-2xl border border-[#E8E2D8] shadow-[0_2px_10px_rgba(18,60,105,0.05)] overflow-hidden">
      <div className="p-4 border-b border-[#F2EDE6] flex justify-end">
        <Button onClick={openCreate} variant="secondary" leftIcon={<Plus className="w-4 h-4" />}>
          Nouveau profil
        </Button>
      </div>

      {(creating || editingId) && (
        <div className="p-4 border-b border-[#F2EDE6] space-y-3 bg-[#FAF9F7]">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <label className="block space-y-1.5">
              <span className="text-sm font-semibold text-[#102136]">Code</span>
              <input
                value={form.code}
                onChange={e => setForm({ ...form, code: e.target.value })}
                placeholder="Ex. BACKEND"
                className="w-full rounded-xl border border-[#E8E2D8] p-2.5 text-sm focus:border-[#123C69] outline-none bg-white"
              />
            </label>
            <label className="block space-y-1.5">
              <span className="text-sm font-semibold text-[#102136]">Nom</span>
              <input
                value={form.name}
                onChange={e => setForm({ ...form, name: e.target.value })}
                placeholder="Ex. Backend"
                className="w-full rounded-xl border border-[#E8E2D8] p-2.5 text-sm focus:border-[#123C69] outline-none bg-white"
              />
            </label>
          </div>
          <label className="block space-y-1.5">
            <span className="text-sm font-semibold text-[#102136]">Description</span>
            <textarea
              value={form.description}
              onChange={e => setForm({ ...form, description: e.target.value })}
              rows={2}
              className="w-full rounded-xl border border-[#E8E2D8] p-2.5 text-sm focus:border-[#123C69] outline-none bg-white"
            />
          </label>
          {error && (
            <p className="text-sm text-[#9C2727]">{error}</p>
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
        <div className="px-6 py-8 text-center text-sm text-[#797E88]">Chargement...</div>
      ) : profiles.length === 0 ? (
        <div className="px-6 py-8 text-center text-sm text-[#797E88]">Aucun profil pour le moment.</div>
      ) : (
        <div className="divide-y divide-[#F2EDE6]">
          {profiles.map(profile => (
            <div key={profile.id} className="px-6 py-4 flex items-center justify-between gap-4">
              <div>
                <div className="flex items-center gap-2">
                  <span className="font-semibold text-[#102136]">{profile.name}</span>
                  <span className="font-mono text-xs text-[#797E88]">{profile.code}</span>
                  <Badge variant={profile.active ? 'success' : 'default'}>
                    {profile.active ? 'Actif' : 'Inactif'}
                  </Badge>
                </div>
                {profile.description && (
                  <p className="text-xs text-[#484F59] mt-1">{profile.description}</p>
                )}
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => handleToggleActive(profile)}
                  title={profile.active ? 'Désactiver' : 'Activer'}
                  className={`px-3 py-1.5 rounded-lg border text-xs font-semibold transition cursor-pointer ${
                    profile.active
                      ? 'border-[#E8E2D8] text-[#484F59] hover:bg-[#FAF9F7]'
                      : 'border-[#B8D3EC] text-[#123C69] hover:bg-[#E6EFF8]'
                  }`}
                >
                  {profile.active ? 'Désactiver' : 'Activer'}
                </button>
                <button
                  onClick={() => openEdit(profile)}
                  title="Modifier"
                  className="p-2 text-[#123C69] hover:bg-[#E6EFF8] rounded-lg transition"
                >
                  <Edit2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
