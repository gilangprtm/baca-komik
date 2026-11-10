'use client';
import { useEffect, useRef, useState } from 'react';
import { Skeleton } from '@/components/ui/skeleton';

export function InfiniteSentinel({ onVisible, enabled = true }: { onVisible: () => void; enabled?: boolean }) {
  const ref = useRef<HTMLDivElement>(null);
  const [supported, setSupported] = useState(true);
  const callback = useRef(onVisible);
  callback.current = onVisible;
  useEffect(() => {
    if (!('IntersectionObserver' in window)) { setSupported(false); return; }
    const node = ref.current;
    if (!node || !enabled) return;
    const observer = new IntersectionObserver(entries => {
      if (entries.some(entry => entry.isIntersecting)) callback.current();
    }, { rootMargin: '400px' });
    observer.observe(node);
    return () => observer.disconnect();
  }, [enabled]);
  return <div ref={ref} className="infinite-sentinel" style={{ minHeight: 1, width: '100%' }}>{enabled && !supported && <button type="button" onClick={() => callback.current()}>Muat lainnya</button>}</div>;
}

export function LoadingCards({ label = 'Memuat komik' }: { label?: string }) {
  return <div role="status" aria-label={label} className="grid">{Array.from({ length: 6 }, (_, i) => <div key={i} className="card"><Skeleton className="h-72" /></div>)}</div>;
}
