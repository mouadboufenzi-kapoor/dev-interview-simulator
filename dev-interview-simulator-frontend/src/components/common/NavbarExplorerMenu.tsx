import type { RefObject } from 'react';
import { Badge } from './Badge';
import { ChevronDown, Radio, Trophy } from 'lucide-react';

interface ModuleItem {
  icon: typeof Radio;
  title: string;
  subtitle: string;
  iconClassName: string;
}

const MODULES: ModuleItem[] = [
  { icon: Radio, title: 'Veille technique', subtitle: 'Radar & actualités IT', iconClassName: 'text-navy-900' },
  { icon: Trophy, title: 'Classement', subtitle: 'Top scores de la promo', iconClassName: 'text-crimson-700' },
];

interface Props {
  open: boolean;
  onToggle: () => void;
  menuRef: RefObject<HTMLDivElement | null>;
}

export const NavbarExplorerMenu = ({ open, onToggle, menuRef }: Props) => (
  <div className="relative" ref={menuRef}>
    <button
      type="button"
      onClick={onToggle}
      className="flex items-center gap-1 text-xs font-sans text-ink-warm hover:text-navy-900 px-2 sm:px-2.5 py-1.5 rounded-lg hover:bg-canvas-subtle transition cursor-pointer focus-visible:ring-2 focus-visible:ring-navy-900 focus-visible:ring-offset-2 focus-visible:ring-offset-white dark:focus-visible:ring-offset-canvas"
    >
      <span className="hidden sm:inline">Explorer</span>
      <ChevronDown className="w-3.5 h-3.5" />
    </button>

    {/* Dropdown Menu for Future Features */}
    {open && (
      <div className="absolute right-0 mt-2 w-64 bg-surface border-[0.5px] border-card-border rounded-2xl p-2 shadow-xl animate-in fade-in slide-in-from-top-1 duration-150 z-40 space-y-1">
        <div className="px-3 py-2 border-b border-border-subtle">
          <span className="text-[10px] font-mono uppercase tracking-wider text-ink-muted font-semibold">
            Modules à venir
          </span>
        </div>

        {MODULES.map(({ icon: Icon, title, subtitle, iconClassName }) => (
          <div
            key={title}
            className="p-2.5 rounded-xl hover:bg-canvas-subtle transition flex items-center justify-between cursor-default"
          >
            <div className="flex items-center gap-2.5 text-xs text-ink">
              <Icon className={`w-4 h-4 ${iconClassName}`} />
              <div>
                <p className="font-semibold">{title}</p>
                <p className="text-[10px] text-ink-muted">{subtitle}</p>
              </div>
            </div>
            <Badge variant="default" size="sm">
              Bientôt
            </Badge>
          </div>
        ))}
      </div>
    )}
  </div>
);
