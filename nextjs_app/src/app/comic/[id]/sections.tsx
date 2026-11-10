'use client';
import {useState} from 'react';
import Link from 'next/link';
import type {Manga,Chapter,ApiEnvelope} from '@/lib/api';
import {commentToText} from '@/lib/comment-text';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Card, CardContent } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';

type Comment={objectId:number;nick:string;comment:string;time:number};
export function ComicSections({manga,initial}:{manga:Manga;initial:Chapter[]}) {
  const [tab,setTab]=useState<'chapters'|'info'|'comments'>('chapters');
  const [chapters,setChapters]=useState(initial); const [page,setPage]=useState(1); const [more,setMore]=useState(true); const [loading,setLoading]=useState(false); const [chapterError,setChapterError]=useState('');
  const [comments,setComments]=useState<Comment[]|null>(null); const [commentError,setCommentError]=useState(''); const [commentLoading,setCommentLoading]=useState(false);
  async function loadChapters(){if(loading||!more)return;setLoading(true);setChapterError('');try{const p=page+1;const x=await fetch(`/api/shinigami/chapter/${encodeURIComponent(manga.manga_id)}/list?page=${p}&page_size=24&sort_by=chapter_number&sort_order=desc`).then(r=>{if(!r.ok)throw Error(`API error (${r.status})`);return r.json()}) as ApiEnvelope<Chapter[]>;if(x.retcode!==0)throw Error(x.message||'Chapter request failed');const incoming=x.data||[];setChapters(v=>{const ids=new Set(v.map(c=>c.chapter_id));return [...v,...incoming.filter(c=>!ids.has(c.chapter_id))]});setPage(p);setMore(incoming.length>0&&(x.meta? p<x.meta.total_page:incoming.length>=24));}catch(e){setChapterError(e instanceof Error?e.message:'Unable to load chapters');}finally{setLoading(false)}}
  async function loadComments(){setCommentLoading(true);setCommentError('');try{const p=new URLSearchParams({path:`series/${manga.manga_id}`,pageSize:'10',page:'1',lang:'en',sortBy:'insertedAt_desc'});const x=await fetch(`/api/comment/comment?${p}`).then(r=>{if(!r.ok)throw Error(`Commento error (${r.status})`);return r.json()});if(x.errno!==0)throw Error(x.errmsg||'Comment request failed');setComments(x.data?.data||[]);}catch(e){setCommentError(e instanceof Error?e.message:'Unable to load comments');}finally{setCommentLoading(false)}}
  function select(value:'chapters'|'info'|'comments'){setTab(value);if(value==='comments'&&comments===null&&!commentLoading)void loadComments();}
  return <Tabs value={tab} onValueChange={(v:string)=>{if(v==='chapters'||v==='info'||v==='comments')select(v)}}><TabsList aria-label="Comic sections"><TabsTrigger value="chapters">Chapters</TabsTrigger><TabsTrigger value="info">Info</TabsTrigger><TabsTrigger value="comments">Comments</TabsTrigger></TabsList>
  <TabsContent value={tab} aria-label={tab==='chapters'?'Chapters':tab==='info'?'Info':'Comments'}>
  {tab==='info'?<Card><CardContent><h2>Info</h2><p>{manga.description||'Tidak ada deskripsi.'}</p><p>{Object.entries(manga.taxonomy||{}).flatMap(([k,v])=>v.map(x=>`${k}: ${x.name}`)).join(' · ')}</p></CardContent></Card>:tab==='chapters'?<Card><CardContent><h2>Chapters</h2>{chapters.length?chapters.map((c,i)=><p key={`${c.chapter_id}-${i}`}><Link href={`/reader/${c.chapter_id}`}>Chapter {c.chapter_number}{c.chapter_title?` · ${c.chapter_title}`:''}</Link></p>):<p>Chapter tidak tersedia.</p>}{chapterError&&<Alert variant="destructive"><AlertDescription>{chapterError}</AlertDescription></Alert>}{loading&&<div role="status" aria-label="Memuat chapter"><Skeleton className="my-2 h-5 w-2/3"/><Skeleton className="my-2 h-5 w-1/2"/></div>}{more&&<Button disabled={loading} onClick={()=>void loadChapters()}>{loading?'Memuat…':'Muat chapter lainnya'}</Button>}</CardContent></Card>:<><h2>Comments</h2>{commentLoading?<div role="status" aria-label="Memuat komentar"><Skeleton className="my-2 h-20 w-full"/><Skeleton className="my-2 h-20 w-full"/></div>:commentError?<><Alert variant="destructive"><AlertDescription>{commentError}</AlertDescription></Alert><Button onClick={()=>void loadComments()}>Coba lagi</Button></>:comments?.length?comments.map(c=><Card key={c.objectId}><CardContent><strong>{c.nick}</strong><p style={{whiteSpace:'pre-wrap'}}>{commentToText(c.comment)}</p></CardContent></Card>):<Card><CardContent><p>{comments?'Belum ada komentar.':'Belum dimuat.'}</p></CardContent></Card>}</>}
  </TabsContent></Tabs>;
}
