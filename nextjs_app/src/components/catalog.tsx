'use client';/* eslint @next/next/no-img-element: "off" -- API image hosts vary; preserve direct lazy loading without arbitrary host allowlists. */
import Link from 'next/link';
import { useEffect, useId, useRef, useState } from 'react';
import type { ChapterSummary, Manga } from '@/lib/api';
import { countryFlag, isRecentlyUpdated, relativeAge } from '@/lib/comic-card';
import { toggle, all } from '@/lib/store';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';

const chapterCache = new Map<string, Promise<ChapterSummary[]>>();
let active = 0;
const pending: (() => void)[] = [];

export function CountryMark({ code, label }: { code?: string; label: string }) {
  const clipId = useId();
  return <svg className={`country-mark${code ? ` country-mark-${code.toLowerCase()}` : ' country-mark-unknown'}`} viewBox="0 0 24 16" role="img" aria-label={label}>
    <title>{label}</title>
    <defs><clipPath id={clipId}><rect width="24" height="16" rx="2" /></clipPath></defs>
    <g clipPath={`url(#${clipId})`}>
      {code === 'JP' ? <><rect width="24" height="16" fill="#fff" /><circle cx="12" cy="8" r="4.5" fill="#bc002d" /></>
        : code === 'ID' ? <><rect width="24" height="8" fill="#e31b23" /><rect y="8" width="24" height="8" fill="#fff" /></>
        : code === 'CN' ? <><rect width="24" height="16" fill="#de2910" /><path d="M5 2.2l.8 2.1 2.2.1-1.7 1.4.6 2.1L5 6.7 3.2 8l.6-2.1L2 4.5l2.2-.1z" fill="#ffde00" /><circle cx="9.4" cy="2.9" r=".65" fill="#ffde00" /><circle cx="11.1" cy="4.8" r=".65" fill="#ffde00" /><circle cx="11" cy="7.1" r=".65" fill="#ffde00" /><circle cx="9.2" cy="9" r=".65" fill="#ffde00" /></>
        : code === 'KR' ? <><rect width="24" height="16" fill="#fff" /><path d="M12 3.5a4.5 4.5 0 0 1 0 9 2.25 2.25 0 0 0 0-4.5 2.25 2.25 0 0 1 0-4.5" fill="#cd2e3a" /><path d="M12 12.5a4.5 4.5 0 0 1 0-9 2.25 2.25 0 0 0 0 4.5 2.25 2.25 0 0 1 0 4.5" fill="#0047a0" /><path d="M3 3l4 2M3 5l4 2M17 9l4 2M17 11l4 2" stroke="#111" strokeWidth="1.2" /></>
        : <><circle cx="12" cy="8" r="6" fill="#d8e0e2" /><path d="M12 3v3M12 10v3M7 8h3M14 8h3" stroke="#45545a" strokeWidth="1.2" strokeLinecap="round" /></>}
    </g>
  </svg>;
}
function loadChapters(id: string) {
  const cached = chapterCache.get(id);
  if (cached) return cached;
  const request = new Promise<ChapterSummary[]>((resolve, reject) => {
    const run = () => {
      active++;
      fetch(`/api/shinigami/chapter/${encodeURIComponent(id)}/list?page=1&page_size=8&sort_by=chapter_number&sort_order=desc`)
        .then(async response => { if (!response.ok) throw Error('Chapter request failed'); const body = await response.json(); if (body.retcode !== 0) throw Error('Chapter request failed'); resolve(body.data || []); })
        .catch(reject).finally(() => { active--; pending.shift()?.(); });
    };
    if (active < 4) run(); else pending.push(run);
  });
  chapterCache.set(id, request);
  request.catch(() => chapterCache.delete(id));
  return request;
}

