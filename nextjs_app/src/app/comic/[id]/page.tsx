/* eslint @next/next/no-img-element: "off" -- Covers come from variable upstream hosts. */
import Link from 'next/link';
import { Play } from 'lucide-react';
import { get, type Manga } from '@/lib/api';
import { ComicSections } from './sections';
import { BookmarkButton, CountryMark } from '@/components/catalog';
import { countryFlag } from '@/lib/comic-card';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import type { Metadata } from 'next';

export async function generateMetadata({params}:{params:Promise<{id:string}>}): Promise<Metadata> {
  try {
    const {id}=await params;
    const manga=await get<Manga>(`/manga/detail/${encodeURIComponent(id)}`);
    const description=manga.description?.replace(/\s+/g,' ').trim().slice(0,300)||`Detail ${manga.title} di BacaKomik. Jelajahi informasi komik dan chapter yang tersedia.`;
    return {title:manga.title,description,openGraph:{title:manga.title,description,type:'website'}};
  } catch {
    return {};
  }
}

export default async function Comic({params}:{params:Promise<{id:string}>}) {
  const {id}=await params;
  try {
    const m=await get<Manga>(`/manga/detail/${encodeURIComponent(id)}`);
    const cover=m.cover_portrait_url||m.cover_image_url||'';
    const flag=countryFlag(m.country_id);
    const firstChapter=m.latest_chapter_id;
    return <div className="comic-detail">
      <section className="comic-hero">
        {cover&&<div className="comic-hero-backdrop" style={{backgroundImage:`url("${cover.replace(/"/g,'%22')}")`}} aria-hidden="true"/>}

        {cover&&<div className="comic-hero-cover-wrap"><img className="comic-hero-cover" src={cover} alt={`Cover ${m.title}`}/>{m.user_rate!=null&&<span className="comic-cover-rating">★ {m.user_rate}</span>}<CountryMark code={flag?.[0]} label={flag?.[1]||"Negara tidak diketahui"}/></div>}
        <h1>{m.title}</h1>
      </section>
      <div className="comic-detail-body">
        {firstChapter&&<Button className="comic-read-button" render={<Link href={`/reader/${firstChapter}`}/>}><Play fill="currentColor"/> Baca</Button>}
        <div className="comic-bookmark-action"><BookmarkButton m={m} plain/></div>
        <ComicSections manga={m} initial={[]}/>
      </div>
    </div>;
  } catch(e) {
    return <><Alert variant="destructive"><AlertDescription>{e instanceof Error?e.message:'Gagal memuat komik'}</AlertDescription></Alert><Button variant="outline" render={<Link href="/"/>}>Kembali</Button></>;
  }
}