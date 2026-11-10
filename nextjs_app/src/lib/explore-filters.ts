import type { Manga } from './api';
import { matchesCountry } from './country-filter';

export type ExploreFilters = { query: string; genre: string; format: string; country: string };
const normalize = (value: unknown) => typeof value === 'string' ? value.trim().toLowerCase().replace(/[_\s]+/g, '-') : '';

export function matchesExploreFilters(manga: Manga, filters: Pick<ExploreFilters, 'genre' | 'format' | 'country'>): boolean {
  if (filters.genre && !manga.taxonomy?.Genre?.some(tag => normalize(tag.slug) === normalize(filters.genre) || (!tag.slug && normalize(tag.name) === normalize(filters.genre)))) return false;
  if (filters.format && !manga.taxonomy?.Format?.some(tag => normalize(tag.slug) === normalize(filters.format) || (!tag.slug && normalize(tag.name) === normalize(filters.format)))) return false;
  if (!matchesCountry(manga, filters.country)) return false;
  return true;
}

export function exploreListUrl(filters: ExploreFilters, page: number) {
  const params = new URLSearchParams({ page: String(page), page_size: '24', sort: 'popularity' });
  if (filters.query.trim()) params.set('q', filters.query.trim());
  if (filters.genre) { params.set('genre_include', filters.genre); params.set('genre_include_mode', 'and'); }
  if (filters.format) params.set('format', filters.format);
  return `/api/shinigami/manga/list?${params}`;
}

export function filterExploreRows(rows: Manga[], filters: ExploreFilters) {
  return rows.filter(row => matchesExploreFilters(row, filters));
}
