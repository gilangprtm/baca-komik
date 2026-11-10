import { describe, expect, it, vi } from 'vitest';
import type { Manga } from './api';
import { exploreListUrl, filterExploreRows, type ExploreFilters } from './explore-filters';
import { ExplorePager } from './explore-pager';
const empty: ExploreFilters = { query: '', genre: '', format: '', country: '' };
const row = (id: string, country = 'CN', genre = 'action', format = 'manhua'): Manga => ({ manga_id: id, title: id, country_id: country, taxonomy: { Genre: [{ name: genre, slug: genre }], Format: [{ name: format, slug: format }] } });
const response = (data: Manga[], page = 1, total_page = 1) => new Response(JSON.stringify({ retcode: 0, data, meta: { page, total_page } }));

describe('Explore AND contract', () => {
  for (const selection of [{genre:'action'}, {format:'manhua'}, {country:'CN'}, {genre:'action',format:'manhua'}, {genre:'action',country:'CN'}, {format:'manhua',country:'CN'}, {genre:'action',format:'manhua',country:'CN'}]) {
    it(`enforces ${JSON.stringify(selection)}`, () => {
      const filters = { ...empty, ...selection };
      const rows = [row('yes'), row('genre', 'CN', 'sports'), row('format', 'CN', 'action', 'manhwa'), row('country', 'KR'), { manga_id:'missing',title:'missing' }];
      const expected = rows.filter(m => (!selection.genre || m.taxonomy?.Genre[0].slug === selection.genre) && (!selection.format || m.taxonomy?.Format[0].slug === selection.format) && (!selection.country || m.country_id === selection.country));
      expect(filterExploreRows(rows, filters)).toEqual(expected);
    });
  }
  it('normalizes case, JP/JPN, and fallback names but trusts a present slug', () => {
    expect(filterExploreRows([row('yes', 'jPn', 'ACTION', 'Manhua')], { ...empty, country:'JP', genre:'action',format:'manhua' })).toHaveLength(1);
    const manga = row('name'); manga.taxonomy = { Genre: [{name:'Martial Arts'}] };
    expect(filterExploreRows([manga], {...empty,genre:'martial-arts'})).toHaveLength(1);
    manga.taxonomy.Genre[0].slug = 'sports';
    expect(filterExploreRows([manga], {...empty,genre:'martial-arts'})).toHaveLength(0);
    expect(filterExploreRows([{manga_id:'missing',title:'missing'}],empty)).toHaveLength(1);
  });
  it('uses list canonical parameters, leaving ranked search to upstream', () => {
    const url = new URL(exploreListUrl({...empty,query:' Demonic ',genre:'action',format:'manhua',country:'CN'},2),'http://test');
    expect(url.pathname).toBe('/api/shinigami/manga/list');
    expect(Object.fromEntries(url.searchParams)).toEqual({page:'2',page_size:'24',sort:'popularity',q:'Demonic',genre_include:'action',genre_include_mode:'and',format:'manhua'});
    expect(filterExploreRows([row('not a substring')],{...empty,query:'Demonic'})).toHaveLength(1);
  });
});

describe('Explore raw pagination and cancellation', () => {
  it('scans empty pages, deduplicates within/across pages, and stops using raw meta', async () => {
    const fetcher = vi.fn().mockResolvedValueOnce(response([row('kr','KR')],1,3)).mockResolvedValueOnce(response([row('cn'),row('cn')],2,3)).mockResolvedValueOnce(response([row('cn'),row('last')],3,3));
    const pager = new ExplorePager({...empty,country:'CN'},fetcher);
    expect((await pager.next()).items).toEqual([]);
    expect(pager.snapshot.ended).toBe(false);
    expect((await pager.next()).items.map(m=>m.manga_id)).toEqual(['cn']);
    expect((await pager.next()).items.map(m=>m.manga_id)).toEqual(['cn','last']);
    expect(pager.snapshot.ended).toBe(true);
    await pager.next(); expect(fetcher).toHaveBeenCalledTimes(3);
  });
  it('finishes an exhaustive empty combination', async () => {
    const pager = new ExplorePager({...empty,country:'CN'},vi.fn().mockResolvedValueOnce(response([row('kr','KR')],1,2)).mockResolvedValueOnce(response([],2,2)));
    await pager.next(); const state = await pager.next(); expect(state.items).toEqual([]); expect(state.ended).toBe(true);
  });
  it('does not automatically retry errors; explicit retry uses failed page and retains data', async () => {
    const fetcher = vi.fn().mockResolvedValueOnce(response([row('first')],1,2)).mockRejectedValueOnce(Error('offline')).mockResolvedValueOnce(response([row('second')],2,2));
    const pager = new ExplorePager(empty,fetcher); await pager.next(); await pager.next();
    expect(pager.snapshot.error).toBe('offline'); expect(pager.snapshot.page).toBe(1);
    await pager.next(); expect(fetcher).toHaveBeenCalledTimes(2);
    const state = await pager.next(true); expect(state.items.map(m=>m.manga_id)).toEqual(['first','second']);
    expect(fetcher.mock.calls.map(call=>new URL(call[0],'http://test').searchParams.get('page'))).toEqual(['1','2','2']);
  });
  it('ignores delayed obsolete responses after dispose and starts new criteria at page one', async () => {
    let resolve!: (response: Response) => void;
    const fetcher = vi.fn((input: string, init?: RequestInit) => { void input; void init; return new Promise<Response>(r=>{resolve=r;}); });
    const old = new ExplorePager(empty,fetcher); const pending = old.next(); old.dispose();
    const fresh = new ExplorePager({...empty,country:'KR'},vi.fn().mockResolvedValue(response([row('new','KR')])));
    resolve(response([row('stale')])); await pending;
    expect(old.snapshot.items).toEqual([]); expect(fetcher.mock.calls[0][1]?.signal?.aborted).toBe(true);
    expect((await fresh.next()).items.map(m=>m.manga_id)).toEqual(['new']);
  });
  it('handles HTTP/envelope errors and abort without loops or cursor advancement', async () => {
    for (const failure of [new Response('',{status:503}),new Response(JSON.stringify({retcode:1,message:'bad'}))]) {
      const fetcher=vi.fn().mockResolvedValue(failure); const pager=new ExplorePager(empty,fetcher);
      await pager.next(); await pager.next(); expect(fetcher).toHaveBeenCalledTimes(1); expect(pager.snapshot.page).toBe(0); expect(pager.snapshot.error).toBeTruthy();
    }
    const fetcher=vi.fn().mockRejectedValue(new DOMException('aborted','AbortError')); const pager=new ExplorePager(empty,fetcher);
    await pager.next(); await pager.next(); expect(fetcher).toHaveBeenCalledTimes(1); expect(pager.snapshot.page).toBe(0);
  });
});
