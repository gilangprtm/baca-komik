'use client';
/* eslint @next/next/no-img-element: "off" -- page URLs use per-chapter base_url and may vary; direct lazy loading avoids an arbitrary URL proxy. */
import Link from 'next/link';
import {useEffect,useRef,useState} from 'react';
import {get,type Manga} from '@/lib/api';
import {getProgress,saveHistory} from '@/lib/store';
import { Button } from '@/components/ui/button';
import {ChevronLeft,ChevronRight,House,Play,Pause} from 'lucide-react';
import {ComicSections} from '@/app/comic/[id]/sections';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Card, CardContent } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Heart } from 'lucide-react';

type Detail={chapter_id:string;manga_id:string;chapter_number:number;chapter_title?:string;base_url:string;chapter:{path:string;data:string[]};prev_chapter_id?:string|null;next_chapter_id?:string|null};
type ChapterRow={chapter_id:string;chapter_number:number;chapter_title?:string};
export default function Reader({params}:{params:Promise<{id:string}>}) {
 const [autoPlay,setAutoPlay]=useState(false);
 const [donationOpen,setDonationOpen]=useState(false);
 const [id,setId]=useState('');const [chapter,setChapter]=useState<Detail|null>(null);const [error,setError]=useState('');const [page,setPage]=useState(0);const [manga,setManga]=useState<Manga|null>(null);const [chapters,setChapters]=useState<ChapterRow[]>([]);const [chapterPage,setChapterPage]=useState(0);const [chapterError,setChapterError]=useState('');const refs=useRef<(HTMLImageElement|null)[]>([]);const pageRef=useRef(0);
 useEffect(()=>{params.then(x=>setId(x.id));},[params]);
 useEffect(()=>{if(!autoPlay)return;let frame=0;let previous=0;const tick=(now:number)=>{if(previous)window.scrollBy(0,Math.min((now-previous)/1000,0.05)*65);previous=now;frame=requestAnimationFrame(tick);};frame=requestAnimationFrame(tick);return()=>cancelAnimationFrame(frame);},[autoPlay]);
 useEffect(()=>{setAutoPlay(false)},[id]);
 // Clock-aligned reminders (10:05, 10:10, etc.), at most once per 5-minute slot per tab.
 useEffect(()=>{
   if(!chapter)return;
   const check=()=>{
     if(document.visibilityState!=='visible')return;
     const now=new Date();
     if(now.getMinutes()%5!==0)return;
     const slot=`${now.getFullYear()}-${now.getMonth()}-${now.getDate()}-${now.getHours()}-${now.getMinutes()}`;
     const key='bacakomik-donation-last-slot';
     try{if(sessionStorage.getItem(key)===slot)return;sessionStorage.setItem(key,slot);}catch{return;}
     setAutoPlay(false);
     setDonationOpen(true);
   };
   const timer=window.setInterval(check,1000);
   return()=>window.clearInterval(timer);
 },[chapter]);

 useEffect(()=>{if(!id)return;let live=true;setChapter(null);setManga(null);setPage(0);pageRef.current=0;refs.current=[];setError('');setChapters([]);setChapterPage(0);get<Detail>(`/chapter/detail/${encodeURIComponent(id)}`).then(async x=>{const old=await getProgress(x.chapter_id).catch(()=>undefined);if(!live)return;const resumePage=x.chapter.data.length?Math.min(old?.current_page??0,x.chapter.data.length-1):0;setPage(resumePage);pageRef.current=resumePage;setChapter(x);if(resumePage>0)setTimeout(()=>refs.current[resumePage]?.scrollIntoView({behavior:'instant'}),100);void get<Manga>(`/manga/detail/${encodeURIComponent(x.manga_id)}`).then(value=>live&&setManga(value)).catch(()=>{});}).catch(e=>live&&setError(e.message));return()=>{live=false}},[id]);
 useEffect(()=>{if(!chapter)return;let live=true;get<ChapterRow[]>(`/chapter/${encodeURIComponent(chapter.manga_id)}/list?page=1&page_size=50&sort_by=chapter_number&sort_order=desc`).then(x=>{if(live){setChapters(x||[]);setChapterPage(1);}}).catch(e=>live&&setChapterError(e.message));return()=>{live=false}},[chapter]);
 useEffect(()=>{if(!chapter)return;const totalPages=chapter.chapter.data.length;const save=(currentPage:number)=>saveHistory({chapter_id:chapter.chapter_id,manga_id:chapter.manga_id,chapter_number:chapter.chapter_number,title:manga?.title,cover:manga?.cover_portrait_url||manga?.cover_image_url,current_page:currentPage,total_pages:totalPages}).catch(()=>{});void save(pageRef.current);let timer:ReturnType<typeof setTimeout>;let observer:IntersectionObserver;const observe=()=>{observer?.disconnect();const height=window.innerHeight;observer=new IntersectionObserver(entries=>{const visible=entries.filter(entry=>entry.isIntersecting).sort((a,b)=>a.boundingClientRect.top-b.boundingClientRect.top);if(!visible.length)return;const index=Number((visible[0].target as HTMLImageElement).dataset.page);setPage(index);pageRef.current=index;clearTimeout(timer);timer=setTimeout(()=>void save(index),150);},{rootMargin:`-${Math.floor(height*.2)}px 0px -${Math.floor(height*.65)}px 0px`});refs.current.forEach(img=>img&&observer.observe(img));};observe();window.addEventListener('resize',observe);return()=>{observer?.disconnect();window.removeEventListener('resize',observe);clearTimeout(timer)}},[chapter,manga]);
 async function moreChapters(){setChapterError('');try{const next=chapterPage+1;const x=await get<ChapterRow[]>(`/chapter/${encodeURIComponent(chapter!.manga_id)}/list?page=${next}&page_size=50&sort_by=chapter_number&sort_order=desc`);setChapters(v=>{const ids=new Set(v.map(c=>c.chapter_id));return [...v,...(x||[]).filter(c=>!ids.has(c.chapter_id))]});setChapterPage(next);}catch(e){setChapterError(e instanceof Error?e.message:'Unable to load chapters');}}
 useEffect(()=>{const f=(e:KeyboardEvent)=>{if(e.key==='ArrowLeft'&&chapter?.prev_chapter_id)location.href=`/reader/${chapter.prev_chapter_id}`;if(e.key==='ArrowRight'&&chapter?.next_chapter_id)location.href=`/reader/${chapter.next_chapter_id}`};addEventListener('keydown',f);return()=>removeEventListener('keydown',f)},[chapter]);
 if(error)return <Alert variant="destructive"><AlertDescription>{error} <Button onClick={()=>setId('')}>Kembali</Button></AlertDescription></Alert>;
 if(!chapter)return <div role="status" aria-label="Memuat chapter"><Skeleton className="h-8 w-48"/><Skeleton className="mx-auto mt-4 aspect-[2/3] w-full max-w-[760px]"/></div>;
 const total=chapter.chapter.data.length;
 if(total===0)return <><Alert><AlertDescription>Chapter ini belum memiliki halaman.</AlertDescription></Alert><Link href={`/comic/${chapter.manga_id}`}>Kembali ke detail komik</Link></>;
 return <div className="reader-screen">
 <Dialog open={donationOpen} onOpenChange={setDonationOpen}>
   <DialogContent className="reader-donation-dialog w-[calc(100%-2rem)] max-w-sm sm:max-w-sm grid-cols-1" aria-describedby="donation-description">
     <DialogHeader>
       <DialogTitle>Dukung BacaKomik</DialogTitle>
       <p id="donation-description" className="text-sm leading-relaxed text-muted-foreground">Jika kamu menikmati membaca komik di sini, dukung pengembangan BacaKomik melalui donasi. Terima kasih atas dukunganmu!</p>
     </DialogHeader>
     <div className="flex w-full flex-col gap-3 pt-2">
       <Button className="min-h-12 w-full bg-[#7136ed] text-white hover:bg-[#8251f4]" render={<a href="https://saweria.co/playbit" target="_blank" rel="noopener noreferrer" onClick={()=>setDonationOpen(false)}/>}><Heart className="size-5"/> Donasi melalui Saweria</Button>
       <Button variant="outline" className="min-h-11 w-full" onClick={()=>setDonationOpen(false)}>Lanjutkan membaca</Button>
     </div>
   </DialogContent>
 </Dialog>
 <div className="reader-topline"><Link href={`/comic/${chapter.manga_id}`}>{manga?.title||'Detail komik'}</Link><span>Chapter {chapter.chapter_number}</span><span className="reader-page-counter">{page+1}/{total}</span></div>
 <section className="reader">{chapter.chapter.data.map((file,index)=><img key={`${chapter.chapter.path}${file}`} ref={el=>{refs.current[index]=el}} data-page={index} loading={index<2?'eager':'lazy'} src={`${chapter.base_url}${chapter.chapter.path}${file}`} alt={`Halaman ${index+1}`}/>)}</section>
 <div className="reader-end"><p>Chapter {chapter.chapter_number} selesai</p>{chapter.next_chapter_id&&<Button render={<Link href={`/reader/${chapter.next_chapter_id}`}/>}>Chapter berikutnya <ChevronRight/></Button>}</div>
 {manga&&<ComicSections key={chapter.chapter_id} manga={manga} initial={[]} commentsOnly commentChapterId={chapter.chapter_id}/>}
 <nav className="reader-controls" aria-label="Navigasi pembaca">
 {chapter.prev_chapter_id&&<Link href={`/reader/${chapter.prev_chapter_id}`} aria-label="Chapter sebelumnya"><ChevronLeft/></Link>}
 <button type="button" aria-label={autoPlay?'Hentikan scroll otomatis':'Mulai scroll otomatis'} aria-pressed={autoPlay} onClick={()=>setAutoPlay(v=>!v)}>{autoPlay?<Pause fill="currentColor"/>:<Play fill="currentColor"/>}</button>
 <Link href="/" aria-label="Beranda"><House/></Link>
 {chapter.next_chapter_id&&<Link href={`/reader/${chapter.next_chapter_id}`} aria-label="Chapter berikutnya"><ChevronRight/></Link>}
 </nav>
 </div>;
}
