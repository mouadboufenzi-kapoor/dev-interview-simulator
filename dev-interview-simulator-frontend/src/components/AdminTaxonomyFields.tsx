import type { Dispatch, SetStateAction } from 'react';
import type { AdminChallengeRequest } from '../api/adminApi';
import type { Profile } from '../api/profileApi';
import type { Category, Skill } from '../types';
import { MultiSelect } from './common/MultiSelect';

interface Props {
  formData: AdminChallengeRequest;
  setFormData: Dispatch<SetStateAction<AdminChallengeRequest>>;
  profiles: Profile[];
  categories: Category[];
  skills: Skill[];
}

export const AdminTaxonomyFields = ({ formData, setFormData, profiles, categories, skills }: Props) => (
  <div className="space-y-4 pt-4 border-t border-border-subtle">
    <h3 className="font-serif font-bold text-lg text-navy-900">Profils, catégories et compétences</h3>
    <MultiSelect
      label="Profils associés"
      options={profiles}
      selectedIds={formData.profileIds}
      onChange={ids => setFormData({ ...formData, profileIds: ids })}
      emptyMessage="Aucun profil actif disponible."
    />
    <MultiSelect
      label="Catégories"
      options={categories}
      selectedIds={formData.categoryIds}
      onChange={ids => setFormData({ ...formData, categoryIds: ids })}
      emptyMessage="Aucune catégorie disponible."
    />
    <MultiSelect
      label="Compétences"
      options={skills}
      selectedIds={formData.skillIds}
      onChange={ids => setFormData({ ...formData, skillIds: ids })}
      emptyMessage="Aucune compétence disponible."
    />
  </div>
);
