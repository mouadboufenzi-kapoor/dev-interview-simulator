import { useEffect, useRef, useState } from 'react';

export interface StatItem {
  value: number;
  label: string;
  suffix?: string;
}

const nf = new Intl.NumberFormat('fr-FR');

const prefersReducedMotion = () =>
  typeof window !== 'undefined' &&
  window.matchMedia('(prefers-reduced-motion: reduce)').matches;

function useInView<T extends Element>(threshold = 0.35) {
  const ref = useRef<T>(null);
  const [seen, setSeen] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (!el || seen) return;
    if (typeof IntersectionObserver === 'undefined') {
      setSeen(true);
      return;
    }
    const io = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setSeen(true);
          io.disconnect();
        }
      },
      { threshold }
    );
    io.observe(el);
    return () => io.disconnect();
  }, [seen, threshold]);
  return { ref, seen };
}

function useCountUp(target: number, start: boolean, reduce: boolean, duration = 900) {
  const [value, setValue] = useState(reduce ? target : 0);
  useEffect(() => {
    if (reduce) {
      setValue(target);
      return;
    }
    if (!start) return;
    let raf = 0;
    let t0: number | null = null;
    const tick = (ts: number) => {
      if (t0 === null) t0 = ts;
      const p = Math.min((ts - t0) / duration, 1);
      setValue(Math.round(target * (1 - Math.pow(1 - p, 3))));
      if (p < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [target, start, reduce, duration]);
  return value;
}

const TILE_COLORS = [
  'bg-stat-1 text-stat-1-text md:bg-[#123a64] md:text-white',
  'bg-stat-2 text-white text-relief md:bg-[#ff5a2f] md:text-white',
  'bg-stat-3 text-stat-3-text md:bg-[#d6e0f0] md:text-[#0a2342]',
];

const StatTile = ({
  item,
  index,
  start,
  reduce,
}: {
  item: StatItem;
  index: number;
  start: boolean;
  reduce: boolean;
}) => {
  const current = useCountUp(item.value, start, reduce);
  const suffix = item.suffix ?? '';
  const done = current >= item.value;
  return (
    <li
      className={`min-w-0 rounded border-2 border-border shadow-panel px-2.5 py-3 sm:px-5 sm:py-5 md:rounded-[6px] md:border-[#0a2342] md:px-3 md:py-4 md:shadow-[4px_4px_0_#0a2342] ${TILE_COLORS[index % 3]}`}
    >
      <span className="sr-only">{`${nf.format(item.value)}${suffix} ${item.label}`}</span>
      <span
        aria-hidden="true"
        className="block whitespace-nowrap font-bold leading-none tracking-[-0.03em] tabular-nums text-[1.55rem] sm:text-4xl md:text-[34px]"
      >
        {nf.format(current)}
        {done ? suffix : ''}
      </span>
      <span aria-hidden="true" className="mt-2 block text-[11px] leading-tight sm:text-sm md:text-[14px]">
        {item.label}
      </span>
    </li>
  );
};

export const StatTiles = ({ items, className = '' }: { items: StatItem[]; className?: string }) => {
  const reduce = prefersReducedMotion();
  const { ref, seen } = useInView<HTMLUListElement>();
  return (
    <ul
      ref={ref}
      className={`grid w-full min-w-0 grid-cols-[1.3fr_1.1fr_1fr] gap-2.5 text-center sm:grid-cols-3 sm:gap-4 md:gap-3.5 ${className}`}
    >
      {items.slice(0, 3).map((item, i) => (
        <StatTile key={item.label} item={item} index={i} start={seen} reduce={reduce} />
      ))}
    </ul>
  );
};
