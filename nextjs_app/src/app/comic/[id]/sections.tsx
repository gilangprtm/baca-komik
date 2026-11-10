'use client';
import {useCallback,useEffect,useRef,useState} from 'react';
import Link from 'next/link';
import {ArrowDown,ArrowUp,ChevronDown,ChevronUp,Search,ThumbsUp} from 'lucide-react';
import type {Manga,Chapter,ApiEnvelope} from '@/lib/api';
import {commentToText} from '@/lib/comment-text';
import {InfiniteSentinel} from '@/components/infinite-loading';
import {Tabs,TabsList,TabsTrigger,TabsContent} from '@/components/ui/tabs';
import {Button} from '@/components/ui/button';
import {Input} from '@/components/ui/input';
import {Alert,AlertDescription} from '@/components/ui/alert';
import {Skeleton} from '@/components/ui/skeleton';

type Comment={objectId:number;nick:string;comment:string;time:number;avatar?:string;like?:number;children?:Comment[];reply_user?:{nick?:string};};
function replyCount(c:Comment):number{return (c.children||[]).reduce((sum,child)=>sum+1+replyCount(child),0);}
function CommentItem({comment,depth=0}:{comment:Comment;depth?:number}){
  const [open,setOpen]=useState(false);
  const children=comment.children||[];
  const count=replyCount(comment);
  const timestamp=comment.time>0?new Date(comment.time<1e12?comment.time*1000:comment.time).toLocaleDateString('id-ID'):null;
  return <article className={depth?'comic-comment comic-comment-reply':'comic-comment'}>
    <div className="comic-comment-head">
      {comment.avatar?<img className="comic-comment-avatar" src={comment.avatar} alt="" loading="lazy" referrerPolicy="no-referrer"/>:<span className="comic-comment-avatar comic-comment-avatar-fallback">{(comment.nick||'?').slice(0,1).toUpperCase()}</span>}
      <div className="comic-comment-author"><strong>{comment.nick||'Pengguna'}</strong>{timestamp&&<time>{timestamp}</time>}</div>
    </div>
    {comment.reply_user?.nick&&<span className="comic-reply-to">Membalas {comment.reply_user.nick}</span>}
    <p>{commentToText(comment.comment||'')}</p>
    <div className="comic-comment-actions">{typeof comment.like==='number'&&<span><ThumbsUp size={16}/>{comment.like}</span>}
      {count>0&&<button type="button" aria-expanded={open} onClick={()=>setOpen(v=>!v)}>{open?<ChevronUp size={17}/>:<ChevronDown size={17}/>} {open?'Sembunyikan balasan':`${count} balasan`}</button>}
    </div>
    {open&&children.length>0&&<div className="comic-replies">{children.map((child,i)=><CommentItem key={child.objectId||i} comment={child} depth={depth+1}/>)}</div>}
  </article>;
}
const BATCH=24;
export function ComicSections({manga,initial}:{manga:Manga;initial:Chapter[]}) {
  const [tab,setTab]=useState<'chapters'|'comments'>('chapters');
  const [expanded,setExpanded]=useState(false);
  const [query,setQuery]=useState('');
  const [ascending,setAscending]=useState(false);
  const [chapters,setChapters]=useState(initial);
  const [chapterPage,setChapterPage]=useState(1);
  const [chapterMore,setChapterMore]=useState(initial.length>=BATCH);
  const [chapterLoading,setChapterLoading]=useState(false);
  const [chapterError,setChapterError]=useState('');
  const chapterBusy=useRef(false);
  const [comments,setComments]=useState<Comment[]>([]);
  const [commentPage,setCommentPage]=useState(0);
  const [commentMore,setCommentMore]=useState(true);
  const [commentLoading,setCommentLoading]=useState(false);
  const [commentError,setCommentError]=useState('');
  const commentBusy=useRef(false);
  const loadChapters=useCallback(async()=>{
    if(chapterBusy.current||!chapterMore)return;
    chapterBusy.current=true;setChapterLoading(true);setChapterError('');
    try {
      const p=chapterPage+1;
      const r=await fetch(`/api/shinigami/chapter/${encodeURIComponent(manga.manga_id)}/list?page=${p}&page_size=${BATCH}&sort_by=chapter_number&sort_order=desc`);
      if(!r.ok)throw Error(`API error (${r.status})`);
      const x=await r.json() as ApiEnvelope<Chapter[]>;
      if(x.retcode!==0)throw Error(x.message||'Gagal memuat chapter');
      const incoming=Array.isArray(x.data)?x.data:[];
      setChapters(old=>{const ids=new Set(old.map(c=>c.chapter_id));return [...old,...incoming.filter(c=>!ids.has(c.chapter_id))]});
      setChapterPage(p);
      setChapterMore(incoming.length>0&&(x.meta?p<x.meta.total_page:incoming.length>=BATCH));
    }catch(e){setChapterError(e instanceof Error?e.message:'Gagal memuat chapter');}
    finally{chapterBusy.current=false;setChapterLoading(false);}
  },[chapterMore,chapterPage,manga.manga_id]);
  const loadComments=useCallback(async()=>{
    if(commentBusy.current||!commentMore)return;
    commentBusy.current=true;setCommentLoading(true);setCommentError('');
    try{
      const next=commentPage+1;
      const p=new URLSearchParams({path:`series/${manga.manga_id}`,pageSize:'10',page:String(next),lang:'en',sortBy:'insertedAt_desc'});
      const r=await fetch(`/api/comment/comment?${p}`);
      if(!r.ok)throw Error(`Comment error (${r.status})`);
      const x=await r.json();
      if(x.errno!==0)throw Error(x.errmsg||'Gagal memuat komentar');
      const incoming:Comment[]=Array.isArray(x.data?.data)?x.data.data:[];
      setComments(old=>{const ids=new Set(old.map(c=>c.objectId));return [...old,...incoming.filter(c=>!ids.has(c.objectId))]});
      setCommentPage(next);setCommentMore(incoming.length>=10);
    }catch(e){setCommentError(e instanceof Error?e.message:'Gagal memuat komentar');}
    finally{commentBusy.current=false;setCommentLoading(false);}
  },[commentMore,commentPage,manga.manga_id]);
  useEffect(()=>{if(tab==='comments'&&commentPage===0&&!commentLoading&&!commentError)void loadComments();},[tab,commentPage,commentLoading,commentError,loadComments]);
  const filtered=chapters.filter(c=>!query||String(c.chapter_number).includes(query)||c.chapter_title?.toLowerCase().includes(query.toLowerCase())).sort((a,b)=>ascending?a.chapter_number-b.chapter_number:b.chapter_number-a.chapter_number);
  const taxonomy=Object.entries(manga.taxonomy||{});
  return <>
    <div className="comic-meta">
      {manga.user_rate!=null&&<div className="comic-rating">★ {manga.user_rate}</div>}
      <p className={expanded?'comic-description expanded':'comic-description'}>{manga.description||'Tidak ada deskripsi.'}</p>
      {Boolean(manga.description)&&<button className="comic-read-more" onClick={()=>setExpanded(v=>!v)}>{expanded?'Read Less':'Read More'}</button>}
      {taxonomy.map(([key,values])=>values.length>0&&<div className="comic-taxonomy" key={key}><strong>{key}</strong><div>{values.map((v,i)=><span key={v.slug||`${v.name}-${i}`}>{v.name}</span>)}</div></div>)}
      {manga.release_year&&<div className="comic-taxonomy"><strong>Tahun</strong><div><span>{manga.release_year}</span></div></div>}
    </div>
    <Tabs value={tab} onValueChange={v=>{if(v==='chapters'||v==='comments')setTab(v)}} className="comic-tabs">
      <TabsList className="comic-tabs-list" aria-label="Chapter dan komentar">
        <TabsTrigger value="chapters">Chapter</TabsTrigger><TabsTrigger value="comments">Comment</TabsTrigger>
      </TabsList>
      <TabsContent value="chapters" className="comic-tab-content">
        <div className="comic-chapter-toolbar"><div className="comic-search"><Search size={18}/><Input aria-label="Cari chapter" placeholder="Cari chapter..." value={query} onChange={e=>setQuery(e.target.value)}/></div><Button variant="outline" size="icon" aria-label="Balik urutan chapter" onClick={()=>setAscending(v=>!v)}>{ascending?<ArrowUp/>:<ArrowDown/>}</Button></div>
        <div className="comic-chapter-list">{filtered.map((c,i)=><Link className="comic-chapter-item" key={c.chapter_id||i} href={`/reader/${c.chapter_id}`}><strong>Chapter {c.chapter_number}{c.chapter_title?` · ${c.chapter_title}`:''}</strong>{(c.release_date||c.created_at)&&<small>{new Date(c.release_date||c.created_at||'').toLocaleDateString('id-ID')}</small>}</Link>)}</div>
        {!filtered.length&&!chapterLoading&&<p className="muted">Chapter tidak ditemukan.</p>}
        {chapterLoading&&<div aria-label="Memuat chapter"><Skeleton className="my-3 h-16 w-full"/><Skeleton className="my-3 h-16 w-full"/></div>}
        {chapterError&&<Alert variant="destructive"><AlertDescription>{chapterError} <Button onClick={()=>void loadChapters()}>Coba lagi</Button></AlertDescription></Alert>}
        <InfiniteSentinel enabled={chapterMore&&!chapterLoading&&!chapterError} onVisible={()=>void loadChapters()}/>
      </TabsContent>
      <TabsContent value="comments" className="comic-tab-content">
        <div className="comic-comments">{comments.map((c,i)=><CommentItem key={c.objectId||i} comment={c}/>)}</div>
        {!comments.length&&!commentLoading&&!commentError&&<p className="muted">Belum ada komentar.</p>}
        {commentLoading&&<div aria-label="Memuat komentar"><Skeleton className="my-3 h-24 w-full"/><Skeleton className="my-3 h-24 w-full"/></div>}
        {commentError&&<Alert variant="destructive"><AlertDescription>{commentError} <Button onClick={()=>void loadComments()}>Coba lagi</Button></AlertDescription></Alert>}
        <InfiniteSentinel enabled={tab==='comments'&&commentMore&&!commentLoading&&!commentError} onVisible={()=>void loadComments()}/>
      </TabsContent>
    </Tabs>
  </>;
}