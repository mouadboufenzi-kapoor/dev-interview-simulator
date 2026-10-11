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

export const MultiSelect = ({ label, options, selectedIds, onChange, emptyMessage = 'Aucune option disponible.' }: Props) => {
  const toggle = (id: number) => {
    if (selectedIds.includes(id)) {
      onChange(selectedIds.filter(selectedId => selectedId !== id));
    } else {
      onChange([...selectedIds, id]);
    }
  };

  return (
    <div className="space-y-1.5">
      {label && <span className="text-sm font-semibold text-[#102136]">{label}</span>}
      {options.length === 0 ? (
        <p className="text-sm text-[#797E88]">{emptyMessage}</p>
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
                    ? 'bg-[#E6EFF8] border-[#123C69] text-[#123C69] font-semibold'
                    : 'bg-white border-[#E8E2D8] text-[#484F59] hover:bg-[#FAF9F7]'
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
