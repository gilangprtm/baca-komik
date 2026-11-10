'use client';
import { useCallback, useRef, useState } from 'react';
import { Grid } from '@/components/catalog';
import { InfiniteSentinel, LoadingCards } from '@/components/infinite-loading';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import type { ListMeta, Manga } from '@/lib/api';

export default function HomeFeed({ initialItems, meta }: { initialItems: Manga[]; meta?: ListMeta }) {
  const [items, setItems] = useState(initialItems);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [ended, setEnded] = useState(meta ? meta.total_page <= 1 : initialItems.length < 24);
  const busy = useRef(false);
  const load = useCallback(async () => {
    if (busy.current || ended) return;
    busy.current = true; setLoading(true); setError('');
    const next = page + 1;
    try {
      const response = await fetch(`/api/shinigami/manga/list?page=${next}&page_size=24&is_update=true&sort=latest`);
      if (!response.ok) throw new Error(`API error (${response.status})`);
      const body = await response.json();
      if (body.retcode !== 0) throw new Error(body.message || 'API request failed');
      const rows: Manga[] = body.data || [];
      setItems(current => { const ids = new Set(current.map(item => item.manga_id)); return [...current, ...rows.filter(item => !ids.has(item.manga_id))]; });
      setPage(next);
      if (body.meta ? next >= body.meta.total_page : rows.length < 24) setEnded(true);
    } catch (e) { setError(e instanceof Error ? e.message : 'Unable to load comics'); }
    finally { busy.current = false; setLoading(false); }
  }, [ended, page]);
  return <>{items.length ? <Grid items={items}/> : !loading && <Card><CardContent><p>Belum ada komik tersedia.</p></CardContent></Card>}
    {loading && <LoadingCards label="Memuat komik berikutnya"/>}{error && <Alert variant="destructive"><AlertDescription>{error} <Button variant="outline" onClick={() => void load()}>Coba lagi</Button></AlertDescription></Alert>}
    <InfiniteSentinel onVisible={() => void load()} enabled={!loading && !ended && !error}/></>;
}
