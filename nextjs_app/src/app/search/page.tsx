'use client';
import { useCallback, useEffect, useRef, useState } from 'react';
import { SlidersHorizontal } from 'lucide-react';
import { Grid } from '@/components/catalog';
import { InfiniteSentinel, LoadingCards } from '@/components/infinite-loading';
import type { Manga } from '@/lib/api';
import { ExplorePager } from '@/lib/explore-pager';
import type { ExploreFilters } from '@/lib/explore-filters';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Card, CardContent } from '@/components/ui/card';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';

export default function Search() {
  const [query, setQuery] = useState('');
  const [genre, setGenre] = useState(''); const [format, setFormat] = useState(''); const [country, setCountry] = useState('');
  const [filtersOpen, setFiltersOpen] = useState(false);
  const [draftFilters, setDraftFilters] = useState({ genre: '', format: '', country: '' });
  const activeFilterCount = [genre, format, country].filter(Boolean).length;
  const [items, setItems] = useState<Manga[]>([]); const [genres, setGenres] = useState<{slug:string;name:string}[]>([]); const [formats, setFormats] = useState<{slug:string;name:string}[]>([]);
  const [error, setError] = useState(''); const [loading, setLoading] = useState(true); const [page, setPage] = useState(0); const [ended, setEnded] = useState(false);
  const pager = useRef<ExplorePager | null>(null); const criteria = useRef<ExploreFilters>({query,genre,format,country}); criteria.current={query,genre,format,country};
  const sync = useCallback((instance: ExplorePager) => { const state=instance.snapshot; setItems(state.items); setPage(state.page); setEnded(state.ended); setError(state.error); setLoading(false); },[]);
  const requestPage = useCallback(async (instance: ExplorePager,retry=false) => { setLoading(true); setError(''); await instance.next(retry); if(pager.current===instance) sync(instance); },[sync]);
  useEffect(() => { fetch('/api/shinigami/genre/list').then(r=>r.json()).then(x=>setGenres(x.data||[])).catch(()=>{}); fetch('/api/shinigami/format/list').then(r=>r.json()).then(x=>setFormats(x.data||[])).catch(()=>{}); },[]);
  useEffect(() => { const instance=new ExplorePager(criteria.current); pager.current=instance; setItems([]);setPage(0);setEnded(false);setError('');setLoading(true);const timer=setTimeout(()=>void requestPage(instance),300);return()=>{clearTimeout(timer);instance.dispose();}; },[query,genre,format,country,requestPage]);
  const loadNext = () => { const instance=pager.current;if(instance&&!loading&&!ended&&!error)void requestPage(instance); };
  const filter = (label:string,value:string,setter:(value:string)=>void,options:{value:string;label:string}[]) => { const allLabel = label === 'Genre' ? 'Semua genre' : label === 'Format' ? 'Semua format' : 'Semua negara'; const id = `filter-${label.toLowerCase()}`; const choices = [{value:'__all__',label:allLabel},...options]; return <Select items={choices} value={value || '__all__'} onValueChange={(v:string|null)=>{if(v!==null)setter(v==='__all__'?'':v)}}><SelectTrigger id={id} aria-label={label} className="explore-filter-select min-w-0"><SelectValue placeholder={allLabel}/></SelectTrigger><SelectContent className="max-h-48"><SelectItem value="__all__">{allLabel}</SelectItem>{options.map(x=><SelectItem key={x.value} value={x.value}>{x.label}</SelectItem>)}</SelectContent></Select>; };
  const openFilters = () => { setDraftFilters({ genre, format, country }); setFiltersOpen(true); };
  const clearDraftFilters = () => setDraftFilters({ genre: '', format: '', country: '' });
  const applyFilters = () => { setGenre(draftFilters.genre); setFormat(draftFilters.format); setCountry(draftFilters.country); setFiltersOpen(false); };
  return <><div className="explore-toolbar">
      <Input className="explore-search-input" aria-label="Cari komik" placeholder="Cari komik…" value={query} onChange={e => setQuery(e.target.value)}/>
      <Button variant="outline" size="icon" aria-label={`Filter${activeFilterCount ? ` (${activeFilterCount} aktif)` : ''}`} title="Filter" onClick={openFilters} className="explore-filter-button"><SlidersHorizontal aria-hidden="true" className="size-5"/>{activeFilterCount > 0 && <span aria-hidden="true" className="absolute -top-1 -right-1 flex size-4 items-center justify-center rounded-full bg-primary text-[10px] text-primary-foreground">{activeFilterCount}</span>}</Button>
    </div>
    <Dialog open={filtersOpen} onOpenChange={setFiltersOpen}><DialogContent aria-describedby={undefined} className="explore-filter-dialog"><DialogHeader className="explore-filter-header"><DialogTitle>Filter komik</DialogTitle></DialogHeader><div className="explore-filter-fields grid min-w-0 gap-4"><div className="explore-filter-field grid min-w-0 gap-2"><label htmlFor="filter-genre" className="w-full">Genre</label>{filter('Genre',draftFilters.genre,v=>setDraftFilters(s=>({...s,genre:v})),genres.map(x=>({value:x.slug,label:x.name})))}</div><div className="explore-filter-field grid min-w-0 gap-2"><label htmlFor="filter-format" className="w-full">Format</label>{filter('Format',draftFilters.format,v=>setDraftFilters(s=>({...s,format:v})),formats.map(x=>({value:x.slug,label:x.name})))}</div><div className="explore-filter-field grid min-w-0 gap-2"><label htmlFor="filter-negara" className="w-full">Negara</label>{filter('Negara',draftFilters.country,v=>setDraftFilters(s=>({...s,country:v})),['KR','CN','JP','ID'].map(x=>({value:x,label:x})))}</div></div><DialogFooter className="explore-filter-footer"><Button variant="outline" onClick={clearDraftFilters}>Hapus filter</Button><Button onClick={applyFilters}>Terapkan</Button></DialogFooter></DialogContent></Dialog>
    {items.length > 0 && <Grid items={items}/>} {loading && <LoadingCards label={items.length ? 'Memuat hasil berikutnya' : 'Memuat hasil pencarian'}/>} {error && <Alert variant="destructive"><AlertDescription>{error} <Button variant="outline" onClick={() => {const instance=pager.current;if(instance)void requestPage(instance,true);}}>Coba lagi</Button></AlertDescription></Alert>}
    {!loading && !error && ended && !items.length && <Card><CardContent><p>Tidak ada hasil.</p></CardContent></Card>}<InfiniteSentinel onVisible={loadNext} enabled={!loading && !ended && page > 0 && !error}/></>;
}
