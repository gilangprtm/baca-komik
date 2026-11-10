/* eslint @next/next/no-img-element: "off" -- API image hosts vary; preserve direct loading without broad remote image config. */
import Link from 'next/link';
import { get, type Manga, type Chapter } from '@/lib/api';
import { ComicSections } from './sections';
import { BookmarkButton } from '@/components/catalog';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';

export default async function Comic({params}:{params:Promise<{id:string}>}) {
  const {id}=await params;
  try {
    const [m, chapters] = await Promise.all([
      get<Manga>(`/manga/detail/${encodeURIComponent(id)}`),
      get<Chapter[]>(`/chapter/${encodeURIComponent(id)}/list?page=1&page_size=24&sort_by=chapter_number&sort_order=desc`),
    ]);
    return <><Card><CardContent className="row"><img className="cover" src={m.cover_portrait_url||m.cover_image_url||''} alt=""/><div><h1>{m.title}</h1><p>{m.release_year||''} · {m.country_id||''} · ★ {m.user_rate||'—'}</p><BookmarkButton m={m}/>{m.latest_chapter_id&&<p><Button variant="outline" render={<Link href={`/reader/${m.latest_chapter_id}`}/>}>Mulai membaca terbaru</Button></p>}</div></CardContent></Card><ComicSections manga={m} initial={chapters} /><p><Link href="/">Kembali ke katalog</Link></p></>;
  } catch(e) { return <><Alert variant="destructive"><AlertDescription>{e instanceof Error?e.message:'Unable to load comic'}</AlertDescription></Alert><Button variant="outline" render={<Link href="/"/>}>Kembali</Button></>; }
}
