import type { Manga } from './api';

export function matchesCountry(manga: Manga, country: string): boolean {
  if (!country) return true;
  const normalize = (value?: string) => { const code = value?.trim().toUpperCase(); return code === 'JPN' ? 'JP' : code; };
  return Boolean(manga.country_id) && normalize(manga.country_id) === normalize(country);
}

export function filterByCountry(rows: Manga[], country: string): Manga[] {
  return country ? rows.filter(manga => matchesCountry(manga, country)) : rows;
}
