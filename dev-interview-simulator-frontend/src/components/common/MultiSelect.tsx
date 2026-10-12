/* Texte FR embarqué — point de bascule i18n (étape 12). */
const DEFAULT_EMPTY_MESSAGE = 'Aucune option disponible.';

interface MultiSelectOption {
  id: number;
  name: string;
}

interface Props {
  label?: string;
  options: MultiSelectOption[];
  selectedIds: number[];
  onChange: (ids: number[]) => void;
  emptyMessage?: string;
}

export const MultiSelect = ({ label, options, selectedIds, onChange, emptyMessage = DEFAULT_EMPTY_MESSAGE }: Props) => {
  const toggle = (id: number) => {
    if (selectedIds.includes(id)) {
      onChange(selectedIds.filter(selectedId => selectedId !== id));
    } else {
      onChange([...selectedIds, id]);
    }
  };

  return (
    <div className="space-y-1.5">
      {label && <span className="text-sm font-semibold text-ink">{label}</span>}
      {options.length === 0 ? (
        <p className="text-sm text-ink-muted">{emptyMessage}</p>
      ) : (
        <div className="flex flex-wrap gap-2">
          {options.map(option => {
            const isSelected = selectedIds.includes(option.id);
            return (
              <button
                key={option.id}
                type="button"
                onClick={() => toggle(option.id)}
                className={`px-3 py-2 rounded-xl border text-sm transition ${
                  isSelected
                    ? 'bg-navy-100 border-navy-900 text-navy-900 font-semibold'
                    : 'bg-surface border-border text-ink-secondary hover:bg-canvas-subtle'
                }`}
              >
                {option.name}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
};
