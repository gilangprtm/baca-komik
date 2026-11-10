import { openDB } from 'idb';
import type { Manga } from './api';

export type HistoryEntry = {
  chapter_id: string;
  manga_id: string;
  chapter_number: number;
  title?: string;
  cover?: string;
  current_page: number;
  total_pages: number;
  updated_at: number;
};

const db = () => openDB('bacakomik-local', 1, {
  upgrade(database) {
    database.createObjectStore('bookmarks', { keyPath: 'manga_id' });
    database.createObjectStore('history', { keyPath: 'chapter_id' });
  },
});

export async function toggle(manga: Manga) {
  const database = await db();
  const tx = database.transaction('bookmarks', 'readwrite');
  const exists = await tx.store.get(manga.manga_id);
  if (exists) await tx.store.delete(manga.manga_id);
  else await tx.store.put(manga);
  await tx.done;
  return !exists;
}

export function all(store: 'bookmarks'): Promise<Manga[]>;
export function all(store: 'history'): Promise<HistoryEntry[]>;
export async function all(store: 'bookmarks' | 'history') {
  return (await db()).getAll(store);
}

export async function saveHistory(row: Omit<HistoryEntry, 'updated_at'>) {
  const database = await db();
  const previous = await database.get('history', row.chapter_id);
  const entry = { ...previous, ...row, updated_at: Date.now() };
  await database.put('history', entry);
  return entry;
}

export async function getProgress(chapterId: string) {
  return (await db()).get('history', chapterId) as Promise<HistoryEntry | undefined>;
}
