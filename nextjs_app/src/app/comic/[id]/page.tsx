/* eslint @next/next/no-img-element: "off" -- Covers come from variable upstream hosts. */
import Link from 'next/link';
import { ArrowLeft, House, Play } from 'lucide-react';
import { get, type Manga, type Chapter } from '@/lib/api';
import { ComicSections } from './sections';
import { BookmarkButton } from '@/components/catalog';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';

export default async function Comic({params}:{params:Promise<{id:string}>}) {
  const {id}=await params;
  try {
    const [m,chapters]=await Promise.all([
      get<Manga>(`/manga/detail/${encodeURIComponent(id)}`),
      get<Chapter[]>(`/chapter/${encodeURIComponent(id)}/list?page=1&page_size=24&sort_by=chapter_number&sort_order=desc`),
    ]);
    const cover=m.cover_portrait_url||m.cover_image_url||'';
    const firstChapter=chapters[chapters.length-1]?.chapter_id||m.latest_chapter_id;
    return <div className="comic-detail">
      <section className="comic-hero">
        {cover&&<div className="comic-hero-backdrop" style={{backgroundImage:`url("${cover.replace(/"/g,'%22')}")`}} aria-hidden="true"/>}
        <div className="comic-hero-nav"><Link href="/" aria-label="Kembali"><ArrowLeft/></Link><Link href="/" aria-label="Beranda"><House/></Link></div>
        {cover&&<img className="comic-hero-cover" src={cover} alt={`Cover ${m.title}`}/>}
        <h1>{m.title}</h1>
      </section>
      <div className="comic-detail-body">
        {firstChapter&&<Button className="comic-read-button" render={<Link href={`/reader/${firstChapter}`}/>}><Play fill="currentColor"/> Baca</Button>}
        <div className="comic-bookmark-action"><BookmarkButton m={m}/></div>
        <ComicSections manga={m} initial={chapters}/>
      </div>
    </div>;
  } catch(e) {
    return <><Alert variant="destructive"><AlertDescription>{e instanceof Error?e.message:'Gagal memuat komik'}</AlertDescription></Alert><Button variant="outline" render={<Link href="/"/>}>Kembali</Button></>;
  }
}