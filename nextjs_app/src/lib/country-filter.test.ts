import { describe, expect, it } from 'vitest';
import type { Manga } from './api';
import { filterByCountry } from './country-filter';

const rows: Manga[] = [
  { manga_id: 'kr', title: 'Korean comic', country_id: 'KR' },
  { manga_id: 'cn', title: 'Chinese comic', country_id: 'CN' },
  { manga_id: 'cn-lower', title: 'Lowercase country', country_id: 'cn' },
  { manga_id: 'unknown', title: 'Unknown country' },
];

describe('Explore country filtering', () => {
  it('excludes KR and unknown countries, retaining CN/cn without mutating input', () => {
    const original = structuredClone(rows);
    expect(filterByCountry(rows, 'CN')).toEqual([rows[1], rows[2]]);
    expect(rows).toEqual(original);
  });

  it('compares the selected country case-insensitively', () => {
    expect(filterByCountry(rows, 'cn')).toEqual([rows[1], rows[2]]);
  });

  it('leaves the input rows unchanged when no country is selected', () => {
    expect(filterByCountry(rows, '')).toBe(rows);
  });

  it('filters each page independently, including pages with no matches', () => {
    expect(filterByCountry([rows[0]], 'CN')).toEqual([]);
    expect(filterByCountry([rows[2], rows[0]], 'CN')).toEqual([rows[2]]);
  });
});
