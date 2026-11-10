import { describe, expect, it } from 'vitest';
import { countryFlag, isRecentlyUpdated, relativeAge } from './comic-card';

const now = Date.parse('2025-02-02T12:00:00Z');
describe('comic card helpers', () => {
  it('marks only valid timestamps younger than 24 hours as UP', () => {
    expect(isRecentlyUpdated(new Date(now - 1).toISOString(), now)).toBe(true);
    expect(isRecentlyUpdated(new Date(now - 24 * 60 * 60 * 1000).toISOString(), now)).toBe(false);
    expect(isRecentlyUpdated(new Date(now + 1).toISOString(), now)).toBe(false);
    expect(isRecentlyUpdated('invalid', now)).toBe(false);
  });
  it('formats Indonesian relative ages without fabricating invalid or future ages', () => {
    expect(relativeAge(new Date(now - 39 * 60 * 1000).toISOString(), now)).toBe('39 mnt');
    expect(relativeAge(new Date(now - 7 * 24 * 60 * 60 * 1000).toISOString(), now)).toBe('7 hari');
    expect(relativeAge(new Date(now + 1).toISOString(), now)).toBeUndefined();
    expect(relativeAge('invalid', now)).toBeUndefined();
  });
  it('maps known country aliases and leaves unknown codes unmapped', () => {
    expect(countryFlag('KR')?.[0]).toBe('KR');
    expect(countryFlag('CN')?.[0]).toBe('CN');
    expect(countryFlag('JP')).toEqual(countryFlag('JPN'));
    expect(countryFlag('JP')?.[0]).toBe('JP');
    expect(countryFlag('ID')?.[0]).toBe('ID');
    expect(countryFlag('XX')).toBeUndefined();
    expect(countryFlag(undefined)).toBeUndefined();
  });
});