export function ComicCard({ m, showChapters = true, resumeChapterId }: { m: Manga; showChapters?: boolean; resumeChapterId?: string }) {
  const [chapters, setChapters] = useState<ChapterSummary[] | undefined>(() => m.chapters);
  const [requested, setRequested] = useState(Boolean(m.chapters));
  const [visible, setVisible] = useState(false);
  const article = useRef<HTMLElement>(null);
  useEffect(() => {
    if (!showChapters || chapters || !visible) return;
    let live = true;
    void loadChapters(m.manga_id).then(rows => { if (live) { setChapters(rows); setRequested(true); } }).catch(() => { if (live) setRequested(true); });
    return () => { live = false; };
  }, [chapters, m.manga_id, showChapters, visible]);
  useEffect(() => {
    const element = article.current;
    if (!element) return;
    if (!('IntersectionObserver' in window)) { setVisible(true); return; }
    const observer = new IntersectionObserver(entries => { if (entries.some(entry => entry.isIntersecting)) { setVisible(true); observer.disconnect(); } }, { rootMargin: '300px' });
    observer.observe(element);
    return () => observer.disconnect();
  }, []);
  const flag = countryFlag(m.country_id);
  const rows = showChapters && chapters?.length ? [...chapters].sort((a,b) => b.chapter_number-a.chapter_number).slice(0,2) : [];
  const latest: ChapterSummary[] = rows.length === 0 && m.latest_chapter_number != null ? [{ chapter_number: m.latest_chapter_number, chapter_id: m.latest_chapter_id, release_date: m.latest_chapter_time }] : [];
  const shown = rows.length ? rows : latest;
  return <Card className="comic-card"><article ref={article}>
    <Link className="comic-cover" href={`/comic/${m.manga_id}`} aria-label={`${m.title} — detail komik`}>
      <img loading="lazy" src={m.cover_portrait_url || m.cover_image_url || ''} alt="" />
      <CountryMark code={flag?.[0]} label={flag?.[1] || (m.country_id ? `Negara: ${m.country_id}` : 'Negara tidak diketahui')} />
    </Link>
    <div className="comic-info">
      <Link className="comic-title" href={`/comic/${m.manga_id}`}>{isRecentlyUpdated(m.latest_chapter_time) && <Badge variant="destructive" className="up-badge">UP</Badge>}<span className="comic-title-text">{m.title}</span></Link>
      {showChapters && (shown.length ? shown.map((chapter, i) => {
        const age = relativeAge(chapter.release_date || chapter.created_at || (!rows.length ? m.latest_chapter_time : undefined));
        const label = `Chapter ${chapter.chapter_number}`;
        const content = <><span>{label}</span><span className="chapter-age">{age || 'Waktu tidak tersedia'}</span></>;
        return chapter.chapter_id
          ? <Link className="chapter-row" key={chapter.chapter_id} href={`/reader/${chapter.chapter_id}`} aria-label={`Baca ${label} — ${m.title}`}>{content}</Link>
          : <div className="chapter-row muted" key={`${chapter.chapter_number}-${i}`}>{content}</div>;
      }) : requested ? <div className="chapter-row muted">Chapter tidak tersedia</div> : <div className="chapter-row muted" role="status" aria-label="Memuat chapter"><Skeleton className="h-4 w-28"/></div>)}
      {resumeChapterId && <Link className="library-resume-button" href={`/reader/${resumeChapterId}`}>Lanjutkan membaca</Link>}
    </div>
  </article></Card>;
}
export function Grid({ items, showChapters = true }: { items: Manga[]; showChapters?: boolean }) { return <div className="grid">{items.map(m => <ComicCard key={m.manga_id} m={m} showChapters={showChapters} />)}</div>; }
export function BookmarkButton({ m, plain = false }: { m: Manga; plain?: boolean }) { const [yes, set] = useState(false); useEffect(() => { all('bookmarks').then(a => set(a.some(x => x.manga_id === m.manga_id))).catch(() => {}); }, [m.manga_id]); return <Button variant={plain ? 'ghost' : yes ? 'secondary' : 'default'} aria-pressed={yes} onClick={async () => set(await toggle(m))}>{yes ? '★ Bookmarked' : '☆ Bookmark'}</Button>; }
